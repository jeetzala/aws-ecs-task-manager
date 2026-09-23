import os

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
    secret_loaded = bool(os.getenv("TASK_MANAGER_TOKEN"))

    return jsonify(
        status="healthy",
        secret_loaded=secret_loaded
    ), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
