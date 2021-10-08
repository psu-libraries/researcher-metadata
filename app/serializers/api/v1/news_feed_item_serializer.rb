# frozen_string_literal: true

module API::V1
  class NewsFeedItemSerializer
    include FastJsonapi::ObjectSerializer
    attributes :title, :url, :description

    attribute :published_on do |object|
      object.published_on.try(:iso8601)
    end
  end
end
