# frozen_string_literal: true

class PublicationDownloadJob < ApplicationJob
  queue_as 'default'

  def perform(file_id)
    file = ActivityInsightOAFile.find(file_id)

    Net::HTTP.start(ActivityInsightOAFile::S3_AUTHORIZER_HOST_NAME, use_ssl: true) do |http|
      request = Net::HTTP::Get.new file.download_uri
      request['X-API-Key'] = Settings.activity_insight_s3_authorizer.api_key

      http.request request do |response|
        if response.code == '200'
          unless File.directory?(file.file_download_location.store_dir)
            FileUtils.mkdir_p(file.file_download_location.store_dir)
          end
          File.open(file.file_download_location.store_dir.join(file.download_filename), 'w:ASCII-8BIT') do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end

          file.update_download_location
        else
          Rails.logger.error "#{response.code}: #{response.message}"
        end
      end
    end
  end
end
