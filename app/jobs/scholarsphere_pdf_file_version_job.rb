# frozen_string_literal: true

class ScholarspherePdfFileVersionJob < ApplicationJob
  queue_as 'scholarsphere-pdf-file-version'

  def perform(file_meta:, publication_meta:, exif_file_version:)
    pdf_file_version = ScholarspherePdfFileVersion.new(file_meta: file_meta, publication_meta: publication_meta).version

    Rails.cache.write("file_version_job_#{job_id}", { pdf_file_version: pdf_file_version, file_meta: file_meta, exif_file_version: exif_file_version })
  end
end
