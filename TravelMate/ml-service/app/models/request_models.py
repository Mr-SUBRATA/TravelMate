from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict
from enum import Enum
from datetime import datetime
from app.core.budget_optimizer import SpendingPriority

class TravelPace(str, Enum):
    RELAXED = "relaxed"
    BALANCED = "balanced"
    INTENSE = "intense"

class WeatherData(BaseModel):
    rain_prob: float = Field(0.0, ge=0, le=1)
    temp: float = Field(20, ge=-50, le=60)
    condition: str = "clear"
    wind_speed: Optional[float] = 0
    
    @validator('rain_prob')
    def validate_rain_prob(cls, v):
        if v < 0 or v > 1:
            raise ValueError('Rain probability must be between 0 and 1')
        return v

class QuizAnswers(BaseModel):
    """User quiz answers with validation"""
    art_interest: int = Field(3, ge=1, le=5)
    foodie_score: int = Field(3, ge=1, le=5)
    adventure_seeking: int = Field(3, ge=1, le=5)
    crowd_tolerance: int = Field(3, ge=1, le=5)
    budget_conscious: int = Field(3, ge=1, le=5)
    travel_pace: TravelPace = TravelPace.BALANCED
    interests: List[str] = []
    deal_breakers: List[str] = []
    
    # 🔥 ADD THIS METHOD - Fixes the enum issue!
    def dict(self, *args, **kwargs):
        d = super().dict(*args, **kwargs)
        # Convert travel_pace enum to string
        if 'travel_pace' in d and hasattr(d['travel_pace'], 'value'):
            d['travel_pace'] = d['travel_pace'].value
        return d

class RecommendRequest(BaseModel):
    user_id: str
    quiz_answers: QuizAnswers
    destination: str = "Paris"
    weather: Optional[WeatherData] = None
    places: List[Dict] = Field(default_factory=list)
    top_k: int = Field(5, ge=1, le=20)

class ExplainRequest(BaseModel):
    user_id: str
    activity_id: str
    quiz_answers: QuizAnswers
    weather: Optional[WeatherData] = None

class AdaptRequest(BaseModel):
    user_id: str
    itinerary: List[Dict]
    weather_forecast: List[WeatherData]
    quiz_answers: QuizAnswers

class GroupRequest(BaseModel):
    users: List[Dict]
    destination: str
    days: int = Field(3, ge=1, le=14)
    constraints: Optional[Dict] = None

class BudgetRequest(BaseModel):
    user_id: str
    total_budget: float = Field(..., gt=0)
    num_days: int = Field(..., ge=1)
    destination: str
    priority: SpendingPriority = SpendingPriority.BALANCED
    quiz_answers: QuizAnswers
    
class RouteRequest(BaseModel):
    source: str
    destination: str
    preference: Optional[str] = "balanced"  # cheapest, fastest, balanced


class RiskRequest(BaseModel):
    """
    Request model for risk assessment
    """
    destination: str = Field(..., description="City or country name")
    month: int = Field(
        datetime.now().month,
        ge=1,
        le=12,
        description="Month number (1-12)",
    )
    weather: Optional[WeatherData] = Field(
        None,
        description="Optional weather data",
    )

    class Config:
        json_schema_extra = {
            "example": {
                "destination": "Bahamas",
                "month": 9,
                "weather": {
                    "rain_prob": 0.8,
                    "temp": 28,
                    "condition": "stormy",
                },
            }
        }


class TransportRequest(BaseModel):
    """
    Request model for transport options
    """
    source: str = Field(..., description="Starting city", min_length=2)
    destination: str = Field(..., description="Target city", min_length=2)
    preference: str = Field(
        "balanced",
        description="cheapest, fastest, eco, or balanced",
    )

    @validator("preference")
    def validate_preference(cls, v: str) -> str:
        allowed = ["cheapest", "fastest", "eco", "balanced"]
        if v not in allowed:
            raise ValueError(f"Preference must be one of: {allowed}")
        return v

    class Config:
        json_schema_extra = {
            "example": {
                "source": "Paris",
                "destination": "London",
                "preference": "balanced",
            }
        }