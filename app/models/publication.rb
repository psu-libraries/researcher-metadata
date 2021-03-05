class Publication < ApplicationRecord
  OPEN_ACCESS_POLICY_START = Date.new(2020, 7, 1)

  class NonDuplicateMerge < ArgumentError; end

  include Swagger::Blocks

  def self.publication_types
    [
      "Academic Journal Article", "In-house Journal Article", "Professional Journal Article",
      "Trade Journal Article", "Journal Article", "Review Article", "Abstract", "Blog", "Book", "Chapter",
      "Book/Film/Article Review", "Conference Proceeding", "Encyclopedia/Dictionary Entry",
      "Extension Publication", "Magazine/Trade Publication", "Manuscript", "Newsletter",
      "Newspaper Article", "Comment/Debate", "Commissioned Report", "Digital or Visual Product",
      "Editorial", "Foreword/Postscript", "Letter", "Paper", "Patent", "Poster",
      "Scholarly Edition", "Short Survey", "Working Paper", "Other"
     ]
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

  belongs_to :duplicate_group,
             class_name: :DuplicatePublicationGroup,
             foreign_key: :duplicate_publication_group_id,
             optional: true,
             inverse_of: :publications
  belongs_to :journal, optional: true, inverse_of: :publications

  has_one :publisher, through: :journal
  
  validates :publication_type, :title, presence: true
  validates :publication_type, inclusion: {in: publication_types }

  scope :visible, -> { where visible: true }

  scope :published_during_membership,
        -> { visible.
          joins(:user_organization_memberships).
          where('published_on >= user_organization_memberships.started_on AND (published_on <= user_organization_memberships.ended_on OR user_organization_memberships.ended_on IS NULL)').
          distinct(:id) }

  scope :subject_to_open_access_policy, -> { where('published_on >= ?', Publication::OPEN_ACCESS_POLICY_START) }

  scope :open_access, -> { where(%{(open_access_url IS NOT NULL AND open_access_url != '') OR (user_submitted_open_access_url IS NOT NULL AND user_submitted_open_access_url != '') OR (scholarsphere_open_access_url IS NOT NULL AND scholarsphere_open_access_url != '')}) }

  accepts_nested_attributes_for :authorships, allow_destroy: true
  accepts_nested_attributes_for :contributor_names, allow_destroy: true
  accepts_nested_attributes_for :taggings, allow_destroy: true

  def self.find_by_wos_pub(pub)
    by_doi = where(doi: "https://doi.org/#{pub.doi}")
    if by_doi.any?
      by_doi
    else
      # TODO:  We can make this query more accurate using postgres trigram matching
      # on the title and sub-title in the same way that we do when we're finding 
      # duplicate publications.
      where("title ILIKE ? AND EXTRACT(YEAR FROM published_on) = ?",
            "%#{pub.title}%",
            pub.publication_date.try(:year))
    end
  end

  def confirmed_authorships
    authorships.where(confirmed: true)
  end

  def doi_url_path
    d = doi
    d.try(:gsub, "https://doi.org/", "")
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
      field(:open_access_url) do
        label 'Open access URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:user_submitted_open_access_url) do
        label 'User-submitted open access URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:scholarsphere_open_access_url) do
        label 'Scholarsphere open access URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:published_on)
      field(:total_scopus_citations) { label 'Citations' }
      field(:visible) { label 'Visible via API'}
      field(:publisher_name)
      field(:publication_type)
      field(:status)
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
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
      field(:user_submitted_open_access_url) { label 'User-submitted open access URL' }
      field(:scholarsphere_open_access_url) { label 'Scholarsphere Open Access URL' }
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
      field(:visible) { label 'Visible via API?'}
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
      field(:open_access_url) do
        label 'Open access URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:user_submitted_open_access_url) do
        label 'User-submitted open access URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
      end
      field(:scholarsphere_open_access_url) do
        label 'Scholarsphere open access URL'
        pretty_value { %{<a href="#{value}" target="_blank">#{value}</a>}.html_safe if value }
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
      field(:visible) { label 'Visible via API?'}
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
      field(:user_submitted_open_access_url) { label 'User-submitted open access URL' }
      field(:scholarsphere_open_access_url) { label 'Scholarsphere Open Access URL' }
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
      field(:visible) { label 'Visible via API?'}
    end
  end

  def ai_import_identifiers
    imports.where(source: 'Activity Insight').map { |i| i.source_identifier }
  end

  def pure_import_identifiers
    imports.where(source: 'Pure').map { |i| i.source_identifier }
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
    policy = PreferredOpenAccessPolicy.new(self)
    policy.url
  end

  def scholarsphere_upload_pending?
    authorships.where.not(scholarsphere_uploaded_at: nil).any?
  end

  def open_access_waived?
    waivers.any?
  end

  def no_open_access_information?
    !has_open_access_information?
  end

  def has_open_access_information?
    !preferred_open_access_url.blank? || scholarsphere_upload_pending? || open_access_waived?
  end

  def orcid_allowed?
    doi.present? || url.present? || preferred_open_access_url.present?
  end

  def is_journal_article?
    publication_type.include? 'Journal Article'
  end

  def all_non_duplicate_ids
    (non_duplicate_ids.uniq - [id]).sort
  end

  def merge!(publications_to_merge)
    pubs_to_delete = publications_to_merge - [self]
    all_pubs = (publications_to_merge.to_a + [self]).uniq

    all_pubs.each do |p|
      other_pubs = all_pubs - [p]

      p.non_duplicate_groups.each do |ndg|
        if other_pubs.map { |op| op.non_duplicate_groups }.flatten.include?(ndg)
          raise NonDuplicateMerge
        end
      end
    end

    ActiveRecord::Base.transaction do
      imports_to_reassign = pubs_to_delete.map { |p| p.imports }.flatten

      imports_to_reassign.each do |i|
        i.update_attributes!(publication: self)
      end

      all_authorships = all_pubs.map { |p| p.authorships }.flatten
      authorships_by_user = all_authorships.group_by { |a| a.user }

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
                    scholarsphere_uploaded_at: amp.scholarsphere_timestamp_to_keep)
        amp.waivers_to_destroy.each { |w| w.destroy }
      end

      pubs_to_delete.each do |p|
        p.non_duplicate_groups.each do |ndg|
          ndg.publications << self
        end

        p.reload.destroy
      end

      update_attributes!(updated_by_user_at: Time.current)
    end
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

  private

  def preferred_journal_info_policy
    PreferredJournalInfoPolicy.new(self)
  end
end
