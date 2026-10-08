"""API back-end : gestion d'une liste de tâches stockée dans MySQL."""
import os
import time

import pymysql
from flask import Flask, jsonify, request

app = Flask(__name__)

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "appuser"),
    "password": os.getenv("DB_PASSWORD", "apppassword"),
    "database": os.getenv("DB_NAME", "tpdb"),
    "cursorclass": pymysql.cursors.DictCursor,
    "autocommit": True,
    "connect_timeout": 5,
}


def get_conn(retries: int = 10, delay: int = 3):
    """Connexion à MySQL avec quelques tentatives (la BDD peut démarrer après l'API)."""
    last_error = None
    for _ in range(retries):
        try:
            return pymysql.connect(**DB_CONFIG)
        except pymysql.MySQLError as exc:
            last_error = exc
            time.sleep(delay)
    raise last_error


@app.get("/health")
def health():
    try:
        with get_conn(retries=1) as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
        return jsonify(status="ok", database="up", host=os.uname().nodename)
    except Exception as exc:  # noqa: BLE001
        return jsonify(status="degraded", database="down", error=str(exc)), 503


@app.get("/api/tasks")
def list_tasks():
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("SELECT id, title, done, created_at FROM tasks ORDER BY id DESC")
        rows = cur.fetchall()
    for row in rows:
        row["done"] = bool(row["done"])
        row["created_at"] = row["created_at"].isoformat()
    return jsonify(rows)


@app.post("/api/tasks")
def create_task():
    data = request.get_json(silent=True) or {}
    title = (data.get("title") or "").strip()
    if not title:
        return jsonify(error="Le champ 'title' est obligatoire"), 400
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("INSERT INTO tasks (title) VALUES (%s)", (title[:255],))
        task_id = cur.lastrowid
    return jsonify(id=task_id, title=title, done=False), 201


@app.patch("/api/tasks/<int:task_id>")
def toggle_task(task_id: int):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("UPDATE tasks SET done = NOT done WHERE id = %s", (task_id,))
        if cur.rowcount == 0:
            return jsonify(error="Tâche introuvable"), 404
    return jsonify(id=task_id, toggled=True)


@app.delete("/api/tasks/<int:task_id>")
def delete_task(task_id: int):
    with get_conn() as conn, conn.cursor() as cur:
        cur.execute("DELETE FROM tasks WHERE id = %s", (task_id,))
        if cur.rowcount == 0:
            return jsonify(error="Tâche introuvable"), 404
    return "", 204


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
