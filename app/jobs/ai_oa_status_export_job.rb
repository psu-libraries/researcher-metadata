# frozen_string_literal: true

class AiOAStatusExportJob < ApplicationJob
  class InvalidExportStatus < RuntimeError; end
  queue_as 'default'

  def perform(file_id, export_status)
    raise InvalidExportStatus.new(export_status) unless ActivityInsightOAFile.export_statuses.include?(export_status)

    ActivityInsightOAStatusExporter.new(file_id, export_status).export

    if export_status == 'Cannot Deposit'
      file = ActivityInsightOAFile.find(file_id)
      file.remove_file_download_location!
      file.save!
    end
  end
end
