from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline

app = FastAPI(title="MoodBuddy AI Service")

# Load model ONCE (important for speed)
sentiment_pipeline = pipeline(
    "sentiment-analysis",
    model="distilbert-base-uncased-finetuned-sst-2-english"
)

class TextInput(BaseModel):
    text: str

@app.get("/")
def root():
    return {"status": "MoodBuddy AI is running"}

@app.post("/analyze")
def analyze_sentiment(input: TextInput):
    result = sentiment_pipeline(input.text)[0]

    return {
        "label": result["label"],
        "score": float(result["score"])
    }
