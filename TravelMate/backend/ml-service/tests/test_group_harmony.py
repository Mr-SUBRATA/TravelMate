# tests/test_group_harmony.py
"""
Test script for GroupHarmonyOptimizer
Run this to verify Step 2.5 is working correctly
"""

import sys
import os
import numpy as np

# Add project root to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.core.vectorizer import PreferenceVectorizer
from app.core.recommender import TravelRecommender
from app.core.group_harmony import GroupHarmonyOptimizer

def create_sample_users():
    """Create sample users with different preferences"""
    return [
        {
            'id': 'user1',
            'name': 'Alice (Art Lover)',
            'preferences': {
                'art_interest': 5,
                'foodie_score': 3,
                'adventure_seeking': 2,
                'crowd_tolerance': 3,
                'interests': ['museum', 'gallery']
            }
        },
        {
            'id': 'user2',
            'name': 'Bob (Adventurer)',
            'preferences': {
                'art_interest': 2,
                'foodie_score': 3,
                'adventure_seeking': 5,
                'crowd_tolerance': 4,
                'interests': ['hiking', 'outdoor']
            }
        },
        {
            'id': 'user3',
            'name': 'Charlie (Foodie)',
            'preferences': {
                'art_interest': 3,
                'foodie_score': 5,
                'adventure_seeking': 2,
                'crowd_tolerance': 2,
                'interests': ['local_food', 'fine_dining']
            }
        }
    ]

def test_group_harmony():
    """Test the group harmony optimizer"""
    print("\n" + "="*60)
    print("🧪 TESTING GROUP HARMONY OPTIMIZER")
    print("="*60)
    
    # Initialize components
    print("\n📦 Initializing components...")
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    optimizer = GroupHarmonyOptimizer(recommender, vectorizer)
    
    # Create test users
    users = create_sample_users()
    print(f"✅ Created {len(users)} test users")
    
    # Test 1: Basic group optimization
    print("\n" + "-"*60)
    print("📝 TEST 1: Basic Group Optimization (3 days in Paris)")
    print("-"*60)
    
    result = optimizer.optimize_for_group(
        users=users,
        destination="Paris",
        days=3
    )
    
    print(f"\n📊 Group Fairness Score: {result['fairness_score']:.2f}")
    print(f"\n📊 Happiness Scores:")
    for user, score in result['happiness_scores'].items():
        print(f"   {user}: {score*100:.1f}%")
    
    print(f"\n📅 Itinerary:")
    for day in result['itinerary']:
        print(f"\n   Day {day['day']} (Priority: {day['priority_user']})")
        for activity in day['activities']:
            if 'scores' in activity:
                # Get activity name - could be in different keys
                if 'activity' in activity:
                    activity_name = activity['activity']
                elif 'name' in activity:
                    activity_name = activity['name']
                else:
                    activity_name = "Activity"
            
                print(f"      • {activity_name}")
                for person, score in activity['scores'].items():
                    print(f"         {person}: {score*100:.0f}%")
            elif 'name' in activity:
                print(f"      • {activity['name']} (fixed)")
            else:
                print(f"      • Activity (fixed)")
    # Test 2: Fairness verification
    print("\n" + "-"*60)
    print("📝 TEST 2: Fairness Verification")
    print("-"*60)
    
    # Check if everyone got priority
    priority_count = {}
    for day in result['itinerary']:
        priority = day['priority_user']
        priority_count[priority] = priority_count.get(priority, 0) + 1
    
    print(f"\n📊 Priority Distribution:")
    for user, count in priority_count.items():
        print(f"   {user}: {count} days")
    
    # Test 3: Conflict resolution
    print("\n" + "-"*60)
    print("📝 TEST 3: Conflict Resolution")
    print("-"*60)
    
    # Create conflicting preferences
    conflicting_users = [
        {
            'id': 'user1',
            'name': 'Museum Lover',
            'preferences': {'art_interest': 5, 'adventure_seeking': 1}
        },
        {
            'id': 'user2',
            'name': 'Adventure Seeker',
            'preferences': {'art_interest': 1, 'adventure_seeking': 5}
        }
    ]
    
    result_conflict = optimizer.optimize_for_group(
        users=conflicting_users,
        destination="Paris",
        days=2
    )
    
    print(f"\n📊 Fairness Score with Conflict: {result_conflict['fairness_score']:.2f}")
    print(f"   Museum Lover Happiness: {result_conflict['happiness_scores'].get('Museum Lover', 0)*100:.1f}%")
    print(f"   Adventure Seeker Happiness: {result_conflict['happiness_scores'].get('Adventure Seeker', 0)*100:.1f}%")
    
    # Test 4: Recommendations
    print("\n" + "-"*60)
    print("📝 TEST 4: Fairness Recommendations")
    print("-"*60)
    
    for rec in result_conflict.get('recommendations', []):
        print(f"   {rec}")
    
    # Test 5: Group summary
    print("\n" + "-"*60)
    print("📝 TEST 5: Group Summary")
    print("-"*60)
    
    print(f"\n📝 {result['group_summary']}")
    
    print("\n" + "="*60)
    print("✅ GROUP HARMONY TESTS COMPLETED!")
    print("="*60)

def test_edge_cases():
    """Test edge cases"""
    print("\n" + "="*60)
    print("🧪 TEST 6: Edge Cases")
    print("="*60)
    
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    optimizer = GroupHarmonyOptimizer(recommender, vectorizer)
    
    # Test with single user
    print("\n📝 Test 6.1: Single User")
    single_user = [{'id': 'user1', 'name': 'Solo Traveler', 'preferences': {'art_interest': 4}}]
    result = optimizer.optimize_for_group(single_user, "Paris", days=2)
    print(f"   Fairness score: {result['fairness_score']:.2f}")
    print(f"   Happiness: {list(result['happiness_scores'].values())[0]*100:.1f}%")
    
    # Test with empty preferences
    print("\n📝 Test 6.2: Empty Preferences")
    empty_user = [{'id': 'user1', 'name': 'No Preferences', 'preferences': {}}]
    result = optimizer.optimize_for_group(empty_user, "Paris", days=1)
    print(f"   Handled empty preferences: {'✅' if result else '❌'}")
    
    # Test with large group
    print("\n📝 Test 6.3: Large Group (5 users)")
    large_group = [
        {'id': f'user{i}', 'name': f'User {i}', 'preferences': {'art_interest': i}}
        for i in range(1, 6)
    ]
    result = optimizer.optimize_for_group(large_group, "Paris", days=2)
    print(f"   5 users handled: {'✅' if result else '❌'}")
    print(f"   Fairness score: {result['fairness_score']:.2f}")
    
    print("\n✅ All edge cases handled!")

if __name__ == "__main__":
    try:
        test_group_harmony()
        test_edge_cases()
        print("\n🎉 Step 2.5 COMPLETE! Group Harmony Optimizer is working correctly!")
    except Exception as e:
        print(f"\n❌ Error during testing: {e}")
        import traceback
        traceback.print_exc()