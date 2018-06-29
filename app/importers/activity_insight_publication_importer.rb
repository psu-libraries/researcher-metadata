class ActivityInsightPublicationImporter < CSVImporter

  def row_to_object(row)
    Publication.new(row)
  end

  def bulk_import(objects)
    Publication.import(objects)
  end

  private

  def encoding
    'bom|utf-8'
  end
end
