# frozen_string_literal: true

desc 'Merge all groups of duplicate publication records that can be automatically merged'
task auto_merge_duplicate_pubs: :environment do
  DuplicatePublicationGroup.auto_merge
end

desc 'Merge all groups of duplicate publication records that can be automatically merged on doi'
task auto_merge_duplicate_pubs_on_doi: :environment do
  DuplicatePublicationGroup.auto_merge_on_doi
end
