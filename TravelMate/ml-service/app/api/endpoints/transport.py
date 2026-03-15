# app/api/endpoints/transport.py
"""
Transport Options Endpoint - Multi-mode transport with costs
Feature 3: Transportation Medium + Real Costs
"""

from fastapi import APIRouter, HTTPException, Request, Query
import logging
import time
from typing import Optional

from app.models.request_models import TransportRequest
from app.models.response_models import TransportResponse, TransportOption
from app.core.transport_costs import TransportCostCalculator

router = APIRouter()
logger = logging.getLogger(__name__)

# Initialize transport calculator
transport_calc = TransportCostCalculator()

@router.post("/transport", response_model=TransportResponse)
async def get_transport_options(request: Request, transport_req: TransportRequest):
    """
    Get all transport options between source and destination
    
    This endpoint:
    1. Returns multiple transport modes (flight, train, bus, etc.)
    2. Includes costs, durations, and CO2 emissions
    3. Sorts by preference (cheapest, fastest, eco, balanced)
    
    Parameters:
    - source: Starting city
    - destination: Target city
    - preference: 'cheapest', 'fastest', 'eco', or 'balanced' (default)
    
    Returns:
    - List of transport options with details
    - Best option based on preference
    """
    start_time = time.time()
    
    try:
        logger.info(f"📥 Transport request: {transport_req.source} → {transport_req.destination}")
        
        # Get best option based on preference
        result = transport_calc.get_best_option(
            source=transport_req.source,
            destination=transport_req.destination,
            preference=transport_req.preference
        )
        
        if 'error' in result:
            return TransportResponse(
                source=transport_req.source,
                destination=transport_req.destination,
                options=[],
                best_option=None,
                total_options=0,
                message=result['message']
            )
        
        # Format options
        options = []
        for opt in result['all_options']:
            options.append(TransportOption(
                mode=opt['mode'],
                mode_emoji=opt['mode_emoji'],
                mode_name=opt['mode_name'],
                distance_km=opt['distance_km'],
                duration_hours=opt['duration_hours'],
                duration_minutes=opt['duration_minutes'],
                duration_display=opt['duration_display'],
                cost_usd=opt['cost_usd'],
                cost_display=opt['cost_display'],
                co2_kg=opt['co2_kg'],
                co2_display=opt['co2_display'],
                comfort_level=opt['comfort_level'],
                availability=opt['availability']
            ))
        
        # Format best option
        best = result['best_option']
        best_option = TransportOption(
            mode=best['mode'],
            mode_emoji=best['mode_emoji'],
            mode_name=best['mode_name'],
            distance_km=best['distance_km'],
            duration_hours=best['duration_hours'],
            duration_minutes=best['duration_minutes'],
            duration_display=best['duration_display'],
            cost_usd=best['cost_usd'],
            cost_display=best['cost_display'],
            co2_kg=best['co2_kg'],
            co2_display=best['co2_display'],
            comfort_level=best['comfort_level'],
            availability=best['availability']
        )
        
        processing_time = (time.time() - start_time) * 1000
        logger.info(f"📤 Found {len(options)} transport options in {processing_time:.2f}ms")
        
        return TransportResponse(
            source=transport_req.source,
            destination=transport_req.destination,
            options=options,
            best_option=best_option,
            total_options=len(options),
            message=result.get('reason', '')
        )
        
    except Exception as e:
        logger.error(f"❌ Error finding transport options: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/transport/compare")
async def compare_transport(
    source: str = Query(..., description="Starting city"),
    destination: str = Query(..., description="Target city")
):
    """
    Compare transport options between two cities
    
    Returns cheapest, fastest, and most eco-friendly options
    """
    try:
        result = transport_calc.compare_options(source, destination)
        return result
        
    except Exception as e:
        logger.error(f"❌ Error comparing options: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/transport/estimate")
async def estimate_cost(
    source: str = Query(..., description="Starting city"),
    destination: str = Query(..., description="Target city"),
    mode: Optional[str] = Query(None, description="Transport mode (flight, train, bus, etc.)")
):
    """
    Estimate travel cost for specific mode or all modes
    """
    try:
        result = transport_calc.estimate_travel_cost(source, destination, mode)
        return result
        
    except Exception as e:
        logger.error(f"❌ Error estimating cost: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/transport/modes")
async def get_supported_modes():
    """Get list of supported transport modes"""
    return {
        "modes": [
            {"id": "flight", "name": "Flight", "emoji": "✈️"},
            {"id": "train", "name": "Train", "emoji": "🚂"},
            {"id": "bus", "name": "Bus", "emoji": "🚌"},
            {"id": "car", "name": "Car Rental", "emoji": "🚗"},
            {"id": "taxi", "name": "Taxi", "emoji": "🚕"},
            {"id": "metro", "name": "Metro/Subway", "emoji": "🚇"},
            {"id": "ferry", "name": "Ferry", "emoji": "⛴️"},
            {"id": "walk", "name": "Walking", "emoji": "🚶"},
            {"id": "bike", "name": "Bicycle", "emoji": "🚲"}
        ]
    }

@router.get("/transport/health")
async def transport_health():
    """Health check for transport service"""
    return {
        "status": "healthy",
        "feature": "Multi-mode Transport with Costs",
        "supported_modes": list(transport_calc.cost_per_km.keys()),
        "cities_available": len(transport_calc.distances)
    }