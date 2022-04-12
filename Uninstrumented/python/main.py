from flask import Flask, jsonify, request

app = Flask(__name__)

@app.errorhandler(ValueError)
def handle_value_exception(error):
    response = jsonify(message=str(error))
    response.status_code = 400
    return response

@app.route("/fibonacci")
def fib():
    n = request.args.get("n", None)
    return jsonify(n=n, result=calcfib(n))

def calcfib(x):
    try:
        x = int(x)
        assert 1 <= x <= 90
    except (ValueError, AssertionError) as e:
        raise ValueError("n must be between 1 and 90") from e

    a, b = 0, 1  # a, b initialized as F(0), F(1)
    for _ in range(1, x):
        a, b = b, a+b  # a, b always store F(i-1), F(i)
    return a

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
