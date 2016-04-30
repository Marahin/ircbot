class HelpObj
  def initialize
    @plugins = Array.new
  end

  def commands
    commands = Array.new
    @plugins.each do |plugin|
      plugin[:commands].each do |command|
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

  def add_plugin(name, filename)
    @plugins.push(
      {:plugin => name, :filename => filename, :commands => [] }
    )
  end

  def plugins
    val = Array.new
    @plugins.each do |plugin|
      val.push({ :plugin => plugin[:plugin], :filename => plugin[:filename] })
    end
    return val
  end
end

Help = HelpObj.new
