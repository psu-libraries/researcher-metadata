class AiPublicationExportJob
  include SuckerPunch::Job

  def perform(publication_ids, target)
    publications = Publication.find(publication_ids)
    ActivityInsightPublicationExporter.new(publications, target).export
  end
end
