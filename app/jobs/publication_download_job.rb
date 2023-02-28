# frozen_string_literal: true

class PublicationDownloadJob < ApplicationJob
    queue_as 'default'
  
    def perform(file_id)
      file = ActivityInsightOAFile.find(file_id)
      
      #download file
      #file.location is current s3 location
      #file.file is where we want to store new location
      #will need API key
      IO.popen("wget -O - https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTeFukJU2K-x1eMK9tROH9rFC8UWTE6pE-Jjw&usqp=CAU > /dev/null") {|file| puts file.read}
    end
  end