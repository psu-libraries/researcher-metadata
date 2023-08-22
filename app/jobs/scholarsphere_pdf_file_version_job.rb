# frozen_string_literal: true

class ScholarspherePdfFileVersionJob < ApplicationJob
  queue_as 'scholarsphere-pdf-file-version'

  def perform(file_path:, publication_id:)
    publication = Publication.find(publication_id)
    pdf_file_version = ScholarspherePdfFileVersion.new(file_path: file_path, 
                                                       publication: publication)

    Rails.cache.write("file_version_job_#{job_id}", { pdf_file_version: pdf_file_version.version, 
                                                      pdf_file_score: pdf_file_version.score,
                                                      file_path: file_path })
  end
end
