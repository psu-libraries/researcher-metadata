# frozen_string_literal: true

class OpenAlexWork
  def initialize(parsed_work)
    @parsed_work = parsed_work
  end

  def doi
    DOISanitizer.new(parsed_work['doi']).url
  end

  private

    attr_reader :parsed_work
end
