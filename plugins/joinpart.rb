class JoinPart
  include Cinch::Plugin

  Help.add_plugin(self.name, __FILE__, "Joining / Leaving channels plugin.")
  Help.add_command(self.name, "join #channel",
  "tells the bot to join a channel. If Admins plugin is loaded, this command is only usable by privileged users."
  )
  Help.add_command(self.name, "part #channel",
  "tells the bot to leave a channel. If Admins plugin is loaded, this command is only usable by privileged users."
  )

  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part

  def join(m, channel)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( false ))
    Channel(channel).join
  end

  def part(m, channel)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( false ))
    channel ||= m.channel
    Channel(channel).part if channel
  end
end
