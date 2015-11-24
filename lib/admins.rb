class Admins
  include Cinch::Plugin

  $admins = ['marahin']
  match /admins/

  def execute( m )
    m.reply "#{ m.user.nick }, currently admins are: #{ $admins.join(", ") }"
  end

  def self.check_user( user )
    if not $admins.nil?
      puts "Checking if #{ user.authname } exists in admins array... #{ $admins }"
      puts "#{ $admins.include?( user.authname ) }"
      $admins.include?( user.authname )
    else
      false
    end
  end
end
