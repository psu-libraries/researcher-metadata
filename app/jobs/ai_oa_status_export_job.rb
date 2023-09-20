# frozen_string_literal: true

class AiOAStatusExportJob < ApplicationJob
  def perform(target)
    files = ActivityInsightOAFile.send_oa_status_to_activity_insight
    ActivityInsightOAStatusExporter.new(files, target).export
  end
end
  