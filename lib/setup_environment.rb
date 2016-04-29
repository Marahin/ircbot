require 'rubygems'

Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
  require file if file != __FILE__
end

# get the config file
setup_config

# set basic variables and constants
setup_variables

# load plugins enabled in config
setup_plugins


# array of plugins that support HelpObj

# help class


# RUNNING SETUP METHODS #


