def setup_plugins
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
end