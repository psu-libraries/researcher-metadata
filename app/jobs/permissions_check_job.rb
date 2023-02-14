# frozen_string_literal: true

class PermissionsCheckJob < ApplicationJob
  def perform(publication)
    files = ActivityInsightOaFile.where(publication_id: publication.id)
    accepted = false
    published = false
    
    files.each do |file|
      accepted = true if file.version == 'accepted'
      published = true if file.version == 'published'
    end
       
    permissions = if accepted
                    OabPermissionsService.new(publication.doi_url_path, 'acceptedVersion')
                  elsif published
                    OabPermissionsService.new(publication.doi_url_path, 'publishedVersion')
                  end
    if permissions 
      publication.set_statement = permissions.set_statement
      publication.licence = permissions.licence
      publication.embargo_date = permissions.embargo_end_date
    end 

    publication.permissions_last_checked_at = Time.current
    publication.save!
  end
end