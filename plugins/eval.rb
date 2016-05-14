class AdminEval
  include Cinch::Plugin
  require 'timeout'

  Help.add_plugin(self.name, __FILE__, "EVAL function add-on, allowing users to execute code through IRC.")
  Help.add_command(self.name,
  "eval m.reply \"it's ruby code!\"",
  "executes given ruby code. If Admins plugin is loaded, this command is only usable by Admins."
  )

  match /eval (.+)/
  def execute(m, args)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( false ))
    val = nil
    begin
      Timeout::timeout(5) do
        val = eval(args)
          if val
            m.reply "#{ $RESULT_CHARACTER } #{ val }"
          else
            m.reply "#{ $RESULT_CHARACTER } nil. I'm sorry."
          end
        # Something that should be interrupted if it takes more than 5  seconds...
      end
    rescue Timeout::Error
        m.reply "#{ $RESULT_CHARACTER } #{ m.user.nick }, you have done something evil, and the thread just crashed or zombie'd. Calling admins now."
        Object.const_defined?('Admins') ? (m.reply "#{ $RESULT_CHARACTER } #{ $admins.join(", ")} - PLEASE HELP.") : ()
    end
  end

end
