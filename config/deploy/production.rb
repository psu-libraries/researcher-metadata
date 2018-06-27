# Tell capistrano to use the production environment. This is key for running
# the database migrations via "cap production deploy:migrations".
set :rails_env, "production"

# The hosts that we're deploying to.
role :app, "researchweb1prod.vmhost.psu.edu"
role :web, "researchweb1prod.vmhost.psu.edu"
role :db,  "researchweb1prod.vmhost.psu.edu", primary: true
