# frozen_string_literal: true

class AiOAStatusExportJob < ApplicationJob
  def perform
    files = ActivityInsightOAFile.send_oa_status_to_activity_insight
    ActivityInsightOAStatusExporter.new(files).export
  end
end
