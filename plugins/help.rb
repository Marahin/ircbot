# -*- coding: utf-8 -*-
## == Author
# Marvin Gülker (Quintus)
#
# == License
# A help plugin for Cinch.
# Copyright © 2012 Marvin Gülker

# Help plugin for Cinch.
class Help
  include Cinch::Plugin

  listen_to :connect, :method => :on_connect
  match /help(.*)/i

  set :help, <<-EOF
[/msg] cinch help
  Post a short introduction and list available plugins.
[/msg] cinch help <plugin>
  List all commands available in a plugin.
[/msg] cinch help search <query>
  Search all plugin’s commands and list all commands containing
  <query>.
  EOF

  def execute(msg, query)
    query = query.strip.downcase
    response = ""

    # Act depending on the subcommand.
    if query.empty?
      response << @intro_message.strip << "\n"
      response << "Available plugins:\n"
      response << @bot.config.plugins.plugins.map{|plugin| format_plugin_name(plugin)}.join(", ")
      response << "\n'help <plugin>' for help on a specific plugin."

    # Help for a specific plugin
    elsif plugin = @help.keys.find{|plugin| format_plugin_name(plugin) == query}
      @help[plugin].keys.sort.each do |command|
        response << format_command(command, @help[plugin][command], plugin)
      end

    # help search <...>
    elsif query =~ /^search (.*)$/i
      query2 = $1.strip
      @help.each_pair do |plugin, hsh|
        hsh.each_pair do |command, explanation|
          response << format_command(command, explanation, plugin) if command.include?(query2)
        end
      end

      # For plugins without help
      response << "Sorry, no help available for the #{format_plugin_name(plugin)} plugin." if response.empty?

    # Something we don't know what do do with
    else
      response << "Sorry, I cannot find '#{query}'."
    end

    response << "Sorry, nothing found." if response.empty?
    msg.reply(response)
  end

  # Called on startup. This method iterates the list of registered plugins
  # and parses all their help messages, collecting them in the @help hash,
  # which has a structure like this:
  #
  #   {Plugin => {"command" => "explanation"}}
  #
  # where +Plugin+ is the plugin’s class object. It also parses configuration
  # options.
  def on_connect(msg)
    @help = {}

    if config[:intro]
      @intro_message = config[:intro] % @bot.nick
    else
      @intro_message = "#{@bot.nick} at your service."
    end

    @bot.config.plugins.plugins.each do |plugin|
      @help[plugin] = Hash.new{|h, k| h[k] = ""}
      next unless plugin.help # Some plugins don't provide help
      current_command = "<unparsable content>" # For not properly formatted help strings

      plugin.help.lines.each do |line|
        if line =~ /^\s+/
          @help[plugin][current_command] << line.strip
        else
          current_command = line.strip.gsub(/cinch/i, @bot.name)
        end
      end
    end
  end

  private

  # Format the help for a single command in a nice, unicode mannor.
  def format_command(command, explanation, plugin)
    result = ""

    result << "┌─ " << command << " ─── Plugin: " << format_plugin_name(plugin) << " ─" << "\n"
    result << explanation.lines.map(&:strip).join(" ").chars.each_slice(80).map(&:join).join("\n")
    result << "\n" << "└ ─ ─ ─ ─ ─ ─ ─ ─\n"

    result
  end

  # Downcase the plugin name and clip it to the last component
  # of the namespace, so it can be displayed in a user-friendly
  # way.
  def format_plugin_name(plugin)
    plugin.to_s.split("::").last.downcase
  end

end
