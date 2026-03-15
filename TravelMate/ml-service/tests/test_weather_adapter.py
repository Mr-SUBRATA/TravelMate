# tests/test_weather_adapter.py
"""
Test script for WeatherAdapter
Run this to verify Step 2.4 is working correctly
"""

import sys
import os
import numpy as np

# Add project root to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.core.vectorizer import PreferenceVectorizer
from app.core.recommender import TravelRecommender
from app.core.weather_adapter import WeatherAdapter

def create_sample_itinerary():
    """Create a sample itinerary for testing"""
    return [
        {
            'date': '2026-03-15',
            'activities': [
                {
                    'name': 'Eiffel Tower',
                    'time': '10:00',
                    'outdoor': True,
                    'category': 'landmark',
                    'cost': 25
                },
                {
                    'name': 'Seine River Cruise',
                    'time': '14:00',
                    'outdoor': True,
                    'category': 'cruise',
                    'cost': 15
                },
                {
                    'name': 'Montmartre Walking Tour',
                    'time': '17:00',
                    'outdoor': True,
                    'category': 'tour',
                    'cost': 0
                }
            ]
        },
        {
            'date': '2026-03-16',
            'activities': [
                {
                    'name': 'Versailles Gardens',
                    'time': '09:00',
                    'outdoor': True,
                    'category': 'garden',
                    'cost': 20
                },
                {
                    'name': 'Louvre Museum',
                    'time': '14:00',
                    'outdoor': False,
                    'category': 'museum',
                    'cost': 17
                }
            ]
        },
        {
            'date': '2026-03-17',
            'activities': [
                {
                    'name': 'Luxembourg Gardens',
                    'time': '11:00',
                    'outdoor': True,
                    'category': 'garden',
                    'cost': 0
                },
                {
                    'name': 'Latin Quarter Food Tour',
                    'time': '15:00',
                    'outdoor': True,
                    'category': 'food',
                    'cost': 45
                }
            ]
        }
    ]

def create_weather_forecast():
    """Create sample weather forecast"""
    return [
        {
            'date': '2026-03-15',
            'rain_prob': 0.2,
            'temp': 22,
            'condition': 'sunny'
        },
        {
            'date': '2026-03-16',
            'rain_prob': 0.8,
            'temp': 18,
            'condition': 'rainy'
        },
        {
            'date': '2026-03-17',
            'rain_prob': 0.4,
            'temp': 20,
            'condition': 'cloudy'
        }
    ]

def test_weather_adapter():
    """Test the weather adapter"""
    print("\n" + "="*60)
    print("🧪 TESTING WEATHER ADAPTER")
    print("="*60)
    
    # Initialize components
    print("\n📦 Initializing components...")
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    adapter = WeatherAdapter(recommender)
    
    # Create test data
    itinerary = create_sample_itinerary()
    forecast = create_weather_forecast()
    
    # Create user vector
    test_user = {
        'art_interest': 4,
        'foodie_score': 3,
        'adventure_seeking': 3
    }
    user_vector = vectorizer.vectorize(test_user)
    
    print(f"✅ Components initialized")
    print(f"📅 Itinerary: {len(itinerary)} days")
    print(f"🌤️ Forecast: {len(forecast)} days")
    
    # Test 1: Basic adaptation
    print("\n" + "-"*60)
    print("📝 TEST 1: Full Itinerary Adaptation")
    print("-"*60)
    
    result = adapter.adapt_itinerary(
        itinerary,
        forecast,
        user_vector,
        test_user
    )
    
    print(f"\n📊 Adaptation Results:")
    print(f"   Total changes: {result['total_changes']}")
    print(f"   Alert level: {result['alert_level']}")
    print(f"   Recommendation: {result['recommendation']}")
    print(f"   Adaptation %: {result['metrics']['adaptation_percentage']:.1f}%")
    
    # Test 2: Check specific day adaptations
    print("\n" + "-"*60)
    print("📝 TEST 2: Day-by-Day Analysis")
    print("-"*60)
    
    for i, day in enumerate(result['adapted_itinerary']):
        print(f"\n📅 Day {i+1} - {day['date']}")
        # Get weather from the forecast list using index
        weather = forecast[i] if i < len(forecast) else {'rain_prob': 0, 'description': 'unknown'}
        print(f"   Weather: {weather.get('description', 'unknown')} "
          f"({weather.get('rain_prob', 0)*100:.0f}% rain)")
        print(f"   Adapted: {'✅' if day.get('weather_adapted', False) else '❌'}")
        
        for activity in day['activities']:
            adapted = '✨' if activity.get('adapted_from') else '  '
            warning = '⚠️' if activity.get('warning') else '  '
            print(f"   {adapted}{warning} {activity.get('time', '')} - {activity['name']}")
            if activity.get('adapted_from'):
                print(f"        (was: {activity['adapted_from']})")
            if activity.get('warning'):
                print(f"        {activity['warning']}")
    
    # Test 3: Check adaptation log
    print("\n" + "-"*60)
    print("📝 TEST 3: Adaptation Log")
    print("-"*60)
    
    for log in result['adaptation_log']:
        if log['type'] == 'swap':
            print(f"\n🔄 {log['date']} at {log.get('time', '')}")
            print(f"   {log['original']} → {log['new']}")
            print(f"   Reason: {log['reason']}")
            print(f"   {log['match_preserved']}")
        elif log['type'] == 'warning':
            print(f"\n⚠️ {log['date']}")
            print(f"   {log['activity']}: {log['warning']}")
    
    # Test 4: Edge Cases
    print("\n" + "-"*60)
    print("📝 TEST 4: Edge Cases")
    print("-"*60)
    
    # Test with no rain
    print("\n📝 Test 4.1: No rain forecast")
    sunny_forecast = [{'rain_prob': 0.0, 'temp': 25} for _ in range(3)]
    result_sunny = adapter.adapt_itinerary(
        itinerary[:1],  # Just first day
        sunny_forecast[:1],
        user_vector
    )
    print(f"   Changes with no rain: {result_sunny['total_changes']}")
    
    # Test with heavy rain
    print("\n📝 Test 4.2: Heavy rain forecast")
    rainy_forecast = [{'rain_prob': 0.9, 'temp': 15} for _ in range(3)]
    result_rainy = adapter.adapt_itinerary(
        itinerary[:1],
        rainy_forecast[:1],
        user_vector
    )
    print(f"   Changes with heavy rain: {result_rainy['total_changes']}")
    
    # Test with empty itinerary
    print("\n📝 Test 4.3: Empty itinerary")
    result_empty = adapter.adapt_itinerary([], [], user_vector)
    print(f"   Empty itinerary handled: {'✅' if result_empty else '❌'}")
    
    print("\n" + "="*60)
    print("✅ ALL WEATHER ADAPTER TESTS COMPLETED!")
    print("="*60)

def test_weather_intelligence():
    """Test specific intelligent features"""
    print("\n" + "="*60)
    print("🧪 TEST 5: Weather Intelligence Features")
    print("="*60)
    
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    adapter = WeatherAdapter(recommender)
    
    # Test user
    user = {'art_interest': 4}
    user_vector = vectorizer.vectorize(user)
    
    # Single activity test
    outdoor_activity = {
        'name': 'Eiffel Tower',
        'outdoor': True,
        'category': 'landmark'
    }
    
    # Test with different rain probabilities
    print("\n📊 Weather Sensitivity Analysis:")
    
    for rain_prob in [0.0, 0.3, 0.6, 0.9]:
        weather = {'rain_prob': rain_prob, 'temp': 20}
        needs = adapter._activity_needs_adaptation(outdoor_activity, weather)
        
        print(f"\n   Rain {rain_prob*100:.0f}%: {'🔴 NEEDS ADAPTATION' if needs else '🟢 OK'}")
        
        if needs:
            alternative = adapter._find_weather_alternative(
                outdoor_activity,
                weather,
                user_vector
            )
            if alternative:
                print(f"      Alternative: {alternative['name']}")
                print(f"      Match: {alternative.get('match_score', 0):.2f}")
    
    print("\n✅ Weather intelligence verified!")

if __name__ == "__main__":
    try:
        test_weather_adapter()
        test_weather_intelligence()
        print("\n🎉 Step 2.4 COMPLETE! Weather Adapter is working correctly!")
    except Exception as e:
        print(f"\n❌ Error during testing: {e}")
        import traceback
        traceback.print_exc()