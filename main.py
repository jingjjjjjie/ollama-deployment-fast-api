from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import os

app = FastAPI(title="Ollama FastAPI", description="FastAPI wrapper for Ollama")

OLLAMA_BASE_URL = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")


class ChatRequest(BaseModel):
    model: str
    prompt: str


class ChatResponse(BaseModel):
    response: str
    model: str


@app.get("/")
async def root():
    return {"message": "Ollama FastAPI is running", "docs": "/docs"}


@app.get("/health")
async def health_check():
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{OLLAMA_BASE_URL}/api/tags")
            if response.status_code == 200:
                return {"status": "healthy", "ollama": "connected"}
            else:
                return {"status": "unhealthy", "ollama": "disconnected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Ollama service unavailable: {str(e)}")


@app.get("/models")
async def list_running_models():
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{OLLAMA_BASE_URL}/api/ps")
            response.raise_for_status()
            return response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch running models: {str(e)}")


@app.post("/chat")
async def chat(request: ChatRequest):
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            ollama_request = {
                "model": request.model,
                "prompt": request.prompt,
                "stream": False
            }
            response = await client.post(
                f"{OLLAMA_BASE_URL}/api/generate",
                json=ollama_request
            )
            response.raise_for_status()
            result = response.json()
            return {
                "response": result.get("response", ""),
                "model": request.model
            }
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=e.response.status_code, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chat request failed: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8010)
