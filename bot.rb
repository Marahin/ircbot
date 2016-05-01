#!/usr/local/bin/ruby
#encoding: utf-8
ROOT_PATH = File.expand_path(File.dirname(__FILE__))
require 'cinch'
require "#{ ROOT_PATH }/lib/setup_environment"

@bot = Cinch::Bot.new do
  ## BOT SETUP ##
  configure do |c|
    # IRC Server IP
    # c.server = 'irc.freenode.net'
    # due to freenodes loadbalancing being shit, setting it to static IP
    c.server = $config[:bot][:server]
    c.ssl.use = $config[:bot][:use_ssl]
    c.port = $config[:bot][:port]
    c.channels = $config[:bot][:channels]
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
  on :message, /^!help(?: (.*))?$/ do |m, args|
    help(m, args)
  end

  helpers do
    def help(m, plugin = nil)
      if plugin.nil?
        m.reply "#{ $RESULT_CHARACTER }you can do !help plugin command (e.g. !help admins admin), ask for list of plugins (!help plugins) or ask for list of commands (!help commands)."
      else
        plugin_name = plugin.split[0]
        if plugin_name == "plugins"
          if Help.plugins.size > 0
            m.reply "#{$RESULT_CHARACTER}Available plugins:"
            messages = Array.new
            Help.plugins.multithreaded_each do |plugin|
              msg = plugin[:plugin] + '(' + plugin[:filename] + ')'
              plugin[:description].nil? ? (msg+='.') : (msg+='. ' + plugin[:description])
              messages.push(msg)
            end
            messages.each do |msg|
              m.reply msg
            end
          else
            m.reply "#{ $RESULT_CHARACTER }there are currently no plugins supporting Help system. Check out the current repository version with example plugins at https://github.com/Marahin/ircbot"
          end
        elsif plugin_name == "commands"
          if Help.commands.size > 0
          else

          end
        elsif plugin.split.size > 1 then
          command_name = plugin.split[1]
          arguments = plugin.split[2..(plugin.split.size)]
        else
          plugin = Help.plugins.find{ |pl| pl[:plugin] == plugin_name }
          if plugin
            plugin_info = "#{ $RESULT_CHARACTER }#{plugin_name} (#{plugin[:filename]})"
            if plugin[:description]
              plugin_info += ' - ' + plugin[:description]
            end
            plugin_info[-1] == '.' ? () : (plugin_info += '.')
            plugin_info += ' Available commands: '
            commands = Help.plugin_commands(plugin_name) || Array.new
            debug Help.plugin_commands(plugin_name).to_s + " -> " + (plugin_name)
            messages = [ plugin_info ]
            commands.size == 0 ? (msg[0] += 'none. Sorry.') : (
              commands.each do |command|
                messages.push(
                  '< /'+ $config[:plugins_prefix] + command[:syntax] + '/ > ' + command[:description]
                )
              end
            )
            messages.each do |msg|
              m.reply msg
            end
          else
            m.reply "#{ $RESULT_CHARACTER }could not find plugin named #{plugin_name}. Do !help plugins if you want to see the list of loaded plugins (and make sure to ask for the plugin name, not the filename, for the future record)."
          end
          # help for the given plugin
        end
      end
      debug "plugin: l #{ plugin.length }, tf #{ plugin ? true : false }, s #{ plugin }"
    end

    def hook_plugin(m, plugin)
      return unless ( Object.const_defined?('Admins') ? ( Admins.check_user( m.user ) ) : ( true ))
      # TODO: .select returns array instead of first element,
      # so it _should_ PROBABLY be replaced with .find, which returns ONE element
      # - the one that would be the first in the array.
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
        m.reply "#{ $RESULT_CHARACTER }Could not unload #{plugin} because no matching class was found."
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

# macius.loggers.level = :log
@bot.start
