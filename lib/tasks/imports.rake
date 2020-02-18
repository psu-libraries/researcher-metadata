namespace :import do
  desc 'Import all Activity Insight data from API'
  task :activity_insight => :environment do
    ActivityInsightImporter.new.call
  end

  desc 'Import Web of Science data from local files'
  task :web_of_science => :environment do
    if Rails.env.development?
      dirname = Pathname.new('/Volumes/WA_ext_HD/web_of_science_data/import')
    else
      dirname = Rails.root.join('db/data/wos')
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
  task :open_access_button => :environment do
    OpenAccessButtonPublicationImporter.new.call
  end

  desc 'Import PSU RSS news feed items'
  task :rss_news => :environment do
    NewsFeedItemImporter.new().call
  end

  desc 'Import Pure Users'
  task :pure_users, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:pure_users)
    )
    PureUserImporter.new(filename: args.filename).call
  end

  desc 'Import Pure Organizations'
  task :pure_organizations, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:pure_organizations)
    )
    PureOrganizationsImporter.new(filename: args.filename).call
  end

  desc 'Import Pure publications'
  task :pure_publications, [:dirname] => :environment do |_task, args|
    args.with_defaults(
      dirname: dirname_for(:pure_publications)
    )
    PurePublicationImporter.new(dirname: args.dirname).call
  end

  desc 'Import Pure publication tags'
  task :pure_publication_tags, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:pure_publication_tags)
    )
    PurePublicationTagImporter.new(filename: args.filename).call
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
  task :ldap => :environment do
    LDAPImporter.new.call
  end

  desc 'Import all data'
  task :all => :environment do
    PureOrganizationsImporter.new(
      filename: filename_for(:pure_organizations)
    ).call

    ActivityInsightImporter.new.call
    
    PureUserImporter.new(
      filename: filename_for(:pure_users)
    ).call

    PurePublicationImporter.new(
      dirname: dirname_for(:pure_publications)
    ).call

    PurePublicationTagImporter.new(
      filename: filename_for(:pure_publication_tags)
    ).call

    ETDCSVImporter.new(
      filename: filename_for(:etds)
    ).call

    CommitteeImporter.new(
      filename: filename_for(:committees)
    ).call

    NSFGrantImporter.new(
      dirname: dirname_for(:nsf_grants)
    ).call

    OpenAccessButtonPublicationImporter.new.call
  end
end

def filename_for(key)
  case key
  when :pure_users then Rails.root.join('db/data/pure_users.json')
  when :pure_organizations then Rails.root.join('db/data/pure_organizations.json')
  when :pure_publication_tags then Rails.root.join('db/data/pure_publication_fingerprints.json')
  when :etds then Rails.root.join('db/data/etds.csv')
  when :committees then Rails.root.join('db/data/committees.csv')
  end
end

def dirname_for(key)
  case key
  when :pure_publications then Rails.root.join('db/data/pure_publications')
  when :nsf_grants then Rails.root.join('db/data/nsf_grants')
  end
end
