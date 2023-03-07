# frozen_string_literal: true

class PublicationDownloadJob < ApplicationJob
  queue_as 'default'

  def perform(file_id)
    file = ActivityInsightOAFile.find(file_id)

    remote_file = File.popen("wget -q --header 'X-API-Key: #{Settings.activity_insight_s3_authorizer.api_key}' -O - 'ai-s3-authorizer.k8s.libraries.psu.edu/api/v1/#{file.location}'")
    sleep(1) until remote_file.size.positive?
    file.file_download_location = FileIO.new(remote_file, file.location.split('/').last)
    file.save!
  end
end
