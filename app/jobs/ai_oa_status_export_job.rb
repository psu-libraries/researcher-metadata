# frozen_string_literal: true

class AiOAStatusExportJob < ApplicationJob
  queue_as 'default'

  def perform(file_id, export_status)
    ActivityInsightOAStatusExporter.new(file_id, export_status).export
  end
end
