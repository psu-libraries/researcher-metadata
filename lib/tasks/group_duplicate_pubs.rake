desc 'Detect and group duplicate publication records'
task :group_duplicate_pubs do
  DuplicatePublicationGroup.group_duplicates
end
