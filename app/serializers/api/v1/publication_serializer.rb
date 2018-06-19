module API::V1
  class PublicationSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title
  end
end
