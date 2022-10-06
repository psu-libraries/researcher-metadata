# frozen_string_literal: true

class ISSNSanitizer
  def initialize(value)
    @value = value
  end

  def issn
    return nil if ISBNSanitizer.new(value).isbn || DOISanitizer.new(value).url

    match = /(ISSN |eISSN )?\d{4}-\d{3}(\d|x|X)/.match(value)
    match[0] if match
  end

  private

    attr_reader :value
end
