
# database class
=begin
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
=end