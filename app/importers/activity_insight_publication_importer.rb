class ActivityInsightPublicationImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if publication_type(row) =~ /journal article/i
      p = Publication.find_by(activity_insight_identifier: row[:id]) || Publication.new

      p.title = row[:title]
      p.publication_type = "Academic Journal Article" if p.new_record?
      p.journal_title = journal_title(row)
      p.publisher = publisher(row)
      p.secondary_title = row[:title_secondary]
      p.status = status(row)
      p.volume = volume(row)
      p.issue = row[:issue]
      p.edition = row[:edition]
      p.page_range = page_range(row)
      p.url = url(row)
      p.issn = row[:isbnissn]
      p.abstract = row[:abstract]
      p.authors_et_al = authors_et_al(row)
      p.published_on = published_on(row)
      p.activity_insight_identifier = row[:id] if p.new_record?

      p
    end
  end

  def bulk_import(objects)
    Publication.import(objects, on_duplicate_key_update: {conflict_target: [:activity_insight_identifier],
                                                          columns: [:title,
                                                                    :journal_title,
                                                                    :publisher,
                                                                    :secondary_title,
                                                                    :status,
                                                                    :volume,
                                                                    :issue,
                                                                    :edition,
                                                                    :page_range,
                                                                    :url,
                                                                    :issn,
                                                                    :abstract,
                                                                    :authors_et_al,
                                                                    :published_on]})
  end

  private

  def publication_type(row)
    extract_value(row: row, header_key: :contype, header_count: 12) || row[:contypeother]
  end

  def journal_title(row)
    extract_value(row: row, header_key: :journal_name, header_count: 3) || row[:journal_name_other]
  end

  def publisher(row)
    extract_value(row: row, header_key: :publisher, header_count: 6) || row[:publisher_other]
  end

  def status(row)
    extract_value(row: row, header_key: :status, header_count: 3)
  end

  def volume(row)
    extract_value(row: row, header_key: :volume, header_count: 2)
  end

  def page_range(row)
    extract_value(row: row, header_key: :pagenum, header_count: 4) ||
      extract_value(row: row, header_key: :pub_pagenum, header_count: 2)
  end

  def url(row)
    extract_value(row: row, header_key: :web_address, header_count: 3)
  end

  def authors_et_al(row)
    row[:authors_etal] == 'true'
  end

  def published_on(row)
    extract_value(row: row, header_key: :pub_start, header_count: 5)
  end

  def encoding
    'bom|utf-8'
  end

  def extract_value(row:, header_key:, header_count:)
    value = nil
    header_count.times do |i|
      if i == 0
        value = row[header_key] if row[header_key].present? && row[header_key].to_s.downcase != 'other'
      else
        key = header_key.to_s + (i+1).to_s
        value = row[key.to_sym] if row[key.to_sym].present? && row[key.to_sym].to_s.downcase != 'other'
      end
    end
    value
  end
end
