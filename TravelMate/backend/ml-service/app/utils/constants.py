# app/utils/constants.py
"""
Constants used across the ML service
"""

# Category weights for vectorization
CATEGORY_WEIGHTS = {
    'art': {'museum': 0.9, 'gallery': 0.8, 'street_art': 0.6},
    'food': {'street_food': 0.9, 'local_cuisine': 1.0, 'fine_dining': 0.8},
    'adventure': {'extreme_sports': 1.0, 'hiking': 0.8, 'cycling': 0.7},
    'relaxation': {'spa': 0.9, 'yoga': 0.8, 'beach': 0.8},
    'history': {'historical_site': 0.9, 'museum': 0.8, 'monument': 0.8},
    'shopping': {'mall': 0.7, 'boutique': 0.8, 'market': 0.9}
}

# Dimension mapping for 50-dim vector
DIMENSION_MAP = {
    'art': (0, 10), 'food': (10, 20), 'nature': (20, 25),
    'adventure': (25, 30), 'relaxation': (30, 35), 'history': (35, 40),
    'shopping': (40, 45), 'crowd_tolerance': (45, 46),
    'budget_sensitivity': (46, 47), 'pace_preference': (47, 48),
    'social_preference': (48, 49), 'weather_sensitivity': (49, 50)
}

# Weather adaptation thresholds
WEATHER_THRESHOLDS = {
    'rain_swap': 0.6, 'heat_alert': 35, 'cold_alert': 5,
    'wind_alert': 30, 'snow_alert': 0.1
}

# Scoring weights for hybrid recommendation
SCORING_WEIGHTS = {
    'similarity': 0.5, 'weather': 0.2, 'crowd': 0.15,
    'budget': 0.15, 'time': 0.1, 'popularity': 0.1
}

# Default values
DEFAULT_VALUES = {
    'art_interest': 3, 'foodie_score': 3, 'adventure_seeking': 3,
    'crowd_tolerance': 3, 'budget_conscious': 3, 'daily_budget': 150,
    'trip_duration': 7, 'travel_pace': 'balanced', 'group_size': 1
}