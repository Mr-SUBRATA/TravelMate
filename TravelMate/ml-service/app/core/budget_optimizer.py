# app/core/budget_optimizer.py
"""
Budget optimization engine - creates Pareto frontier for cost vs experience trade-offs
This is YOUR intellectual property that helps users make informed decisions
"""

import numpy as np
from typing import List, Dict, Optional, Tuple
import logging
from dataclasses import dataclass
from enum import Enum

logger = logging.getLogger(__name__)

class SpendingPriority(Enum):
    """User's spending priority"""
    BUDGET = "budget"          # Save money, minimize costs
    BALANCED = "balanced"       # Balance cost and experience
    EXPERIENCE = "experience"   # Maximize experience, spend more

@dataclass
class BudgetOption:
    """Represents a budget option on the Pareto frontier"""
    name: str
    total_cost: float
    experience_score: float
    activities_count: int
    dining_quality: str
    accommodation_type: str
    savings: float
    recommendations: List[str]

class BudgetOptimizer:
    """
    Optimizes budget allocation and generates Pareto frontier
    Shows trade-offs between spending and satisfaction
    """
    
    def __init__(self, recommender):
        """
        Initialize budget optimizer
        
        Args:
            recommender: TravelRecommender instance for activity costs
        """
        self.recommender = recommender
        logger.info("✅ Budget Optimizer initialized")
    
    def optimize_budget(self,
                       user_vector: np.ndarray,
                       total_budget: float,
                       num_days: int,
                       destination: str,
                       priority: SpendingPriority = SpendingPriority.BALANCED,
                       preferences: Optional[Dict] = None) -> Dict:
        """
        Generate optimized budget allocation
        
        Args:
            user_vector: User preference vector
            total_budget: Total budget for trip
            num_days: Number of days
            destination: Target destination
            priority: Spending priority
            preferences: Additional user preferences
            
        Returns:
            Budget optimization results with Pareto frontier
        """
        # Calculate daily budget
        daily_budget = total_budget / num_days
        
        # Get activities for destination
        activities = self._get_activities_for_destination(destination)
        
        # Generate different budget scenarios
        scenarios = self._generate_budget_scenarios(
            user_vector,
            activities,
            total_budget,
            daily_budget,
            num_days,
            priority
        )
        
        # Find Pareto optimal points
        pareto_frontier = self._find_pareto_frontier(scenarios)
        
        # Find optimal scenario for user's priority
        optimal = self._find_optimal_scenario(
            pareto_frontier,
            total_budget,
            priority
        )
        
        # Generate allocation breakdown
        allocation = self._create_budget_allocation(
            optimal,
            daily_budget,
            num_days
        )
        
        # Generate recommendations
        recommendations = self._generate_budget_recommendations(
            optimal,
            total_budget,
            priority
        )
        
        return {
            'total_budget': total_budget,
            'daily_budget': daily_budget,
            'num_days': num_days,
            'priority': priority.value,
            'optimal_scenario': optimal,
            'pareto_frontier': pareto_frontier,
            'allocation': allocation,
            'recommendations': recommendations,
            'scenarios': scenarios[:5],  # Top 5 scenarios
            'savings_potential': self._calculate_savings_potential(scenarios, total_budget),
            'upgrade_options': self._find_upgrade_options(optimal, scenarios)
        }
    
    def _generate_budget_scenarios(self,
                                  user_vector: np.ndarray,
                                  activities: List[Dict],
                                  total_budget: float,
                                  daily_budget: float,
                                  num_days: int,
                                  priority: SpendingPriority) -> List[Dict]:
        """
        Generate different budget scenarios by varying allocations
        """
        scenarios = []
        
        # Generate scenarios with different budget multipliers
        for multiplier in np.linspace(0.5, 1.5, 11):  # 50% to 150% of budget
            scenario_budget = total_budget * multiplier
            
            # Adjust daily budget
            scenario_daily = scenario_budget / num_days
            
            # Select activities based on budget
            selected_activities = self._select_activities_for_budget(
                user_vector,
                activities,
                scenario_daily * 0.6,  # 60% for activities
                num_days * 3  # ~3 activities per day
            )
            
            # Calculate experience score
            experience_score = self._calculate_experience_score(
                selected_activities,
                user_vector
            )
            
            # Calculate costs
            activity_cost = sum(a.get('cost', 0) for a in selected_activities)
            accommodation_cost = scenario_budget * 0.3  # 30% for accommodation
            food_cost = scenario_budget * 0.2  # 20% for food
            transport_cost = scenario_budget * 0.1  # 10% for transport
            
            total_cost = activity_cost + accommodation_cost + food_cost + transport_cost
            
            scenarios.append({
                'name': self._get_scenario_name(multiplier),
                'budget_multiplier': multiplier,
                'total_budget': scenario_budget,
                'total_cost': total_cost,
                'experience_score': experience_score,
                'activities': selected_activities[:5],  # Top 5 activities
                'activity_cost': activity_cost,
                'accommodation_cost': accommodation_cost,
                'food_cost': food_cost,
                'transport_cost': transport_cost,
                'activities_count': len(selected_activities),
                'dining_quality': self._get_dining_quality(scenario_budget / num_days),
                'accommodation_type': self._get_accommodation_type(scenario_budget / num_days)
            })
        
        # Sort by cost
        scenarios.sort(key=lambda x: x['total_cost'])
        
        return scenarios
    
    def _select_activities_for_budget(self,
                                     user_vector: np.ndarray,
                                     activities: List[Dict],
                                     activity_budget: float,
                                     max_activities: int) -> List[Dict]:
        """
        Select best activities within budget
        """
        # Get recommendations sorted by score
        recommendations = self.recommender.recommend(
            user_vector=user_vector,
            top_k=len(activities)
        )
        
        # Filter and select within budget
        selected = []
        remaining_budget = activity_budget
        
        for rec in recommendations:
            cost = rec.get('cost', 0)
            if cost <= remaining_budget and len(selected) < max_activities:
                selected.append(rec)
                remaining_budget -= cost
        
        return selected
    
    def _find_pareto_frontier(self, scenarios: List[Dict]) -> List[Dict]:
        """
        Find Pareto optimal points (cannot improve one metric without hurting another)
        """
        pareto_points = []
        
        for i, scenario in enumerate(scenarios):
            dominated = False
            
            for j, other in enumerate(scenarios):
                if i == j:
                    continue
                
                # Check if other scenario dominates this one
                if (other['total_cost'] <= scenario['total_cost'] and 
                    other['experience_score'] >= scenario['experience_score'] and
                    (other['total_cost'] < scenario['total_cost'] or 
                     other['experience_score'] > scenario['experience_score'])):
                    dominated = True
                    break
            
            if not dominated:
                pareto_points.append(scenario)
        
        # Sort by cost
        pareto_points.sort(key=lambda x: x['total_cost'])
        
        return pareto_points
    
    def _find_optimal_scenario(self,
                              pareto_frontier: List[Dict],
                              target_budget: float,
                              priority: SpendingPriority) -> Dict:
        """
        Find optimal scenario based on user priority
        """
        if priority == SpendingPriority.BUDGET:
            # Find cheapest acceptable scenario
            for scenario in pareto_frontier:
                if scenario['experience_score'] > 0.5:  # Minimum acceptable experience
                    return scenario
            
            return pareto_frontier[0] if pareto_frontier else {}
            
        elif priority == SpendingPriority.EXPERIENCE:
            # Find best experience within 20% of budget
            max_budget = target_budget * 1.2
            best_experience = None
            best_score = 0
            
            for scenario in pareto_frontier:
                if scenario['total_cost'] <= max_budget:
                    if scenario['experience_score'] > best_score:
                        best_score = scenario['experience_score']
                        best_experience = scenario
            
            return best_experience or pareto_frontier[-1] if pareto_frontier else {}
            
        else:  # BALANCED
            # Find closest to budget with good experience
            best_scenario = None
            best_value = float('inf')
            
            for scenario in pareto_frontier:
                # Value = distance from budget + (1 - experience) penalty
                budget_diff = abs(scenario['total_cost'] - target_budget) / target_budget
                experience_penalty = 1 - scenario['experience_score']
                value = budget_diff + experience_penalty * 0.5
                
                if value < best_value:
                    best_value = value
                    best_scenario = scenario
            
            return best_scenario or pareto_frontier[len(pareto_frontier)//2] if pareto_frontier else {}
    
    def _create_budget_allocation(self,
                                 scenario: Dict,
                                 daily_budget: float,
                                 num_days: int) -> Dict:
        """
        Create detailed budget allocation breakdown
        """
        if not scenario:
            return {}
        
        return {
            'daily': {
                'accommodation': scenario.get('accommodation_cost', 0) / num_days,
                'food': scenario.get('food_cost', 0) / num_days,
                'activities': scenario.get('activity_cost', 0) / num_days,
                'transport': scenario.get('transport_cost', 0) / num_days,
                'total': daily_budget
            },
            'total': {
                'accommodation': scenario.get('accommodation_cost', 0),
                'food': scenario.get('food_cost', 0),
                'activities': scenario.get('activity_cost', 0),
                'transport': scenario.get('transport_cost', 0),
                'total': scenario.get('total_cost', 0)
            },
            'percentages': {
                'accommodation': (scenario.get('accommodation_cost', 0) / scenario.get('total_cost', 1)) * 100,
                'food': (scenario.get('food_cost', 0) / scenario.get('total_cost', 1)) * 100,
                'activities': (scenario.get('activity_cost', 0) / scenario.get('total_cost', 1)) * 100,
                'transport': (scenario.get('transport_cost', 0) / scenario.get('total_cost', 1)) * 100
            }
        }
    
    def _calculate_experience_score(self,
                                   activities: List[Dict],
                                   user_vector: np.ndarray) -> float:
        """
        Calculate overall experience score for a set of activities
        """
        if not activities:
            return 0.0
        
        total_score = 0
        for activity in activities:
            total_score += activity.get('final_score', 0.5)
        
        return total_score / len(activities)
    
    def _calculate_savings_potential(self,
                                    scenarios: List[Dict],
                                    target_budget: float) -> Dict:
        """
        Calculate potential savings by adjusting budget
        """
        if not scenarios:
            return {}
        
        # Find best value for money
        best_value = None
        best_ratio = 0
        
        for scenario in scenarios:
            if scenario['total_cost'] > 0:
                value_ratio = scenario['experience_score'] / scenario['total_cost']
                if value_ratio > best_ratio:
                    best_ratio = value_ratio
                    best_value = scenario
        
        # Find scenarios near target budget
        near_budget = [
            s for s in scenarios
            if abs(s['total_cost'] - target_budget) / target_budget < 0.1
        ]
        
        if near_budget:
            avg_experience = np.mean([s['experience_score'] for s in near_budget])
        else:
            avg_experience = 0
        
        return {
            'best_value_scenario': best_value,
            'best_value_ratio': best_ratio,
            'avg_experience_at_budget': avg_experience,
            'max_savings': max(0, target_budget - min(s['total_cost'] for s in scenarios)),
            'min_budget': min(s['total_cost'] for s in scenarios),
            'max_budget': max(s['total_cost'] for s in scenarios)
        }
    
    def _find_upgrade_options(self,
                            current: Dict,
                            scenarios: List[Dict]) -> List[Dict]:
        """
        Find upgrade options from current scenario
        """
        if not current:
            return []
        
        current_cost = current.get('total_cost', 0)
        current_score = current.get('experience_score', 0)
        
        upgrades = []
        for scenario in scenarios:
            if scenario['total_cost'] > current_cost * 1.1:  # At least 10% more expensive
                score_improvement = scenario['experience_score'] - current_score
                cost_increase = scenario['total_cost'] - current_cost
                
                if score_improvement > 0:
                    upgrades.append({
                        'name': scenario['name'],
                        'cost_increase': cost_increase,
                        'score_improvement': score_improvement,
                        'value_ratio': score_improvement / cost_increase if cost_increase > 0 else 0,
                        'new_total': scenario['total_cost'],
                        'new_score': scenario['experience_score']
                    })
        
        # Sort by best value
        upgrades.sort(key=lambda x: x['value_ratio'], reverse=True)
        
        return upgrades[:3]  # Top 3 upgrades
    
    def _generate_budget_recommendations(self,
                                        optimal: Dict,
                                        total_budget: float,
                                        priority: SpendingPriority) -> List[str]:
        """
        Generate budget recommendations
        """
        recommendations = []
        
        if not optimal:
            return recommendations
        
        optimal_cost = optimal.get('total_cost', 0)
        optimal_score = optimal.get('experience_score', 0)
        
        if optimal_cost < total_budget * 0.9:
            recommendations.append(
                f"💰 You're under budget! You could save ${total_budget - optimal_cost:.0f} "
                f"or upgrade your experience."
            )
        elif optimal_cost > total_budget * 1.1:
            recommendations.append(
                f"⚠️ Your optimal plan is ${optimal_cost - total_budget:.0f} over budget. "
                f"Consider these alternatives..."
            )
        
        if priority == SpendingPriority.BUDGET:
            recommendations.append(
                f"💡 As a budget-conscious traveler, you're getting {optimal_score*100:.0f}% "
                f"experience for ${optimal_cost:.0f}."
            )
        elif priority == SpendingPriority.EXPERIENCE:
            recommendations.append(
                f"✨ You're maximizing experience! {optimal_score*100:.0f}% satisfaction "
                f"for ${optimal_cost:.0f}."
            )
        else:
            recommendations.append(
                f"⚖️ Balanced approach: {optimal_score*100:.0f}% experience "
                f"at ${optimal_cost:.0f}."
            )
        
        # Dining recommendation
        dining = optimal.get('dining_quality', 'mid-range')
        recommendations.append(
            f"🍽️ Recommended dining: {dining} restaurants to fit your budget."
        )
        
        # Accommodation recommendation
        accommodation = optimal.get('accommodation_type', 'mid-range hotels')
        recommendations.append(
            f"🏨 Accommodation: {accommodation} for best value."
        )
        
        return recommendations
    
    def _get_scenario_name(self, multiplier: float) -> str:
        """Get name for budget scenario"""
        if multiplier < 0.7:
            return "Budget Saver"
        elif multiplier < 0.9:
            return "Economy"
        elif multiplier < 1.1:
            return "Balanced"
        elif multiplier < 1.3:
            return "Premium"
        else:
            return "Luxury"
    
    def _get_dining_quality(self, daily_budget: float) -> str:
        """Determine dining quality based on daily budget"""
        if daily_budget < 50:
            return "budget (street food, casual)"
        elif daily_budget < 100:
            return "mid-range (local restaurants)"
        elif daily_budget < 200:
            return "upscale (nice restaurants)"
        else:
            return "fine dining (Michelin star)"
    
    def _get_accommodation_type(self, daily_budget: float) -> str:
        """Determine accommodation type based on daily budget"""
        if daily_budget < 50:
            return "hostels/budget hotels"
        elif daily_budget < 100:
            return "3-star hotels"
        elif daily_budget < 200:
            return "4-star hotels"
        else:
            return "luxury 5-star hotels"
    
    def _get_activities_for_destination(self, destination: str) -> List[Dict]:
        """Get activities for destination"""
        return [
            d for d in self.recommender.destinations
            if d.get('city', '').lower() == destination.lower()
        ] or self.recommender.destinations
    
    def get_pareto_chart_data(self, scenarios: List[Dict]) -> Dict:
        """
        Get data formatted for Pareto chart visualization
        """
        return {
            'points': [
                {
                    'cost': s['total_cost'],
                    'experience': s['experience_score'],
                    'name': s['name']
                }
                for s in scenarios
            ],
            'pareto_frontier': [
                {
                    'cost': s['total_cost'],
                    'experience': s['experience_score'],
                    'name': s['name']
                }
                for s in self._find_pareto_frontier(scenarios)
            ],
            'x_label': 'Total Cost ($)',
            'y_label': 'Experience Score (%)',
            'title': 'Budget vs Experience Trade-off'
        }