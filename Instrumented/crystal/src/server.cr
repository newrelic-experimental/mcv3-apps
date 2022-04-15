require "./fibonacci"

# This stub instantiates an instance of the Fibonacci server, and runs it.

OpenTelemetry.configure do |config|
  config.service_name = "Fibonacci Server"
  config.service_version = Fibonacci::VERSION
  config.exporter = OpenTelemetry::Exporter.new(variant: :http) do |exporter|
    exporter = exporter.as(OpenTelemetry::Exporter::Http)
    exporter.endpoint = "https://otlp.nr-data.net:4318/v1/traces"
    headers = HTTP::Headers.new
    headers["api-key"] = ENV["NEW_RELIC_LICENSE_KEY"]?.to_s
    exporter.headers = headers
  end
end

class Fibonacci
  trace("fibonacci") do
    OpenTelemetry.trace.in_span("fibonacci(#{x})") do |span|
      span["fibonacci.n"] = x
      result = previous_def
      span["fibonacci.result"] = result.to_s

      result
    end
  end
end

Fibonacci.new.run.wait
