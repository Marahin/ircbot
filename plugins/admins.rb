class Admins
  include Cinch::Plugin

  $admins = ['marahin']
  match /admins/

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
