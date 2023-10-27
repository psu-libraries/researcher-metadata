# frozen_string_literal: true

class AiPublicationExportJob < ApplicationJob
  queue_as 'ai-publication-export'

  def perform(publication_ids, target)
    publications = Publication.find(publication_ids)
    ActivityInsightPublicationExporter.new(publications, target).export
  end
end
