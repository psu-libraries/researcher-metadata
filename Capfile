load 'deploy'         # The default tasks that come with capistrano
load 'deploy/assets'  # Precompile rails assets during deployment
load 'config/deploy'  # Our custom deployment recipe
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r } # Our custom tasks