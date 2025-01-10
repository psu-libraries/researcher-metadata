# frozen_string_literal: true

namespace :doi_verification do
  task :check_all :environment do
    Publication.find_each do |pub|
      DOIVerificationJob.perform_later(pub.id)
    end
  end

  task :check_unverified :environment do
    unverified_publications = Publication.where(:doi_verified == false || :doi_verified == nil)
    unverified_publications.find_each do |pub|
      DOIVerificationJob.perform_later(pub.id)
    end
  end
end
