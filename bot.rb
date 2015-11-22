#!/usr/local/bin/ruby
#encoding: utf-8

require 'cinch'

IRC_ENCODING='UTF-8'

plugins = [
    {
      :file => 'admins.rb',
      :name => 'Admins'
    },
    {
      :file => 'eval.rb',
      :name => 'AdminEval'
    },
    {
      :file => 'joinpart.rb',
      :name => 'JoinPart'
    },
    {
        :file => 'rss.rb',
        :name => 'Rss'
    },
    {
      :file => 'shortener.rb',
      :name => 'Gimbus'
    }
]

plugins.map{ |plugin| plugin[:file] }.each do |plugin_file_name|
  puts "Loading lib/#{ plugin_file_name }..."
  if load "lib/#{ plugin_file_name }"
    print " OK"
  else
    print " - something went wrong... Continuing."
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    # IRC Server IP
    c.server = 'irc.freenode.net'
    # If you use SSL, write like this
    c.ssl.use = false
    # IRC Server port
    c.port = '6667'
    # IRC Server Password
    # c.password = "password"
    # Channel name & password
    c.channels = ['#3lab-news']
    # bot nick name and real name
    c.nick = 'm4ciu5_97'
    c.realname = 'macius'
    c.user = 'macius'
    c.plugins.prefix = /^!/
    #c.plugins.plugins = plugins.map{ |plugin| plugin[:name]}
    c.plugins.plugins = plugins.map{ |plugin| Object.const_get(plugin[:name])  }
  end

  on :channel, /reload (.+)/ do |m, module_name|
    if load "lib/#{ module_name }.rb"
      m.reply "➥ #{ m.user.nick }: successfully reloaded #{ module_name }."
    else
      m.reply "➥ #{ m.user.nick }: could not reload #{ module_name }."
    end
  end
end

#bot.loggers.level = :log
bot.start