# frozen_string_literal: true

class OABResponse
  attr_reader :json

  def initialize(json)
    @json = json
  end

  def url
    json['url']
  end

  def doi
    DOISanitizer.new(json['metadata']['doi']).url if json['metadata']
  end

  def to_s
    json
  end
end
