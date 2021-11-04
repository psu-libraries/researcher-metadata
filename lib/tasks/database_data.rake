# frozen_string_literal: true
require 'progressbar'

namespace :database_data do
  # These tasks are for getting production data into local, qa, and stage environments
  # :get_prod_data_file should be run first
  # Then run :load_to_local, :load_to_qa, or :load_to_stage to load the data into
  # your local, qa, or stage environments respectively
  # These tasks should be run from the root directory of the application on your local machine

  task get_prod_data_file: :environment do
    desc 'Pull production data down as a sql.gz file and store it in the tmp directory'
    datetime = DateTime.now.to_s
    filename = "psql-rmd-prod-data-#{datetime}.sql"
    hostname = 'rmdweb1prod'

    Net::SSH.start(hostname, "deploy", port: 1855) do |ssh|
      # Pull down db config to be parsed
      db_config = YAML.safe_load(`ssh deploy@#{hostname} -p 1855 'cat rmd/current/config/database.yml'`)

      # Parse values from db config
      db_password = db_config['production']['password']
      db_username = db_config['production']['username']
      db_host = db_config['production']['host']
      db_name = db_config['production']['database']

      # Dump data into sql file and gzip
      pg_prog = ProgressBar.create(total: nil, title: "pg_dump", format: "%t |%B| %a")
      Thread.new { until pg_prog.finished? do pg_prog.increment; sleep(0.2); end }
      `ssh deploy@#{hostname} -p 1855 PGPASSWORD=#{db_password} 'pg_dump --clean \
                                                                         --no-owner \
                                                                         -U #{db_username} \
                                                                         -h #{db_host} \
                                                                         -d #{db_name} > #{filename}'`
      pg_prog.finish

      gz_prog = ProgressBar.create(total: nil, title: "gzip", format: "%t |%B| %a")
      Thread.new { until gz_prog.finished? do gz_prog.increment; sleep(0.2); end }
      `ssh deploy@#{hostname} -p 1855 'gzip #{filename}'`
      gz_prog.finish

      # Pull db dump down to local application's tmp directory
      rsync_prog = ProgressBar.create(total: nil, title: "rsync", format: "%t |%B| %a")
      Thread.new { until rsync_prog.finished? do rsync_prog.increment; sleep(0.2); end }
      `rsync -e 'ssh -p 1855' deploy@#{hostname}:~/#{filename}.gz #{Rails.root}/tmp/#{filename}.gz`
      rsync_prog.finish

      # Delete file on server
      `ssh deploy@#{hostname} -p 1855 'rm #{filename}.gz'`
    end
  end

  task load_to_local: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the local postgres db'
    filename = File.basename(Dir["#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz"].first, ".gz")

    # Get local db config
    db_config = YAML.load_file("#{Rails.root}/config/database.yml")

    # Unzip production data file
    `gunzip #{Rails.root}/tmp/#{filename}.gz`

    # Load data into local db
    psql_prog = ProgressBar.create(total: nil, title: "psql", format: "%t |%B| %a")
    Thread.new { until psql_prog.finished? do psql_prog.increment; sleep(0.2); end }
    `psql #{db_config['development']['database']} < #{Rails.root}/tmp/#{filename}`
    psql_prog.finish

    # Delete the data file
    Dir.glob("#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz").each { |file| File.delete(file) }
  end

  task load_to_qa: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the qa postgres db'
    filename = File.basename(Dir["#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz"].first, ".gz")
    hostname = 'rmdweb1qa'

    # Pull down db config to be parsed
    db_config = YAML.safe_load(`ssh deploy@#{hostname} -p 1855 'cat rmd/current/config/database.yml'`)

    # Parse values from db config
    db_password = db_config['staging']['password']
    db_username = db_config['staging']['username']
    db_host = db_config['staging']['host']
    db_name = db_config['staging']['database']

    # Push file out to qa
    rsync_prog = ProgressBar.create(total: nil, title: "rsync", format: "%t |%B| %a")
    Thread.new { until rsync_prog.finished? do rsync_prog.increment; sleep(0.2); end }
    `rsync -e 'ssh -p 1855' #{Rails.root}/tmp/#{filename}.gz deploy@#{hostname}:~/#{filename}.gz`
    rsync_prog.finish

    # Unzip production data file and load it into the qa postgres db
    psql_prog = ProgressBar.create(total: nil, title: "psql", format: "%t |%B| %a")
    Thread.new { until psql_prog.finished? do psql_prog.increment; sleep(0.2); end }
    `ssh deploy@#{hostname} -p 1855 'gunzip #{filename}.gz'`
    `ssh deploy@#{hostname} -p 1855 PGPASSWORD=#{db_password} 'psql  -U #{db_username} \
                                                                     -h #{db_host} \
                                                                     -d #{db_name} < #{filename};
                                                               rm #{filename}'`
    psql_prog.finish

    # Delete the data file
    Dir.glob("#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz").each { |file| File.delete(file) }
  end

  task load_to_stage: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the stage postgres db'
    filename = File.basename(Dir["#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz"].first, ".gz")
    hostname = 'rmdweb1stage'

    # Pull down db config to be parsed
    db_config = YAML.safe_load(`ssh deploy@#{hostname} -p 1855 'cat rmd/current/config/database.yml'`)

    # Parse values from db config
    db_password = db_config['beta']['password']
    db_username = db_config['beta']['username']
    db_host = db_config['beta']['host']
    db_name = db_config['beta']['database']

    # Push file out to stage
    rsync_prog = ProgressBar.create(total: nil, title: "rsync", format: "%t |%B| %a")
    Thread.new { until rsync_prog.finished? do rsync_prog.increment; sleep(0.2); end }
    `rsync -e 'ssh -p 1855' #{Rails.root}/tmp/#{filename}.gz deploy@#{hostname}:~/#{filename}.gz`
    rsync_prog.finish

    # Unzip production data file and load it into the stage postgres db
    psql_prog = ProgressBar.create(total: nil, title: "psql", format: "%t |%B| %a")
    Thread.new { until psql_prog.finished? do psql_prog.increment; sleep(0.2); end }
    `ssh deploy@#{hostname} -p 1855 'gunzip #{filename}.gz'`
    `ssh deploy@#{hostname} -p 1855 PGPASSWORD=#{db_password} 'psql  -U #{db_username} \
                                                                     -h #{db_host} \
                                                                     -d #{db_name} < #{filename};
                                                               rm #{filename}'`
    psql_prog.finish

    # Delete the data file
    Dir.glob("#{Rails.root}/tmp/psql-rmd-prod-data-*.sql.gz").each { |file| File.delete(file) }
  end
end
