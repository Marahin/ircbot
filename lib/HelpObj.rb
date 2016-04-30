class HelpObj
  def initialize
    @plugins = Array.new
    @plugins.extend(MultithreadedEach)
  end

  def commands
    commands = Array.new.extend(MultithreadedEach)
    @plugins.multithreaded_each do |plugin|
      plugin[:commands].multithreaded_each do |command|
        commands.push( command )
      end
    end
    return commands
  end

  def add_command(plugin, syntax, description)
    @plugins.select{ |pl| pl[:plugin] == plugin }.each do |pl2|
      pl2[:commands].push( { :syntax => syntax, :description => description } )
    end
  end

  def add_plugin(name, filename, description = nil)
    @plugins.push(
      {:plugin => name, :filename => filename, :description => description, :commands => Array.new.extend(MultithreadedEach)}
    )
  end

  def plugins
    val = Array.new
    @plugins.each do |plugin|
      val.push({ :plugin => plugin[:plugin], :filename => plugin[:filename] })
    end
    return val
  end

  def plugin_commands(plugin)
    commands = Array.new
    plugin = @plugins.find{ |pl| pl == plugin }
    commands ||= plugin[:commands] || Array.new
  end
end

Help = HelpObj.new
