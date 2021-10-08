# frozen_string_literal: true

# Tell capistrano to use the staging environment. This is key for running
# the database migrations via "cap staging deploy:migrations".
set :rails_env, 'staging'

# The hosts that we're deploying to.
role :app, 'rmdweb1qa.vmhost.psu.edu'
role :web, 'rmdweb1qa.vmhost.psu.edu'
role :db,  'rmdweb1qa.vmhost.psu.edu', primary: true
