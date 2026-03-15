# app/api/endpoints/adapt.py
from fastapi import APIRouter, HTTPException, Request
import logging
from typing import List
from app.models.request_models import AdaptRequest
from app.models.response_models import AdaptResponse, DayPlan, Activity

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/adapt-weather", response_model=AdaptResponse)
async def adapt_itinerary(request: Request, adapt_req: AdaptRequest):
    """
    Adapt an existing itinerary based on weather forecast
    """
    try:
        # Get ML components
        vectorizer = request.app.state.vectorizer
        weather_adapter = request.app.state.weather_adapter
        
        logger.info(f"📥 Weather adaptation request for user: {adapt_req.user_id}")
        
        # Get user vector
        user_vector = vectorizer.vectorize(adapt_req.quiz_answers.dict())
        
        # Convert weather forecast to dict
        weather_list = [w.dict() for w in adapt_req.weather_forecast]
        
        # Adapt itinerary
        result = weather_adapter.adapt_itinerary(
            original_itinerary=adapt_req.itinerary,
            weather_forecast=weather_list,
            user_vector=user_vector,
            user_preferences=adapt_req.quiz_answers.dict()
        )
        
        # Format response
        adapted_days = []
        for day in result['adapted_itinerary']:
            activities = []
            for act in day.get('activities', []):
                activities.append(Activity(
                    name=act.get('name', ''),
                    time=act.get('time', ''),
                    outdoor=act.get('outdoor', False),
                    cost=act.get('cost', 0),
                    adapted_from=act.get('adapted_from'),
                    warning=act.get('warning')
                ))
            
            adapted_days.append(DayPlan(
                date=day.get('date', ''),
                weather=day.get('weather', {}),
                activities=activities,
                weather_adapted=day.get('weather_adapted', False),
                adaptation_reason=day.get('adaptation_reason')
            ))
        
        return AdaptResponse(
            user_id=adapt_req.user_id,
            original_itinerary=adapt_req.itinerary,
            adapted_itinerary=adapted_days,
            total_changes=result['total_changes'],
            adaptation_log=result.get('adaptation_log', []),
            alert_level=result.get('alert_level', 'none'),
            recommendation=result.get('recommendation', '')
        )
        
    except Exception as e:
        logger.error(f"❌ Error adapting itinerary: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))