# frozen_string_literal: true

class OpenAlexDatasets
  WORK_TYPE = 'dataset'

  def initialize(datasets_data)
    @datasets_data = datasets_data
  end

  def self.find_in_batches(&)
    c = OpenAlexAPIClient.new
    cursor = '*'

    loop do
      datasets = new(c.get_works(type: WORK_TYPE, cursor: cursor))
      cursor = datasets.next_cursor
      datasets.each(&)
      break if datasets.next_cursor.nil?

      sleep 1 unless Rails.env.test?
    end
  end

  def each(&)
    datasets_data['results'].each do |result|
      yield OpenAlexWork.new(result)
    end
  end

  def next_cursor
    datasets_data['meta']['next_cursor']
  end

  private

    attr_reader :datasets_data
end
