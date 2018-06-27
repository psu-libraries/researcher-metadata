# Tell capistrano to use the staging environment. This is key for running
# the database migrations via "cap staging deploy:migrations".
set :rails_env, "staging"

# The hosts that we're deploying to.
role :app, "researchweb1qa.vmhost.psu.edu"
role :web, "researchweb1qa.vmhost.psu.edu"
role :db,  "researchweb1qa.vmhost.psu.edu", primary: true
