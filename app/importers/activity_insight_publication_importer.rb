class ActivityInsightPublicationImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if publication_type(row) =~ /journal article/i && status(row) == 'Published'
      pi = PublicationImport.find_by(source: ActivityInsightCSVImporter::IMPORT_SOURCE,
                                     source_identifier: row[:id]) ||
        PublicationImport.new(source: ActivityInsightCSVImporter::IMPORT_SOURCE,
                              source_identifier: row[:id],
                              publication: Publication.create!(pub_attrs(row)))
      p = pi.publication

      if pi.persisted?
        p.update_attributes!(pub_attrs(row)) unless p.updated_by_user_at.present?
        return nil
      end

      pi
    end
  end

  def bulk_import(objects)
    PublicationImport.import(objects)
  end

  private

  def pub_attrs(row)
    {
      title: row[:title],
      publication_type: publication_type(row),
      journal_title: journal_title(row),
      publisher: publisher(row),
      secondary_title: row[:title_secondary],
      status: status(row),
      volume: volume(row),
      issue: row[:issue],
      edition: row[:edition],
      page_range: page_range(row),
      url: url(row),
      issn: row[:isbnissn],
      doi: ActivityInsightPublication.new(row).doi,
      abstract: row[:abstract],
      authors_et_al: authors_et_al(row),
      published_on: published_on(row)
    }
  end

  def publication_type(row)
    ai_type = extract_value(row: row, header_key: :contype, header_count: 12) || row[:contypeother]
    cleaned_ai_type = ai_type.downcase.strip

    if cleaned_ai_type == 'journal article, academic journal'
      'Academic Journal Article'
    elsif cleaned_ai_type == 'journal article, in-house journal' ||
      cleaned_ai_type == 'journal article, in-house'
      'In-house Journal Article'
    elsif cleaned_ai_type == 'journal article, professional journal'
      'Professional Journal Article'
    elsif cleaned_ai_type == 'journal article, public or trade journal' ||
      cleaned_ai_type == 'magazine or trade journal article'
      'Trade Journal Article'
    elsif cleaned_ai_type == 'journal article'
      'Journal Article'
    else
      nil
    end
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
