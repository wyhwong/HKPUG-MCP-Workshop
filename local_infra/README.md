# Local Infrastructure Setup

```bash
docker-compose up -d
```

Checking after Ollama is up

```bash
curl http://localhost:11434/api/generate -d '{
    "model": "<MODEL_NAME>",
    "prompt":"Why is the sky blue?",
    "stream": false
}'
```
