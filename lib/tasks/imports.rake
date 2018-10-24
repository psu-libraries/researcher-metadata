namespace :import do
  desc 'Import Activity Insight users'
  task :ai_users, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_users)
    )
    ActivityInsightUserImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight contracts'
  task :ai_contracts, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_contracts)
    )
    ActivityInsightContractImporter.new(filename: args.filename).call
  end

  desc 'Import PSU RSS news feed items'
  task :rss_news => :environment do
    NewsFeedItemImporter.new().call
  end

  desc 'Import Activity Insight publications'
  task :ai_publications, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_publications)
    )
    ActivityInsightPublicationImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight authorships'
  task :ai_authorships, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_authorships)
    )
    ActivityInsightAuthorshipImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight contributors'
  task :ai_contributors, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_authorships)
    )
    ActivityInsightContributorImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight presentations'
  task :ai_presentations, [:filename] => :environment do |_task, args|
    args.with_defaults(filename: filename_for(:ai_presentations))
    ActivityInsightPresentationImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight presenters'
  task :ai_presenters, [:filename] => :environment do |_task, args|
    args.with_defaults(filename: filename_for(:ai_presenters))
    ActivityInsightPresenterImporter.new(filename: args.filename).call
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

  desc 'Import all data'
  #TODO Update this task with the correct order of dependencies
  task :all => :environment do
    PureUserImporter.new(
      filename: filename_for(:pure_users)
    ).call

    PurePublicationImporter.new(
      dirname: dirname_for(:pure_publications)
    ).call

    PurePublicationTagImporter.new(
      filename: filename_for(:pure_publication_tags)
    ).call

    ActivityInsightUserImporter.new(
      filename: filename_for(:ai_users)
    ).call

    ActivityInsightPublicationImporter.new(
      filename: filename_for(:ai_publications)
    ).call

    ActivityInsightAuthorshipImporter.new(
      filename: filename_for(:ai_authorships)
    ).call

    ActivityInsightContributorImporter.new(
      filename: filename_for(:ai_authorships)
    ).call
  end
end

def filename_for(key)
  case key
  when :pure_users then Rails.root.join('db/data/pure_users.json')
  when :pure_organizations then Rails.root.join('db/data/pure_organizations.json')
  when :pure_publication_tags then Rails.root.join('db/data/pure_publication_fingerprints.json')
  when :ai_users then Rails.root.join('db/data/ai_users.csv')
  when :ai_publications then Rails.root.join('db/data/ai_publications.csv')
  when :ai_authorships then Rails.root.join('db/data/ai_authorships.csv')
  when :etds then Rails.root.join('db/data/etds.csv')
  when :committees then Rails.root.join('db/data/committees.csv')
  when :ai_contracts then Rails.root.join('db/data/ai_contracts.csv')
  when :ai_presentations then Rails.root.join('db/data/ai_presentations.csv')
  when :ai_presenters then Rails.root.join('db/data/ai_presenters.csv')
  end
end

def dirname_for(key)
  case key
  when :pure_publications then Rails.root.join('db/data/pure_publications')
  end
end
