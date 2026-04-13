# frozen_string_literal: true

class NSFAwards
  def initialize(awards_data)
    @awards_data = awards_data
  end

  delegate :count, to: :parsed_data, prefix: false

  def each(&)
    parsed_data.each do |a|
      yield NSFAward.new(a)
    end
  end

  private

    attr_reader :awards_data

    def parsed_data
      JSON.parse(awards_data)['response']['award']
    end
end
