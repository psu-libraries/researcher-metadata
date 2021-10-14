# frozen_string_literal: true

class PurePublishersImporter < PureImporter
  def call
    pbar = ProgressBar.create(title: 'Importing Pure publishers', total: total_pages) unless Rails.env.test?

    1.upto(total_pages) do |i|
      offset = (i - 1) * page_size
      publishers = get_records(type: record_type, page_size: page_size, offset: offset)

      publishers['items'].each do |item|
        p = Publisher.find_by(pure_uuid: item['uuid']) || Publisher.new
        p.pure_uuid = item['uuid'] if p.new_record?
        p.name = item['name']
        p.save!
      rescue StandardError => e
        log_error(e, {
                    publisher_id: p&.id,
                    item: item
                  })
      end
      pbar.increment unless Rails.env.test?

    rescue StandardError => e
      log_error(e, {})
    end
    pbar.finish unless Rails.env.test?
  rescue StandardError => e
    log_error(e, {})
  end

  def page_size
    1000
  end

  def record_type
    'publishers'
  end
end
