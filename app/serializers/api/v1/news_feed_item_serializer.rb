module API::V1
  class NewsFeedItemSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :url, :description

    attribute :pubdate do |object|
      object.pubdate.try(:iso8601)
    end
  end
end
