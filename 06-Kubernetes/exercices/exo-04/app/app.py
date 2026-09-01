from flask import Flask, request, jsonify
import os
import sys

app = Flask(__name__)
LOG_FILE = "/app/logs/events.log"

@app.route("/log", methods=["POST"])
def write_log():
    message = request.json.get("message", "")
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    with open(LOG_FILE, "a") as f:
        f.write(message + "\n")
    return jsonify({"status": "ok", "message": message}), 201

@app.route("/log", methods=["GET"])
def read_log():
    if not os.path.exists(LOG_FILE):
        return jsonify({"logs": []}), 200
    with open(LOG_FILE, "r") as f:
        lines = f.read().splitlines()
    return jsonify({"logs": lines}), 200

@app.route("/crash", methods=["POST"])
def crash():
    sys.exit(1)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)