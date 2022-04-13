# fibonacci

This is a sample application which will be instrumented with OpenTelemetry. You can find the instrumented version [here](../../Instrumented/crystal).

This example contains a very simple API server implemented with just the Crystal Standard Library. On any request, it looks for a query parameter *n* and, if that parameter exists, and is a positive number, the *nth* number in the Fibonacci Sequence will be calculated and returned. This

If the query appears to be malformed in any way, an error message is returned.

A secondard tool, *load_generator*, is also included. When ran, it will loop, sending random queries to the Fibonacci API server and displaying the results.

## Installation

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
