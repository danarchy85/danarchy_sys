answer = gets.chomp

if answer =~ /^y(es)?$/i
  puts 'yes'
else
  puts 'no'
end
