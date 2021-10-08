# frozen_string_literal: true

# Tell capistrano to use the beta environment. This is key for running
# the database migrations via "cap beta deploy:migrations".
set :rails_env, 'beta'

# The hosts that we're deploying to.
role :app, 'rmdweb1stage.vmhost.psu.edu'
role :web, 'rmdweb1stage.vmhost.psu.edu'
role :db,  'rmdweb1stage.vmhost.psu.edu', primary: true
