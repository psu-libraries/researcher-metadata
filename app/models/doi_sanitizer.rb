# frozen_string_literal: true

class DOISanitizer
  def initialize(value)
    @value = value
  end

  def url
    doi_match = /10\.\S+\/\S+/.match(value)
    "https://doi.org/#{doi_match[0]}".gsub("\u200b", '').gsub("\u2013", '-') if doi_match
  end

  private

    attr_reader :value
end
