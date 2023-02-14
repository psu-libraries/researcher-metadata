# frozen_string_literal: true

class PermissionsCheckJob < ApplicationJob
  def perform(publication)
    files = ActivityInsightOaFile.where(publication_id: publication.id)
    files.each do |file|
        #need file version from other ticket, replace file.version with whatever it's called
      permissions = OabPermissionsService.new(publication.doi_url_path, 'acceptedVersion')
      if permissions #possibly if file.version instead & move service to if block, depends if file.version can ever be nil?
        byebug
        publication.set_statement = permissions.set_statement
        publication.licence = permissions.licence
        publication.embargo_date = permissions.embargo_end_date
        break
      end
    rescue StandardError
    end

    publication.permissions_last_checked_at = Time.current
    publication.save!
  end
end