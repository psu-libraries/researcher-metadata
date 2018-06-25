class Publication < ActiveRecord::Base
  include Swagger::Blocks

  validates :title, presence: true

  swagger_schema :Publication do
    key :required, [:id, :title]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :title do
      key :type, :string
    end
  end

  swagger_schema :PublicationInput do
    allOf do
      schema do
        key :'$ref', :Publication
      end
      schema do
        key :required, [:title]
        property :id do
          key :type, :integer
          key :format, :int64
        end
      end
    end
  end
end
