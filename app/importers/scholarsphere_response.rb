# frozen_string_literal: true

class ScholarsphereResponse
  attr_reader :response

  def initialize(response)
    @response = response
  end

  def doi_found?
    url.present?
  end

  def url
    response&.parsed_response&.first.present? ? response&.parsed_response&.first&.[]('url') : nil
  end
end
