desc 'Merge all groups of duplicate publication records that can be automatically merged'
task auto_merge_duplicate_pubs: :environment do
  DuplicatePublicationGroup.auto_merge
end
