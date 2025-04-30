#!/bin/bash

# Ollama im Hintergrund starten
/bin/ollama serve &
# Prozess-ID speichern
pid=$!

# Warten, bis Ollama gestartet ist
sleep 5

echo "Lade Nomic-embed-text herunter..."
ollama pull nomic-embed-text
ollama pull mistral
echo "Download abgeschlossen."

sleep 20
# Auf Beendigung des Ollama-Prozesses warten
wait $pid
