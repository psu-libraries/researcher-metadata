# frozen_string_literal: true

namespace :doi_verification do
  task :check_all :environment do
    Publication.find_each do |pub|
      DOIVerificationJob.perform_later(pub.id)
    end
  end

  task :check_unverified :environment do
    Publication.all_pubs_needs_doi_verification.find_each do |pub|
      DOIVerificationJob.perform_later(pub.id)
    end
  end
end
