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
    puts "Setting up a new game with #{player1.colored_name} and #{player2.colored_name}"
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
      print_win_message_for(player_a, turns)
      game_over = true
    end
    game_over
  end
  
  def print_win_message_for(player, turns)
    emoji = %w[❤️ 😀 ✅ 🍺].shuffle.last
    puts "#{emoji * 3}  #{player.name} wins in #{turns} turns! #{emoji * 3}".upcase
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
      move = gets.strip.downcase #waits for human to type
      source = move[0]
      target = move[1]
      break if valid_move?(source, target, opponent)
    end
    [source, target]
  end

  def take_turn(opponent)
    
    source, target = get_move(opponent)
    if !valid_move?(source, target, opponent)
      raise "#{source}, #{target} is not a valid move. Check that get_move always returns a valid move"
    end
    
    if is_valid_letter?(source) && is_valid_letter?(target)
      puts " - #{colored_name}'s Move: Tapped #{source.upcase} to your #{target.upcase}"
      puts ""
    else
      puts " - #{colored_name}'s Move: Self tap! Setting fingers to #{source} and #{target}"
      puts ""
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

  def print_error(string)
    puts string.red
  end

  def valid_move?(source, target, opponent)
    
    #validate inputs
    if !is_valid_letter?(source) && !is_valid_number?(source)
      print_error "Sorry! Type 'L' or 'R' or a valid number for the first letter. Try again"
      return false
    end

    if !is_valid_letter?(target) && !is_valid_number?(target)
      print_error "Sorry! Type 'L' or 'R' or a valid number for the second letter. Try again"
      return false
    end

    if (is_valid_number?(source) && is_valid_letter?(target)) || (is_valid_number?(target) && is_valid_letter?(source))
      print_error "Sorry! You can't mix letters and numbers. Try again"
      return false
    end

    #check for hands down
    if is_valid_letter?(source) && is_valid_letter?(target)
      if source == L && left.down?
        print_error "Sorry! Left hand is down. You can not tap with it. Try again"
        return false
      end

      if source == R && right.down?
        print_error "Sorry! Right hand is down. You can not tap with it. Try again"
        return false
      end
    
      if target == L && opponent.left.down?
        print_error "Sorry! Your opponent's left hand is down. You can not tap it. Try again"
        return false
      end

      if target == R && opponent.right.down?
        print_error "Sorry! Your opponent's right hand is down. You can not tap it. Try again"
        return false
      end
    end
    
    #self tap validation
    if is_valid_number?(source) && is_valid_number?(target)
      if (source.to_i + target.to_i) != total_finger_count
        print_error "Sorry! You must enter digits that sum to your current total finger count of #{left.finger_count + right.finger_count}"
        return false
      end

      if (source.to_i == left.finger_count) || (source.to_i == right.finger_count)
        print_error "Sorry! You may not keep your finger count the same. Try again"
        return false
      end
    end
    
    true
    
  end

  def total_finger_count
    left.finger_count + right.finger_count
  end

  def self_tap_ok?
    total_finger_count > 1 && total_finger_count < 7
  end

end

class ComputerPlayer < Player
  def print_error(string)
    #don't print errors for the computer. they can't read! #puts string.red
  end
  
  def self_tap
    puts "RANDOMLY SELF TAPPING with total_finger_count=#{total_finger_count}" if DEBUG
    choices = case total_finger_count
    when 2
      [%w[2 0], %w[1 1]]
    when 3
      [%w[3 0], %w[2 1]]
    when 4
      [%w[4 0], %w[3 1], %w[2 2]]
    when 5
      [%w[4 1], %w[3 2]]
    when 6
      [%w[4 2], %w[3 3]]
    else
      raise "Unsupported total_finger_count #{total_finger_count}."
    end
    source, target = choices.shuffle.last
  end
  
  def random_move(opponent)
    source, target = nil
    loop do

      #computer brains!
      source = [L,R].shuffle.last
      target = [L,R].shuffle.last
      random_self_tap_percentage = 0.33
      if rand < random_self_tap_percentage && self_tap_ok?
        source, target = self_tap
      end

      break if valid_move?(source, target, opponent)
    end
#    puts "COMPUTER MOVE: #{source} => #{target}".green
    [source, target]
  end
end


class RandomComputerPlayer < ComputerPlayer
    
  def get_move(opponent)
    random_move opponent
  end
  
end

class SmartComputerPlayer < ComputerPlayer
  
  def am_i_vulnerable?(count1, count2)
    (left.finger_count + count1 == Hand::MAX_FINGERS) || 
      (right.finger_count + count1 == Hand::MAX_FINGERS) ||
        (left.finger_count + count2 == Hand::MAX_FINGERS) || 
          (right.finger_count + count2 == Hand::MAX_FINGERS)
  end
  
  def get_move(opponent)

    source, target = nil
    
    #Rule: If we can ever tap to make a 5, do it!
    if right.finger_count + opponent.right.finger_count == Hand::MAX_FINGERS
      puts "WE CAN MAKE A FIVE!!!" if DEBUG
      source = R
      target = R
    elsif right.finger_count + opponent.left.finger_count == Hand::MAX_FINGERS
      puts "WE CAN MAKE A FIVE!!!" if DEBUG
      source = R
      target = L
    elsif left.finger_count + opponent.left.finger_count == Hand::MAX_FINGERS
      puts "WE CAN MAKE A FIVE!!!" if DEBUG
      source = L
      target = L
    elsif left.finger_count + opponent.right.finger_count == Hand::MAX_FINGERS
      puts "WE CAN MAKE A FIVE!!!" if DEBUG
      source = L
      target = R

    #Rule: if you have a hand down, always self tap
    elsif (left.down? || right.down?) && total_finger_count > 1
      puts "WE HAVE A HAND DOWN. SELF TAP" if DEBUG
      source, target = case total_finger_count
      when 2 then %w[1 1]
      when 3 then %w[2 1]
      when 4
        #don't make it easy for them to kill you
        if opponent.left.finger_count == 3 || opponent.right.finger_count == 3 
          %w[3 1]
        else
          %w[2 2]
        end
      end
    end
    
    #Rule: do not make a move if it will leave you vulnerable to losing a hand
    if source.nil? && target.nil?
      safe_moves = []
      their_new_finger_count = Hand.new_total_after_tap(left.finger_count, opponent.left.finger_count)
      puts "their_new_finger_count after L, L would be #{their_new_finger_count}" if DEBUG
      if !am_i_vulnerable?(their_new_finger_count, opponent.right.finger_count) && valid_move?(L, L, opponent)
        safe_moves << [L,L]
      end

      their_new_finger_count = Hand.new_total_after_tap(right.finger_count, opponent.left.finger_count)
      puts "their_new_finger_count after L, R would be #{their_new_finger_count}" if DEBUG
      if !am_i_vulnerable?(their_new_finger_count, opponent.left.finger_count) && valid_move?(L, R, opponent)
        safe_moves << [L,R]
      end

      their_new_finger_count = Hand.new_total_after_tap(left.finger_count, opponent.right.finger_count)
      puts "their_new_finger_count after R, L would be #{their_new_finger_count}" if DEBUG
      if !am_i_vulnerable?(their_new_finger_count, opponent.right.finger_count) && valid_move?(R, L, opponent)
        safe_moves << [R,L]
      end

      their_new_finger_count = Hand.new_total_after_tap(right.finger_count, opponent.right.finger_count)
      puts "their_new_finger_count after R, R would be #{their_new_finger_count}" if DEBUG
      if !am_i_vulnerable?(their_new_finger_count, opponent.right.finger_count) && valid_move?(R, R, opponent)
        safe_moves << [R,R]
      end
      
      if safe_moves.empty? 
        if self_tap_ok?
          puts "NO SAFE MOVES. SELF TAPPING" if DEBUG
          source, target = self_tap
          source, target = nil if !valid_move?(source, target, opponent) #kludge safety check
        end
      else
        puts "SAFE CHOICES INCLUDE: #{safe_moves.inspect}. Picking a safe one at random" if DEBUG
        source, target = safe_moves.shuffle.last #this could be even smarter
      end
      
    end
          
    if source.nil? && target.nil?
      random_move(opponent)
    else
      [source, target]
    end
    
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
    self.finger_count = Hand.new_total_after_tap(finger_count, hand.finger_count)
  end

  def self.new_total_after_tap(finger_count_1, finger_count_2)
    count = finger_count_1 + finger_count_2
    #this is the wrap-around logic
    if count >= MAX_FINGERS
      count = count - MAX_FINGERS
    end
    count
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

  def red; colorize(31); end
  def green; colorize(32); end
  def yellow; colorize(33); end
  def blue; colorize(34); end
  def pink; colorize(35); end
  def light_blue; colorize(36); end
end

# player1 = HumanPlayer.new("Gabi", :light_blue)
player2 = SmartComputerPlayer.new("Zeke", :pink)
#player1 = RandomComputerPlayer.new("Gabi", :light_blue)
player1 = SmartComputerPlayer.new( "Gabi", :light_blue)
#player2 = RandomComputerPlayer.new("Joe (dumb )", :pink)
# player2 = SmartComputerPlayer.new("Zeke (smart)", :pink)
players = [player1, player2].shuffle
chopsticks = Chopsticks.new(players[0], players[1])
chopsticks.play

