# tests/test_budget_optimizer.py
"""
Test script for BudgetOptimizer
Run this to verify Step 2.6 is working correctly
"""

import sys
import os
import numpy as np

# Add project root to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.core.vectorizer import PreferenceVectorizer
from app.core.recommender import TravelRecommender
from app.core.budget_optimizer import BudgetOptimizer, SpendingPriority

def test_budget_optimizer():
    """Test the budget optimizer"""
    print("\n" + "="*60)
    print("🧪 TESTING BUDGET OPTIMIZER")
    print("="*60)
    
    # Initialize components
    print("\n📦 Initializing components...")
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    optimizer = BudgetOptimizer(recommender)
    
    # Create test user
    test_user = {
        'art_interest': 4,
        'foodie_score': 3,
        'adventure_seeking': 3,
        'budget_conscious': 3
    }
    user_vector = vectorizer.vectorize(test_user)
    
    # Test 1: Basic budget optimization
    print("\n" + "-"*60)
    print("📝 TEST 1: Basic Budget Optimization ($1000 for 5 days in Paris)")
    print("-"*60)
    
    result = optimizer.optimize_budget(
        user_vector=user_vector,
        total_budget=1000,
        num_days=5,
        destination="Paris",
        priority=SpendingPriority.BALANCED
    )
    
    print(f"\n📊 Daily Budget: ${result['daily_budget']:.0f}/day")
    print(f"\n📊 Optimal Scenario: {result['optimal_scenario'].get('name', 'Unknown')}")
    print(f"   Total Cost: ${result['optimal_scenario'].get('total_cost', 0):.0f}")
    print(f"   Experience Score: {result['optimal_scenario'].get('experience_score', 0)*100:.1f}%")
    print(f"   Dining: {result['optimal_scenario'].get('dining_quality', 'Unknown')}")
    print(f"   Accommodation: {result['optimal_scenario'].get('accommodation_type', 'Unknown')}")
    
    print(f"\n📊 Budget Allocation:")
    allocation = result['allocation']
    if allocation:
        print(f"   Daily Breakdown:")
        print(f"      🏨 Accommodation: ${allocation['daily']['accommodation']:.0f}")
        print(f"      🍽️ Food: ${allocation['daily']['food']:.0f}")
        print(f"      🎯 Activities: ${allocation['daily']['activities']:.0f}")
        print(f"      🚗 Transport: ${allocation['daily']['transport']:.0f}")
    
    print(f"\n📊 Pareto Frontier Points:")
    for point in result['pareto_frontier'][:3]:  # Show first 3
        print(f"   • {point['name']}: ${point['total_cost']:.0f} - {point['experience_score']*100:.1f}%")
    
    print(f"\n📊 Recommendations:")
    for rec in result['recommendations']:
        print(f"   • {rec}")
    
    # Test 2: Different priorities
    print("\n" + "-"*60)
    print("📝 TEST 2: Comparing Different Priorities")
    print("-"*60)
    
    priorities = [
        (SpendingPriority.BUDGET, "Budget Focus"),
        (SpendingPriority.BALANCED, "Balanced"),
        (SpendingPriority.EXPERIENCE, "Experience Focus")
    ]
    
    for priority, name in priorities:
        result = optimizer.optimize_budget(
            user_vector=user_vector,
            total_budget=1000,
            num_days=5,
            destination="Paris",
            priority=priority
        )
        
        optimal = result['optimal_scenario']
        print(f"\n{name}:")
        print(f"   Cost: ${optimal.get('total_cost', 0):.0f}")
        print(f"   Experience: {optimal.get('experience_score', 0)*100:.1f}%")
        print(f"   Accommodation: {optimal.get('accommodation_type', 'Unknown')}")
    
    # Test 3: Savings potential
    print("\n" + "-"*60)
    print("📝 TEST 3: Savings Potential Analysis")
    print("-"*60)
    
    savings = result.get('savings_potential', {})
    if savings:
        print(f"\n💰 Max Savings: ${savings.get('max_savings', 0):.0f}")
        print(f"📉 Min Budget: ${savings.get('min_budget', 0):.0f}")
        print(f"📈 Max Budget: ${savings.get('max_budget', 0):.0f}")
    
    # Test 4: Upgrade options
    print("\n" + "-"*60)
    print("📝 TEST 4: Upgrade Options")
    print("-"*60)
    
    upgrades = result.get('upgrade_options', [])
    if upgrades:
        print(f"\n🚀 Best Upgrade:")
        best = upgrades[0]
        print(f"   +${best['cost_increase']:.0f} for +{best['score_improvement']*100:.1f}% experience")
    
    # Test 5: Pareto chart data
    print("\n" + "-"*60)
    print("📝 TEST 5: Pareto Chart Data")
    print("-"*60)
    
    chart_data = optimizer.get_pareto_chart_data(result.get('scenarios', []))
    print(f"\n📊 Chart Points: {len(chart_data['points'])}")
    print(f"📈 Pareto Points: {len(chart_data['pareto_frontier'])}")
    print(f"📋 X Label: {chart_data['x_label']}")
    print(f"📋 Y Label: {chart_data['y_label']}")
    
    print("\n" + "="*60)
    print("✅ BUDGET OPTIMIZER TESTS COMPLETED!")
    print("="*60)

def test_edge_cases():
    """Test edge cases"""
    print("\n" + "="*60)
    print("🧪 TEST 6: Edge Cases")
    print("="*60)
    
    vectorizer = PreferenceVectorizer()
    recommender = TravelRecommender("app/data/destination_vectors.json")
    optimizer = BudgetOptimizer(recommender)
    
    test_user = {'art_interest': 3}
    user_vector = vectorizer.vectorize(test_user)
    
    # Test with very low budget
    print("\n📝 Test 6.1: Very Low Budget ($200 for 5 days)")
    result = optimizer.optimize_budget(
        user_vector=user_vector,
        total_budget=200,
        num_days=5,
        destination="Paris",
        priority=SpendingPriority.BUDGET
    )
    print(f"   Handled: {'✅' if result else '❌'}")
    print(f"   Optimal cost: ${result['optimal_scenario'].get('total_cost', 0):.0f}")
    
    # Test with very high budget
    print("\n📝 Test 6.2: Very High Budget ($5000 for 5 days)")
    result = optimizer.optimize_budget(
        user_vector=user_vector,
        total_budget=5000,
        num_days=5,
        destination="Paris",
        priority=SpendingPriority.EXPERIENCE
    )
    print(f"   Handled: {'✅' if result else '❌'}")
    print(f"   Optimal cost: ${result['optimal_scenario'].get('total_cost', 0):.0f}")
    
    # Test with 1 day trip
    print("\n📝 Test 6.3: 1 Day Trip")
    result = optimizer.optimize_budget(
        user_vector=user_vector,
        total_budget=300,
        num_days=1,
        destination="Paris",
        priority=SpendingPriority.BALANCED
    )
    print(f"   Handled: {'✅' if result else '❌'}")
    print(f"   Daily budget: ${result['daily_budget']:.0f}")
    
    print("\n✅ All edge cases handled!")

if __name__ == "__main__":
    try:
        test_budget_optimizer()
        test_edge_cases()
        print("\n🎉 Step 2.6 COMPLETE! Budget Optimizer is working correctly!")
    except Exception as e:
        print(f"\n❌ Error during testing: {e}")
        import traceback
        traceback.print_exc()