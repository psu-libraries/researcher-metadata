class Publication < ActiveRecord::Base
  include Swagger::Blocks

  validates :title, presence: true

  swagger_schema :Publication do
    property :id do
      key :type, :integer
      key :format, :int64
    end
  end
end
