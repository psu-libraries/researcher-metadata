# frozen_string_literal: true

# TODO: This does not work anymore.  This syntax is used with SuckerPunch, not DelayedJob
class AiPublicationExportJob
  def perform(publication_ids, target)
    publications = Publication.find(publication_ids)
    ActivityInsightPublicationExporter.new(publications, target).export
  end
  handle_asynchronously :perform
end
