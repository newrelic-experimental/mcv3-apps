require "http/server"
require "big/big_int"

class Fibonacci
  getter finished : Channel(Nil) = Channel(Nil).new

  def fibonacci(x)
    a, b = x > 93 ? {BigInt.new(0), BigInt.new(1)} : {0_u64, 1_u64}

    (x - 1).times do
      a, b = b, a + b
    end
    a
  end

  def run
    spawn(name: "Fibonacci Server") do
      server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
      ]) do |context|
        n = context.request.query_params["n"]?

        if n && n.to_i > 0
          answer = fibonacci(n.to_i)
          context.response << answer.to_s
          context.response.content_type = "text/plain"
        else
          context.response.respond_with_status(
            400,
            "Please provide a positive integer as the 'n' query parameter"
          )
        end
      end

      server.bind_tcp "0.0.0.0", 5000
      server.listen
    end

    self
  end

  def wait
    finished.receive
  end
end

Fibonacci.new.run.wait