# app/services/gemini_place_service.py
"""
Gemini-powered place generation service
Generates realistic place data on-demand for any destination
"""

import google.generativeai as genai
import json
import os
import logging
from typing import List, Dict, Optional
import asyncio
from datetime import datetime

logger = logging.getLogger(__name__)

class GeminiPlaceService:
    """
    Uses Google Gemini to generate place data for any destination
    Falls back to cached/mock data if API fails
    """
    
    def __init__(self):
        # Configure Gemini
        api_key = "AIzaSyBG8EQkg-_WATRIc_zA9IOkMa7uyhHa_ts" #os.getenv("GEMINI_API_KEY")
        
        if not api_key:
            logger.warning("⚠️ GEMINI_API_KEY not found in environment")
            self.available = False
            return
            
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-1.5-flash')
        self.available = True
        self.cache = {}  # Simple in-memory cache
        logger.info("✅ Gemini Place Service initialized")
    
    async def generate_places(self, 
                             destination: str, 
                             count: int = 20,
                             user_preferences: Optional[Dict] = None) -> List[Dict]:
        """
        Generate places for a destination using Gemini
        
        Args:
            destination: City or country name
            count: Number of places to generate
            user_preferences: Optional user preferences to personalize results
            
        Returns:
            List of places in the format your ML service expects
        """
        # Check cache first
        cache_key = f"{destination}_{count}"
        if cache_key in self.cache:
            logger.info(f"📦 Cache hit for {destination}")
            return self.cache[cache_key]
        
        if not self.available:
            return self._get_fallback_places(destination, count)
        
        try:
            # Build prompt with user preferences if available
            prompt = self._build_prompt(destination, count, user_preferences)
            
            # Call Gemini (with timeout)
            response = await asyncio.wait_for(
                self.model.generate_content_async(prompt),
                timeout=10.0
            )
            
            # Parse response
            places = self._parse_response(response.text, destination)
            
            if places and len(places) >= 5:
                # Cache successful response
                self.cache[cache_key] = places
                logger.info(f"✅ Generated {len(places)} places for {destination}")
                return places
            else:
                logger.warning(f"⚠️ Gemini returned insufficient places, using fallback")
                return self._get_fallback_places(destination, count)
                
        except asyncio.TimeoutError:
            logger.error(f"⏱️ Gemini timeout for {destination}")
            return self._get_fallback_places(destination, count)
        except Exception as e:
            logger.error(f"❌ Gemini error: {str(e)}")
            return self._get_fallback_places(destination, count)
    
    def _build_prompt(self, destination: str, count: int, user_preferences: Optional[Dict]) -> str:
        """Build a detailed prompt for Gemini"""
        
        pref_context = ""
        if user_preferences:
            pref_context = f"""
            User preferences:
            - Art interest: {user_preferences.get('art_interest', 3)}/5
            - Food interest: {user_preferences.get('foodie_score', 3)}/5
            - Adventure interest: {user_preferences.get('adventure_seeking', 3)}/5
            - Interests: {user_preferences.get('interests', [])}
            
            Consider these preferences when suggesting places.
            """
        
        return f"""Generate a list of {count} places in {destination} for a travel planning app.

        {pref_context}

        IMPORTANT: Return ONLY a valid JSON array. No markdown, no explanations, no additional text.

        Each place must have this exact structure:
        {{
            "place_id": "unique_id_here",
            "name": "Place Name",
            "categories": ["category1", "category2"],
            "price_level": 2,
            "rating": 4.5,
            "city": "{destination}"
        }}

        Category options: museum, art, historical, landmark, food, restaurant, outdoor, 
                         nature, shopping, religious, entertainment, nightlife, adventure

        Price level: 1 (budget), 2 (moderate), 3 (expensive), 4 (luxury)
        Rating: between 3.0 and 5.0, with one decimal place

        Guidelines:
        - Include a diverse mix of places (landmarks, restaurants, museums, parks, etc.)
        - Make ratings realistic (famous places 4.5+, hidden gems 4.0-4.4)
        - place_id should be unique (e.g., "paris_louvre_001")
        - Include the city field exactly as "{destination}"

        Example format:
        [
            {{
                "place_id": "paris_louvre_001",
                "name": "Louvre Museum",
                "categories": ["museum", "art", "historical"],
                "price_level": 2,
                "rating": 4.8,
                "city": "Paris"
            }}
        ]

        Generate exactly {count} places. Return ONLY the JSON array."""
    
    def _parse_response(self, text: str, destination: str) -> List[Dict]:
        """Parse Gemini response, handling various response formats"""
        
        # Clean the response text
        text = text.strip()
        
        # Remove markdown code blocks if present
        if text.startswith("```json"):
            text = text[7:]
        if text.startswith("```"):
            text = text[3:]
        if text.endswith("```"):
            text = text[:-3]
        
        text = text.strip()
        
        # Try to parse JSON
        try:
            places = json.loads(text)
            
            # Validate and clean each place
            validated = []
            for p in places:
                # Ensure required fields
                cleaned = {
                    'place_id': p.get('place_id', f"{destination.lower()}_{len(validated)}"),
                    'name': p.get('name', f"Place in {destination}"),
                    'categories': p.get('categories', ['tourist_attraction']),
                    'price_level': min(4, max(1, p.get('price_level', 2))),
                    'rating': min(5.0, max(3.0, p.get('rating', 4.0))),
                    'city': destination
                }
                validated.append(cleaned)
            
            return validated
            
        except json.JSONDecodeError as e:
            logger.error(f"JSON parse error: {e}")
            # Try to extract JSON from response
            import re
            json_match = re.search(r'\[.*\]', text, re.DOTALL)
            if json_match:
                try:
                    places = json.loads(json_match.group())
                    return places
                except:
                    pass
            return []
    
    def _get_fallback_places(self, destination: str, count: int) -> List[Dict]:
        """Provide fallback data when Gemini fails"""
        
        # Common categories for fallback
        categories_pool = [
            ['museum', 'art'],
            ['landmark', 'historical'],
            ['restaurant', 'food'],
            ['park', 'outdoor'],
            ['shopping', 'mall'],
            ['religious', 'historical'],
            ['entertainment', 'nightlife']
        ]
        
        places = []
        for i in range(min(count, 10)):  # Limit to 10 in fallback
            cats = categories_pool[i % len(categories_pool)]
            places.append({
                'place_id': f"{destination.lower()}_fallback_{i}",
                'name': f"{destination} {cats[0].title()} {i+1}",
                'categories': cats,
                'price_level': (i % 4) + 1,
                'rating': round(4.0 + (i % 10) / 10, 1),
                'city': destination
            })
        
        return places
    
    def generate_batch(self, destinations: List[str], count_per: int = 15) -> Dict[str, List[Dict]]:
        """
        Generate places for multiple destinations (can be run offline)
        Useful for pre-populating your database
        """
        results = {}
        for dest in destinations:
            # Use asyncio.run for each or run sequentially
            import asyncio
            places = asyncio.run(self.generate_places(dest, count_per))
            results[dest] = places
            logger.info(f"Generated {len(places)} places for {dest}")
        return results
    
    def save_to_file(self, destinations: List[str], filename: str = "generated_places.json"):
        """Generate and save places to a JSON file"""
        results = self.generate_batch(destinations)
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        logger.info(f"✅ Saved generated places to {filename}")
