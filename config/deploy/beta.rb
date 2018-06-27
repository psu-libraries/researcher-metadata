# Tell capistrano to use the beta environment. This is key for running
# the database migrations via "cap beta deploy:migrations".
set :rails_env, "beta"

# The hosts that we're deploying to.
role :app, "researchweb1stage.vmhost.psu.edu"
role :web, "researchweb1stage.vmhost.psu.edu"
role :db,  "researchweb1stage.vmhost.psu.edu", primary: true
