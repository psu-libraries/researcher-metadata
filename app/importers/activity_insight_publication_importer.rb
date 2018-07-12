class ActivityInsightPublicationImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if row[:contype] == "Journal Article, Academic Journal" ||
      row[:contype2] == "Journal Article, Academic Journal" ||
      row[:contype3] == "Journal Article, Academic Journal" ||
      row[:contype4] == "Journal Article, Academic Journal" ||
      row[:contype5] == "Journal Article, Academic Journal" ||
      row[:contype6] == "Journal Article, Academic Journal" ||
      row[:contype7] == "Journal Article, Academic Journal" ||
      row[:contype8] == "Journal Article, Academic Journal" ||
      row[:contype9] == "Journal Article, Academic Journal" ||
      row[:contype10] == "Journal Article, Academic Journal" ||
      row[:contype11] == "Journal Article, Academic Journal" ||
      row[:contype12] == "Journal Article, Academic Journal"

      p = Publication.new
      p.title = row[:title]
      p.activity_insight_identifier = row[:id]
      p.characteristic = "Journal Article, Academic Journal"
      p.secondary_title = row[:title_secondary]
      p.source = row[:journal_name]
      p.issue = row[:issue]
      p.edition = row[:edition]
      p.isbn_issn = row[:isbnissn]
      p.abstract = row[:abstract]

      p.source = extract_value(row: row, header_key: :journal_name, header_count: 3)
      p.source = row[:journal_name_other] if row[:journal_name_other].present?
      p.status = extract_value(row: row, header_key: :status, header_count: 3)
      p.volume = extract_value(row: row, header_key: :volume, header_count: 2)
      p.page_range = extract_value(row: row, header_key: :pagenum, header_count: 4)
      unless p.page_range.present?
        p.page_range = extract_value(row: row, header_key: :pub_pagenum, header_count: 2)
      end
      p.url = extract_value(row: row, header_key: :web_address, header_count: 3)
      p.published_at = extract_value(row: row, header_key: :pub_start, header_count: 5)
      p
    else
      nil
    end
  end

  def bulk_import(objects)
    Publication.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end

  def extract_value(row:, header_key:, header_count:)
    value = ''
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
