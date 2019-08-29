class ActivityInsightPublication
  def initialize(pub_data)
    @pub_data = pub_data
  end

  def doi
    web_address = extract_value(row: pub_data, header_key: :web_address, header_count: 3)
    DOIParser.new(web_address).url || DOIParser.new(pub_data[:isbnissn]).url
  end

  private

  attr_reader :pub_data

  def extract_value(row:, header_key:, header_count:)
    value = nil
    header_count.times do |i|
      if i == 0
        value = row[header_key] if row[header_key].present?
      else
        key = header_key.to_s + (i+1).to_s
        value = row[key.to_sym] if row[key.to_sym].present?
      end
    end
    value
  end
end
