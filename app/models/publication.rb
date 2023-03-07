# frozen_string_literal: true

class Publication < ApplicationRecord
  OPEN_ACCESS_POLICY_START = Date.new(2020, 7, 1)

  class NonDuplicateMerge < ArgumentError; end

  include Swagger::Blocks

  PUBLISHED_STATUS = 'Published'
  IN_PRESS_STATUS = 'In Press'

  def self.publication_types
    [
      'Academic Journal Article', 'In-house Journal Article', 'Professional Journal Article',
      'Trade Journal Article', 'Journal Article', 'Review Article', 'Abstract', 'Blog', 'Book', 'Chapter',
      'Book/Film/Article Review', 'Conference Proceeding', 'Encyclopedia/Dictionary Entry',
      'Extension Publication', 'Magazine/Trade Publication', 'Manuscript', 'Newsletter',
      'Newspaper Article', 'Comment/Debate', 'Commissioned Report', 'Digital or Visual Product',
      'Editorial', 'Foreword/Postscript', 'Letter', 'Paper', 'Patent', 'Poster',
      'Scholarly Edition', 'Short Survey', 'Working Paper', 'Other'
    ]
  end

  def self.oa_publication_types
    [
      'Academic Journal Article',
      'Conference Proceeding',
      'Journal Article',
      'In-house Journal Article',
      'Professional Journal Article'
    ]
  end

  def self.journal_types
    [
      'Academic Journal Article',
      'In-house Journal Article',
      'Professional Journal Article',
      'Trade Journal Article',
      'Journal Article'
    ]
  end

  def self.merge_allowed
    [
      'Academic Journal Article', 'In-house Journal Article', 'Professional Journal Article', 'Trade Journal Article',
      'Journal Article', 'Review Article', 'Chapter', 'Conference Proceeding', 'Encyclopedia/Dictionary Entry',
      'Magazine/Trade Publication', 'Comment/Debate', 'Editorial', 'Letter', 'Paper'
    ]
  end

  def self.postprint_statuses
    [
      'Already Openly Available',
      'Cannot Deposit',
      'Deposited to ScholarSphere',
      'File provided was not a post-print',
      'In Progress'
    ]
  end

  def self.open_access_statuses
    ['gold', 'hybrid', 'bronze', 'green', 'closed']
  end

  def self.oa_workflow_states
    ['automatic DOI verification pending', 'oa metadata search pending']
  end

  def self.preferred_versions
    [I18n.t('file_versions.accepted_version'), I18n.t('file_versions.published_version')].freeze
  end

  has_many :authorships, inverse_of: :publication
  has_many :users, through: :authorships
  has_many :user_organization_memberships, through: :users
  has_many :taggings, -> { order rank: :desc }, class_name: :PublicationTagging, inverse_of: :publication
  has_many :tags, through: :taggings
  has_many :contributor_names,
           -> { order position: :asc },
           dependent: :destroy,
           inverse_of: :publication
  has_many :imports, class_name: :PublicationImport, dependent: :destroy
  has_many :organizations, through: :users
  has_many :research_funds
  has_many :grants, through: :research_funds
  has_many :waivers, through: :authorships
  has_many :non_duplicate_group_memberships,
           class_name: :NonDuplicatePublicationGroupMembership,
           inverse_of: :publication
  has_many :non_duplicate_groups,
           class_name: :NonDuplicatePublicationGroup,
           through: :non_duplicate_group_memberships
  has_many :non_duplicates,
           through: :non_duplicate_groups,
           class_name: :Publication,
           source: :publications
  has_many :open_access_locations,
           inverse_of: :publication
  has_many :activity_insight_oa_files,
           inverse_of: :publication

  belongs_to :duplicate_group,
             class_name: :DuplicatePublicationGroup,
             foreign_key: :duplicate_publication_group_id,
             optional: true,
             inverse_of: :publications
  belongs_to :journal, optional: true, inverse_of: :publications

  has_one :publisher, through: :journal

  validates :publication_type, :title, :status, presence: true
  validates :publication_type, inclusion: { in: publication_types }
  validates :status, inclusion: { in: [PUBLISHED_STATUS, IN_PRESS_STATUS] }
  validates :open_access_status, inclusion: { in: open_access_statuses, allow_nil: true }
  validates :activity_insight_postprint_status, inclusion: { in: postprint_statuses, allow_nil: true }
  validates :oa_workflow_state, inclusion: { in: oa_workflow_states, allow_nil: true }
  validates :preferred_version, inclusion: { in: preferred_versions, allow_nil: true }

  validate :doi_format_is_valid

  scope :visible, -> { where visible: true }

  scope :published_during_membership,
        -> {
          visible
            .joins(:user_organization_memberships)
            .where('published_on >= user_organization_memberships.started_on AND (published_on <= user_organization_memberships.ended_on OR user_organization_memberships.ended_on IS NULL)')
            .distinct(:id)
        }

  scope :subject_to_open_access_policy, -> { oa_publication.published.where('published_on >= ?', Publication::OPEN_ACCESS_POLICY_START) }
  scope :claimable_by, ->(user) { oa_publication.visible.where.not(id: user.authorships.unclaimable.map(&:publication_id)) }

  scope :open_access, -> { distinct(:id).left_outer_joins(:open_access_locations).where.not(open_access_locations: { publication_id: nil }) }
  scope :scholarsphere_open_access, -> { open_access.where(open_access_locations: { source: Source::SCHOLARSPHERE }) }
  scope :user_open_access, -> { open_access.where(open_access_locations: { source: Source::USER }) }
  scope :oab_open_access, -> { open_access.where(open_access_locations: { source: Source::OPEN_ACCESS_BUTTON }) }
  scope :unpaywall_open_access, -> { open_access.where(open_access_locations: { source: Source::UNPAYWALL }) }

  scope :oa_publication, -> { where(publication_type: oa_publication_types) }
  scope :non_oa_publication, -> { where.not(publication_type: oa_publication_types) }

  scope :with_no_oa_locations, -> { distinct(:id).left_outer_joins(:open_access_locations).where(open_access_locations: { publication_id: nil }) }
  scope :activity_insight_oa_publication, -> { oa_publication.with_no_oa_locations.joins(:activity_insight_oa_files).where.not(activity_insight_oa_files: { location: nil }) }
  scope :doi_failed_verification, -> { activity_insight_oa_publication.where('doi_verified = false') }
  scope :needs_doi_verification, -> { activity_insight_oa_publication.where(doi_verified: nil).where(%{oa_workflow_state IS DISTINCT FROM 'automatic DOI verification pending'}) }
  scope :needs_permissions_check, -> { activity_insight_oa_publication.where(licence: nil, doi_verified: true, permissions_last_checked_at: nil) }
  scope :needs_oa_metadata_search,
        -> {
          activity_insight_oa_publication
            .where(doi_verified: true)
            .where(%{oa_workflow_state IS DISTINCT FROM 'oa metadata search pending'})
            .where(%{oa_status_last_checked_at IS NULL OR oa_status_last_checked_at < ?}, 1.hour.ago)
        }
  scope :published, -> { where(publications: { status: PUBLISHED_STATUS }) }

  accepts_nested_attributes_for :authorships, allow_destroy: true
  accepts_nested_attributes_for :contributor_names, allow_destroy: true
  accepts_nested_attributes_for :taggings, allow_destroy: true
  accepts_nested_attributes_for :open_access_locations, allow_destroy: true

  def self.find_by_wos_pub(pub)
    by_doi = pub.doi ? where(doi: pub.doi) : Publication.none
    if by_doi.any?
      by_doi
    else
      # TODO:  We can make this query more accurate using postgres trigram matching
      # on the title and sub-title in the same way that we do when we're finding
      # duplicate publications.
      where('title ILIKE ? AND EXTRACT(YEAR FROM published_on) = ?',
            "%#{pub.title}%",
            pub.publication_date.try(:year))
    end
  end

  def status=(new_status)
    write_attribute(:status, StatusMapper.map(new_status.to_s))
  end

  def confirmed_authorships
    authorships.confirmed
  end

  def confirmed_users
    users.where(authorships: { confirmed: true })
  end

  def doi_url_path
    d = doi
    d.try(:gsub, 'https://doi.org/', '')
  end

  swagger_schema :PublicationV1 do
    key :type, :object
    key :required, [:id, :type, :attributes]
    property :id do
      key :type, :string
      key :example, '123'
      key :description, 'The ID of the object'
    end
    property :type do
      key :type, :string
      key :example, 'publication'
      key :description, 'The type of the object'
    end
    property :attributes do
      key :type, :object
      key :required, [:title, :publication_type, :contributors, :tags, :pure_ids, :activity_insight_ids]
      property :title do
        key :type, :string
        key :example, 'A Scholarly Research Article'
        key :description, 'The title of the publication'
      end
      property :secondary_title do
        key :type, [:string, :null]
        key :example, 'A Comparative Analysis'
        key :description, 'The sub-title of the publication'
      end
      property :journal_title do
        key :type, [:string, :null]
        key :example, 'An Academic Journal'
        key :description, 'The title of the journal in which the publication was published'
      end
      property :publication_type do
        key :type, :string
        key :example, 'Academic Journal Article'
        key :description, 'The type of the publication'
      end
      property :publisher do
        key :type, [:string, :null]
        key :example, 'A Publishing Company'
        key :description, 'The publisher of the publication'
      end
      property :status do
        key :type, [:string, :null]
        key :example, 'Published'
        key :description, 'The status of the publication'
      end
      property :volume do
        key :type, [:string, :null]
        key :example, '30'
        key :description, 'The volume of the journal in which the publication was published'
      end
      property :issue do
        key :type, [:string, :null]
        key :example, '12'
        key :description, 'The issue of the journal in which the publication was published'
      end
      property :edition do
        key :type, [:string, :null]
        key :example, '6'
        key :description, 'the edition of the journal in which the publication was published'
      end
      property :page_range do
        key :type, [:string, :null]
        key :example, '110-123'
        key :description, 'The range of page numbers on which the publication content appears in the journal'
      end
      property :authors_et_al do
        key :type, [:boolean, :null]
        key :example, true
        key :description, 'Whether or not the publication has additional, unlisted authors'
      end
      property :abstract do
        key :type, [:string, :null]
        key :example, 'A summary of the research'
        key :description, 'A brief summary of the content of the publication'
      end
      property :doi do
        key :type, [:string, :null]
        key :example, 'https://doi.org/example'
        key :description, 'The Digital Object Identifier URL for the publication'
      end
      property :preferred_open_access_url do
        key :type, [:string, :null]
        key :example, 'https://example.org/articles/article-123.pdf'
        key :description, 'A URL for an open access copy of the publication'
      end
      property :published_on do
        key :type, [:string, :null]
        key :example, '2010-12-05'
        key :description, 'The date on which the publication was published'
      end
      property :citation_count do
        key :type, [:integer, :null]
        key :example, 50
        key :description, 'The number of times that the publication has been cited in other works'
      end
      property :contributors do
        key :type, :array
        items do
          key :type, :object
          property :first_name do
            key :type, [:string, :null]
            key :example, 'Anne'
            key :description, 'The first name of a person who contributed to the publication'
          end
          property :middle_name do
            key :type, [:string, :null]
            key :example, 'Example'
            key :description, 'The middle name of a person who contributed to the publication'
          end
          property :last_name do
            key :type, [:string, :null]
            key :example, 'Contributor'
            key :description, 'The last name of a person who contributed to the publication'
          end
          property :psu_user_id do
            key :type, [:string, :null]
            key :example, 'abc1234'
            key :description, 'The Penn State user ID of a person who contributed to the publication if they have one'
          end
        end
      end
      property :tags do
        key :type, :array
        items do
          key :type, :object
          key :required, [:name]
          property :name do
            key :type, :string
            key :example, 'A Topic'
            key :description, 'The name of a tag'
          end
          property :rank do
            key :type, [:number, :null]
            key :example, 1.25
            key :description, 'The ranking of the tag'
          end
        end
      end
      property :pure_ids do
        key :type, :array
        key :description, 'Unique identifiers for corresponding records in the Pure database that represent the publication'
        items do
          key :type, :string
          key :example, 'abc-def-123-456'
        end
      end
      property :activity_insight_ids do
        key :type, :array
        key :description, 'Unique identifiers for corresponding records in the Activity Insight database that represent the publication'
        items do
          key :type, :string
          key :example, '1234567890'
        end
      end
      property :profile_preferences do
        key :type, :array
        key :description, 'An array of settings for each user who is an author of the publication indicating how they prefer to have the publication displayed in a profile'
        items do
          key :type, :object
          key :required, [:user_id, :webaccess_id, :visible_in_profile, :position_in_profile]
          property :user_id do
            key :type, :number
            key :example, 123
            key :description, 'The ID of the user to which this set of preferences belongs'
          end
          property :webaccess_id do
            key :type, :string
            key :example, 'abc123'
            key :description, 'The WebAccess ID of the user to which this set of preferences belongs'
          end
          property :visible_in_profile do
            key :type, :boolean
            key :example, true
            key :description, "The user's preference for whether or not this publication should be displayed in their profile"
          end
          property :position_in_profile do
            key :type, [:number, :null]
            key :example, 8
            key :description, "The user's preference for what position this publication should occupy in a list of their publications in their profile"
          end
        end
      end
    end
  end

  rails_admin do
    list do
      scopes [
        nil,
        :open_access,
        :scholarsphere_open_access,
        :user_open_access,
        :oab_open_access,
        :unpaywall_open_access
      ]

      field(:id)
      field(:title)
      field(:secondary_title)
      field(:organizations)
      field(:journal_title)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:url) { label 'URL' }
      field(:issn) { label 'ISSN' }
      field(:doi) do
        label 'DOI'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:doi_verified)
      field(:published_on)
      field(:total_scopus_citations) { label 'Citations' }
      field(:visible) { label 'Visible via API' }
      field(:publisher_name)
      field(:publication_type)
      field(:status)
      field(:activity_insight_postprint_status)
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
      field(:open_access_button_last_checked_at)
      field(:unpaywall_last_checked_at)
    end

    create do
      field(:title)
      field(:secondary_title)
      field(:publication_type, :enum) do
        enum do
          Publication.publication_types.map { |t| [t, t] }
        end
      end
      field(:journal_title)
      field(:status)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:doi) { label 'DOI' }
      field(:open_access_locations)
      field(:issn) { label 'ISSN' }
      field(:abstract)
      field(:authors_et_al) { label 'Et al authors?' }
      field(:published_on)
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
      field(:duplicate_group)
      field(:users) { read_only true }
      field(:authorships)
      field(:contributor_names)
      field(:visible) { label 'Visible via API?' }
    end

    show do
      field(:title)
      field(:secondary_title)
      field(:publication_type)
      field(:journal_title)
      field(:journal)
      field(:publisher_name)
      field(:status)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:url) { label 'URL' }
      field(:issn) { label 'ISSN' }
      field(:doi) do
        label 'DOI'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:doi_verified)
      field(:activity_insight_postprint_status)
      field(:open_access_status)
      field(:open_access_button_last_checked_at)
      field(:unpaywall_last_checked_at)
      field(:open_access_locations) do
        pretty_value do
          bindings[:view].render(
            partial: 'rails_admin/partials/publications/open_access_locations.html.erb',
            locals: { open_access_locations: PreferredOpenAccessPolicy.new(value).rank_all }
          )
        end
      end
      field(:abstract)
      field(:authors_et_al) { label 'Et al authors?' }
      field(:published_on)
      field(:total_scopus_citations) { label 'Number of Scopus citations' }
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
      field(:duplicate_group)
      field(:users) { read_only true }
      field(:authorships)
      field(:contributor_names)
      field(:grants)
      field(:imports)
      field(:organizations)
      field(:visible) { label 'Visible via API?' }
    end

    edit do
      field(:title)
      field(:secondary_title)
      field(:publication_type, :enum) do
        enum do
          Publication.publication_types.map { |t| [t, t] }
        end
      end
      field(:journal_title)
      field(:status)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:doi) { label 'DOI' }
      field(:doi_verified, :enum) do
        label 'DOI verified?'
        enum do
          [['True', true], ['False', false]]
        end
      end
      field(:open_access_locations)
      field(:issn) { label 'ISSN' }
      field(:abstract)
      field(:authors_et_al) { label 'Et al authors?' }
      field(:published_on)
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
      field(:duplicate_group)
      field(:users) { read_only true }
      field(:authorships)
      field(:contributor_names)
      field(:visible) { label 'Visible via API?' }
    end
  end

  def ai_import_identifiers
    imports.where(source: 'Activity Insight').map(&:source_identifier)
  end

  def pure_import_identifiers
    imports.where(source: 'Pure').map(&:source_identifier)
  end

  def mark_as_updated_by_user
    self.updated_by_user_at = Time.current
  end

  def year
    published_on.try(:year)
  end

  def published_by
    preferred_journal_title || preferred_publisher_name
  end

  def preferred_open_access_url
    policy = PreferredOpenAccessPolicy.new(open_access_locations)
    policy.url
  end

  # TODO more of these and we should metaprogram them from `OpenAccessLocation.sources`
  def scholarsphere_open_access_url
    scholarsphere_locations = open_access_locations.filter(&:source_scholarsphere?)
    policy = PreferredOpenAccessPolicy.new(scholarsphere_locations)

    policy.url
  end

  def user_submitted_open_access_url
    user_locations = open_access_locations.filter(&:source_user?)
    policy = PreferredOpenAccessPolicy.new(user_locations)

    policy.url
  end

  def scholarsphere_upload_pending?
    authorships.where(%{id IN (SELECT authorship_id FROM scholarsphere_work_deposits WHERE status = 'Pending')}).any?
  end

  def scholarsphere_upload_failed?
    authorships.where(%{id IN (SELECT authorship_id FROM scholarsphere_work_deposits WHERE status = 'Failed')}).any?
  end

  def open_access_waived?
    waivers.any?
  end

  def no_open_access_information?
    !has_open_access_information?
  end

  def has_open_access_information?
    preferred_open_access_url.present? || scholarsphere_upload_pending? || open_access_waived?
  end

  def orcid_allowed?
    doi.present? || url.present? || preferred_open_access_url.present?
  end

  def is_oa_publication?
    Publication.oa_publication_types.include? publication_type
  end

  def is_journal_publication?
    Publication.journal_types.include? publication_type
  end

  def is_merge_allowed?
    Publication.merge_allowed.include? publication_type
  end

  def publication_type_other?
    publication_type == 'Other'
  end

  def all_non_duplicate_ids
    (non_duplicate_ids.uniq - [id]).sort
  end

  def merge!(publications_to_merge)
    merge(publications_to_merge)
  end

  def merge_on_matching!(publication_to_merge)
    merge([self, publication_to_merge]) { PublicationMergeOnMatchingPolicy.new(self, publication_to_merge).merge! }
  end

  def has_single_import_from_pure?
    imports.count == 1 && imports.where(source: 'Pure').any?
  end

  def has_single_import_from_ai?
    imports.count == 1 && imports.where(source: 'Activity Insight').any?
  end

  def preferred_journal_title
    preferred_journal_info_policy.journal_title
  end

  def preferred_publisher_name
    preferred_journal_info_policy.publisher_name
  end

  def published?
    status == PUBLISHED_STATUS
  end

  def matchable_title
    MatchableFormatter.new(title).format
  end

  def matchable_secondary_title
    secondary_title.present? ? MatchableFormatter.new(secondary_title).format : ''
  end

  def can_receive_new_ai_oa_files?
    no_open_access_information? && is_oa_publication? && no_valid_file_version?
  end

  def self.filter_by_activity_insight_id(query, activity_insight_id)
    query.joins(:imports)
      .where(publication_imports: {
               source: 'Activity Insight',
               source_identifier: activity_insight_id
             }).uniq
  end

  def self.filter_by_doi(query, doi)
    # allow DOI param to be provided in any of the following formats:
    # 1. https://doi.org/10.123/example
    # 2. doi:10.123/example
    # 3. 10.123/example
    url_prefix = 'https://doi.org/'

    unless doi.start_with?(url_prefix)
      doi.delete_prefix!('doi:')
      doi = url_prefix + doi
    end

    query.where(doi: doi).uniq
  end

  def update_from_unpaywall(unpaywall_response)
    if unpaywall_response.matchable_title == matchable_title && doi.blank? && unpaywall_response.doi.present?
      self.doi = unpaywall_response.doi
      self.doi_verified = true
      title_match = true
    end

    unpaywall_locations = doi.present? || title_match ? unpaywall_response.oa_locations : []
    unpaywall_locations_by_url = doi.present? || title_match ? unpaywall_response.oal_urls : {}
    existing_locations = open_access_locations.filter { |l| l.source == Source::UNPAYWALL }

    ActiveRecord::Base.transaction do
      locations_to_delete = existing_locations.reject { |l| unpaywall_locations_by_url.key? l.url }
      locations_to_delete.each(&:destroy)

      self.open_access_status = unpaywall_response.oa_status if doi.present? || title_match

      self.unpaywall_last_checked_at = Time.zone.now

      save!

      OpenAccessLocation.create_or_update_from_unpaywall(unpaywall_locations, self)
    end
  end

  private

    def merge(publications_to_merge)
      pubs_to_delete = publications_to_merge - [self]
      all_pubs = (publications_to_merge.to_a + [self]).uniq

      all_pubs.each do |p|
        other_pubs = all_pubs - [p]

        p.non_duplicate_groups.each do |ndg|
          if other_pubs.map(&:non_duplicate_groups).flatten.include?(ndg)
            raise NonDuplicateMerge
          end
        end
      end

      ActiveRecord::Base.transaction do
        imports_to_reassign = pubs_to_delete.map(&:imports).flatten

        imports_to_reassign.each do |i|
          i.update!(publication: self)
        end

        all_authorships = all_pubs.map(&:authorships).flatten
        authorships_by_user = all_authorships.group_by(&:user)

        authorships_to_keep = []

        authorships_by_user.each do |user, auths|
          existing_authorship = authorships.find_by(user: user)
          if existing_authorship
            authorships_to_keep << existing_authorship
          else
            authorship_to_keep = auths.first
            authorship_to_keep.update!(publication: self)
            authorships_to_keep << authorship_to_keep
          end
        end

        authorships_to_keep.each do |atk|
          amp = AuthorshipMergePolicy.new(authorships_by_user[atk.user])

          atk.update!(orcid_resource_identifier: amp.orcid_resource_id_to_keep,
                      role: amp.role_to_keep,
                      confirmed: amp.confirmed_value_to_keep,
                      open_access_notification_sent_at: amp.oa_timestamp_to_keep,
                      updated_by_owner_at: amp.owner_update_timestamp_to_keep,
                      waiver: amp.waiver_to_keep,
                      visible_in_profile: amp.visibility_value_to_keep,
                      position_in_profile: amp.position_value_to_keep,
                      scholarsphere_work_deposits: amp.scholarsphere_deposits_to_keep)
          amp.waivers_to_destroy.each(&:destroy)
        end

        oalmp = OpenAccessLocationMergePolicy.new(all_pubs)
        self.open_access_locations = oalmp.open_access_locations_to_keep

        self.activity_insight_oa_files = all_pubs.map(&:activity_insight_oa_files).flatten

        yield if block_given?

        DOIVerificationMergePolicy.new(self, all_pubs).merge!

        pubs_to_delete.each do |p|
          p.non_duplicate_groups.each do |ndg|
            ndg.publications << self
          end

          p.reload.destroy
        end

        update!(updated_by_user_at: Time.current, visible: true)
      end
    # TODO: This is just a temporary solution to prevent errors from stopping the auto
    # deduplication processes.  The returned error is rescued in the code for running
    # those processes. The error will still be raised when manually deduping.
    # Ideally, these errors should be logged somewhere like the ImporterErrorLog.
    rescue StandardError => e
      (raise e)
    end

    def preferred_journal_info_policy
      PreferredJournalInfoPolicy.new(self)
    end

    def doi_format_is_valid
      if !doi.nil? && !doi.empty?
        unless doi == DOISanitizer.new(doi).url
          errors.add(:doi, I18n.t('models.publication.validation_errors.doi_format'))
        end
      end
    end

    def no_valid_file_version?
      !(preferred_version.present? && activity_insight_oa_files.map(&:version).include?(preferred_version))
    end
end
