# frozen_string_literal: true

class AiOAWfVersionCheckJob < ApplicationJob
  queue_as 'default'

  def perform(ai_oa_file_id)
    file = ActivityInsightOAFile.find(ai_oa_file_id)
    exif_file_version = ExifFileVersionChecker.new(file_path: file.file_download_location.to_s,
                                                   journal: file.publication.journal&.title).version
    if exif_file_version.present?
      file.update! version: pdf_file_version
      return
    end

    pdf_file_version = FileVersionChecker.new(file_path: file.file_download_location.to_s,
                                              publication: file.publication).version

    file.update! version: pdf_file_version
  end
end
