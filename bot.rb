#!/usr/local/bin/ruby
#encoding: utf-8
ROOT_PATH = File.expand_path(File.dirname(__FILE__))
require 'cinch'

@bot = Cinch::Bot.new do
  require "#{ ROOT_PATH }/lib/setup_environment"
  ## BOT SETUP ##
  configure do |c|
    # IRC Server IP
    # c.server = 'irc.freenode.net'
    # due to freenodes loadbalancing being shit, setting it to static IP
    c.server = $config[:bot][:server]
    # If you use SSL, write like this
    c.ssl.use = $config[:bot][:use_ssl]
    # IRC Server port
    c.port = $config[:bot][:port]
    # IRC Server Password
    # c.password = "password"
    # Channel name & password
    c.channels = $config[:bot][:channels]
    # bot nick name and real name
    c.nick = $config[:bot][:nick]
    c.realname = $config[:bot][:realname]
    c.user = $config[:bot][:user]
    c.plugins.prefix = Regexp.new( $config[:plugins_prefix] )
    c.plugins.plugins = $plugins.map{ |plugin| Object.const_get(plugin[:name])}
    puts "Loading #{ $plugins }"
  end
  ## END OF BOT SETUP ##

  on :message, /^!unhook (.+)/ do |m, plugin|
    unhook_plugin(m, plugin)
  end
  on :message, /^!hook (.+)/ do |m, plugin|
    hook_plugin(m, plugin)
  end
  on :message, /^!reload (.+)/ do |m, plugin|
    reload_plugin(m, plugin)
  end

  helpers do
    def hook_plugin(m, plugin)
      return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( true ))
      real_plugin = $plugins.select{ |arr_plug| arr_plug[:name] == plugin }
      real_plugin = real_plugin.length > 0 ? ( real_plugin[0] ) : ( nil )
      if real_plugin.nil?
        m.reply "#{ $RESULT_CHARACTER } Cannot find #{ plugin }"
        raise
      else
        plugin = real_plugin
      end
      mapping ||= plugin[:file].gsub(/(.)([A-Z])/) { |_|
        $1 + "_" + $2
      }.downcase # we downcase here to also catch the first letter
      file_name = "#{$plugins_path}#{mapping}"
      unless File.exist?(file_name)
        m.reply "#{ $RESULT_CHARACTER }Could not load #{plugin[:name]} because #{file_name} does not exist."
        return
      end
      begin
        load(file_name)
      rescue
        m.reply "#{ $RESULT_CHARACTER }Could not load #{plugin[:name]}."
        raise
      end
      begin
        const = Object.const_get(plugin[:name])
      rescue NameError
        m.reply "#{ $RESULT_CHARACTER }Could not load #{plugin[:name]} because no matching class was found."
        return
      end
      @bot.plugins.register_plugin(const)
      m.reply "#{ $RESULT_CHARACTER }Successfully loaded #{plugin[:name]}"
    end

    def unhook_plugin(m, plugin )
      return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( true ))
      begin
        plugin_class = Object.const_get(plugin)
      rescue NameError
        m.reply "#{ $RESULT_CHARACTER } Could not unload #{plugin} because no matching class was found."
        return
      end

      @bot.plugins.select {|p| p.class == plugin_class}.each do |p|
        @bot.plugins.unregister_plugin(p)
      end

      plugin_class.hooks.clear
      plugin_class.matchers.clear
      plugin_class.listeners.clear
      plugin_class.timers.clear
      plugin_class.ctcps.clear
      plugin_class.react_on = :message
      plugin_class.plugin_name = nil
      plugin_class.help = nil
      plugin_class.prefix = nil
      plugin_class.suffix = nil
      plugin_class.required_options.clear

      m.reply "#{ $RESULT_CHARACTER }Successfully unloaded #{plugin}"

    end

    def reload_plugin(m, plugin )
      return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( true ))
      if unhook_plugin(m, plugin)
        hook_plugin(m, plugin)
      end
    end
  end
end

#macius.loggers.level = :log
@bot.start
