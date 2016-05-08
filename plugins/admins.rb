class Admins
  include Cinch::Plugin

  $admins = ['marahin']
  match /admins/

  Help.add_plugin(self.name, __FILE__, "User privilege plugin to maintain various commands.")
  Help.add_command(self.name, "admins", "lists all admins")

  def execute( m )
    m.reply "#{ $RESULT_CHARACTER } #{ m.user.nick }, currently admins are: #{ $admins.join(", ") }"
  end

  def self.check_user( user )
    if not $admins.nil?
      $admins.include?( user.authname )
    else
      false
    end
  end
end
