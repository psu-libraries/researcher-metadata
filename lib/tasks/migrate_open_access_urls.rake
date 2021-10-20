# frozen_string_literal: true

desc 'Migrate open access URLs from old data model to new data model'
task migrate_open_access_urls: :environment do
  OpenAccessUrlsMigrationService.call
end
