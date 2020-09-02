ONE = <<-TXT
."".
|  |
|  |
|  |
|  |--.--._ 
|  | _|  | `|
|  /` )  |  |
| /  /'--:__/
|/  /       |
(  ' \      |
 \    `.   /
  |       |
  |       |
TXT

TWO = <<-TXT
     .--.
  ."";  |
  |  |  |
  |  |  |
  |  |  |
  |  |  |--._ 
  |  | _|  | `|
  |  /` )  |  |
  | /  /'--:__/
  |/  /       |
  (  ' \      |
   \    `.   /
    |       |
    |       |
TXT

THREE = <<-TXT
     .--.
  .'';  |.-.
  |  |  |  |
  |  |  |  |
  |  |  |  |
  |  |  |  |_ 
  |  | _|  / `,
  }  /``) /  /
  |`/   /:__/ \
  |/   /      |
  (   '\      |
   \    `.   /
    |       |
    |       |
TXT

FOUR = <<-TXT
     .--.
  .'';  |.-.
  |  |  |  |
  |  |  |  |.-.
  |  |  |  |  |
  |  |  |  |  |
  |  | _|  |  ,
  }  /``)     |
  |`/   /     \
  |/   /      |
  (   '\      |
   \    `.   /
    |       |
    |       |
TXT

ZERO = <<-TXT
        _______
     .-"       "-.
    /             \
   /               \
   |   .--. .--.   |
   | )/   | |   \( |
   |/ \__/   \__/ \|
   /      /^\      \
   \__    '='    __/
     |\         /|
     |\'"VUUUV"'/|
     \ `"""""""` /
      `-._____.-'
TXT

class Chopsticks
  
  attr_accessor :player1
  attr_accessor :player2
  attr_accessor :turns
  
  def initialize(player1, player2)
    puts "Setting up a new game with #{player1.name} and #{player2.name}"
    self.player1 = player1
    self.player2 = player2
    self.turns = 0
  end
  
  def play
    puts "playing..."
    
    while true
      self.turns = turns + 1
      print_out_game
      player1.take_turn(player2)
      if player2.both_hands_down?
        puts "Player 1 wins!"
        return
      end
      self.turns = turns + 1
      print_out_game
      player2.take_turn(player1)
      if player1.both_hands_down?
        puts "Player 2 wins!"
        return
      end
    end  
  end
  
  def print_out_game
    puts "========  TURN #{turns} ========"
    puts "[#{player1.name}]: #{player1.left.pretty_print} | #{player1.right.pretty_print}"
    puts "--------------------------------"
    puts "[#{player2.name}]: #{player2.left.pretty_print} | #{player2.right.pretty_print}"
    puts "================================"
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
  
  def both_hands_down?
    left.down? && right.down?
  end

  def take_turn(opponent)
    puts "[#{name}] Choose a hand to tap with, and the oppponent's hand to tap"
    move = gets.strip
    source, target = parse_move(move)
    puts "[#{name}] Tapping my #{source} to your #{target}"
    if source == "l"
      if target == "l"
        opponent.left.tapped_by!(left)
      elsif target == "r"
        opponent.right.tapped_by!(left)
      end
    elsif source == "r"
      if target == "l"
        opponent.left.tapped_by!(right)
      elsif target == "r"
        opponent.right.tapped_by!(right)
      end
    end
  end

  def parse_move(move)
    #assume LL, LR, RL, RR
    if move != "ll" && move != "lr" && move != "rl" && move != "rr" 
      raise "INVALID MOVE #{move}"
    end
    [move[0], move[1]]
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
  
  # def tap!(other_hand)
#     other_hand.tapped(finger_count)
#   end
#
  def tapped_by!(hand)
    self.finger_count = finger_count + hand.finger_count
    if finger_count >= MAX_FINGERS
      self.finger_count = finger_count - MAX_FINGERS
    end
  end

  def up?
    !down?
  end

  def down?
    finger_count == 0
  end

  def pretty_print
    if down?
      "-"
    else
      finger_count
    end
    
    # case finger_count
    # when 1 then ONE
    # when 2 then TWO
    # when 3 then THREE
    # when 4 then FOUR
    # when 0 then ZERO
    # end
  end

end

player1 = Player.new("Gabi")
player2 = Player.new("Zeke")
chopsticks = Chopsticks.new(player1, player2)
chopsticks.play

