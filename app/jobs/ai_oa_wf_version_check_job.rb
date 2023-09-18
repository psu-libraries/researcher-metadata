# frozen_string_literal: true

class AiOAWfVersionCheckJob < ApplicationJob
  queue_as 'default'

  def perform(ai_oa_file_id)
    file = ActivityInsightOAFile.find(ai_oa_file_id)
    publication = Publication.find(file.publication)
    pdf_file_version = FileVersionChecker.new(file_path: file.file_path,
                                              publication: publication)

    file.update version: pdf_file_version
    file.save!
  end
end
