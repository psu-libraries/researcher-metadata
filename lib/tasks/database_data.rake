# frozen_string_literal: true

require 'progressbar'
require 'aws-sdk-s3'
require 'tty-prompt'

namespace :database_data do
  # These tasks are for getting production data into local, qa, and stage environments
  # :get_prod_data_file should be run first
  # Then run :load_to_local, :load_to_qa, or :load_to_stage to load the data into
  # your local, qa, or stage environments respectively
  # These tasks should be run from the root directory of the application on your local machine

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
    desc 'Downloads a database dump from s3'
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

  task get_prod_data_file: :environment do
    desc 'Pull production data down as a sql.gz file and store it in the tmp directory'
    datetime = DateTime.now.to_s
    filename = "psql-rmd-prod-data-#{datetime}.sql"
    hostname = 'rmdweb1prod'

    Net::SSH.start(hostname, 'deploy', port: 1855) do |ssh|
      # Pull down db config to be parsed
      db_config = Rails.configuration.database_configuration

      # Parse values from db config
      db_password = db_config['production']['password']
      db_username = db_config['production']['username']
      db_host = db_config['production']['host']
      db_name = db_config['production']['database']

      # Dump data into sql file and gzip
      pg_prog = ProgressBar.create(total: nil, title: 'pg_dump', format: '%t |%B| %a')
      Thread.new { until pg_prog.finished? do pg_prog.increment; sleep(0.2); end }
      ssh.exec!("PGPASSWORD=#{db_password} pg_dump --clean \
                                                             --no-owner \
                                                             -U #{db_username} \
                                                             -h #{db_host} \
                                                             -d #{db_name} > #{filename}")
      pg_prog.finish

      # Gzip file
      gz_prog = ProgressBar.create(total: nil, title: 'gzip', format: '%t |%B| %a')
      Thread.new { until gz_prog.finished? do gz_prog.increment; sleep(0.2); end }
      ssh.exec!("gzip #{filename}")
      gz_prog.finish

      # Pull db dump down to local application's tmp directory
      rsync_prog = ProgressBar.create(total: nil, title: 'rsync', format: '%t |%B| %a')
      Thread.new { until rsync_prog.finished? do rsync_prog.increment; sleep(0.2); end }
      `rsync -e 'ssh -p 1855' -P deploy@#{hostname}:~/#{filename}.gz #{Rails.root}/tmp/#{filename}.gz`
      rsync_prog.finish

      # Delete file on server
      ssh.exec!("rm #{filename}.gz")
    end
  end

  task load_to_local: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the local postgres db'
    filename = File.basename(Dir["#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz"].first, '.gz')

    # Get local db config
    db_config = Rails.configuration.database_configuration

    # Unzip production data file
    `gunzip #{Rails.root}/tmp/#{filename}.gz`

    # Load data into local db
    psql_prog = ProgressBar.create(total: nil, title: 'psql', format: '%t |%B| %a')
    Thread.new { until psql_prog.finished? do psql_prog.increment; sleep(0.2); end }
    `psql #{db_config['development']['database']} < #{Rails.root}/tmp/#{filename}`
    psql_prog.finish

    # Delete the data file
    Dir.glob("#{Rails.root}/tmp/psql-rmd-prod-data-*.sql").each { |file| File.delete(file) }
  end

  task load_to_qa: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the qa postgres db'
    filename = File.basename(Dir["#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz"].first, '.gz')
    hostname = 'rmdweb1qa'

    Net::SSH.start(hostname, 'deploy', port: 1855) do |ssh|
      # Pull down db config to be parsed
      db_config = Rails.configuration.database_configuration

      # Parse values from db config
      db_password = db_config['staging']['password']
      db_username = db_config['staging']['username']
      db_host = db_config['staging']['host']
      db_name = db_config['staging']['database']

      # Push file out to qa
      rsync_prog = ProgressBar.create(total: nil, title: 'rsync', format: '%t |%B| %a')
      Thread.new { until rsync_prog.finished? do rsync_prog.increment; sleep(0.2); end }
      `rsync -e 'ssh -p 1855' #{Rails.root}/tmp/#{filename}.gz deploy@#{hostname}:~/#{filename}.gz`
      rsync_prog.finish

      # Unzip production data file and load it into the qa postgres db
      psql_prog = ProgressBar.create(total: nil, title: 'psql', format: '%t |%B| %a')
      Thread.new { until psql_prog.finished? do psql_prog.increment; sleep(0.2); end }
      ssh.exec!("gunzip #{filename}.gz")
      ssh.exec!("PGPASSWORD=#{db_password} 'psql  -U #{db_username} \
                                                            -h #{db_host} \
                                                            -d #{db_name} < #{filename};
                                                      rm #{filename}")
      psql_prog.finish
    end

    # Delete the data file
    Dir.glob("#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz").each { |file| File.delete(file) }
  end

  task load_to_stage: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the stage postgres db'
    filename = File.basename(Dir["#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz"].first, '.gz')
    hostname = 'rmdweb1stage'

    Net::SSH.start(hostname, 'deploy', port: 1855) do |ssh|
      # Pull down db config to be parsed
      db_config = Rails.configuration.database_configuration

      # Parse values from db config
      db_password = db_config['beta']['password']
      db_username = db_config['beta']['username']
      db_host = db_config['beta']['host']
      db_name = db_config['beta']['database']

      # Push file out to stage
      rsync_prog = ProgressBar.create(total: nil, title: 'rsync', format: '%t |%B| %a')
      Thread.new { until rsync_prog.finished? do rsync_prog.increment; sleep(0.2); end }
      `rsync -e 'ssh -p 1855' #{Rails.root}/tmp/#{filename}.gz deploy@#{hostname}:~/#{filename}.gz`
      rsync_prog.finish

      # Unzip production data file and load it into the stage postgres db
      psql_prog = ProgressBar.create(total: nil, title: 'psql', format: '%t |%B| %a')
      Thread.new { until psql_prog.finished? do psql_prog.increment; sleep(0.2); end }
      ssh.exec!("gunzip #{filename}.gz")
      ssh.exec!("PGPASSWORD=#{db_password} psql  -U #{db_username} \
                                                           -h #{db_host} \
                                                           -d #{db_name} < #{filename};
                                                     rm #{filename}")
      psql_prog.finish
    end

    # Delete the data file
    Dir.glob("#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz").each { |file| File.delete(file) }
  end
end
