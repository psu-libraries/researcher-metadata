class Publication < ActiveRecord::Base
  include Swagger::Blocks

  has_many :authorships
  has_many :people, through: :authorships
  validates :title, presence: true

  swagger_schema :Publication do
    property :id do
      key :type, :integer
      key :format, :int64
    end
  end
end
