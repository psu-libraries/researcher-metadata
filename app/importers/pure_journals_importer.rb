# frozen_string_literal: true

class PureJournalsImporter < PureImporter
  def call
    pbar = ProgressBar.create(title: 'Importing Pure journals', total: total_pages) unless Rails.env.test?

    1.upto(total_pages) do |i|
      offset = (i - 1) * page_size
      journals = get_records(type: record_type, page_size: page_size, offset: offset)

      journals['items'].each do |item|
        j = Journal.find_by(pure_uuid: item['uuid']) || Journal.new
        j.pure_uuid = item['uuid'] if j.new_record?
        j.title = item['titles'].first['value']
        j.publisher = Publisher.find_by(pure_uuid: item['publisher']['uuid']) if item['publisher']
        j.save!
      end
      pbar.increment unless Rails.env.test?
    end
    pbar.finish unless Rails.env.test?
  end

  def page_size
    1000
  end

  def record_type
    'journals'
  end
end
