# app/api/endpoints/gemini_generate.py
"""
Endpoint for on-demand place generation using Gemini
Backend can call this to get place data
"""

from fastapi import APIRouter, HTTPException, Request
import logging
from typing import List, Optional
from pydantic import BaseModel

from app.services.gemini_place_service import GeminiPlaceService

router = APIRouter()
logger = logging.getLogger(__name__)

# Initialize Gemini service
gemini_service = GeminiPlaceService()

class GenerateRequest(BaseModel):
    destination: str
    count: int = 20
    user_id: Optional[str] = None

class GenerateResponse(BaseModel):
    destination: str
    places: List[dict]
    source: str  # "gemini", "cache", or "fallback"
    count: int

@router.post("/generate-places", response_model=GenerateResponse)
async def generate_places(request: GenerateRequest):
    """
    Generate place data for a destination using Gemini
    Backend can call this to get places for any destination
    """
    try:
        logger.info(f"📥 Generating {request.count} places for {request.destination}")
        
        # Optional: Get user preferences if user_id provided
        user_prefs = None
        if request.user_id:
            # You could fetch user preferences here
            pass
        
        # Generate places
        places = await gemini_service.generate_places(
            destination=request.destination,
            count=request.count,
            user_preferences=user_prefs
        )
        
        # Determine source for response
        cache_key = f"{request.destination}_{request.count}"
        source = "gemini"
        if cache_key in gemini_service.cache:
            source = "cache"
        elif len(places) <= 5:
            source = "fallback"
        
        return GenerateResponse(
            destination=request.destination,
            places=places,
            source=source,
            count=len(places)
        )
        
    except Exception as e:
        logger.error(f"❌ Error generating places: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/generate-and-save")
async def generate_and_save(destinations: List[str], filename: str = "places.json"):
    """
    Generate places for multiple destinations and save to file
    Useful for pre-populating your database
    """
    try:
        gemini_service.save_to_file(destinations, filename)
        return {"message": f"Generated places saved to {filename}", "destinations": destinations}
    except Exception as e:
        logger.error(f"❌ Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/gemini-status")
async def gemini_status():
    """Check if Gemini service is available"""
    return {
        "available": gemini_service.available,
        "cache_size": len(gemini_service.cache)
    }