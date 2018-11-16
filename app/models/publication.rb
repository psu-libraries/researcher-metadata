class Publication < ApplicationRecord
  include Swagger::Blocks

  def self.publication_types
    ["Academic Journal Article",
     "In-house Journal Article",
     "Professional Journal Article",
     "Trade Journal Article",
     "Journal Article"]
  end

  has_many :authorships, inverse_of: :publication
  has_many :users, through: :authorships
  has_many :taggings, -> { order rank: :desc }, class_name: :PublicationTagging, inverse_of: :publication
  has_many :tags, through: :taggings
  has_many :contributors,
           -> { order position: :asc },
           dependent: :destroy,
           inverse_of: :publication
  has_many :imports, class_name: :PublicationImport
  has_many :organizations, through: :users

  belongs_to :duplicate_group,
             class_name: :DuplicatePublicationGroup,
             foreign_key: :duplicate_publication_group_id,
             optional: true,
             inverse_of: :publications

  validates :publication_type, :title, presence: true
  validates :publication_type, inclusion: {in: publication_types }

  scope :visible, -> { where visible: true }

  accepts_nested_attributes_for :authorships, allow_destroy: true
  accepts_nested_attributes_for :contributors, allow_destroy: true
  accepts_nested_attributes_for :taggings, allow_destroy: true

  swagger_schema :Publication do
    property :id do
      key :type, :integer
      key :format, :int64
    end
  end

  rails_admin do
    list do
      field(:id)
      field(:title)
      field(:secondary_title)
      field(:organizations, :has_many_association) do
        searchable [:id]
      end
      field(:publication_type)
      field(:journal_title)
      field(:publisher)
      field(:status)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:url) { label 'URL' }
      field(:issn) { label 'ISSN' }
      field(:doi) { label 'DOI' }
      field(:abstract)
      field(:authors_et_al) { label 'Et al authors?' }
      field(:published_on)
      field(:total_scopus_citations) { label 'Number of citations' }
      field(:visible) { label 'Visible via API'}
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
      field(:publisher)
      field(:status)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:url) { label 'URL' }
      field(:issn) { label 'ISSN' }
      field(:doi) { label 'DOI' }
      field(:abstract)
      field(:authors_et_al) { label 'Et al authors?' }
      field(:published_on)
      field(:total_scopus_citations) { label 'Number of citations' }
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
      field(:duplicate_group)
      field(:users) { read_only true }
      field(:authorships)
      field(:contributors)
      field(:visible) { label 'Visible via API?'}
    end

    show do
      field(:title)
      field(:secondary_title)
      field(:publication_type)
      field(:journal_title)
      field(:publisher)
      field(:status)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:url) { label 'URL' }
      field(:issn) { label 'ISSN' }
      field(:doi) { label 'DOI' }
      field(:abstract)
      field(:authors_et_al) { label 'Et al authors?' }
      field(:published_on)
      field(:total_scopus_citations) { label 'Number of citations' }
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
      field(:duplicate_group)
      field(:users) { read_only true }
      field(:authorships)
      field(:contributors)
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
      field(:publisher)
      field(:status)
      field(:volume)
      field(:issue)
      field(:edition)
      field(:page_range)
      field(:url) { label 'URL' }
      field(:issn) { label 'ISSN' }
      field(:doi) { label 'DOI' }
      field(:abstract)
      field(:authors_et_al) { label 'Et al authors?' }
      field(:published_on)
      field(:total_scopus_citations) { label 'Number of citations' }
      field(:created_at) { read_only true }
      field(:updated_at) { read_only true }
      field(:updated_by_user_at) { read_only true }
      field(:duplicate_group)
      field(:users) { read_only true }
      field(:authorships)
      field(:contributors)
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
end
