# Local Infrastructure Setup

This document provides instructions for setting some local infrastructure. This is specifically for those non-participants who want to go through the content of the workshop at home.

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

## Author
[@wyhwong](https://github.com/wyhwong)
