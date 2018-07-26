namespace :import do
  desc 'Import Activity Insight users'
  task :ai_users, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:ai_users)
    )
    ActivityInsightUserImporter.new(filename: args.filename).call
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

  desc 'Import Pure Users'
  task :pure_users, [:filename] => :environment do |_task, args|
    args.with_defaults(
      filename: filename_for(:pure_users)
    )
    PureUserImporter.new(filename: args.filename).call
  end

# desc 'Import Pure publications'
# task :pure_publications, [:filename] => :environment do |_task, args|
#   args.with_defaults(
#     filename: filename_for(:pure_publications)
#   )
#   PurePublicationImporter.new(filename: filename).call
# end

  desc 'Import all data'
  task :all => :environment do
    PureUserImporter.new(
      filename: filename_for(:pure_users)
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
  when :ai_users then Rails.root.join('db/data/ai_users.csv')
  when :ai_publications then Rails.root.join('db/data/ai_publications.csv')
  when :ai_authorships then Rails.root.join('db/data/ai_authorships.csv')
  end
end
