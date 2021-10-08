# frozen_string_literal: true

desc 'Detect and group duplicate publication records'
task group_duplicate_pubs: :environment do
  DuplicatePublicationGroup.group_duplicates
end
