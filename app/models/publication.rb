# frozen_string_literal: true

class Publication < ApplicationRecord
  OPEN_ACCESS_POLICY_START = Date.new(2020, 7, 1)

  class NonDuplicateMerge < ArgumentError; end

  PUBLISHED_STATUS = 'Published'
  IN_PRESS_STATUS = 'In Press'

  PUBLISHED_OR_ACCEPTED_VERSION = 'Published or Accepted'
  NO_VERSION = 'None'

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
    ['gold', 'hybrid', 'bronze', 'green', 'closed', 'unknown']
  end

  def self.oa_workflow_states
    ['automatic DOI verification pending', 'oa metadata search pending']
  end

  def self.preferred_versions
    preferred_version_options.pluck(1)
  end

  def self.preferred_version_options
    [
      [I18n.t('file_versions.accepted_version_display'), I18n.t('file_versions.accepted_version')],
      [I18n.t('file_versions.published_version_display'), I18n.t('file_versions.published_version')],
      [I18n.t('file_versions.published_or_accepted_version_display'), PUBLISHED_OR_ACCEPTED_VERSION],
      [I18n.t('file_versions.no_version_display'), NO_VERSION]
    ].freeze
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
  has_many :preferred_ai_oa_files,
           -> {
             joins(:publication)
               .where(
                 <<-SQL.squish
                   preferred_version = activity_insight_oa_files.version
                   OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'acceptedVersion')
                   OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'publishedVersion')
                 SQL
               )
           },
           class_name: :ActivityInsightOAFile,
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

  scope :with_no_scholarsphere_oa_locations, -> {
                                               distinct(:id).left_outer_joins(:open_access_locations)
                                                 .where(%{NOT EXISTS (SELECT * FROM open_access_locations WHERE open_access_locations.publication_id = publications.id AND open_access_locations.source = '#{Source::SCHOLARSPHERE}')})
                                             }
  scope :activity_insight_oa_publication, -> {
                                            oa_publication.with_no_scholarsphere_oa_locations
                                              .joins(:activity_insight_oa_files)
                                              .where.not(activity_insight_oa_files: { location: nil })
                                              .where('preferred_file_version_none_email_sent != true OR preferred_file_version_none_email_sent IS NULL')
                                          }
  scope :flagged_for_review, -> {
    activity_insight_oa_publication
      .where(flagged_for_review: true)
      .includes(:activity_insight_oa_files)
      .order('activity_insight_oa_files.created_at ASC')
  }
  scope :nonflagged_activity_insight_oa_publication, -> {
    activity_insight_oa_publication
      .where('flagged_for_review != true OR flagged_for_review IS NULL')
  }
  scope :troubleshooting_list, -> {
    activity_insight_oa_publication
      .where(%{(open_access_status != 'gold' AND open_access_status != 'hybrid') OR open_access_status IS NULL})
      .includes(:activity_insight_oa_files)
      .order('activity_insight_oa_files.created_at ASC')
  }
  scope :doi_failed_verification, -> {
    nonflagged_activity_insight_oa_publication
      .where('doi_verified = false')
      .where('doi_error != true OR doi_error IS NULL')
  }
  scope :needs_doi_verification, -> { activity_insight_oa_publication.where(doi_verified: nil).where(%{oa_workflow_state IS DISTINCT FROM 'automatic DOI verification pending'}) }
  scope :filter_oa_status_from_workflow, -> { where.not(%{open_access_status = 'gold' OR open_access_status = 'hybrid' OR open_access_status IS NULL}) }
  scope :needs_permissions_check, -> {
    activity_insight_oa_publication
      .filter_oa_status_from_workflow
      .where(preferred_version: nil, doi_verified: true, permissions_last_checked_at: nil)
  }
  scope :needs_oa_metadata_search,
        -> {
          activity_insight_oa_publication
            .where.not(%{open_access_status = 'gold' OR open_access_status = 'hybrid'})
            .where(doi_verified: true)
            .where(%{oa_workflow_state IS DISTINCT FROM 'oa metadata search pending'})
            .where(%{oa_status_last_checked_at IS NULL OR oa_status_last_checked_at < ?}, 1.hour.ago)
        }
  scope :file_version_check_failed, -> {
    nonflagged_activity_insight_oa_publication
      .filter_oa_status_from_workflow
      .where.not(preferred_version: nil)
      .where.not(preferred_version: NO_VERSION)
      .where(%{EXISTS (SELECT * FROM activity_insight_oa_files WHERE activity_insight_oa_files.publication_id = publications.id AND activity_insight_oa_files.version = 'unknown')})
      .where(%{NOT EXISTS (SELECT * FROM activity_insight_oa_files WHERE activity_insight_oa_files.publication_id = publications.id AND publications.preferred_version = activity_insight_oa_files.version)})
      .where(%{NOT EXISTS (SELECT * FROM activity_insight_oa_files WHERE activity_insight_oa_files.publication_id = publications.id AND activity_insight_oa_files.version IS NULL)})
  }
  scope :wrong_file_version, -> {
    nonflagged_activity_insight_oa_publication
      .where.not(preferred_version: nil)
      .where.not(preferred_version: NO_VERSION)
      .where(%{NOT EXISTS (SELECT * FROM activity_insight_oa_files WHERE activity_insight_oa_files.publication_id = publications.id AND activity_insight_oa_files.version = 'unknown')})
      .where(%{NOT EXISTS (SELECT * FROM activity_insight_oa_files WHERE activity_insight_oa_files.publication_id = publications.id AND activity_insight_oa_files.version = 'notArticleFile')})
      .where(
        <<-SQL.squish
          NOT EXISTS (
            SELECT id FROM activity_insight_oa_files
            WHERE activity_insight_oa_files.publication_id = publications.id
              AND (
                publications.preferred_version = activity_insight_oa_files.version
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'acceptedVersion')
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'publishedVersion')
              )
          )
        SQL
      )
      .where(%{NOT EXISTS (SELECT * FROM activity_insight_oa_files WHERE activity_insight_oa_files.publication_id = publications.id AND activity_insight_oa_files.version IS NULL)})
  }
  scope :published, -> { where(publications: { status: PUBLISHED_STATUS }) }
  scope :needs_manual_preferred_version_check, -> {
    activity_insight_oa_publication
      .filter_oa_status_from_workflow
      .where.not(permissions_last_checked_at: nil)
      .where(preferred_version: nil)
  }
  scope :preferred_file_version_none, -> {
                                        nonflagged_activity_insight_oa_publication
                                          .where(%{preferred_version = '#{NO_VERSION}'})
                                          .includes(:activity_insight_oa_files)
                                          .order('activity_insight_oa_files.created_at ASC')
                                      }
  scope :needs_manual_permissions_review, -> {
    nonflagged_activity_insight_oa_publication
      .where(%{preferred_version IS NOT NULL AND preferred_version != '#{NO_VERSION}'})
      .where(
        <<-SQL.squish
          EXISTS (
            SELECT id FROM activity_insight_oa_files
            WHERE activity_insight_oa_files.publication_id = publications.id
              AND activity_insight_oa_files.permissions_last_checked_at IS NOT NULL
              AND (
                preferred_version = activity_insight_oa_files.version
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'acceptedVersion')
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'publishedVersion')
              )
          )
        SQL
      )
      .where(
        <<-SQL.squish
          NOT EXISTS (
            SELECT id FROM activity_insight_oa_files
            WHERE activity_insight_oa_files.publication_id = publications.id
              AND activity_insight_oa_files.permissions_last_checked_at IS NOT NULL
              AND (
                preferred_version = activity_insight_oa_files.version
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'acceptedVersion')
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'publishedVersion')
              )
              AND activity_insight_oa_files.license IS NOT NULL
              AND (activity_insight_oa_files.set_statement IS NOT NULL OR activity_insight_oa_files.checked_for_set_statement IS TRUE)
              AND (activity_insight_oa_files.embargo_date IS NOT NULL OR activity_insight_oa_files.checked_for_embargo_date IS TRUE)
          )
        SQL
      )
  }
  scope :ready_for_metadata_review, -> {
    nonflagged_activity_insight_oa_publication
      .where(%{preferred_version IS NOT NULL AND preferred_version != '#{NO_VERSION}'})
      .where(
        <<-SQL.squish
          EXISTS (
            SELECT id FROM activity_insight_oa_files
            WHERE activity_insight_oa_files.publication_id = publications.id
              AND (
                preferred_version = activity_insight_oa_files.version
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'acceptedVersion')
                OR (preferred_version = '#{PUBLISHED_OR_ACCEPTED_VERSION}' AND activity_insight_oa_files.version = 'publishedVersion')
              )
              AND activity_insight_oa_files.license IS NOT NULL
              AND (activity_insight_oa_files.set_statement IS NOT NULL OR activity_insight_oa_files.checked_for_set_statement IS TRUE)
              AND (activity_insight_oa_files.embargo_date IS NOT NULL OR activity_insight_oa_files.checked_for_embargo_date IS TRUE)
              AND activity_insight_oa_files.downloaded IS TRUE
              AND activity_insight_oa_files.file_download_location IS NOT NULL
              AND (open_access_status != 'gold' AND open_access_status != 'hybrid' AND open_access_status IS NOT NULL)
          )
        SQL
      )
  }

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

  def activity_insight_upload_user
    activity_insight_oa_files.first.user
  end

  def doi_url_path
    d = doi
    d.try(:gsub, 'https://doi.org/', '')
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
      field(:doi_error)
      field(:flagged_for_review)
      field(:preferred_version)
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
      field(:preferred_file_version_none_email_sent)
      field(:users) do
        filterable true
        searchable [:webaccess_id]
        queryable true
      end
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
      field(:flagged_for_review)
      group :doi do
        field(:doi) do
          label 'DOI'
          pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
        end
        field(:doi_verified)
        field(:doi_error)
      end
      field(:activity_insight_postprint_status)
      field(:open_access_status)
      field(:open_access_button_last_checked_at)
      field(:unpaywall_last_checked_at)
      field(:open_access_locations) do
        pretty_value do
          bindings[:view].render(
            partial: 'rails_admin/partials/publications/open_access_locations',
            locals: { open_access_locations: PreferredOpenAccessPolicy.new(value).rank_all }
          )
        end
      end
      field(:activity_insight_oa_files)
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
      field(:users)
      group :preferred_version do
        field(:preferred_version)
        field(:preferred_file_version_none_email_sent)
      end
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
      field(:flagged_for_review)
      group :doi do
        field(:doi) { label 'DOI' }
        field(:doi_verified, :enum) do
          label 'DOI verified?'
          enum do
            [['True', true], ['False', false]]
          end
        end
        field(:doi_error, :enum) do
          label 'DOI error?'
          enum do
            [['True', true], ['False', false]]
          end
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
      group :preferred_version do
        field(:preferred_version, :enum) do
          label 'Preferred Version'
          enum { Publication.preferred_version_options }
        end
        field(:preferred_file_version_none_email_sent)
      end
    end

    scope do
      Publication.joins(:users)
    end
  end

  def preferred_version=(val)
    super(val == '' ? nil : val)
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

  def no_scholarsphere_open_access_information?
    !(scholarsphere_open_access_url.present? || scholarsphere_upload_pending? || open_access_waived?)
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

  def has_pure_import?
    imports.where(source: 'Pure').any?
  end

  def has_single_import_from_pure?
    imports.count == 1 && has_pure_import?
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
    no_scholarsphere_open_access_information? && is_oa_publication? && no_valid_file_version?
  end

  def preferred_version_display
    option = self.class.preferred_version_options.find do |o|
      o[1] == preferred_version
    end

    option[0]
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

      update_oa_status_from_unpaywall(unpaywall_response)

      self.unpaywall_last_checked_at = Time.zone.now

      save!

      OpenAccessLocation.create_or_update_from_unpaywall(unpaywall_locations, self) if unpaywall_locations.present?
    end
  end

  def update_oa_status_from_unpaywall(unpaywall_response)
    unpaywall_match = doi.present? || unpaywall_response.matchable_title == matchable_title
    self.open_access_status = if unpaywall_match && unpaywall_response.oa_status.present?
                                unpaywall_response.oa_status
                              else
                                'unknown'
                              end
  end

  def ai_file_for_deposit
    return nil if preferred_version.blank? || preferred_version == NO_VERSION

    if preferred_version != PUBLISHED_OR_ACCEPTED_VERSION
      return activity_insight_oa_files
          .where(version: preferred_version)
          .order('created_at DESC')
          .first
    end

    activity_insight_oa_files
      .where("version = 'acceptedVersion' OR version = 'publishedVersion'")
      .order('created_at DESC')
      .first
  end

  def can_deposit_to_scholarsphere?
    ai_file_for_deposit.license.present? &&
      ai_file_for_deposit.file_download_location.present? &&
      title.present? &&
      abstract.present? &&
      published_on.present? &&
      doi == DOISanitizer.new(doi).url &&
      !scholarsphere_upload_pending? &&
      !scholarsphere_upload_failed?
  end

  def has_verified_doi?
    doi.present? && doi_verified
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
