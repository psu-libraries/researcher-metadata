class PurePublishersImporter < PureImporter
  def call
    1.upto(total_pages) do |i|
      offset = (i-1) * page_size
      publishers = get_records(type: record_type, page_size: page_size, offset: offset)

      publishers['items'].each do |item|
        p = Publisher.find_by(pure_uuid: item['uuid']) || Publisher.new
        p.pure_uuid = item['uuid'] if p.new_record?
        p.name = item['name']
        p.save!
      end
    end
  end

  def page_size
    1000
  end

  def total_pages
    (total_records / page_size.to_f).ceil
  end

  def record_type
    'publishers'
  end
end
