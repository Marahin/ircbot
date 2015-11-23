class AdminEval
  include Cinch::Plugin

  match /eval (.+)/, method: :admin_eval



  def admin_eval(m, args)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( true ))
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