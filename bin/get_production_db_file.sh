# Pull down db config to be parsed
DBCONFIG=$(ssh deploy@rmdweb1prod -p 1855 'cat rmd/current/config/database.yml')

# Parse values from db config locally
DBPASSWORD=$(ruby -ryaml -e "db_config = YAML::load('$DBCONFIG'); puts db_config['production']['password']")
DBUSERNAME=$(ruby -ryaml -e "db_config = YAML::load('$DBCONFIG'); puts db_config['production']['username']")
DBHOST=$(ruby -ryaml -e "db_config = YAML::load('$DBCONFIG'); puts db_config['production']['host']")
DBNAME=$(ruby -ryaml -e "db_config = YAML::load('$DBCONFIG'); puts db_config['production']['db_name']")

# Create the db dump on server
ssh deploy@rmdweb1prod -p 1855 PGPASSWORD=$DBPASSWORD \
                               PGUSER=$DBUSERNAME \
                               PGHOST=$DBHOST \
                               PGDATABASE=$DBNAME 'pg_dump --clean \
                                                           --no-owner > psql-rmd-prod-data.sql ;
                                                   gzip psql-rmd-prod-data.sql'

# Pull db dump down to local project's tmp directory
rsync -e 'ssh -p 1855' deploy@rmdweb1prod:~/psql-rmd-prod-data.sql.gz tmp/psql-rmd-prod-data.sql.gz

# Delete file on server
ssh deploy@rmdweb1prod -p 1855 'rm psql-rmd-prod-data.sql.gz'
