class HelpObj
  def initialize(name, description)
    @name = name
    @description = description
    @commands = { }
    @help ||= {}
    @help.merge!({"#{name}" => {"descr" => "#{description}", "obj" => self } })
  end

  def generic_descr
    return "#{@name}: #{@description}."
  end

  def commands
    return @commands
  end

  def add_command(syntax, descr)
    #@commands.merge!()
    @commands.merge!( {:syntax => syntax, :description => descr})
  end
end