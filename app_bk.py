import psycopg2
import os
import requests
from flask import Flask, request, jsonify
from qdrant_client import QdrantClient
from qdrant_client.http.models import VectorParams, Distance, PointStruct
from uuid import uuid4

app = Flask(__name__)

QDRANT_HOST = os.getenv('QDRANT_HOST')
QDRANT_PORT = os.getenv('QDRANT_PORT')

POSTGRES_DB = os.getenv('POSTGRES_DB')
POSTGRES_PORT = os.getenv('POSTGRES_PORT')
POSTGRES_HOST = os.getenv('POSTGRES_HOST')
POSTGRES_USER = os.getenv('POSTGRES_USER')
POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')

OLLAMA_HOST = os.getenv('OLLAMA_HOST')
OLLAMA_PORT = os.getenv('OLLAMA_PORT')


print ("Hello")
print (POSTGRES_DB, POSTGRES_PORT, POSTGRES_HOST, POSTGRES_USER, POSTGRES_PASSWORD)

try:
    connection = psycopg2.connect(host=POSTGRES_HOST, port=POSTGRES_PORT, dbname=POSTGRES_DB, user=POSTGRES_USER, password=POSTGRES_PASSWORD)
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM dms_documents")

    results = cursor.fetchall()
    print(results)
    for row in results:
        print(row)

except psycopg2.Error as error :
    print(error)

qdrant = QdrantClient(host=QDRANT_HOST,port=QDRANT_PORT)
qdrant.recreate_collection("collection",vectors_config=VectorParams(size=768,distance=Distance.COSINE))

def getembedding(prompt):
    url = "http://"+ OLLAMA_HOST +":"+OLLAMA_PORT+"/api/embeddings"
    print(url)
    response = requests.post(url, json={"model": "nomic-embed-text", "prompt": prompt})
    print(response)
    return response.json()["embedding"]

points=[]
for row in results:
    embedding = getembedding(str(row))
    points.append(PointStruct(id=str(uuid4()),vector=embedding, payload={"text":row}))

qdrant.upsert(collection_name="collection", points=points)
print(f"points length {len(points)}")


question = "Welche Rechnungen hast du?"
embeddingresponse = getembedding(question)
qdrantsearch = qdrant.search(collection_name = "collection", query_vector = embeddingresponse)

joined_text = "\n\n".join(
    "\n".join(map(str, point.payload["text"]))
    for point in qdrantsearch
)

print(joined_text)

prompt = f"""Use the following context to answer the question:

Context:
{joined_text}

Question: {question}

Answer:"""


urlama = "http://"+ OLLAMA_HOST +":"+OLLAMA_PORT+"/api/generate"
generation_response = requests.post(
    urlama,
    json={
        "model": "mistral",  # Or llama3, or whatever you pulled
        "prompt": prompt,
        "stream": False
    }
)

print("\n Answer:")
print(generation_response.json()["response"])

