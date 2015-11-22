require 'cinch'

class AdminEval
  include Cinch::Plugin

  match /eval (.+)/, method: :admin_eval

  def check_user(user)
    user.refresh # be sure to refresh the data, or someone could steal
    # the nick

    puts "admins include? #{ user.authname }"
    puts $admins.include?(user.authname )
    $admins.include?( user.authname )
  end

  def admin_eval(m, args)
    return unless check_user( m.user )
    val = nil
    t = Thread.new{
      val = eval( args )
    }
    if t.join
      if val
        m.reply "➥ #{ val }"
      else
        m.reply "➥ nil. I'm sorry."
      end
    else
      m.reply "#{ m.user.nick }, you have done something evil, and the thread just crashed or zombie'd. Calling admins now."
      m.reply "#{ $admins.join(", ")} - PLEASE HELP."
    end
  end
end