# frozen_string_literal: true

namespace :generate do
  task :journal_article_no_open_access_location, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).journal_article_no_open_access_location
  end

  task :journal_article_with_open_access_location, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).journal_article_with_open_access_location
  end

  task :journal_article_in_press, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).journal_article_in_press
  end

  task :other_work, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).other_work
  end

  task :journal_article_from_activity_insight, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).journal_article_from_activity_insight
  end

  task :journal_article_duplicate_group, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).journal_article_duplicate_group
  end

  task :journal_article_non_duplicate_group, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).journal_article_non_duplicate_group
  end

  task :presentation, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).presentation
  end

  task :performance, [:webaccess_id] => :environment do |_task, args|
    WorksGenerator.new(args[:webaccess_id]).performance
  end
end
