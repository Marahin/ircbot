require 'yaml'

def setup_config
  $config = YAML::load_file("#{ROOT_PATH}/config.yml")
  if $config.nil?
    raise 'There is no config file present (config.yml)!'
  end
end

def setup_variables
  $RESULT_CHARACTER = $config[:message_prefix] || '#=>'
end