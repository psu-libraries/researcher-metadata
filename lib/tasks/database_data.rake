# frozen_string_literal: true

namespace :database_data do
  task get_prod_data_file: :environment do
    desc 'Pull production data down as a sql.gz file and store it in the tmp directory'

    # Pull down db config to be parsed
    db_config = YAML.load(`ssh deploy@rmdweb1prod -p 1855 'cat rmd/current/config/database.yml'`)

    # Parse values from db config locally
    db_password = db_config['production']['password']
    db_username = db_config['production']['username']
    db_host = db_config['production']['host']
    db_name = db_config['production']['database']

    # Dump data into sql file and gzip
    `ssh deploy@rmdweb1prod -p 1855 PGPASSWORD=#{db_password} \
                                    PGUSER=#{db_username} \
                                    PGHOST=#{db_host} \
                                    PGDATABASE=#{db_name} 'pg_dump --clean \
                                                                   --no-owner > psql-rmd-prod-data.sql ;
                                                           gzip psql-rmd-prod-data.sql'`

    # Pull db dump down to local application's tmp directory
    `rsync -e 'ssh -p 1855' deploy@rmdweb1prod:~/psql-rmd-prod-data.sql.gz #{Rails.root}/tmp/psql-rmd-prod-data.sql.gz`

    # Delete file on server
    `ssh deploy@rmdweb1prod -p 1855 'rm psql-rmd-prod-data.sql.gz'`
  end

  task load_to_local: :environment do
    desc 'Load the gzipped sql file in the tmp directory into the local postgres db'
    db_config = YAML.load_file("#{Rails.root}/config/database.yml")

    `gunzip #{Rails.root}/tmp/psql-rmd-prod-data.sql.gz`

    `psql #{db_config['development']['database']} < #{Rails.root}/tmp/psql-rmd-prod-data.sql`

    # File.delete("#{Rails.root}/tmp/psql-rmd-prod-data.sql") if File.exist?("#{Rails.root}/tmp/psql-rmd-prod-data.sql")
  end
end
