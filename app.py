import os
import re
import psycopg2
import requests
from flask import Flask, request, jsonify
from qdrant_client import QdrantClient
from qdrant_client.http.models import VectorParams, Distance, PointStruct
from uuid import uuid4

app = Flask(__name__)

# --- Umgebungsvariablen ---
QDRANT_HOST = os.getenv('QDRANT_HOST')
QDRANT_PORT = os.getenv('QDRANT_PORT')

POSTGRES_DB = os.getenv('POSTGRES_DB')
POSTGRES_PORT = os.getenv('POSTGRES_PORT')
POSTGRES_HOST = os.getenv('POSTGRES_HOST')
POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')

OLLAMA_HOST = os.getenv('OLLAMA_HOST')
OLLAMA_PORT = os.getenv('OLLAMA_PORT')

print("Starte Flask-App...")
print("Postgres-Infos:", POSTGRES_DB, POSTGRES_PORT, POSTGRES_HOST, POSTGRES_USER, POSTGRES_PASSWORD)

# --- Datenbankverbindung ---
try:
    connection = psycopg2.connect(
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
        dbname=POSTGRES_DB,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD
    )
    cursor = connection.cursor()
    cursor.execute("""
SELECT
    u.user_id,
    u.username,
    d.document_id,
    d.doc_type,
    d.title,
    d.created_at,
    d.file_name,
    d.file_size_kb,
    d.mime_type,
    m.meta_key,
    m.meta_value
FROM          users                 AS u
JOIN          dms_documents         AS d ON d.user_id   = u.user_id
LEFT JOIN     dms_document_metadata AS m ON m.document_id = d.document_id
ORDER BY      u.user_id, d.document_id, m.meta_key;
""")
    results = cursor.fetchall()
    print("Gefundene Daten in 'documents':", results)
except psycopg2.Error as error:
    print("Fehler bei Postgres-Verbindung:", error)
    results = []

# --- Qdrant einrichten ---
qdrant = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)
qdrant.recreate_collection(
    collection_name="collection",
    vectors_config=VectorParams(size=768, distance=Distance.COSINE)
)

# --- Funktion zur Erzeugung von Embeddings ---
def getembedding(prompt: str):
    url = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/embeddings"
    print("Sende Embedding-Request an:", url)
    response = requests.post(url, json={"model": "nomic-embed-text", "prompt": prompt})
    return response.json()["embedding"]

# --- Embeddings für DB-Daten berechnen & in Qdrant hochladen ---
points = []
for row in results:
    embedding = getembedding(str(row))
    points.append(PointStruct(id=str(uuid4()), vector=embedding, payload={"text": row}))

if points:
    qdrant.upsert(collection_name="collection", points=points)
    print(f"Upsert in Qdrant erfolgreich. Anzahl Punkte: {len(points)}")
else:
    print("Keine Punkte zum Upserten vorhanden.")

# --- Routen ---

@app.route("/")
def index():
    return "Hello World! Dein Backend ist erreichbar."

# Healthcheck-Route
@app.route("/health", methods=["GET"])
def health_check():
    """
    Gibt nur "OK" und Status 200 zurück, wenn das Backend bereit ist.
    """
    return "OK", 200

@app.route("/api/data", methods=["GET"])
def get_data():
    """
    Einfache JSON-Antwort, um Backend zu testen.
    """
    data = {
        "message": "Hallo vom Flask-Backend!",
        "db_rows_loaded": len(results)  # Anzahl geladener Zeilen aus der DB
    }
    return jsonify(data)

@app.route("/api/question", methods=["POST"])
def answer_question():
    """
    Nimmt eine Frage (question) entgegen,
    sucht in Qdrant nach passenden Dokumenten
    und generiert eine Antwort über OLLAMA.
    """
    req_data = request.get_json()
    if not req_data or "question" not in req_data:
        return jsonify({"error": "Bitte 'question' im JSON angeben."}), 400

    question = req_data["question"]
    embedding_response = getembedding(question)

    # Suche in Qdrant
    qdrant_search = qdrant.search(
        collection_name="collection",
        query_vector=embedding_response
    )

    # Fundstellen als Kontext zusammenfassen
    joined_text = "\n\n".join(
        "\n".join(map(str, point.payload["text"]))
        for point in qdrant_search
    )

    # Prompt fürs LLM
    prompt = f"""Nimm nur den folgenden Kontext um die Frage auf Deutsch zu beantworten:

Kontext:
{joined_text}

Frage: {question}

Antwort:
"""
    print(prompt)
    # Request an OLLAMA
    generate_url = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/generate"
    generation_response = requests.post(
        generate_url,
        json={
            "model": "mistral",
            "prompt": prompt,
            "stream": False
        }
    )

    # Antwort auslesen
    if generation_response.status_code == 200:
        answer_text = generation_response.json().get("response", "")
        answer_text_clean = re.sub(r"<think>.*?</think>", "", answer_text, flags=re.DOTALL)
        return jsonify({"answer": answer_text_clean})
    else:
        return jsonify({
            "error": "Fehler bei der Anfrage an OLLAMA",
            "details": generation_response.text
        }), generation_response.status_code

if __name__ == '__main__':
    # Auf 0.0.0.0 lauschen, damit der Service auch außerhalb vom Container erreichbar ist
    app.run(debug=True, host="0.0.0.0", port=5000)
