# app/api/endpoints/health.py
from fastapi import APIRouter
import time
import os

router = APIRouter()

@router.get("/health", response_model=dict)
async def health_check():
    """
    Health check endpoint for monitoring
    """
    return {
        "status": "healthy",
        "version": os.getenv("VERSION", "1.0.0"),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "timestamp": time.time(),
        "services": {
            "api": "operational",
            "ml_models": "loaded"
        }
    }