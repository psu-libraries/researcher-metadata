# frozen_string_literal: true

namespace :auto_merge do
  desc 'Merge all groups of duplicate publication records that can be automatically merged'
  task duplicate_pubs: :environment do
    DuplicatePublicationGroup.auto_merge
  end

  desc 'Merge all matching groups of duplicate publication records that can be automatically merged'
  task duplicate_pubs_on_doi: :environment do
    DuplicatePublicationGroup.auto_merge_matching
  end
end
