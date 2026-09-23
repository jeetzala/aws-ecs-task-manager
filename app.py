from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return """
    <h1>AWS ECS Task Manager</h1>
    <p>Containerized Application Running on ECS Fargate</p>
    """


@app.route("/health")
def health():
    return jsonify(status="healthy"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
