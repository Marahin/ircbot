class JoinPart
  include Cinch::Plugin

  match /join (.+)/, method: :join
  match /part(?: (.+))?/, method: :part

  def join(m, channel)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( true ))
    Channel(channel).join
  end

  def part(m, channel)
    return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( true ))
    channel ||= m.channel
    Channel(channel).part if channel
  end
end
