#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Start Ollama service
echo -e "${BLUE}Starting Ollama service...${NC}"
/bin/ollama serve &
OLLAMA_PID=$!

# Wait for service to be ready
until curl -s http://localhost:11434/api/tags > /dev/null 2>&1; do
    sleep 2
done

# Get model name from environment variable
MODEL_NAME=${MODEL_NAME:-"gpt-oss:20b"}

# Pull model if not exists
if ! /bin/ollama list | grep -q "$MODEL_NAME"; then
    /bin/ollama pull "$MODEL_NAME"
fi

# Load model into memory
curl -s http://localhost:11434/api/generate -d "{\"model\":\"$MODEL_NAME\",\"keep_alive\":-1}" > /dev/null

echo -e "${GREEN}Ollama ready with model: $MODEL_NAME${NC}"

# Keep service running
wait $OLLAMA_PID
