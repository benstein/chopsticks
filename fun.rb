puts "Choose the min:"
min = gets.to_i #1

puts "Choose the max:"
max = gets.to_i #10

if min > max
  raise "min must be less than max"
end

number = rand(min..max)

def ask_for_guess(min, max)
  puts "Guess a number #{min} to #{max}?"
    
  guess = gets.to_i
  while guess < min or guess > max
    puts "Your number must be greater than #{min} and less than #{max}. Guess again."
    guess = gets.to_i
  end
  
  guess
end

guess = ask_for_guess min, max
while guess != number do
  error = if guess > number
    "high"
  else
    "low"
  end
  puts "Your guess #{guess} was too #{error}. Guess again!"
  guess = ask_for_guess min, max
end

emoji = %w[❤️ 😀 ✅ 🍺].shuffle.last
puts "You guessed it right! #{emoji}"

