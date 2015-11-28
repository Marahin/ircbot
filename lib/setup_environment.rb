require 'yaml'

## LOADING CONFIG ##
$config = YAML::load_file("#{ROOT_PATH}/config.yml")
if $config.nil?
  raise 'There is no config file present (config.yml)!'
end
## END OF LOADING CONFIG ##

## PLUGINS SETUP ##
$plugins = $config[:plugins]
$plugins_path = ROOT_PATH + '/' + $config[:plugins_path]

$plugins.map{ |plugin| plugin[:file] }.each do |plugin_file_name|
  print "Loading #{ $plugins_path }#{ plugin_file_name }..."
  if require "#{ $plugins_path }#{ plugin_file_name.gsub('.rb', '') }"
    print " OK\n"
  else
    print " - FAILURE. Continuing."
  end
end
## END OF PLUGINS SETUP ##

## RESULT CHARACTER ##
$RESULT_CHARACTER = $config[:message_prefix] || '#=>'
