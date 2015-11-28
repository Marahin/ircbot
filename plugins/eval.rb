class AdminEval
  include Cinch::Plugin
  
  set :help, <<-EOF
eval <code>
  tells cinch to process some <code> and return a value
EOF
  
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