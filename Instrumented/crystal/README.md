# fibonacci

This is the version of the application, found [here](../../Uninstrumented/crystal), which has been instrumented with OpenTelemetry.

This example contains a very simple API server implemented with just the Crystal Standard Library. On any request, it looks for a query parameter *n* and, if that parameter exists, and is a positive number, the *nth* number in the Fibonacci Sequence will be calculated and returned. This

If the query appears to be malformed in any way, an error message is returned.

A secondard tool, *load_generator*, is also included. When ran, it will loop, sending random queries to the Fibonacci API server and displaying the results.

## Instrumentation

The *opentelemetry-instrumentation* package for Crystal features auto-instrumentation of many common libraries, which makes adding OpenTelemetry instrumentation to many Crystal projects very simple.

The only things that are necessary are to add the package to your *shards.yml* file, and then run *shards install*.

```yaml
dependencies:
  opentelemetry-instrumentation:
    github: wyhaines/opentelemetry-instrumentation.cr
```

The uninstrumented [*server.cr*](../../Uninstrumented/crystal/src/server.cr) file is very short:

```crystal
require "./fibonacci"

# This stub instantiates an instance of the Fibonacci server, and runs it.

Fibonacci.new.run.wait
```

Useful instrumentation can be added as simply as this:

```crystal
require "opentelemetry-instrumentation"
```

The instrumentation will detect, at compile time, the installed libraries that it can instrument (including *HTTP::Server* and *Log*), and will automatically instrument them.

You aren't quite done, however. In order for the instrumentation to be useful, it needs to know what to do with the traces that are generated, which means that a small amount of configuration needs to be added, as well...

```crystal
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

Fibonacci.new.run.wait
```

If you previously ran the uninstrumented version of the server, running the instrumented version is identical, except that you will need to set an environment variable with a valid New Relic License Key, so that New Relic's OpenTelemetry ingest service knows who the traces belong to.

```bash
NEW_RELIC_LICENSE_KEY=<your license key> ./server
```

Requests that hit the fibonacci server will generate traces that will show, in great detail, all of the processing steps involved in returning the response, as well as the time spent in each step. Any logs that are generated (such as the activity logs that are sent to STDOUT on every request) will also be captured into the active span at the time that the log was generated, as an event.

Let's imagine, though, that you want more detail about the performance of the `#fibonacci` method itself. The auto-instrumentation doesn't know about that method, nor know it's importance, so it will not have instrumented that method. You, however, want to know how long the calculation itself is taking, and you also want the result of that calculation stored in the span that is sent back to New Relic. Here is how you might do that:

```crystal
class Fibonacci
  trace("fibonacci") do
    OpenTelemetry.trace.in_span("fibonacci(#{x})") do |span|
      span["fibonacci.n"] = x
      result = previous_def
      span["fibonacci.result"] = result.to_s
    end
  end
end

Fibonacci.new.run.wait
```

This will insert a trace around the `#fibonacci` method, without changing the original method, that will open a new child span just to record details about the operation of the fibonacci calculation method. 

## Installation & Usage

If you have Crystal installed on your system, you can compile and run these apps directly. If you do not have Crystal installed, you can find your operating system on the [Install](https://crystal-lang.org/install/) page of the Crystal web site, and follow the instructions. Alternatively, if you have docker available, a Dockerfile is provided to run the examples.

If you are building and running the code manually, you can compile the server with the following command:

```bash
crystal build -p -s -t --release src/server.cr
```

A *fibonacci* binary will be placed in your directory when the code finishes compiling.

To build the load generator, you can use:

```bash
crystal build -p -s -t src/load_generator.cr
```

Then, to run then, using two different shells, execute:

```bash
./server
```

in one shell, and:

```bash
./load_generator
```

in the other.
