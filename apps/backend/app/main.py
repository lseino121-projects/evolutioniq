from fastapi import FastAPI
import os

app = FastAPI()

@app.get("/healthz")
def health():
    return {"ok": True}

@app.get("/")
def root():
    return {"message": "Top .001% DevOps Prep — Backend"}