# frozen_string_literal: true

class FilePermissionsCheckJob < ApplicationJob
  queue_as 'default'

  def perform(file_id)
    file = ActivityInsightOAFile.find(file_id)
    permissions = OABPermissionsService.new(file.doi_url_path, file.version)

    file.license = permissions.licence
    file.set_statement = permissions.set_statement
    file.embargo_date = permissions.embargo_end_date
    file.save!
  end
end
