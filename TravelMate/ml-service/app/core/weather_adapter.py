# app/core/weather_adapter.py
"""
Weather adaptation engine - automatically adjusts itineraries based on weather
This is YOUR intellectual property that makes the system intelligent
"""

import numpy as np
from typing import List, Dict, Optional, Tuple
from datetime import datetime, timedelta
import logging
from app.utils.constants import WEATHER_THRESHOLDS

logger = logging.getLogger(__name__)

class WeatherAdapter:
    """
    Real-time itinerary adaptation based on weather conditions
    """
    
    def __init__(self, recommender):
        """
        Initialize weather adapter
        
        Args:
            recommender: TravelRecommender instance for finding alternatives
        """
        self.recommender = recommender
        self.thresholds = WEATHER_THRESHOLDS
        
        # Activity type mappings
        self.activity_mappings = {
            'outdoor': {
                'park': ['museum', 'gallery', 'indoor_market'],
                'beach': ['aquarium', 'spa', 'shopping_mall'],
                'hiking': ['climbing_gym', 'museum', 'cooking_class'],
                'walking_tour': ['food_tour', 'museum', 'wine_tasting'],
                'viewpoint': ['observation_deck', 'restaurant', 'cafe']
            },
            'weather_sensitive': {
                'rain': ['indoor_activity', 'museum', 'shopping'],
                'heat': ['indoor', 'air_conditioned', 'pool'],
                'cold': ['indoor', 'warm_place', 'cafe'],
                'wind': ['sheltered', 'indoor']
            }
        }
        
        logger.info("✅ Weather Adapter initialized")
    
    def adapt_itinerary(self,
                       original_itinerary: List[Dict],
                       weather_forecast: List[Dict],
                       user_vector: np.ndarray,
                       user_preferences: Optional[Dict] = None) -> Dict:
        """
        Adapt entire itinerary based on weather forecast
        
        Args:
            original_itinerary: List of daily plans
            weather_forecast: List of daily weather forecasts
            user_vector: User preference vector
            user_preferences: Original user preferences
            
        Returns:
            Adapted itinerary with changes explained
        """
        adapted_days = []
        total_changes = 0
        adaptation_log = []
        
        for day_idx, (day_plan, day_weather) in enumerate(
            zip(original_itinerary, weather_forecast)
        ):
            # Adapt single day
            adapted_day, changes, log = self._adapt_day(
                day_plan, 
                day_weather,
                user_vector,
                day_idx
            )
            
            adapted_days.append(adapted_day)
            total_changes += changes
            adaptation_log.extend(log)
        
        # Calculate adaptation metrics
        metrics = self._calculate_adaptation_metrics(
            original_itinerary,
            adapted_days,
            weather_forecast
        )
        
        return {
            'original_itinerary': original_itinerary,
            'adapted_itinerary': adapted_days,
            'total_changes': total_changes,
            'adaptation_log': adaptation_log,
            'metrics': metrics,
            'alert_level': self._determine_alert_level(weather_forecast),
            'recommendation': self._generate_recommendation(weather_forecast)
        }
    
    def _adapt_day(self,
                   day_plan: Dict,
                   weather: Dict,
                   user_vector: np.ndarray,
                   day_idx: int) -> Tuple[Dict, int, List]:
        """
        Adapt a single day's activities based on weather
        """
        adapted_activities = []
        changes = 0
        log = []
        
        # Get day metadata
        date = day_plan.get('date', f"Day {day_idx + 1}")
        day_weather = self._enhance_weather_data(weather)
        
        # Check if day needs adaptation
        needs_adaptation, reason = self._check_day_needs_adaptation(day_weather)
        
        if not needs_adaptation:
            # No adaptation needed
            return day_plan, 0, []
        
        # Adapt each activity
        for activity_idx, activity in enumerate(day_plan.get('activities', [])):
            adapted_activity, changed, log_entry = self._adapt_activity(
                activity,
                day_weather,
                user_vector,
                date,
                activity_idx
            )
            
            adapted_activities.append(adapted_activity)
            if changed:
                changes += 1
                if log_entry:
                    log.append(log_entry)
        
        # If no activities were adapted but day needs it, add suggestions
        if changes == 0 and needs_adaptation:
            suggestions = self._suggest_indoor_alternatives(
                day_plan.get('activities', []),
                day_weather,
                user_vector
            )
            if suggestions:
                adapted_activities.extend(suggestions)
                changes += len(suggestions)
                log.append({
                    'type': 'suggestion',
                    'message': f"Added {len(suggestions)} indoor alternatives due to {reason}"
                })
        
        return {
            'date': date,
            'weather': day_weather,
            'activities': adapted_activities,
            'weather_adapted': changes > 0,
            'adaptation_reason': reason if changes > 0 else None
        }, changes, log
    
    def _adapt_activity(self,
                       activity: Dict,
                       weather: Dict,
                       user_vector: np.ndarray,
                       date: str,
                       activity_idx: int) -> Tuple[Dict, bool, Optional[Dict]]:
        """
        Adapt a single activity based on weather
        """
        # Check if activity needs adaptation
        if not self._activity_needs_adaptation(activity, weather):
            return activity, False, None
        
        # Find alternative
        alternative = self._find_weather_alternative(
            activity,
            weather,
            user_vector
        )
        
        if alternative:
            log_entry = {
                'type': 'swap',
                'date': date,
                'time': activity.get('time', 'Unknown'),
                'original': activity.get('name', 'Unknown'),
                'new': alternative.get('name', 'Unknown'),
                'reason': self._generate_adaptation_reason(activity, weather),
                'match_preserved': f"{alternative.get('match_score', 0)*100:.0f}% match"
            }
            
            # Preserve time slot if possible
            alternative['time'] = activity.get('time')
            alternative['original_activity'] = activity.get('name')
            alternative['adaptation_reason'] = log_entry['reason']
            
            return alternative, True, log_entry
        
        # No alternative found, add warning
        activity['warning'] = self._generate_warning(activity, weather)
        return activity, False, {
            'type': 'warning',
            'date': date,
            'activity': activity.get('name'),
            'warning': activity['warning']
        }
    
    def _find_weather_alternative(self,
                                 original_activity: Dict,
                                 weather: Dict,
                                 user_vector: np.ndarray) -> Optional[Dict]:
        """
        Find best alternative activity for bad weather
        """
        # Get activity category
        category = original_activity.get('category', 'general')
        outdoor = original_activity.get('outdoor', True)
        
        if not outdoor:
            return None  # Already indoor
        
        # Get weather condition
        condition = self._get_weather_condition(weather)
        
        # Find indoor alternatives in same or related category
        alternatives = self.recommender.recommend(
            user_vector=user_vector,
            weather_data={'rain_prob': 1.0},  # Force indoor preference
            top_k=5
        )
        
        # Filter for indoor activities
        indoor_alternatives = [
            a for a in alternatives 
            if not a.get('outdoor', True)
        ]
        
        if indoor_alternatives:
            # Pick best match
            best = indoor_alternatives[0]
            
            # Enhance with adaptation metadata
            best['adapted_from'] = original_activity.get('name')
            best['adaptation_type'] = 'weather'
            best['weather_condition'] = condition
            best['match_score'] = best.get('final_score', 0.7)
            
            return best
        
        return None
    
    def _check_day_needs_adaptation(self, weather: Dict) -> Tuple[bool, str]:
        """
        Check if a day needs weather-based adaptation
        """
        rain_prob = weather.get('rain_prob', 0)
        temp = weather.get('temp', 20)
        condition = weather.get('condition', 'clear')
        
        if rain_prob > self.thresholds['rain_swap']:
            return True, f"{rain_prob*100:.0f}% chance of rain"
        
        if temp > self.thresholds['heat_alert']:
            return True, f"Extreme heat ({temp}°C)"
        
        if temp < self.thresholds['cold_alert']:
            return True, f"Extreme cold ({temp}°C)"
        
        if condition in ['storm', 'heavy_rain', 'snow']:
            return True, f"{condition} conditions"
        
        return False, "weather OK"
    
    def _activity_needs_adaptation(self, activity: Dict, weather: Dict) -> bool:
        """
        Check if specific activity needs adaptation
        """
        if not activity.get('outdoor', False):
            return False  # Indoor activities are fine
        
        rain_prob = weather.get('rain_prob', 0)
        
        # Outdoor activities need adaptation if rain probability > threshold
        return rain_prob > self.thresholds['rain_swap']
    
    def _enhance_weather_data(self, weather: Dict) -> Dict:
        """
        Add derived weather metrics
        """
        enhanced = weather.copy()
        
        # Add qualitative description
        rain_prob = weather.get('rain_prob', 0)
        if rain_prob < 0.2:
            enhanced['description'] = 'sunny'
        elif rain_prob < 0.5:
            enhanced['description'] = 'partly cloudy'
        elif rain_prob < 0.8:
            enhanced['description'] = 'likely rain'
        else:
            enhanced['description'] = 'heavy rain'
        
        # Add recommendation
        if rain_prob > self.thresholds['rain_swap']:
            enhanced['recommendation'] = 'indoor_activities'
        elif rain_prob > self.thresholds['rain_swap'] / 2:
            enhanced['recommendation'] = 'mixed_activities'
        else:
            enhanced['recommendation'] = 'outdoor_ok'
        
        return enhanced
    
    def _generate_adaptation_reason(self, activity: Dict, weather: Dict) -> str:
        """
        Generate human-readable reason for adaptation
        """
        rain_prob = weather.get('rain_prob', 0)
        
        if rain_prob > self.thresholds['rain_swap']:
            return f"☔ {rain_prob*100:.0f}% rain chance - swapped to indoor alternative"
        elif rain_prob > 0.3:
            return f"🌤️ {rain_prob*100:.0f}% rain chance - indoor option recommended"
        else:
            return "🌈 Weather-optimized alternative"
    
    def _generate_warning(self, activity: Dict, weather: Dict) -> str:
        """
        Generate warning for activities that couldn't be adapted
        """
        rain_prob = weather.get('rain_prob', 0)
        
        if rain_prob > self.thresholds['rain_swap']:
            return f"⚠️ High rain chance ({rain_prob*100:.0f}%) - bring umbrella!"
        elif rain_prob > 0.3:
            return f"⚠️ {rain_prob*100:.0f}% chance of rain - consider indoor backup"
        else:
            return ""
    
    def _get_weather_condition(self, weather: Dict) -> str:
        """
        Get primary weather condition
        """
        rain_prob = weather.get('rain_prob', 0)
        
        if rain_prob > 0.8:
            return 'heavy_rain'
        elif rain_prob > 0.5:
            return 'rain'
        elif rain_prob > 0.2:
            return 'drizzle'
        else:
            return 'clear'
    
    def _suggest_indoor_alternatives(self,
                                     activities: List[Dict],
                                     weather: Dict,
                                     user_vector: np.ndarray) -> List[Dict]:
        """
        Suggest indoor alternatives when day needs adaptation
        """
        suggestions = []
        
        # Get top indoor recommendations
        indoor_recs = self.recommender.recommend(
            user_vector=user_vector,
            weather_data={'rain_prob': 1.0},
            top_k=3
        )
        
        for rec in indoor_recs:
            if not rec.get('outdoor', True):
                rec['type'] = 'suggestion'
                rec['suggestion_reason'] = f"Indoor alternative for {weather.get('description', 'rainy')} weather"
                suggestions.append(rec)
        
        return suggestions
    
    def _calculate_adaptation_metrics(self,
                                      original: List[Dict],
                                      adapted: List[Dict],
                                      weather: List[Dict]) -> Dict:
        """
        Calculate metrics about the adaptation
        """
        total_activities = sum(
            len(day.get('activities', [])) for day in original
        )
        
        adapted_activities = sum(
            len([a for a in day.get('activities', []) if a.get('adapted_from')])
            for day in adapted
        )
        
        # Calculate weather severity - handle empty weather
        if weather:
            avg_rain = np.mean([w.get('rain_prob', 0) for w in weather])
            days_affected = sum(1 for w in weather if w.get('rain_prob', 0) > 0.3)
        else:
            avg_rain = 0
            days_affected = 0
        
        return {
            'total_activities': total_activities,
            'adapted_activities': adapted_activities,
            'adaptation_percentage': (adapted_activities / max(total_activities, 1)) * 100,
            'weather_severity': avg_rain,
            'days_affected': days_affected
        }
    
    def _determine_alert_level(self, weather_forecast: List[Dict]) -> str:
        """
        Determine alert level based on forecast
        """
        if not weather_forecast:  # Handle empty list
            return 'none'
    
        max_rain = max([w.get('rain_prob', 0) for w in weather_forecast])
    
        if max_rain > 0.8:
            return 'high'
        elif max_rain > 0.5:
            return 'medium'
        elif max_rain > 0.3:
            return 'low'
        else:
            return 'none'
    
    def _generate_recommendation(self, weather_forecast: List[Dict]) -> str:
        """
        Generate overall recommendation based on forecast
        """
        if not weather_forecast:
            return "ℹ️ No weather data available"
            
        rainy_days = sum(1 for w in weather_forecast if w.get('rain_prob', 0) > 0.5)
        total_days = len(weather_forecast)
        
        if rainy_days == 0:
            return "🌞 Perfect weather for outdoor activities!"
        elif rainy_days <= total_days / 3:
            return "⛅ Mix of sun and rain - plan indoor backups"
        elif rainy_days <= total_days / 2:
            return "☔ Significant rain expected - focus on indoor attractions"
        else:
            return "🌧️ Mostly rainy - we've optimized your itinerary for indoor activities"