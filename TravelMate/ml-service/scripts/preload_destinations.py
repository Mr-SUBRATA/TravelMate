# scripts/preload_destinations.py
"""
Script to pre-generate place data for popular destinations
Run this once to populate your database
"""

import asyncio
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.services.gemini_place_service import GeminiPlaceService
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Popular destinations for your travel app
POPULAR_DESTINATIONS = [
    "Paris", "London", "Rome", "Barcelona", "Amsterdam",
    "Tokyo", "Bangkok", "Singapore", "Dubai", "Istanbul",
    "New York", "Los Angeles", "Las Vegas", "Miami", "Chicago",
    "Sydney", "Melbourne", "Auckland",
    "Cape Town", "Marrakech", "Cairo",
    "Rio de Janeiro", "Lima", "Buenos Aires",
    "Mumbai", "Delhi", "Jaipur", "Goa", "Kerala", "Agra", "Varanasi",
    "Islamabad", "Lahore", "Karachi", "Hunza"
]

async def preload_destinations():
    """Generate places for all popular destinations"""
    
    service = GeminiPlaceService()
    
    if not service.available:
        logger.error("❌ Gemini service not available. Check API key.")
        return
    
    logger.info(f"🚀 Starting preload for {len(POPULAR_DESTINATIONS)} destinations")
    
    all_places = {}
    for i, dest in enumerate(POPULAR_DESTINATIONS, 1):
        logger.info(f"[{i}/{len(POPULAR_DESTINATIONS)}] Generating {dest}...")
        places = await service.generate_places(dest, count=20)
        all_places[dest] = places
        logger.info(f"   ✅ Generated {len(places)} places")
    
    # Save to file
    filename = "preloaded_places.json"
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(all_places, f, indent=2, ensure_ascii=False)
    
    logger.info(f"✅ All destinations saved to {filename}")
    
    # Also save as a single array format for your ML service
    all_places_array = []
    for dest, places in all_places.items():
        all_places_array.extend(places)
    
    with open("all_places_array.json", 'w', encoding='utf-8') as f:
        json.dump(all_places_array, f, indent=2, ensure_ascii=False)
    
    logger.info(f"✅ Combined {len(all_places_array)} places saved to all_places_array.json")

if __name__ == "__main__":
    asyncio.run(preload_destinations())