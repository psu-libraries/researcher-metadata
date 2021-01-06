class PureJournalsImporter < PureImporter
  def call
    1.upto(total_pages) do |i|
      offset = (i-1) * page_size
      journals = get_records(type: record_type, page_size: page_size, offset: offset)

      journals['items'].each do |item|
        j = Journal.find_by(pure_uuid: item['uuid']) || Journal.new
        j.pure_uuid = item['uuid'] if j.new_record?
        j.title = item['name']
        j.save!
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
    'journals'
  end
end
