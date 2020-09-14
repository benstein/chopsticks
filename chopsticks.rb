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
      take_turn(player1, player2) and return
      take_turn(player2, player1) and return
    end  
  end
  
  def take_turn(player_a, player_b)
    game_over = false
    self.turns = turns + 1
    print_out_game
    player_a.take_turn(player_b)
    if player_b.both_hands_down?
      print_win_message_for(player_a)
      game_over = true
    end
    game_over
  end
  
  def print_win_message_for(player)
    emoji = %w[❤️ 😀 ✅ 🍺].shuffle.last
    puts "#{player.name} wins! #{emoji * 3}".upcase
  end
  
  def print_out_game
    puts "========  TURN #{turns} ========"
    puts "[#{player1.colored_name}]: (L) #{player1.left.pretty_print} | #{player1.right.pretty_print}  (R)"
    puts "--------------------------------"
    puts "[#{player2.colored_name}]: (L) #{player2.left.pretty_print} | #{player2.right.pretty_print}  (R)"
    puts "==========================="
    puts ""
  end
  
end

class Player
  
  attr_accessor :name
  attr_accessor :color
  attr_accessor :left, :right
  
  def initialize(name, color=:green)
    puts "Setting up a new player named #{name}" if DEBUG
    self.name = name
    self.color = color
    self.left = Hand.new()
    self.right = Hand.new()
  end
  
  def both_hands_down?
    left.down? && right.down?
  end

  def colored_name
    name.__send__(color)
  end


  # ["r","l"] or ["2","3"]
  def get_move(opponent)
    puts "Getting move until we get a valid one..." if DEBUG
    puts "[#{name.__send__(color)}] Choose a hand to tap from (L or R) and to (L or R). Or type 2 numbers to self tap."
    source, target = nil
    loop do
      move = gets.strip.downcase
      source = move[0]
      target = move[1]
      break if valid_move?(source, target, opponent)
    end
    [source, target]
  end

  def take_turn(opponent)
    source, target = get_move(opponent)
    
    if is_valid_letter?(source) && is_valid_letter?(target)
      puts "[#{colored_name}] Tapping #{source.upcase} to your #{target.upcase}"
    else
      puts "[#{colored_name}] Self tap! Setting fingers to #{source} and #{target}"
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
      puts "Sorry! Type 'L' or 'R' or a valid number for the first letter. Try again".red
      return false
    end

    if !is_valid_letter?(target) && !is_valid_number?(target)
      puts "Sorry! Type 'L' or 'R' or a valid number for the second letter. Try again".red
      return false
    end

    if (is_valid_number?(source) && is_valid_letter?(target)) || (is_valid_number?(target) && is_valid_letter?(source))
      puts "Sorry! You can't mix letters and numbers. Try again".red
      return false
    end
        
    if source == L && left.down?
      puts "Sorry! Left hand is down. You can not tap with it. Try again".red
      return false
    end

    if source == R && right.down?
      puts "Sorry! Right hand is down. You can not tap with it. Try again".red
      return false
    end
    
    if target == L && opponent.left.down?
      puts "Sorry! Your opponent's left hand is down. You can not tap it. Try again".red
      return false
    end

    if target == R && opponent.right.down?
      puts "Sorry! Your opponent's right hand is down. You can not tap it. Try again".red
      return false
    end
    
    #self tap validation
    if is_valid_number?(source) && is_valid_number?(target)
      if (source.to_i + target.to_i) != (left.finger_count + right.finger_count)
        puts "Sorry! You must enter digits that sum to your current total finger count of #{left.finger_count + right.finger_count}".red
        return false
      end

      if (source.to_i == left.finger_count) || (source.to_i == right.finger_count)
        puts "Sorry! You may not keep your finger count the same. Try again".red
        return false
      end
    end
    
    true
    
  end

end

class ComputerPlayer < Player
  
  def get_move(opponent)
    loop do
      source = [L,R].shuffle.last
      target = [L,R].shuffle.last
      break if valid_move?(source, target, opponent)
    end
    puts "COMPUTER MOVE: #{source} => #{target}"
    [source, target]
  end
  
end

class HumanPlayer < Player
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

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end

 player1 = HumanPlayer.new("Gabi", :light_blue)
 player2 = HumanPlayer.new("Zeke", :pink)
# player1 = ComputerPlayer.new("Gabi", :light_blue)
# player2 = ComputerPlayer.new("Zeke", :pink)
players = [player1, player2].shuffle
chopsticks = Chopsticks.new(players[0], players[1])
chopsticks.play

