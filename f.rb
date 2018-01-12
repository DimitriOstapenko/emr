# Find patient by last name or health card number, depending on input format  

  def myfind (str)
   
	  if str.match(/^[[:digit:]]{10}$/)
		puts 'Valid number'
	  elsif str.match(/^[[:alpha:]]+$/)
        	puts 'Valid name'
	  else
		 puts 'invalid string'
	  end
  end

puts 'Enter string: '
str = gets.chomp
myfind(str)
