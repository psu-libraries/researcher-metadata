class Publication < ApplicationRecord
  include Swagger::Blocks

  def self.publication_types
    ["Academic Journal Article"]
  end

  has_many :authorships
  has_many :users, through: :authorships
  has_many :contributors, -> { order position: :asc }

  validates :publication_type, :title, presence: true
  validates :publication_type, inclusion: {in: publication_types }

  swagger_schema :Publication do
    property :id do
      key :type, :integer
      key :format, :int64
    end
  end
end
