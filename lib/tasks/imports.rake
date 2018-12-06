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

  desc 'Import Activity Insight performances'
  task :ai_performances, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_performances)
    )
    ActivityInsightPerformanceImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight performance contributors from file 1'
  task :ai_performance_contributors1, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_performance_contributors1),
    )
    ActivityInsightPerformanceContributorsImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight performance contributors from file 2'
  task :ai_performance_contributors2, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_performance_contributors2)
    )
    ActivityInsightPerformanceContributorsImporter.new(filename: args.filename).call
  end

  desc 'Import Activity Insight performance screenings'
  task :ai_performance_screenings, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_performance_screenings)
    )
    ActivityInsightPerformanceScreeningImporter.new(filename: args.filename).call
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
  task :all => :environment do
    PureOrganizationsImporter.new(
      filename: filename_for(:pure_organizations)
    ).call

    ActivityInsightUserImporter.new(
      filename: filename_for(:ai_users)
    ).call
    
    PureUserImporter.new(
      filename: filename_for(:pure_users)
    ).call

    PurePublicationImporter.new(
      dirname: dirname_for(:pure_publications)
    ).call

    PurePublicationTagImporter.new(
      filename: filename_for(:pure_publication_tags)
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

    ActivityInsightContractImporter.new(
      filename: filename_for(:ai_contracts)
    ).call

    ActivityInsightPresentationImporter.new(
      filename: filename_for(:ai_presentations)
    ).call

    ActivityInsightPresenterImporter.new(
      filename: filename_for(:ai_presenters)
    ).call

    ActivityInsightPerformanceImporter.new(
      filename: filename_for(:ai_performances)
    ).call

    ActivityInsightPerformanceContributorsImporter.new(
      filename: filename_for(:ai_performance_contributors1)
    ).call

    ActivityInsightPerformanceContributorsImporter.new(
      filename: filename_for(:ai_performance_contributors2)

    ActivityInsightPerformanceScreeningImporter.new(
      filename: filename_for(:ai_performance_screenings)
    ).call

    ETDCSVImporter.new(
      filename: filename_for(:etds)
    ).call

    CommitteeImporter.new(
      filename: filename_for(:committees)
    ).call

    NewsFeedItemImporter.new().call

    DuplicatePublicationGroup.group_duplicates
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
  when :ai_performances then Rails.root.join('db/data/ai_performances.csv')
  when :ai_performance_contributors1 then Rails.root.join('db/data/ai_performance_contributors1.csv')
  when :ai_performance_contributors2 then Rails.root.join('db/data/ai_performance_contributors2.csv')
  when :ai_performance_screenings then Rails.root.join('db/data/ai_performance_screenings.csv')
  end
end

def dirname_for(key)
  case key
  when :pure_publications then Rails.root.join('db/data/pure_publications')
  end
end
