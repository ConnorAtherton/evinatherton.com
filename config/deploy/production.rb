server 'connoratherton.com', user: 'connor', roles: %w{app}

set :ssh_options, {
  forward_agent: true
}
