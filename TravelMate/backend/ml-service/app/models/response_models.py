# app/models/response_models.py
"""
Pydantic models for API responses
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

class ScoreDetail(BaseModel):
    similarity: float
    weather: float
    crowd: float
    budget: float
    time: float
    popularity: float

class Recommendation(BaseModel):
    id: str
    name: str
    categories: List[str]
    cost: float
    outdoor: bool
    city: str
    match_score: float
    scores: ScoreDetail
    explanation: Optional[Dict] = None

class RecommendResponse(BaseModel):
    user_id: str
    recommendations: List[Recommendation]
    processing_time_ms: float
    model_version: str

class ExplainResponse(BaseModel):
    user_id: str
    activity_id: str
    match_score: float
    reasons: List[str]
    alternatives: List[Dict]
    confidence: float

class Activity(BaseModel):
    name: str
    time: str
    outdoor: bool
    cost: float
    adapted_from: Optional[str] = None
    warning: Optional[str] = None

class DayPlan(BaseModel):
    date: str
    weather: Dict
    activities: List[Activity]
    weather_adapted: bool
    adaptation_reason: Optional[str] = None

class AdaptResponse(BaseModel):
    user_id: str
    original_itinerary: List[Dict]
    adapted_itinerary: List[DayPlan]
    total_changes: int
    adaptation_log: List[Dict]
    alert_level: str
    recommendation: str

class HappinessScore(BaseModel):
    user_id: str
    user_name: str
    score: float

class GroupItinerary(BaseModel):
    day: int
    date: str
    activities: List[Dict]
    priority_user: str
    happiness: Dict[str, float]

class GroupResponse(BaseModel):
    itinerary: List[GroupItinerary]
    fairness_score: float
    happiness_scores: Dict[str, float]
    fairness_metrics: Dict
    recommendations: List[str]
    group_summary: str

class BudgetAllocation(BaseModel):
    daily: Dict[str, float]
    total: Dict[str, float]
    percentages: Dict[str, float]

class BudgetScenario(BaseModel):
    name: str
    total_cost: float
    experience_score: float
    dining_quality: str
    accommodation_type: str

class BudgetResponse(BaseModel):
    total_budget: float
    daily_budget: float
    num_days: int
    priority: str
    optimal_scenario: Dict
    pareto_frontier: List[Dict]
    allocation: BudgetAllocation
    recommendations: List[str]
    savings_potential: Dict
    upgrade_options: List[Dict]

class HealthResponse(BaseModel):
    status: str
    version: str
    environment: str
    timestamp: float
    services: Dict[str, str]
# Add to existing file

class RouteStep(BaseModel):
    from_city: str
    to_city: str
    mode: str
    duration_minutes: int

class RouteResponse(BaseModel):
    type: str  # direct, nearest_airport, impossible
    original_source: Optional[str] = None
    nearest_airport: Optional[str] = None
    route: List[RouteStep]
    total_duration: int
    message: Optional[str] = None

class RiskResponse(BaseModel):
    risk_score: float
    risk_level: str  # low, medium, high
    reasons: List[str]
    block_trip: bool
    alternative_destination: Optional[str] = None

class TransportOption(BaseModel):
    mode: str
    distance_km: float
    duration_hours: float
    duration_minutes: int
    cost_usd: float

class TransportResponse(BaseModel):
    options: List[TransportOption]
    best_option: TransportOption
# Add to app/models/response_models.py

# ... rest of your file ...

class RiskResponse(BaseModel):
    """
    Response model for risk assessment
    """
    risk_score: float = Field(..., ge=0, le=1, description="Risk score from 0 (safe) to 1 (dangerous)")  # ← NOW WORKS!
    risk_level: str = Field(..., description="LOW, MEDIUM, HIGH, or CRITICAL")
    reasons: List[str] = Field(..., description="List of risk factors")
    block_trip: bool = Field(..., description="True if trip should be blocked")
    alternative_destination: Optional[str] = Field(None, description="Safer alternative suggestion")
    
    class Config:
        json_schema_extra = {  # Note: 'schema_extra' is now 'json_schema_extra' in Pydantic V2
            "example": {
                "risk_score": 0.85,
                "risk_level": "HIGH",
                "reasons": [
                    "⚠️ Hurricane Season (June-November) in Caribbean",
                    "☔ Extreme rain probability: 90%"
                ],
                "block_trip": True,
                "alternative_destination": "Florida"
            }
        }
# Add to app/models/response_models.py

class TransportOption(BaseModel):
    """
    Transport option details
    """
    mode: str = Field(..., description="Transport mode ID")
    mode_emoji: str = Field(..., description="Emoji for display")
    mode_name: str = Field(..., description="Display name")
    distance_km: float = Field(..., description="Distance in kilometers")
    duration_hours: float = Field(..., description="Duration in hours")
    duration_minutes: int = Field(..., description="Duration in minutes")
    duration_display: str = Field(..., description="Human-readable duration")
    cost_usd: float = Field(..., description="Cost in USD")
    cost_display: str = Field(..., description="Formatted cost")
    co2_kg: float = Field(..., description="CO2 emissions in kg")
    co2_display: str = Field(..., description="Formatted emissions")
    comfort_level: str = Field(..., description="Low, Medium, or High")
    availability: str = Field(..., description="Availability description")
    
    class Config:
        json_schema_extra = {
            "example": {
                "mode": "train",
                "mode_emoji": "🚂",
                "mode_name": "Train",
                "distance_km": 450,
                "duration_hours": 2.3,
                "duration_minutes": 135,
                "duration_display": "2h 15m",
                "cost_usd": 54.00,
                "cost_display": "$54.00",
                "co2_kg": 18.45,
                "co2_display": "18.45 kg CO2",
                "comfort_level": "High",
                "availability": "Regular service"
            }
        }

class TransportResponse(BaseModel):
    """
    Response model for transport options
    """
    source: str = Field(..., description="Starting city")
    destination: str = Field(..., description="Target city")
    options: List[TransportOption] = Field(..., description="All transport options")
    best_option: Optional[TransportOption] = Field(None, description="Best option based on preference")
    total_options: int = Field(..., description="Number of options found")
    message: Optional[str] = Field(None, description="Additional information")
    
    class Config:
        json_schema_extra = {
            "example": {
                "source": "Paris",
                "destination": "London",
                "total_options": 4,
                "message": "This option offers the best balance of cost, time, and environmental impact"
            }
        }