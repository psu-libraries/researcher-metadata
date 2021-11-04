# frozen_string_literal: true

namespace :database_data do
  # These tasks are for getting production data into local, qa, and stage environments
  # :get_prod_data_file should be run first
  # Then run :load_to_local, :load_to_qa, or :load_to_stage to load the data into
  # your local, qa, or stage environments respectively
  # These tasks should be run from the root directory of the application on your local machine

  task get_prod_data_file: :environment do
    desc 'Pull production data down as a sql.gz file and store it in the tmp directory'
    hostname = 'rmdweb1prod'

    # Pull down db config to be parsed
    db_config = YAML.safe_load(`ssh deploy@#{hostname} -p 1855 'cat rmd/current/config/database.yml'`)

    # Parse values from db config
    db_password = db_config['production']['password']
    db_username = db_config['production']['username']
    db_host = db_config['production']['host']
    db_name = db_config['production']['database']

    # Dump data into sql file and gzip
    `ssh deploy@#{hostname} -p 1855 PGPASSWORD=#{db_password} 'pg_dump --clean \
                                                                       --no-owner \
                                                                       -U #{db_username} \
                                                                       -h #{db_host} \
                                                                       -d #{db_name} > psql-rmd-prod-data.sql;
                                                               gzip psql-rmd-prod-data.sql'`

    # Pull db dump down to local application's tmp directory
    `rsync -e 'ssh -p 1855' deploy@#{hostname}:~/psql-rmd-prod-data.sql.gz #{Rails.root}/tmp/psql-rmd-prod-data.sql.gz`

    # Delete file on server
    `ssh deploy@#{hostname} -p 1855 'rm psql-rmd-prod-data.sql.gz'`
  end

  task load_to_local: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the local postgres db'
    # Get local db config
    db_config = YAML.load_file("#{Rails.root}/config/database.yml")

    # Unzip production data file
    `gunzip #{Rails.root}/tmp/psql-rmd-prod-data.sql.gz`

    # Load data into local db
    `psql #{db_config['development']['database']} < #{Rails.root}/tmp/psql-rmd-prod-data.sql`

    # Delete the production data file
    File.delete("#{Rails.root}/tmp/psql-rmd-prod-data.sql") if File.exist?("#{Rails.root}/tmp/psql-rmd-prod-data.sql")
  end

  task load_to_qa: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the qa postgres db'
    hostname = 'rmdweb1qa'

    # Pull down db config to be parsed
    db_config = YAML.safe_load(`ssh deploy@#{hostname} -p 1855 'cat rmd/current/config/database.yml'`)

    # Parse values from db config
    db_password = db_config['staging']['password']
    db_username = db_config['staging']['username']
    db_host = db_config['staging']['host']
    db_name = db_config['staging']['database']

    # Push file out to qa
    `rsync -e 'ssh -p 1855' #{Rails.root}/tmp/psql-rmd-prod-data.sql.gz deploy@#{hostname}:~/psql-rmd-prod-data.sql.gz`

    # Unzip production data file and load it into the qa postgres db
    `ssh deploy@#{hostname} -p 1855 'gunzip psql-rmd-prod-data.sql.gz'`
    `ssh deploy@#{hostname} -p 1855 PGPASSWORD=#{db_password} 'psql  -U #{db_username} \
                                                                     -h #{db_host} \
                                                                     -d #{db_name} < psql-rmd-prod-data.sql;
                                                               rm psql-rmd-prod-data.sql'`

    # Delete the production data file
    File.delete("#{Rails.root}/tmp/psql-rmd-prod-data.sql.gz") if File.exist?("#{Rails.root}/tmp/psql-rmd-prod-data.sql.gz")
  end

  task load_to_stage: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the stage postgres db'
    hostname = 'rmdweb1stage'

    # Pull down db config to be parsed
    db_config = YAML.safe_load(`ssh deploy@#{hostname} -p 1855 'cat rmd/current/config/database.yml'`)

    # Parse values from db config
    db_password = db_config['beta']['password']
    db_username = db_config['beta']['username']
    db_host = db_config['beta']['host']
    db_name = db_config['beta']['database']

    # Push file out to stage
    `rsync -e 'ssh -p 1855' #{Rails.root}/tmp/psql-rmd-prod-data.sql.gz deploy@#{hostname}:~/psql-rmd-prod-data.sql.gz`

    # Unzip production data file and load it into the stage postgres db
    `ssh deploy@#{hostname} -p 1855 'gunzip psql-rmd-prod-data.sql.gz'`
    `ssh deploy@#{hostname} -p 1855 PGPASSWORD=#{db_password} 'psql  -U #{db_username} \
                                                                     -h #{db_host} \
                                                                     -d #{db_name} < psql-rmd-prod-data.sql;
                                                               rm psql-rmd-prod-data.sql'`

    # Delete the production data file
    File.delete("#{Rails.root}/tmp/psql-rmd-prod-data.sql.gz") if File.exist?("#{Rails.root}/tmp/psql-rmd-prod-data.sql.gz")
  end
end
