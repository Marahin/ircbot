class JoinPart
  include Cinch::Plugin
  set :help, <<-EOF
join (channel)
  tells cinch to join a (channel)
part (channel)
  tells cinch to leave a (channel)
EOF
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
