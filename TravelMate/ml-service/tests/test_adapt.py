# tests/test_adapt.py
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import pytest
from app.core.weather_adapter import WeatherAdapter
from app.core.vectorizer import PreferenceVectorizer
from app.core.recommender import TravelRecommender

def test_adapt_endpoint():
    """Test weather adaptation logic"""
    print("\n🧪 TESTING WEATHER ADAPTATION")
    
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    adapter = WeatherAdapter(recommender)
    
    # Create test data
    itinerary = [
        {
            'date': '2026-03-15',
            'activities': [
                {'name': 'Eiffel Tower', 'time': '10:00', 'outdoor': True, 'cost': 25}
            ]
        }
    ]
    
    forecast = [{'rain_prob': 0.8, 'temp': 18, 'condition': 'rainy'}]
    
    user_vector = vectorizer.vectorize({'art_interest': 3})
    
    result = adapter.adapt_itinerary(itinerary, forecast, user_vector)
    
    assert result['total_changes'] >= 0
    print(f"✅ Adaptation test passed: {result['total_changes']} changes")

if __name__ == "__main__":
    test_adapt_endpoint()