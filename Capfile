# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Troubleshoot connection problems
require 'capistrano/ssh_doctor'

# Install default ruby bundle options
require 'capistrano/bundler'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
