# frozen_string_literal: true

require_relative '../utilities/works_generator'

namespace :generate do
  task :oa_publication_no_open_access_location, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).oa_publication_no_open_access_location
  end

  task :oa_publication_with_open_access_location, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).oa_publication_with_open_access_location
  end

  task :oa_publication_in_press, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).oa_publication_in_press
  end

  task :other_work, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).other_work
  end

  task :oa_publication_from_activity_insight, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).oa_publication_from_activity_insight
  end

  task :oa_publication_duplicate_group, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).oa_publication_duplicate_group
  end

  task :oa_publication_non_duplicate_group, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).oa_publication_non_duplicate_group
  end

  task :presentation, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).presentation
  end

  task :performance, [:webaccess_id] => :environment do |_task, args|
    Utilities::WorksGenerator.new(args[:webaccess_id]).performance
  end
end
