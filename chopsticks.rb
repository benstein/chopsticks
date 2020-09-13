ONE   = "1️⃣"
TWO   = "2️⃣"
THREE = "3️⃣"
FOUR  = "4️⃣"
ZERO  = "☠️"

L = 'l'
R = 'r'

# DEBUG = true
DEBUG = false

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
    puts "playing..." if DEBUG
    
    while true
      self.turns = turns + 1
      print_out_game
      player1.take_turn(player2)
      if player2.both_hands_down?
        print_win_message_for(player1)
        return
      end
      
      self.turns = turns + 1
      print_out_game
      player2.take_turn(player1)
      if player1.both_hands_down?
        print_win_message_for(player2)
        return
      end
    end  
  end
  
  def print_win_message_for(player)
    emoji = %w[❤️ 😀 ✅ 🍺].shuffle.last
    puts "#{player.name} wins! #{emoji * 3}".upcase
  end
  
  def print_out_game
    puts "========  TURN #{turns} ========"
    puts "[#{player1.name}]: (L) #{player1.left.pretty_print} | #{player1.right.pretty_print}  (R)"
    puts "--------------------------------"
    puts "[#{player2.name}]: (L) #{player2.left.pretty_print} | #{player2.right.pretty_print}  (R)"
    puts "==========================="
    puts ""
  end
  
end

class Player
  
  attr_accessor :name
  attr_accessor :left, :right
  
  def initialize(name)
    puts "Setting up a new player named #{name}" if DEBUG
    self.name = name
    self.left = Hand.new()
    self.right = Hand.new()
  end
  
  def both_hands_down?
    left.down? && right.down?
  end

  #we coudl make more strategy here
  def get_move
    puts "[#{name}] Choose a hand to tap from (L or R) and to (L or R). Or type 2 numbers to self tap."
    gets.strip.downcase
  end

  def take_turn(opponent)
    # source = ""
    # target = ""

    puts "Getting move until we get a valid one..." if DEBUG
    move = get_move
    source, target = parse_move(move)
    while !valid_move?(source, target, opponent)
      move = get_move
      source, target = parse_move(move)
    end
    
    if is_valid_letter?(source) && is_valid_letter?(target)
      puts "[#{name}] Tapping #{source.upcase} to your #{target.upcase}"
    else
      puts "[#{name}] Self tap! Setting fingers to #{source} and #{target}"
    end

    if source == L
      if target == L
        opponent.left.tapped_by!(left)
      elsif target == R
        opponent.right.tapped_by!(left)
      end
    elsif source == R
      if target == L
        opponent.left.tapped_by!(right)
      elsif target == R
        opponent.right.tapped_by!(right)
      end
    elsif is_valid_number?(source) && is_valid_number?(target)
      left.set_finger_count! source.to_i
      right.set_finger_count! target.to_i
    end
  end

  def is_valid_number?(move)
     %w[0 1 2 3 4].include?(move)
  end

  def is_valid_letter?(move)
    move == L || move == R
  end

  def valid_move?(source, target, opponent)
    
    if !is_valid_letter?(source) && !is_valid_number?(source)
      puts "Sorry! Type 'L' or 'R' or a valid number for the first letter. Try again"
      return false
    end

    if !is_valid_letter?(target) && !is_valid_number?(target)
      puts "Sorry! Type 'L' or 'R' or a valid number for the second letter. Try again"
      return false
    end

    if (is_valid_number?(source) && is_valid_letter?(target)) || (is_valid_number?(target) && is_valid_letter?(source))
      puts "Sorry! You can't mix letters and numbers. Try again"
      return false
    end
        
    if source == L && left.down?
      puts "Sorry! Left hand is down. You can not tap with it. Try again"
      return false
    end

    if source == R && right.down?
      puts "Sorry! Right hand is down. You can not tap with it. Try again"
      return false
    end
    
    if target == L && opponent.left.down?
      puts "Sorry! Your opponent's left hand is down. You can not tap it. Try again"
      return false
    end

    if target == R && opponent.right.down?
      puts "Sorry! Your opponent's right hand is down. You can not tap it. Try again"
      return false
    end
    
    #self tap validation
    if is_valid_number?(source) && is_valid_number?(target)
      if !(source.to_i + target.to_i) == (left.finger_count + right.finger_count)
        puts "Sorry! You must enter digits that sum to your current total finger count of #{left.finger_count + right.finger_count}"
        return false
      end
#      if ((source.to_i == left.finger_count) && (target.to_i == right.finger_count)) || 
      if (source.to_i == left.finger_count) || (source.to_i == right.finger_count)
        puts "Sorry! You may not keep your finger count the same. Try again"
        return false
      end
    end
    
    true
    
  end

  def parse_move(move)
    [move[0], move[1]]
  end

end

class Hand
  
  attr_accessor :finger_count
  MAX_FINGERS = 5
  MIN_FINGERS = 0
  
  def initialize()
    puts "Initializing hand" if DEBUG
    self.finger_count = 1
  end
  
  def tapped_by!(hand)
    self.finger_count = finger_count + hand.finger_count
    #this is the wrap-around logic
    if finger_count >= MAX_FINGERS
      self.finger_count = finger_count - MAX_FINGERS
    end
  end

  def set_finger_count!(number)
    if (number < MIN_FINGERS) || (number > (MAX_FINGERS - 1))
      raise "Can not set finger count to #{number}, that is outside range."
    end
    self.finger_count = number
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
    
    case finger_count
    when 1 then ONE
    when 2 then TWO
    when 3 then THREE
    when 4 then FOUR
    when 0 then ZERO
    end
  end

end

player1 = Player.new("Gabi")
player2 = Player.new("Zeke")
players = [player1, player2].shuffle
chopsticks = Chopsticks.new(players[0], players[1])
chopsticks.play

