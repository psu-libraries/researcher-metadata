class AiPublicationExportJob
  def perform(publication_ids, target)
    publications = Publication.find(publication_ids)
    ActivityInsightPublicationExporter.new(publications, target).export
  end
  handle_asynchronously :perform
end
