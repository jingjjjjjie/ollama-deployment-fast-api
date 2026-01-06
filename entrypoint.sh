#!/bin/bash
set -e

# Start Ollama in background
echo "Starting Ollama service..."
/bin/ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "Waiting for Ollama to start..."
until curl -s http://localhost:11434/api/tags > /dev/null 2>&1; do
    sleep 2
done
echo "Ollama is ready!"

# List of required models
MODELS=(
    "gpt-oss:20b"
)

# Check and pull models if needed
for model in "${MODELS[@]}"; do
    echo "Checking if model $model exists..."
    if /bin/ollama list | grep -q "$model"; then
        echo "✓ Model $model already exists"
    else
        echo "→ Pulling model $model..."
        /bin/ollama pull "$model"
        echo "✓ Model $model downloaded successfully"
    fi

    # Load model into memory
    echo "→ Loading model $model into memory..."
    curl -s http://localhost:11434/api/generate -d "{\"model\":\"$model\",\"keep_alive\":-1}" > /dev/null
    echo "✓ Model $model loaded"
done

echo "All models ready and loaded! Ollama is running."

# Keep Ollama running in foreground
wait $OLLAMA_PID
