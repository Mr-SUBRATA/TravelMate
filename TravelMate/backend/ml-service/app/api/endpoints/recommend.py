# app/api/endpoints/recommend.py
from fastapi import APIRouter, HTTPException, Request
import time
import logging
import numpy as np
from typing import List, Dict, Optional

from app.models.request_models import RecommendRequest
from app.models.response_models import RecommendResponse, Recommendation, ScoreDetail
from app.config import settings

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/recommend", response_model=RecommendResponse)
async def get_recommendations(request: Request, recommend_req: RecommendRequest):
    """
    Get personalized travel recommendations based on user preferences
    NOW HANDLES LIVE PLACES FROM BACKEND!
    """
    start_time = time.time()
    
    try:
        # Get ML components
        vectorizer = request.app.state.vectorizer
        recommender = request.app.state.recommender
        
        logger.info(f"📥 Recommendation request for user: {recommend_req.user_id}")
        logger.info(f"📍 Destination: {recommend_req.destination}")
        
        # CRITICAL CHECK: Are there places in the request?
        places_provided = hasattr(recommend_req, 'places') and recommend_req.places is not None and len(recommend_req.places) > 0
        
        if places_provided:
            logger.info(f"✅ Using {len(recommend_req.places)} LIVE places from backend")
            # USE THE LIVE DATA FROM BACKEND!
            recommendations = await process_live_places(
                vectorizer,
                recommend_req.quiz_answers.dict(),
                recommend_req.places,
                recommend_req.weather.dict() if recommend_req.weather else None,
                recommend_req.top_k
            )
        else:
            logger.warning("⚠️ No live places provided, using static destination data")
            # FALLBACK to static data
            user_vector = vectorizer.vectorize(recommend_req.quiz_answers.dict())
            recommendations = recommender.recommend(
                user_vector=user_vector,
                weather_data=recommend_req.weather.dict() if recommend_req.weather else None,
                top_k=recommend_req.top_k
            )
        
        # Format response
        formatted_recommendations = []
        for rec in recommendations:
            formatted_recommendations.append(
                Recommendation(
                    id=rec.get('id', ''),
                    name=rec.get('name', 'Unknown'),
                    categories=rec.get('categories', []),
                    cost=rec.get('cost', 0),
                    outdoor=rec.get('outdoor', False),
                    city=rec.get('city', recommend_req.destination),
                    match_score=rec.get('final_score', 0),
                    scores=ScoreDetail(
                        similarity=rec.get('scores', {}).get('similarity', 0),
                        weather=rec.get('scores', {}).get('weather', 0),
                        crowd=rec.get('scores', {}).get('crowd', 0),
                        budget=rec.get('scores', {}).get('budget', 0),
                        time=rec.get('scores', {}).get('time', 0),
                        popularity=rec.get('scores', {}).get('popularity', 0)
                    )
                )
            )
        
        processing_time = (time.time() - start_time) * 1000
        logger.info(f"📤 Generated {len(recommendations)} recommendations in {processing_time:.2f}ms")
        
        return RecommendResponse(
            user_id=recommend_req.user_id,
            recommendations=formatted_recommendations,
            processing_time_ms=round(processing_time, 2),
            model_version=settings.VERSION
        )
        
    except Exception as e:
        logger.error(f"❌ Error generating recommendations: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

async def process_live_places(vectorizer, quiz_answers_dict, places, weather_data, top_k):
    """Process live places from backend"""
    # Vectorize user preferences
    user_vector = vectorizer.vectorize(quiz_answers_dict)
    
    recommendations = []
    
    for place in places:
        # Create vector from categories
        place_vector = categories_to_vector(place.get('categories', []))
        
        # Calculate similarity
        similarity = np.dot(user_vector, place_vector) / (
            np.linalg.norm(user_vector) * np.linalg.norm(place_vector) + 0.001
        )
        
        # Weather adjustment
        weather_score = 0.8
        is_outdoor = 'outdoor' in place.get('categories', []) or 'mountains' in place.get('categories', []) or 'trekking' in place.get('categories', [])
        
        if weather_data:
            if is_outdoor and weather_data.get('rain_prob', 0) > 0.6:
                similarity *= 0.3
                weather_score = 0.3
            elif is_outdoor:
                weather_score = 0.9
            else:
                weather_score = 1.0
        
        # Calculate cost from price_level (1-4 scale)
        price_level = place.get('price_level', 1)
        cost = price_level * 15
        
        # Get rating
        rating = place.get('rating', 4.0)
        
        recommendations.append({
            'id': place.get('place_id', f"place_{len(recommendations)}"),
            'name': place.get('name', 'Unknown'),
            'categories': place.get('categories', []),
            'cost': cost,
            'outdoor': is_outdoor,
            'city': place.get('city', 'Unknown'),
            'final_score': float(similarity),
            'scores': {
                'similarity': float(similarity),
                'weather': weather_score,
                'crowd': 0.7,
                'budget': 0.8,
                'time': 0.8,
                'popularity': rating / 5.0
            }
        })
    
    # Sort by score and return top_k
    recommendations.sort(key=lambda x: x['final_score'], reverse=True)
    return recommendations[:top_k]

def categories_to_vector(categories: List[str]) -> np.ndarray:
    """Convert ANY categories to a 50-dim vector"""
    vector = np.zeros(50)
    
    # Category to dimension mapping (expanded for Pakistani places)
    category_map = {
        'art': (0, 10), 'museum': (0, 10), 'gallery': (0, 10),
        'food': (10, 20), 'restaurant': (10, 20), 'cafe': (10, 20), 
        'street_food': (10, 20), 'biryani': (10, 20), 'cuisine': (10, 20),
        'outdoor': (20, 30), 'park': (20, 30), 'nature': (20, 30), 
        'beach': (20, 30), 'mountain': (20, 30), 'mountains': (20, 30),
        'valley': (20, 30), 'lake': (20, 30), 'scenic': (20, 30),
        'trekking': (20, 30), 'camping': (20, 30), 'adventure': (20, 30),
        'history': (30, 40), 'historical': (30, 40), 'monument': (30, 40), 
        'fort': (30, 40), 'palace': (30, 40), 'unesco': (30, 40),
        'archaeological': (30, 40), 'ruins': (30, 40), 'architecture': (30, 40),
        'cultural': (30, 40), 'heritage': (30, 40),
        'spiritual': (40, 45), 'religious': (40, 45), 'temple': (40, 45), 
        'mosque': (40, 45), 'church': (40, 45), 'shrine': (40, 45),
        'sufi': (40, 45), 'saint': (40, 45),
        'shopping': (45, 48), 'market': (45, 48), 'bazaar': (45, 48),
        'adventure': (48, 50), 'hiking': (48, 50), 'climbing': (48, 50),
        'skiing': (48, 50), 'jeep': (48, 50), 'expedition': (48, 50)
    }
    
    # Add vector values based on categories
    for cat in categories:
        cat_lower = cat.lower()
        for key, (start, end) in category_map.items():
            if key in cat_lower:
                vector[start:end] += 0.5
    
    # Normalize to unit vector
    norm = np.linalg.norm(vector)
    if norm > 0:
        vector = vector / norm
    
    return vector