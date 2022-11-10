# frozen_string_literal: true

namespace :import do
  desc 'Import all Activity Insight data from API'
  task activity_insight: :environment do
    ActivityInsightImporter.new.call
  end

  desc 'Import Web of Science data from local files'
  task web_of_science: :environment do
    dirname = if Rails.env.development?
                Pathname.new('/Volumes/WA_ext_HD/web_of_science_data/import')
              else
                Rails.root.join('db/data/wos')
              end
    WebOfScienceFileImporter.new(dirname: dirname).call
  end

  desc 'Import NSF grant data from local files'
  task :nsf_grants, [:dirname] => :environment do |_task, args|
    args.with_defaults(
      dirname: dirname_for(:nsf_grants)
    )
    NSFGrantImporter.new(dirname: args.dirname).call
  end

  desc 'Import Open Access Button publication URLs'
  task open_access_button: :environment do
    OpenAccessButtonPublicationImporter.new.import_all
  end

  desc 'Import Open Access Button publication URLs for publications that have not been checked before'
  task new_open_access_button: :environment do
    OpenAccessButtonPublicationImporter.new.import_new
  end

  desc 'Import Open Access Button publication URLs for publications that have a DOI'
  task with_doi_open_access_button: :environment do
    OpenAccessButtonPublicationImporter.new.import_with_doi
  end

  desc 'Import Open Access Button publication URLs for publications that do not have a DOI'
  task without_doi_open_access_button: :environment do
    OpenAccessButtonPublicationImporter.new.import_without_doi
  end

  desc 'Import Unpaywall publication metadata'
  task unpaywall: :environment do
    UnpaywallPublicationImporter.new.import_all
  end

  desc 'Import Unpaywall publication metadata for publications that have not been checked before'
  task new_unpaywall: :environment do
    UnpaywallPublicationImporter.new.import_new
  end

  desc 'Import ScholarSphere publication URLs'
  task scholarsphere: :environment do
    ScholarsphereImporter.new.call
  end

  desc 'Import PSU RSS news feed items'
  task rss_news: :environment do
    NewsFeedItemImporter.new.call
  end

  desc 'Import Pure Users'
  task pure_users: :environment do
    PureUserImporter.new.call
  end

  desc 'Import Pure Organizations'
  task pure_organizations: :environment do
    PureOrganizationsImporter.new.call
  end

  desc 'Import Pure publications'
  task pure_publications: :environment do
    PurePublicationImporter.new.call
  end

  desc 'Import Pure publication tags'
  task pure_publication_tags: :environment do
    PurePublicationTagImporter.new.call
  end

  desc 'Import ETDs'
  task :etds, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:etds)
    )
    ETDCSVImporter.new(filename: args.filename).call
  end

  desc 'Import Committees'
  task :committees, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:committees)
    )
    CommitteeImporter.new(filename: args.filename).call
  end

  desc 'Import user data from LDAP'
  task ldap: :environment do
    LDAPImporter.new.call
  end

  desc 'Import PSU identity data'
  task psu_identity: :environment do
    PsuIdentityImporter.new.call
  end

  desc 'Import publication data from Penn State Law School OAI repositories'
  task law_school_publications: :environment do
    PSULawSchoolPublicationImporter.new.call
    PSUDickinsonPublicationImporter.new.call
  end

  desc 'Import Pure publishers'
  task pure_publishers: :environment do
    PurePublishersImporter.new.call
  end

  desc 'Import Pure journals'
  task pure_journals: :environment do
    PureJournalsImporter.new.call
  end

  desc 'Import all Pure data from API'
  task pure: :environment do
    PureOrganizationsImporter.new.call
    PureUserImporter.new.call
    PurePublishersImporter.new.call
    PureJournalsImporter.new.call
    PurePublicationImporter.new.call
    PurePublicationTagImporter.new.call
  end

  desc 'Import all data'
  task all: :environment do
    PureOrganizationsImporter.new.call
    ActivityInsightImporter.new.call
    PureUserImporter.new.call
    PurePublishersImporter.new.call
    PureJournalsImporter.new.call
    PurePublicationImporter.new.call
    PurePublicationTagImporter.new.call

    ETDCSVImporter.new(
      filename: filename_for(:etds)
    ).call

    CommitteeImporter.new(
      filename: filename_for(:committees)
    ).call

    NSFGrantImporter.new(
      dirname: dirname_for(:nsf_grants)
    ).call

    OpenAccessButtonPublicationImporter.new.import_all
    UnpaywallPublicationImporter.new.import_all
    ScholarsphereImporter.new.call
  end
end

def filename_for(key)
  case key
  when :etds then Rails.root.join('db/data/etds.csv')
  when :committees then Rails.root.join('db/data/committees.csv')
  end
end

def dirname_for(key)
  case key
  when :nsf_grants then Rails.root.join('db/data/nsf_grants')
  end
end
