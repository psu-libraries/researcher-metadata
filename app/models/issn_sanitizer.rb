# frozen_string_literal: true

class ISSNSanitizer
    def initialize(value)
      @value = value
    end
  
    def issn
      return nil if ISBNSanitizer.new(value).isbn || DOISanitizer.new(value).url
      issn_match = /(ISSN |eISSN )?[\S]{4}\-[\S]{4}/.match(value)
    end
  
    private
  
      attr_reader :value
  end
  