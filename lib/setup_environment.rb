require 'yaml'
require 'rubygems'
require 'sqlite3'



# END OF RUNNING SETUP METHODS #

# METHODS #

def setup_variables
  $RESULT_CHARACTER = $config[:message_prefix] || '#=>'
  $db = Storage.new
end

def setup_config
  $config = YAML::load_file("#{ROOT_PATH}/config.yml")
  if $config.nil?
    raise 'There is no config file present (config.yml)!'
  end
end
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

# database class
class Storage
  def initialize
    @db = SQLite3::Database.open( 'db/bot.db' )
  end
  def create(table)
    begin
      @db.execute( %{
      CREATE TABLE #{table}
      (key varchar(100) PRIMARY KEY,
      value varchar(1000))
    } )
    rescue SQLite3::SQLException => details
      puts details
    end
  end
  def use(table)
    @table = table
    self.create( table )
    return self
  end
  def get(key)
    results = @db.get_first_row( %{
      SELECT value FROM #{@table} WHERE key='#{key}'
    } )
    if results
      return results[0]
    end
  end
  def set(key, val)
    result = @db.execute( %{
      REPLACE INTO %s
      (key, value)
      VALUES ('%s', '%s')
    } % [@table, key, val ] )
  end
end

#module for threaded .each method
module MultithreadedEach
  def multithreaded_each
    each_with_object([]) do |item, threads|
      threads << Thread.new { yield item }
    end.each { |thread| thread.join }
    self
  end
end

# RUNNING SETUP METHODS #

setup_config

setup_variables

setup_plugins
