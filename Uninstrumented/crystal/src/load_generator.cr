require "http/client"

loop do
  sequence = (1000 - (rand * 1000000000)**0.33333333).to_i # exponential curve weighted towards smaller numbers
  print "Fibonacci ##{sequence}: "
  response = HTTP::Client.get("http://127.0.0.1:5000?n=#{sequence}")
  if response.success?
    puts response.body
  else
    puts "ERROR: #{response.status}"
  end

  sleep rand * 5
end
