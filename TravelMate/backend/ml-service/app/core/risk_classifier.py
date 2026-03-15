# app/core/risk_classifier.py
"""
Risk Classification Engine - Detects dangerous travel conditions
Feature 2: Risk Classification + Trip Blocking
"""

from typing import Dict, List, Tuple, Optional
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class RiskClassifier:
    """Classifies trip risk based on weather, season, and historical data"""
    
    def __init__(self):
        # Risk thresholds
        self.risk_thresholds = {
            'low': 0.3,
            'medium': 0.6,
            'high': 0.8
        }
        
        # High-risk seasons by destination
        self.high_risk_seasons = {
            'Caribbean': {'months': [6, 7, 8, 9, 10, 11], 'reason': 'Hurricane Season (June-November)'},
            'Southeast Asia': {'months': [5, 6, 7, 8, 9, 10], 'reason': 'Monsoon Season (May-October)'},
            'Japan': {'months': [8, 9, 10], 'reason': 'Typhoon Season (August-October)'},
            'Philippines': {'months': [6, 7, 8, 9, 10, 11, 12], 'reason': 'Typhoon Season'},
            'India': {'months': [6, 7, 8, 9], 'reason': 'Monsoon Season (June-September)'},
            'Thailand': {'months': [5, 6, 7, 8, 9, 10], 'reason': 'Monsoon Season'},
            'Vietnam': {'months': [7, 8, 9, 10, 11], 'reason': 'Typhoon Season'},
            'Bangladesh': {'months': [5, 6, 7, 8, 9, 10], 'reason': 'Monsoon & Flood Season'},
            'Maldives': {'months': [5, 6, 7, 8, 9, 10], 'reason': 'Southwest Monsoon'},
            'Australia': {'months': [11, 12, 1, 2, 3], 'reason': 'Cyclone Season (Northern Australia)'},
            'Florida': {'months': [6, 7, 8, 9, 10, 11], 'reason': 'Hurricane Season'},
            'Gulf of Mexico': {'months': [6, 7, 8, 9, 10, 11], 'reason': 'Hurricane Season'},
            'Mediterranean': {'months': [7, 8], 'reason': 'Extreme Heat & Wildfire Risk'}
        }
        
        # Extreme weather thresholds
        self.weather_thresholds = {
            'rain_prob': 0.9,      # 90% rain = high risk
            'temp': {'min': 0, 'max': 40},  # Below 0°C or above 40°C = high risk
            'wind': 50,             # km/h
            'snow': 0.5,            # 50% snow probability
            'storm': 0.8            # 80% storm probability
        }
        
        # Natural disaster database (simplified)
        self.disaster_zones = {
            'Pacific Ring of Fire': ['Japan', 'Philippines', 'Indonesia', 'New Zealand', 'Chile', 'Peru'],
            'Earthquake Zones': ['Turkey', 'Iran', 'Afghanistan', 'Pakistan', 'Nepal'],
            'Volcanic Areas': ['Hawaii', 'Iceland', 'Italy', 'Mexico']
        }
        
        logger.info("✅ Risk Classifier initialized")
    
    def calculate_risk_score(self, 
                            destination: str, 
                            month: int,
                            weather: Optional[Dict] = None) -> Tuple[float, List[str], bool]:
        """
        Calculate risk score (0-1) and decide if trip should be blocked
        
        Args:
            destination: City or country name
            month: Month number (1-12)
            weather: Optional weather data
            
        Returns:
            - risk_score: 0-1 (0 = safe, 1 = extremely dangerous)
            - reasons: List of risk factors
            - block_trip: True if risk > threshold
        """
        risk_score = 0.0
        reasons = []
        
        # 1. Check seasonal risks
        seasonal_score, seasonal_reasons = self._check_seasonal_risks(destination, month)
        risk_score += seasonal_score
        reasons.extend(seasonal_reasons)
        
        # 2. Check weather risks
        if weather:
            weather_score, weather_reasons = self._check_weather_risks(weather)
            risk_score += weather_score
            reasons.extend(weather_reasons)
        
        # 3. Check disaster zone risks
        disaster_score, disaster_reasons = self._check_disaster_zones(destination)
        risk_score += disaster_score
        reasons.extend(disaster_reasons)
        
        # Cap at 1.0
        risk_score = min(risk_score, 1.0)
        
        # Determine if trip should be blocked
        block_trip = risk_score > self.risk_thresholds['high']
        
        # Add summary message
        if block_trip:
            reasons.append(f"🚫 TRIP BLOCKED: Risk score {risk_score:.0%} exceeds safety threshold")
        
        return risk_score, reasons, block_trip
    
    def _check_seasonal_risks(self, destination: str, month: int) -> Tuple[float, List[str]]:
        """Check if destination has seasonal risks"""
        risk_score = 0.0
        reasons = []
        
        dest_lower = destination.lower()
        
        for region, data in self.high_risk_seasons.items():
            # Check if destination is in this region
            if region.lower() in dest_lower or self._region_matches(destination, region):
                if month in data['months']:
                    risk_score += 0.4
                    reasons.append(f"⚠️ {data['reason']} in {region}")
        
        return min(risk_score, 0.8), reasons
    
    def _check_weather_risks(self, weather: Dict) -> Tuple[float, List[str]]:
        """Check if weather conditions are dangerous"""
        risk_score = 0.0
        reasons = []
        
        # Rain risk
        rain_prob = weather.get('rain_prob', 0)
        if rain_prob > self.weather_thresholds['rain_prob']:
            risk_score += 0.3
            reasons.append(f"☔ Extreme rain probability: {rain_prob*100:.0f}%")
        
        # Temperature risk
        temp = weather.get('temp', 20)
        if temp < self.weather_thresholds['temp']['min']:
            risk_score += 0.3
            reasons.append(f"❄️ Dangerously cold: {temp}°C")
        elif temp > self.weather_thresholds['temp']['max']:
            risk_score += 0.3
            reasons.append(f"🔥 Dangerously hot: {temp}°C")
        
        # Storm risk
        condition = weather.get('condition', '').lower()
        if 'storm' in condition or 'hurricane' in condition:
            risk_score += 0.5
            reasons.append(f"🌪️ Severe storm conditions detected")
        
        # Wind risk
        wind = weather.get('wind_speed', 0)
        if wind > self.weather_thresholds['wind']:
            risk_score += 0.2
            reasons.append(f"💨 High winds: {wind} km/h")
        
        return min(risk_score, 1.0), reasons
    
    def _check_disaster_zones(self, destination: str) -> Tuple[float, List[str]]:
        """Check if destination is in active disaster zone"""
        risk_score = 0.0
        reasons = []
        
        dest_lower = destination.lower()
        
        # Simplified check - in production, you'd call a live disaster API
        disaster_active = {
            'Turkey': {'active': True, 'reason': 'Recent earthquake activity'},
            'Japan': {'active': False, 'reason': ''},
            'Hawaii': {'active': True, 'reason': 'Volcanic activity'}
        }
        
        for place, data in disaster_active.items():
            if place.lower() in dest_lower and data['active']:
                risk_score += 0.6
                reasons.append(f"🌋 Active disaster zone: {data['reason']}")
        
        return min(risk_score, 0.6), reasons
    
    def suggest_alternative(self, destination: str) -> str:
        """Suggest alternative destination with lower risk"""
        alternatives = {
            'Caribbean': 'Florida',
            'Bahamas': 'Florida',
            'Jamaica': 'Cancun',
            'Thailand': 'Singapore',
            'Vietnam': 'Malaysia',
            'Japan': 'South Korea',
            'Philippines': 'Taiwan',
            'India': 'Sri Lanka',
            'Bangladesh': 'Nepal',
            'Florida': 'California',
            'Mexico': 'Arizona'
        }
        
        dest_lower = destination.lower()
        
        for risky, safe in alternatives.items():
            if risky.lower() in dest_lower:
                return safe
        
        # If no specific alternative, suggest a generally safe destination
        return "Mediterranean Europe (Greece, Italy, Spain)"
    
    def get_risk_level(self, score: float) -> str:
        """Convert numeric score to risk level"""
        if score < self.risk_thresholds['low']:
            return "LOW"
        elif score < self.risk_thresholds['medium']:
            return "MEDIUM"
        elif score < self.risk_thresholds['high']:
            return "HIGH"
        else:
            return "CRITICAL"
    
    def _region_matches(self, destination: str, region: str) -> bool:
        """Check if destination is in high-risk region"""
        # Simple keyword matching
        region_keywords = {
            'Caribbean': ['bahamas', 'jamaica', 'cuba', 'puerto rico', 'dominican', 'barbados', 'trinidad'],
            'Southeast Asia': ['thailand', 'vietnam', 'cambodia', 'laos', 'myanmar', 'malaysia', 'indonesia'],
            'Japan': ['japan', 'tokyo', 'osaka', 'kyoto'],
            'Philippines': ['philippines', 'manila', 'cebu'],
            'India': ['india', 'mumbai', 'delhi', 'goa', 'kerala', 'chennai'],
            'Florida': ['miami', 'orlando', 'tampa', 'key west'],
            'Mediterranean': ['greece', 'italy', 'spain', 'portugal', 'croatia', 'turkey']
        }
        
        dest_lower = destination.lower()
        keywords = region_keywords.get(region, [])
        
        for keyword in keywords:
            if keyword in dest_lower:
                return True
        return False