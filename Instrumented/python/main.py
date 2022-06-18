from flask import Flask, jsonify, request
from grpc import Compression
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.trace.status import Status, StatusCode

trace.set_tracer_provider(
   TracerProvider(
       resource=Resource.create(
           {
               "service.name": "fibonacci",
               "service.instance.id": "2193801",
               "telemetry.sdk.name": "opentelemetry",
               "telemetry.sdk.language": "python",
               "telemetry.sdk.version": "0.13.dev0",
           }
       ),
   ),
)

trace.get_tracer_provider().add_span_processor(
   BatchSpanProcessor(OTLPSpanExporter(compression=Compression.Gzip))
)

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)

tracer = trace.get_tracer(__name__)

@app.errorhandler(ValueError)
def handle_value_exception(error):
    trace.get_current_span().set_status(
        Status(StatusCode.ERROR, "Number outside of accepted range.")
    )
    response = jsonify(message=str(error))
    response.status_code = 400
    return response

@app.route("/fibonacci")
def fib():
    n = request.args.get("n", None)
    return jsonify(n=n, result=calcfib(n))

def calcfib(n):
    with tracer.start_as_current_span("fibonacci") as span:
        span.set_attribute("fibonacci.n", n)

        try:
            n = int(n)
            assert 1 <= n <= 90
        except (ValueError, AssertionError) as e:
            raise ValueError("n must be between 1 and 90") from e

        a, b = 0, 1  # a, b initialized as F(0), F(1)
        for _ in range(1, x):
            a, b = b, a+b  # a, b always store F(i-1), F(i)

        span.set_attribute("fibonacci.result", a)
        return a

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
