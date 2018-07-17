class ActivityInsightPublicationImporter < ActivityInsightCSVImporter
  def row_to_object(row)
    if publication_type(row) == "Journal Article, Academic Journal"
      unless PublicationImport.find_by(import_source: "Activity Insight", source_identifier: row[:id])
        pi = PublicationImport.new

        # For now we assume that there are no existing publications in the database to associate
        # with a new import since we only have one import source. When we have multiple import sources,
        # this assumption may be wrong, and we'll have to make an attempt to find (and perhaps update)
        # existing publications before creating new ones.
        p = Publication.create!({
          title: row[:title],
          publication_type: "Academic Journal Article",
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
          abstract: row[:abstract],
          authors_et_al: authors_et_al(row),
          published_at: published_at(row)})

        pi.publication = p

        pi.title = row[:title]
        pi.publication_type = "Academic Journal Article"
        pi.journal_title = journal_title(row)
        pi.publisher = publisher(row)
        pi.secondary_title = row[:title_secondary]
        pi.status = status(row)
        pi.volume = volume(row)
        pi.issue = row[:issue]
        pi.edition = row[:edition]
        pi.page_range = page_range(row)
        pi.url = url(row)
        pi.issn = row[:isbnissn]
        pi.abstract = row[:abstract]
        pi.authors_et_al = authors_et_al(row)
        pi.published_at = published_at(row)

        pi.source_identifier = row[:id]
        pi.import_source = "Activity Insight"
        pi
      end
    end
  end

  def bulk_import(objects)
    PublicationImport.import(objects)
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

  def published_at(row)
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
