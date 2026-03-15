# app/api/endpoints/explain.py
from fastapi import APIRouter, HTTPException, Request
import logging
from app.models.request_models import ExplainRequest
from app.models.response_models import ExplainResponse

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/explain", response_model=ExplainResponse)
async def explain_recommendation(request: Request, explain_req: ExplainRequest):
    """
    Get detailed explanation for why a recommendation was made
    """
    try:
        # Get ML components
        vectorizer = request.app.state.vectorizer
        recommender = request.app.state.recommender
        explanation_gen = request.app.state.explanation_generator
        
        logger.info(f"📥 Explanation request for user: {explain_req.user_id}, activity: {explain_req.activity_id}")
        
        # Get user vector
        user_vector = vectorizer.vectorize(explain_req.quiz_answers.dict())
        
        # Get the specific recommendation
        recommendation = recommender.get_recommendation_by_id(explain_req.activity_id)
        
        if not recommendation:
            raise HTTPException(status_code=404, detail="Activity not found")
        
        # Generate explanations
        context = {}
        if explain_req.weather:
            context['weather'] = explain_req.weather.dict()
        
        explanations = explanation_gen.generate_explanations(
            recommendation=recommendation,
            user_vector=user_vector,
            user_preferences=explain_req.quiz_answers.dict(),
            context=context
        )
        
        # Find alternatives (similar places)
        alternatives = recommender.get_similar_destinations(
            explain_req.activity_id,
            top_k=3
        )
        
        # Format alternatives
        alt_list = []
        for alt in alternatives:
            alt_list.append({
                'id': alt.get('id', ''),
                'name': alt.get('name', ''),
                'match_score': alt.get('final_score', 0)
            })
        
        return ExplainResponse(
            user_id=explain_req.user_id,
            activity_id=explain_req.activity_id,
            match_score=recommendation.get('final_score', 0),
            reasons=explanations['bullet_points'],
            alternatives=alt_list,
            confidence=0.95  # Could be calculated based on data quality
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error generating explanation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))