#Game Setup
# puts "Choose the min:"
# min = gets.to_i
min = 1

# puts "Choose the max:"
# max = gets.to_i
max = 100_000

if min > max
  raise "min must be less than max"
end

strategy = :kugel
number = rand(min..max)

puts "*** SHHH the secret number is #{number} ****"

#instructions for human player to get guesses
def ask_for_guess(min, max)
  puts "Guess a number #{min} to #{max}?"

  guess = gets.to_i
  while guess < min or guess > max
    puts "Your number must be greater than #{min} and less than #{max}. Guess again."
    guess = gets.to_i
  end
  
  guess
end

class Guesser
  attr_accessor :name, :min, :max, :last_guess, :guess_count, :original_max, :original_min

  def initialize(name, min, max)
    self.name = name
    self.min = min
    self.max = max
    self.original_min = min
    self.original_max = max
    self.guess_count = 0
  end
  
  def make_guess(strategy=:gabi)
    self.guess_count = guess_count + 1
    if strategy == :gabi
      guess = (min + max) / 2
      puts "[#{name}]: Returning our guess #{guess}. min is #{min} and max is #{max}"
      self.last_guess = guess
      guess
    elsif strategy == :zeke
      guess = rand(min..max)
      puts "[#{name}]: Returning our guess #{guess}. min is #{min} and max is #{max}"
      self.last_guess = guess
      guess
    elsif strategy == :kugel
      guess = rand(original_min..original_max)
      puts "[#{name}]: Returning our guess #{guess}."
      self.last_guess = guess
      guess
    end
  end
  
  def too_high!
    puts "[#{name}]: Guess was too high!"
    self.max = last_guess - 1
    puts "[#{name}]: Our new max is #{max}"
  end

  def too_low!
    puts "[#{name}]: Guess was too low!"
    self.min = last_guess + 1
    puts "[#{name}]: Our new min is #{min}"
  end

end

#play the game
puts "Creating new guesser with #{min} and #{max} and strategy #{strategy}"
guesser = Guesser.new("Bob", min, max)
puts "#{guesser.name} was created. #{guesser.name} is making a guess.."
guess = guesser.make_guess(strategy)
while guess != number do
  if guess > number
    guesser.too_high!
  else
    guesser.too_low!
  end
#  puts "Your guess #{guess} was too #{error}. Guess again!"
  
  guess = guesser.make_guess(strategy)
end

#win and exit
emoji = %w[❤️ 😀 ✅ 🍺].shuffle.last
puts "#{guesser.name} guessed #{number} between #{min} and #{max} after #{guesser.guess_count} guesses! #{emoji}"

