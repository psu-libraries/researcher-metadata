class Publication < ApplicationRecord
  include Swagger::Blocks

  def self.publication_types
    ["Academic Journal Article",
     "In-house Journal Article",
     "Professional Journal Article",
     "Trade Journal Article",
     "Journal Article"]
  end

  has_many :authorships
  has_many :users, through: :authorships
  has_many :contributors, -> { order position: :asc }, dependent: :destroy
  has_many :imports, class_name: :PublicationImport

  validates :publication_type, :title, presence: true
  validates :publication_type, inclusion: {in: publication_types }
  validates :pure_uuid, :activity_insight_identifier, uniqueness: {allow_nil: true}

  swagger_schema :Publication do
    property :id do
      key :type, :integer
      key :format, :int64
    end
  end
end
