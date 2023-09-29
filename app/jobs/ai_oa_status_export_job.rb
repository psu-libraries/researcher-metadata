# frozen_string_literal: true

class AiOAStatusExportJob < ApplicationJob
  queue_as 'default'

  def perform(file_id)
    ActivityInsightOAStatusExporter.new(file_id).export
  end
end
