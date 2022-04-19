require "http/client"

loop do
  sequence = (rand * 41000).to_i
  print "Fibonacci ##{sequence}: "
  response = HTTP::Client.get("http://127.0.0.1:5000?n=#{sequence}")
  if response.success?
    puts response.body
  else
    puts "ERROR: #{response.status}"
  end

  sleep rand * 5
end
