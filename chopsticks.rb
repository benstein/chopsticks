class Chopsticks
  
  attr_accessor :player1
  attr_accessor :player2
  
  def initialize(player1, player2)
    puts "Setting up a new game with #{player1.name} and #{player2.name}"
    self.player1 = player1
    self.player2 = player2
  end
  
  def play
    puts "playing..."
    
    while true
      player1.take_turn
      if !player2.has_hands_left?
        puts "Player 1 wins!"
        return
      end
      player2.take_turn
      if !player1.has_hands_left?
        puts "Player 2 wins!"
        return
      end
    end
    
  end
  
end

class Player
  
  attr_accessor :name
  attr_accessor :left, :right
  
  def initialize(name)
    puts "Setting up a new player named #{name}"
    self.name = name
    self.left = Hand.new()
    self.right = Hand.new()
  end
  
  def has_hands_left?
    true
    #left has > 0 AND right has > 0
  end

  def take_turn
    puts "[#{name}] TAP A HAND"
  end

end

class Hand
  
  attr_accessor :finger_count
  MAX_FINGERS = 5
  MIN_FINGERS = 0
  
  def initialize()
    puts "Initializing hand"
    self.finger_count = 1
  end

end

player1 = Player.new("Gabi")
player2 = Player.new("Papi")
chopsticks = Chopsticks.new(player1, player2)
chopsticks.play

