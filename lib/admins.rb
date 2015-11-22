require 'cinch'

class Admins
  include Cinch::Plugin

  $admins = ['marahin']
  match /admins/

  def execute( m )
    m.reply "#{ m.user.nick }, currently admins are: #{ $admins.join(", ") }"
  end
end
