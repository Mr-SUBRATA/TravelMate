# tests/test_explanations.py
"""
Test script for ExplanationGenerator
"""

import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import numpy as np
from app.core.explanations import ExplanationGenerator

def test_explanations():
    """Test the explanation generator"""
    print("\n" + "="*60)
    print("🧪 TESTING EXPLANATION GENERATOR")
    print("="*60)
    
    # Initialize
    exp_gen = ExplanationGenerator()
    print("✅ Explanation generator initialized")
    
    # Sample recommendation
    recommendation = {
        'name': 'Louvre Museum',
        'id': 'louvre_123',
        'categories': ['art', 'museum', 'history'],
        'cost': 17,
        'outdoor': False,
        'rating': 4.8,
        'review_count': 287543,
        'popularity': 0.95,
        'final_score': 0.96,
        'best_time': 'morning'
    }
    
    # Sample user preferences
    user_preferences = {
        'art': 5,
        'food': 4,
        'adventure': 2,
        'history': 5,
        'shopping': 3,
        'nature': 2,
        'nightlife': 1,
        'photography': 4
    }
    
    # Sample user vector (simulated)
    user_vector = np.random.rand(50)
    
    # Sample context
    context = {
        'weather': {
            'rain_prob': 80,
            'temp': 18,
            'condition': 'rainy'
        },
        'budget': {
            'daily': 100,
            'total': 1000
        },
        'crowd': {
            'level': 'quiet'
        },
        'time_of_day': 'morning'
    }
    
    # Test 1: Generate explanations
    print("\n📝 TEST 1: Generate Explanations")
    explanations = exp_gen.generate_explanations(
        recommendation=recommendation,
        user_vector=user_vector,
        user_preferences=user_preferences,
        context=context
    )
    
    print(f"\n📊 Short Summary: {explanations['short_summary']}")
    print(f"\n📊 Highlights: {explanations['highlights']}")
    print(f"\n📊 Match Interpretation: {explanations['match_interpretation']}")
    
    print("\n📊 Bullet Points:")
    for point in explanations['bullet_points'][:5]:
        print(f"   {point}")
    
    print("\n📊 Detailed Narrative:")
    print(explanations['detailed_narrative'])
    
    # Test 2: Weather adaptation explanation
    print("\n📝 TEST 2: Weather Adaptation Explanation")
    weather_exp = exp_gen.get_weather_adaptation_explanation(
        original="Montmartre Walking Tour",
        alternative="Orsay Museum",
        weather=context['weather']
    )
    print(f"   {weather_exp}")
    
    # Test 3: Group compromise explanation
    print("\n📝 TEST 3: Group Compromise Explanation")
    group_exp = exp_gen.get_group_compromise_explanation(
        activity="Louvre Museum",
        priority_user="Dad",
        happiness_scores={'Dad': 0.95, 'Mom': 0.45, 'Teen': 0.35}
    )
    print(f"   {group_exp}")
    
    print("\n" + "="*60)
    print("✅ EXPLANATION TESTS COMPLETED!")
    print("="*60)

if __name__ == "__main__":
    test_explanations()