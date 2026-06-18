# frozen_string_literal: true

class OpenAlexAuthor
  def initialize(parsed_author, index)
    @parsed_author = parsed_author
    @index = index
  end

  def orcid
    parsed_author['author']['orcid']
  end

  def position
    index + 1
  end

  def first_name
    display_name_parts[0]
  end

  def middle_name
    display_name_parts[1..-2].join(' ') if display_name_parts.count > 2
  end

  def last_name
    display_name_parts[-1]
  end

  def psu_affiliated?
    !!parsed_author['institutions'].find { |i| i['ror'] == 'https://ror.org/04p491231' }
  end

  private

    attr_reader :parsed_author, :index

    def display_name_parts
      parsed_author['author']['display_name'].split
    end
end
