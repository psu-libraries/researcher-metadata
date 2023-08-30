# frozen_string_literal: true

require 'progressbar'
require 'aws-sdk-s3'
require 'tty-prompt'

namespace :database_data do
  # These tasks are for getting production data into local environments
  # download_from_s3 expects an AWS environment setup
  # For PSU aws, the following command should get you there (given you've configured aws sso)
  # eval "$(aws configure export-credentials --format env)"

  def download_from_s3
    bucket = ENV.fetch('AWS_BUCKET', 'edu.psu.libraries.devteam.rmd-backup')
    prefix = ENV.fetch('DB_PREFIX', 'db')
    prompt = TTY::Prompt.new
    client = Aws::S3::Client.new

    download_prog = ProgressBar.create(total: nil, title: 'download', format: '%t |%B| %a')
    objects = client.list_objects({ bucket: bucket, prefix: prefix }).contents.reverse
    options = objects.map(&:key)
    key = prompt.select('Choose your File', options)
    filename = "#{Rails.root}/tmp/#{File.basename(key)}"
    Thread.new { until download_prog.finished? do download_prog.increment; sleep(0.2); end }
    client.get_object(response_target: filename, bucket: bucket, key: key)
    download_prog.finish
    puts "database downloaded to #{filename}"
    filename
  end

  task download_from_s3: :environment do
    desc 'Downloads a database dump from S3'
    download_from_s3
  end

  task :load_from_backup, [:dump_file] => :environment do |_t, args|
    desc 'Loads a database backup into the development environment'
    filename = args[:dump_file]
    db_config = Rails.configuration.database_configuration

    filename ||= download_from_s3

    # pg_restore expects these environment variables
    ENV['PGHOST'] = db_config['development']['host']
    ENV['PGUSER'] = db_config['development']['username']
    ENV['PGPASSWORD'] = db_config['development']['password']
    ENV['PG_DATABASE'] = db_config['development']['database']

    # Remove any active connections to the database before purging
    begin
      ActiveRecord::Base.connection.execute <<-SQL.squish
      SELECT pg_terminate_backend(pg_stat_activity.pid)
      FROM pg_stat_activity
      WHERE pg_stat_activity.datname = '#{db_config['development']['database']}';
      SQL
    rescue ActiveRecord::StatementInvalid
      puts 'All connections killed.'
    end

    ActiveRecord::Tasks::DatabaseTasks.purge_current

    psql_prog = ProgressBar.create(total: nil, title: 'restore', format: '%t |%B| %a')
    Thread.new { until psql_prog.finished? do psql_prog.increment; sleep(0.2); end }
    `pg_restore --no-owner --no-acl --dbname #{db_config['development']['database']} #{filename}`
    psql_prog.finish

    # Catch up on any migrations
    ActiveRecord::Tasks::DatabaseTasks.migrate
  end
end
