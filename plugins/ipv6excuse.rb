class ipv6Excuse
  include Cinch::Plugin
  require 'open-uri'
  
  Help.add_plugin(self.name, __FILE__, "IPv6Excuse plugin, fetching another excuse for not implementing IPV6 from ipv6excuse.com")
  Help.add_command(self.name,
  "ipv6",
  "fetches another excuse from IPv6Excuse.com."
  )

  match /ipv6 (.+)/
  def execute(m, args)
    # dirty but simple stuff
    # as the response doesn't (or **shouldn't** change), and is in
    # according format: ">We don't have a lab to test it</"
    # we just print out 1..s.length-2
    excuse = open('http://ipv6excuses.com/').read().split('h1')[1]
    # TODO: it should also take care of links inside. To-be-done soon. 
    m.reply "Delivering IPV6 excuse: #{ excuse[1..excuse.length-4 }"
  end

end
