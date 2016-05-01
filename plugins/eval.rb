class AdminEval
  include Cinch::Plugin

  Help.add_plugin(self.name, __FILE__, "EVAL function add-on, allowing users to execute code through IRC.")
  Help.add_command(self.name,
  "eval m.reply \"it's ruby code!\"",
  "executes given ruby code. If Admins plugin is loaded, this command is only usable by Admins."
  )

  match /eval (.+)/
  def execute(m, args)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( false ))
    val = nil
    t = Thread.new{
      val = eval( args )
    }
    if t.join
      if val
        m.reply "#{ $RESULT_CHARACTER } #{ val }"
      else
        m.reply "#{ $RESULT_CHARACTER } nil. I'm sorry."
      end
    else
      m.reply "#{ $RESULT_CHARACTER } #{ m.user.nick }, you have done something evil, and the thread just crashed or zombie'd. Calling admins now."
      Object.const_defined?('Admins') ? (m.reply "#{ $RESULT_CHARACTER } #{ $admins.join(", ")} - PLEASE HELP.") : ()
    end
  end

end
