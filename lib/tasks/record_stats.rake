# frozen_string_literal: true

desc 'Record current metadata statistics'
task record_stats: :environment do
  StatisticsSnapshot.record
end
