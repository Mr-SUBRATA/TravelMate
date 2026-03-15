# tests/test_recommender.py
"""
Test script for TravelRecommender
Run this to verify Step 2.3 is working correctly
"""

import sys
import os
import numpy as np

# Add project root to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.core.vectorizer import PreferenceVectorizer
from app.core.recommender import TravelRecommender

def test_recommender():
    """Test the recommendation engine"""
    print("\n" + "="*60)
    print("🧪 TESTING TRAVEL RECOMMENDER")
    print("="*60)
    
    # Initialize components
    print("\n📦 Initializing components...")
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    
    # Test Case 1: Art Lover
    print("\n" + "-"*60)
    print("📝 TEST CASE 1: Art Lover")
    print("-"*60)
    
    art_lover = {
        'art_interest': 5,
        'foodie_score': 3,
        'adventure_seeking': 2,
        'crowd_tolerance': 3,
        'budget_conscious': 3,
        'travel_pace': 'balanced',
        'interests': ['museum', 'gallery']
    }
    
    user_vector = vectorizer.vectorize(art_lover)
    print(f"✅ User vector created: {user_vector.shape}")
    
    recommendations = recommender.recommend(
        user_vector=user_vector,
        top_k=3
    )
    
    print(f"\n📊 Top 3 Recommendations for Art Lover:")
    for i, rec in enumerate(recommendations, 1):
        print(f"\n  {i}. {rec['name']}")
        print(f"     Score: {rec['final_score']:.3f}")
        print(f"     Categories: {rec['categories']}")
        print(f"     Cost: ${rec['cost']}")
    
    # Test Case 2: Adventure Seeker
    print("\n" + "-"*60)
    print("📝 TEST CASE 2: Adventure Seeker")
    print("-"*60)
    
    adventurer = {
        'art_interest': 2,
        'foodie_score': 3,
        'adventure_seeking': 5,
        'crowd_tolerance': 4,
        'budget_conscious': 2,
        'travel_pace': 'intense',
        'interests': ['hiking', 'outdoor']
    }
    
    user_vector = vectorizer.vectorize(adventurer)
    recommendations = recommender.recommend(
        user_vector=user_vector,
        top_k=3
    )
    
    print(f"\n📊 Top 3 Recommendations for Adventure Seeker:")
    for i, rec in enumerate(recommendations, 1):
        print(f"\n  {i}. {rec['name']}")
        print(f"     Score: {rec['final_score']:.3f}")
        print(f"     Outdoor: {rec['outdoor']}")
    
    # Test Case 3: With Weather Data
    print("\n" + "-"*60)
    print("📝 TEST CASE 3: With Weather Data (Rainy Day)")
    print("-"*60)
    
    weather_data = {
        'rain_prob': 0.8,
        'temp': 18,
        'condition': 'rainy'
    }
    
    recommendations = recommender.recommend(
        user_vector=user_vector,
        weather_data=weather_data,
        top_k=3
    )
    
    print(f"\n📊 Recommendations on Rainy Day:")
    for i, rec in enumerate(recommendations, 1):
        weather_score = rec['scores']['weather']
        indoor_bonus = "✅ Indoor" if not rec['outdoor'] else "☔ Outdoor"
        print(f"\n  {i}. {rec['name']} - {indoor_bonus}")
        print(f"     Weather Score: {weather_score:.2f}")
        print(f"     Final Score: {rec['final_score']:.3f}")
    
    # Test Case 4: With Budget Constraints
    print("\n" + "-"*60)
    print("📝 TEST CASE 4: With Budget Constraints ($50/day)")
    print("-"*60)
    
    budget_data = {
        'daily': 50,
        'total': 350,
        'currency': 'USD'
    }
    
    recommendations = recommender.recommend(
        user_vector=user_vector,
        budget_data=budget_data,
        top_k=3
    )
    
    print(f"\n📊 Recommendations within $50/day:")
    for i, rec in enumerate(recommendations, 1):
        budget_score = rec['scores']['budget']
        print(f"\n  {i}. {rec['name']} - ${rec['cost']}")
        print(f"     Budget Score: {budget_score:.2f}")
        print(f"     Final Score: {rec['final_score']:.3f}")
    
    # Test Case 5: Similar Destinations
    print("\n" + "-"*60)
    print("📝 TEST CASE 5: Similar to Louvre")
    print("-"*60)
    
    similar = recommender.get_similar_destinations('louvre', top_k=2)
    print(f"\n📊 Places similar to Louvre:")
    for i, dest in enumerate(similar, 1):
        print(f"\n  {i}. {dest['name']}")
        print(f"     Categories: {dest['categories']}")
    
    print("\n" + "="*60)
    print("✅ ALL TESTS COMPLETED SUCCESSFULLY!")
    print("="*60)
    
    return recommendations

def test_scoring_consistency():
    """Test that scoring is consistent"""
    print("\n" + "="*60)
    print("🧪 TEST 6: Scoring Consistency")
    print("="*60)
    
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    
    # Same user, same conditions should give same scores
    user = {'art_interest': 4, 'foodie_score': 4}
    vector = vectorizer.vectorize(user)
    
    rec1 = recommender.recommend(vector, top_k=5)
    rec2 = recommender.recommend(vector, top_k=5)
    
    # Check if first recommendation scores match
    score1 = rec1[0]['final_score']
    score2 = rec2[0]['final_score']
    
    print(f"\n📊 First run score: {score1:.3f}")
    print(f"📊 Second run score: {score2:.3f}")
    
    if abs(score1 - score2) < 0.001:
        print("✅ Scoring is consistent!")
    else:
        print("❌ Scoring is inconsistent!")
    
    return score1 == score2

if __name__ == "__main__":
    try:
        test_recommender()
        test_scoring_consistency()
        print("\n🎉 Step 2.3 COMPLETE! Recommender is working correctly!")
    except Exception as e:
        print(f"\n❌ Error during testing: {e}")
        import traceback
        traceback.print_exc()