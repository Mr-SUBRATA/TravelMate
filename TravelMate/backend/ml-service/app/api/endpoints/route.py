# app/api/endpoints/route.py
"""
Route Planning Endpoint - Finds paths between locations using Dijkstra's algorithm
Feature 1: Path/Routing + Nearest Platform/Airport
"""

from fastapi import APIRouter, HTTPException, Request
import logging
from typing import List, Dict, Optional
import time

from app.models.request_models import RouteRequest
from app.models.response_models import RouteResponse, RouteStep
from app.core.transport_router import TransportRouter

router = APIRouter()
logger = logging.getLogger(__name__)

# Initialize the transport router
transport_router = TransportRouter()

@router.post("/route", response_model=RouteResponse)
async def find_route(request: Request, route_req: RouteRequest):
    """
    Find the best route between source and destination
    
    This endpoint:
    1. Uses Dijkstra's algorithm to find shortest path
    2. If no direct route, suggests nearest airport/station
    3. Returns step-by-step directions with transport modes
    
    Parameters:
    - source: Starting location (e.g., "Versailles")
    - destination: Target location (e.g., "Paris")
    - preference: "cheapest", "fastest", or "balanced" (default)
    
    Returns:
    - Route with steps, duration, and any fallback messages
    """
    start_time = time.time()
    
    try:
        logger.info(f"📥 Route request: {route_req.source} → {route_req.destination}")
        
        # Find route using transport router
        result = transport_router.find_route(
            source=route_req.source,
            destination=route_req.destination,
            preference=route_req.preference
        )
        
        # Calculate total duration
        total_duration = 0
        route_steps = []
        
        if result.get('route'):
            for step in result['route']:
                route_steps.append(RouteStep(
                    from_city=step[0],
                    to_city=step[1],
                    mode=step[2],
                    duration_minutes=step[3]
                ))
                total_duration += step[3]
        
        # Prepare response
        response = RouteResponse(
            type=result.get('type', 'direct'),
            original_source=result.get('original_source'),
            nearest_airport=result.get('nearest_airport'),
            route=route_steps,
            total_duration=total_duration,
            message=result.get('message')
        )
        
        processing_time = (time.time() - start_time) * 1000
        logger.info(f"📤 Route found in {processing_time:.2f}ms")
        
        return response
        
    except Exception as e:
        logger.error(f"❌ Error finding route: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/route/health")
async def route_health():
    """Health check for route planning service"""
    return {
        "status": "healthy",
        "feature": "Route Planning with Dijkstra",
        "cities_available": list(transport_router.transport_graph.keys())
    }

@router.get("/route/nearby/{location}")
async def find_nearest_airport(location: str):
    """
    Find the nearest airport/station for a given location
    """
    try:
        nearest = transport_router.nearby_airports.get(location)
        
        if nearest:
            return {
                "location": location,
                "nearest_airport": nearest,
                "message": f"Use {nearest} airport for travel"
            }
        else:
            return {
                "location": location,
                "nearest_airport": location,
                "message": f"{location} already has direct connectivity"
            }
            
    except Exception as e:
        logger.error(f"❌ Error finding nearest airport: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/route/explore/{city}")
async def explore_destinations(city: str):
    """
    Show all destinations reachable from a city
    """
    try:
        destinations = []
        
        if city in transport_router.transport_graph:
            for dest, connections in transport_router.transport_graph[city].items():
                for mode, time in connections.items():
                    destinations.append({
                        "destination": dest,
                        "mode": mode,
                        "duration_minutes": time,
                        "duration_hours": round(time / 60, 1)
                    })
        
        # Sort by duration
        destinations.sort(key=lambda x: x['duration_minutes'])
        
        return {
            "city": city,
            "reachable_destinations": destinations,
            "count": len(destinations)
        }
        
    except Exception as e:
        logger.error(f"❌ Error exploring destinations: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))