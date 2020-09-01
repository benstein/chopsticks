class Kid
  attr_accessor :name
  
  def initialize(name)
    self.name = name
  end
  
  def say_my_name
    puts "My name is #{name}"
  end
    
  def name_me
    puts "Type my name"
    self.name = gets
  end  
  
end


kid = Kid.new("gabi")
kid.name_me
kid.say_my_name


