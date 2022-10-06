# frozen_string_literal: true

class ISBNSanitizer
  def initialize(value)
    @value = value
  end

  def isbn
    return nil if DOISanitizer.new(value).url

    match = /(ISBN-*(1[03])* *(: ){0,1})*(([0-9Xx][- ]*){13}|([0-9Xx][- ]*){10})/.match(value)
    match[0] if match
  end

  private

    attr_reader :value
end
