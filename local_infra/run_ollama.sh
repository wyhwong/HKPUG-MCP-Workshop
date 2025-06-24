#!/bin/bash
echo "Starting Ollama..."
ollama serve &
sleep 5  # Wait for Ollama to start
ollama run ${MODEL_NAME}
tail -f /dev/null  # Keep the script running
