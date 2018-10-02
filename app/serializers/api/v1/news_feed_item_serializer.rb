module API::V1
  class NewsFeedItemSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :url, :description
  end
end
