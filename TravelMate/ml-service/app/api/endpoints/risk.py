# app/api/endpoints/risk.py
"""
Risk Assessment Endpoint - Checks if trips are dangerous
Feature 2: Risk Classification + Trip Blocking
"""

from fastapi import APIRouter, HTTPException, Request
import logging
import time
from datetime import datetime

from app.models.request_models import RiskRequest
from app.models.response_models import RiskResponse
from app.core.risk_classifier import RiskClassifier

router = APIRouter()
logger = logging.getLogger(__name__)

# Initialize risk classifier
risk_classifier = RiskClassifier()

@router.post("/assess-risk", response_model=RiskResponse)
async def assess_trip_risk(request: Request, risk_req: RiskRequest):
    """
    Assess risk level for a trip and block if too dangerous
    
    This endpoint:
    1. Calculates risk score based on destination, month, and weather
    2. Returns reasons for risk
    3. Blocks trip if risk exceeds threshold
    4. Suggests safer alternatives
    
    Parameters:
    - destination: City or country name
    - month: Month number (1-12)
    - weather: Optional weather data
    
    Returns:
    - risk_score: 0-1 value
    - risk_level: LOW/MEDIUM/HIGH/CRITICAL
    - reasons: List of risk factors
    - block_trip: True if trip should be blocked
    - alternative_destination: Safer alternative suggestion
    """
    start_time = time.time()
    
    try:
        logger.info(f"📥 Risk assessment request for: {risk_req.destination} (Month: {risk_req.month})")
        
        # Convert weather to dict if provided
        weather_dict = risk_req.weather.dict() if risk_req.weather else None
        
        # Calculate risk score
        risk_score, reasons, block_trip = risk_classifier.calculate_risk_score(
            destination=risk_req.destination,
            month=risk_req.month,
            weather=weather_dict
        )
        
        # Get risk level
        risk_level = risk_classifier.get_risk_level(risk_score)
        
        # Suggest alternative if trip is blocked
        alternative = None
        if block_trip:
            alternative = risk_classifier.suggest_alternative(risk_req.destination)
            logger.info(f"🚫 Trip BLOCKED for {risk_req.destination}. Suggesting: {alternative}")
        
        processing_time = (time.time() - start_time) * 1000
        logger.info(f"📤 Risk assessment complete in {processing_time:.2f}ms - Score: {risk_score:.2%}, Level: {risk_level}")
        
        return RiskResponse(
            risk_score=risk_score,
            risk_level=risk_level,
            reasons=reasons,
            block_trip=block_trip,
            alternative_destination=alternative
        )
        
    except Exception as e:
        logger.error(f"❌ Error assessing risk: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/risk/health")
async def risk_health():
    """Health check for risk assessment service"""
    return {
        "status": "healthy",
        "feature": "Risk Classification & Trip Blocking",
        "risk_thresholds": risk_classifier.risk_thresholds
    }

@router.get("/risk/seasonal/{destination}")
async def check_seasonal_risk(destination: str, month: int = None):
    """
    Check seasonal risk for a destination
    
    If month not provided, uses current month
    """
    try:
        if month is None:
            month = datetime.now().month
        
        risk_score, reasons, _ = risk_classifier._check_seasonal_risks(destination, month)
        
        return {
            "destination": destination,
            "month": month,
            "risk_score": risk_score,
            "risk_level": risk_classifier.get_risk_level(risk_score),
            "reasons": reasons
        }
        
    except Exception as e:
        logger.error(f"❌ Error checking seasonal risk: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/risk/alternatives/{destination}")
async def get_alternatives(destination: str):
    """Get safer alternatives for a risky destination"""
    try:
        alternative = risk_classifier.suggest_alternative(destination)
        
        return {
            "original_destination": destination,
            "suggested_alternative": alternative,
            "message": f"Consider {alternative} instead - it's safer during this time"
        }
        
    except Exception as e:
        logger.error(f"❌ Error getting alternatives: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))