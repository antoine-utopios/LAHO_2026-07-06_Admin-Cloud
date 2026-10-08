"""Front-end : interface web qui appelle l'API back-end côté serveur.

Le navigateur ne parle qu'au front. C'est le front qui appelle l'API :
l'API (et a fortiori la BDD) n'ont donc pas besoin d'être exposées sur Internet.
"""
import os

import requests
from flask import Flask, redirect, render_template, request, url_for

app = Flask(__name__)

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:5000").rstrip("/")
TIMEOUT = 5


def api(method: str, path: str, **kwargs):
    return requests.request(method, f"{BACKEND_URL}{path}", timeout=TIMEOUT, **kwargs)


@app.get("/")
def index():
    tasks, health, error = [], {}, None
    try:
        health = api("GET", "/health").json()
        tasks = api("GET", "/api/tasks").json()
    except requests.RequestException as exc:
        error = f"API injoignable ({BACKEND_URL}) : {exc.__class__.__name__}"
    return render_template(
        "index.html",
        tasks=tasks,
        health=health,
        error=error,
        front_host=os.uname().nodename,
        backend_url=BACKEND_URL,
    )


@app.post("/tasks")
def add_task():
    title = request.form.get("title", "").strip()
    if title:
        api("POST", "/api/tasks", json={"title": title})
    return redirect(url_for("index"))


@app.post("/tasks/<int:task_id>/toggle")
def toggle_task(task_id: int):
    api("PATCH", f"/api/tasks/{task_id}")
    return redirect(url_for("index"))


@app.post("/tasks/<int:task_id>/delete")
def delete_task(task_id: int):
    api("DELETE", f"/api/tasks/{task_id}")
    return redirect(url_for("index"))


@app.get("/health")
def health():
    return {"status": "ok"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
