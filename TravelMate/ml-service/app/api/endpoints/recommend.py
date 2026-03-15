# app/api/endpoints/recommend.py
from fastapi import APIRouter, HTTPException, Request
import time
import logging

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
        
        # Vectorize user preferences once
        user_vector = vectorizer.vectorize(recommend_req.quiz_answers.dict())

        # CRITICAL CHECK: Are there places in the request?
        places_provided = bool(getattr(recommend_req, "places", None))

        if places_provided:
            logger.info(f"✅ Using {len(recommend_req.places)} LIVE places from backend")
            # Use unified live-data path in core recommender
            recommendations = await recommender.recommend_from_live_data(
                user_vector=user_vector,
                places=recommend_req.places,
                weather_data=recommend_req.weather.dict() if recommend_req.weather else None,
                top_k=recommend_req.top_k,
            )
        else:
            logger.warning("⚠️ No live places provided, using static destination data")
            # FALLBACK to static data
            recommendations = recommender.recommend(
                user_vector=user_vector,
                weather_data=recommend_req.weather.dict() if recommend_req.weather else None,
                top_k=recommend_req.top_k,
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