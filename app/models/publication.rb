class Publication < ApplicationRecord
  include Swagger::Blocks

  has_many :authorships
  has_many :people, through: :authorships
  has_many :imports, class_name: :PublicationImport

  swagger_schema :Publication do
    property :id do
      key :type, :integer
      key :format, :int64
    end
  end
end
