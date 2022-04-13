require "./version"
require "http/server"
require "big/big_int"

class Fibonacci
  private getter finished : Channel(Nil) = Channel(Nil).new

  # This implements an iterative solution to solving for a given
  # fibonacci number. This function will also utilize BigInt, which
  # is an arbitrary precision integer, if the answer will be too large
  # to fit into a 64 bit Integer.
  def fibonacci(x)
    a, b = x > 93 ? {BigInt.new(0), BigInt.new(1)} : {0_u64, 1_u64}

    (x - 1).times do
      a, b = b, a + b
    end
    a
  end

  # In this example, the HTTP server that handles fibonacci requests
  # is spawned into it's own fiber. This example would work just fine
  # if it were kept in the main thread, but this pattern can be useful
  # in larger applications.
  #
  # This example could be much shorter, but it represents a more typical
  # application pattern, with handlers for managing errors, for logging
  # responses, and for automatically compressing the response, if the
  # request allows for it in the *Accept-Encoding* header.
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

  # This is not strictly necessary, but in a larger application, one
  # might want to have the main fiber wait for the fiber that is running
  # the server to finish, and if it does so, cleanup resources. This
  # pattern is a simple one to allow that.
  def wait
    finished.receive
  end
end
