#!/usr/bin/env bash
# One-shot bring-up for the local inventory automation stack.
# Usage: ./scripts/setup.sh
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "No .env found. Copying .env.example -> .env"
  cp .env.example .env
  echo "Edit .env now to set POSTGRES_PASSWORD, N8N_ENCRYPTION_KEY, WAHA_API_KEY, etc."
  read -rp "Press Enter once .env is filled in to continue..."
fi

echo "Starting Docker Compose stack (postgres, ollama, waha, n8n)..."
docker compose up -d

echo "Waiting for Ollama to be ready..."
until curl -sf http://localhost:11434/api/tags > /dev/null; do
  sleep 2
done

MODEL="${OLLAMA_MODEL:-llama3.2-vision:11b}"
echo "Pulling vision model: $MODEL (this can take a while on first run)..."
docker exec -it ollama ollama pull "$MODEL"

echo ""
echo "Stack is up."
echo "  n8n:  http://localhost:5678"
echo "  WAHA: http://localhost:3000"
echo ""
echo "Next steps:"
echo "  1. Open WAHA at http://localhost:3000 and scan the QR code to link WhatsApp."
echo "  2. Open n8n at http://localhost:5678, add your Google Sheets/Drive credentials."
echo "  3. Import workflows/inventory-pipeline.json and activate it."
