# app/api/endpoints/group.py
from fastapi import APIRouter, HTTPException, Request
import logging
from typing import List
from app.models.request_models import GroupRequest
from app.models.response_models import GroupResponse, GroupItinerary

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/group-harmony", response_model=GroupResponse)
async def optimize_group(request: Request, group_req: GroupRequest):
    """
    Optimize itinerary for a group of travelers
    """
    try:
        # Get ML components
        group_optimizer = request.app.state.group_optimizer
        
        logger.info(f"📥 Group optimization request for {len(group_req.users)} users")
        
        # Optimize for group
        result = group_optimizer.optimize_for_group(
            users=group_req.users,
            destination=group_req.destination,
            days=group_req.days,
            constraints=group_req.constraints
        )
        
        # Format response
        group_itinerary = []
        for day in result['itinerary']:
            group_itinerary.append(GroupItinerary(
                day=day['day'],
                date=day.get('date', f"Day {day['day']}"),
                activities=day.get('activities', []),
                priority_user=day.get('priority_user', ''),
                happiness=day.get('happiness', {})
            ))
        
        return GroupResponse(
            itinerary=group_itinerary,
            fairness_score=result['fairness_score'],
            happiness_scores=result['happiness_scores'],
            fairness_metrics=result['fairness_metrics'],
            recommendations=result.get('recommendations', []),
            group_summary=result['group_summary']
        )
        
    except Exception as e:
        logger.error(f"❌ Error optimizing group: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))