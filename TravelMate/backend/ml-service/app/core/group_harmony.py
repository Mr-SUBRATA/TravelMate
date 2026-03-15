# app/core/group_harmony.py
"""
Group harmony algorithm - solves conflicts when multiple users have different preferences
This is YOUR intellectual property that makes group travel possible
"""

import numpy as np
from typing import List, Dict, Optional, Tuple
from collections import defaultdict
import logging
from app.core.vectorizer import PreferenceVectorizer

logger = logging.getLogger(__name__)

class GroupHarmonyOptimizer:
    """
    Optimizes itineraries for groups with different preferences
    Uses fairness algorithms to ensure everyone is happy
    """
    
    def __init__(self, recommender, vectorizer):
        """
        Initialize group optimizer
        
        Args:
            recommender: TravelRecommender instance
            vectorizer: PreferenceVectorizer instance
        """
        self.recommender = recommender
        self.vectorizer = vectorizer
        self.happiness_debt = defaultdict(float)
        
        logger.info("✅ Group Harmony Optimizer initialized")
    
    def optimize_for_group(self,
                          users: List[Dict],
                          destination: str,
                          days: int = 3,
                          constraints: Optional[Dict] = None) -> Dict:
        """
        Generate optimized itinerary for a group
        
        Args:
            users: List of user profiles with preferences
            destination: Target destination
            days: Number of days
            constraints: Optional constraints (budget, etc.)
            
        Returns:
            Optimized group itinerary with fairness metrics
        """
        # Vectorize all users
        user_vectors = []
        for user in users:
            vector = self.vectorizer.vectorize(user.get('preferences', {}))
            user_vectors.append({
                'id': user.get('id', f"user_{len(user_vectors)}"),
                'name': user.get('name', f"User {len(user_vectors)+1}"),
                'vector': vector,
                'preferences': user.get('preferences', {})
            })
        
        # Get available activities for destination
        activities = self._get_activities_for_destination(destination)
        
        # Generate optimized itinerary
        itinerary, metrics = self._build_group_itinerary(
            user_vectors,
            activities,
            days,
            constraints
        )
        
        # Calculate fairness metrics
        fairness = self._calculate_fairness_metrics(user_vectors, itinerary)
        
        return {
            'itinerary': itinerary,
            'fairness_score': fairness['score'],
            'happiness_scores': fairness['happiness'],
            'fairness_metrics': fairness,
            'recommendations': fairness['recommendations'],
            'group_summary': self._generate_group_summary(user_vectors, fairness)
        }
    
    def _build_group_itinerary(self,
                              users: List[Dict],
                              activities: List[Dict],
                              days: int,
                              constraints: Optional[Dict]) -> Tuple[List, Dict]:
        """
        Build itinerary that balances everyone's preferences
        """
        itinerary = []
        daily_happiness = []
        
        # Track whose turn it is (round-robin fairness)
        user_count = len(users)
        turn_index = 0
        
        # Track happiness per user
        happiness_tracker = {user['id']: [] for user in users}
        
        for day in range(days):
            day_activities = []
            day_happiness = []
            
            # Who gets priority today? (Round-robin)
            priority_user = users[turn_index % user_count]
            turn_index += 1
            
            # Get top activities for priority user
            candidates = self.recommender.recommend(
                user_vector=priority_user['vector'],
                top_k=10
            )
            
            # Filter by destination if needed
            candidates = [c for c in candidates if c.get('city') == activities[0].get('city')]
            
            # Find activity that everyone can tolerate
            chosen_activity = self._find_consensus_activity(
                candidates,
                users,
                priority_user,
                happiness_tracker
            )
            
            if chosen_activity:
                day_activities.append(chosen_activity)
                
                # Calculate happiness for all users
                day_scores = {}
                for user in users:
                    # Predict enjoyment for this activity
                    enjoyment = self._predict_enjoyment(
                        user['vector'],
                        chosen_activity
                    )
                    happiness_tracker[user['id']].append(enjoyment)
                    day_scores[user['name']] = round(enjoyment, 2)
                
                day_happiness.append({
                    'activity': chosen_activity['name'],
                    'scores': day_scores,
                    'priority_user': priority_user['name']
                })
            
            # Add some filler activities (meals, travel, etc.)
            day_activities.extend(self._get_filler_activities(day))
            
            itinerary.append({
                'day': day + 1,
                'date': f"Day {day + 1}",
                'activities': day_activities,
                'priority_user': priority_user['name'],
                'happiness': day_happiness
            })
            
            daily_happiness.append(day_happiness)
        
        # Calculate metrics
        metrics = {
            'days_planned': days,
            'total_activities': sum(len(day['activities']) for day in itinerary),
            'priority_distribution': self._calculate_priority_distribution(itinerary, users)
        }
        
        return itinerary, metrics
    
    def _find_consensus_activity(self,
                                candidates: List[Dict],
                                users: List[Dict],
                                priority_user: Dict,
                                happiness_tracker: Dict) -> Optional[Dict]:
        """
        Find activity that priority user loves and others tolerate
        """
        for activity in candidates:
            # Check if activity is feasible
            if not self._is_activity_feasible(activity):
                continue
            
            # Calculate tolerance scores for other users
            tolerance_scores = []
            for user in users:
                if user['id'] == priority_user['id']:
                    continue
                
                enjoyment = self._predict_enjoyment(
                    user['vector'],
                    activity
                )
                tolerance_scores.append(enjoyment)
            
            # Check if others can tolerate it (score > 0.3)
            if all(score > 0.3 for score in tolerance_scores):
                # Add fairness bonus for users with low happiness
                fairness_bonus = self._calculate_fairness_bonus(
                    activity,
                    users,
                    happiness_tracker
                )
                
                activity['fairness_bonus'] = fairness_bonus
                activity['consensus_score'] = np.mean(tolerance_scores) + fairness_bonus
                
                return activity
        
        # No perfect consensus found, return top candidate
        return candidates[0] if candidates else None
    
    def _predict_enjoyment(self, user_vector: np.ndarray, activity: Dict) -> float:
        """
        Predict how much a user will enjoy an activity
        """
        # Use similarity as proxy for enjoyment
        if 'vector' in activity:
            activity_vector = np.array(activity['vector'])
            similarity = np.dot(user_vector, activity_vector) / (
                np.linalg.norm(user_vector) * np.linalg.norm(activity_vector)
            )
            return float(max(0, similarity))
        
        # Fallback based on categories
        user_prefs = user_vector[:10]  # First 10 dimensions
        return float(np.mean(user_prefs))
    
    def _is_activity_feasible(self, activity: Dict) -> bool:
        """
        Check if activity is feasible (time, cost, etc.)
        """
        # Basic feasibility checks
        if activity.get('cost', 0) > 500:  # Too expensive
            return False
        
        return True
    
    def _calculate_fairness_bonus(self,
                                  activity: Dict,
                                  users: List[Dict],
                                  happiness_tracker: Dict) -> float:
        """
        Calculate bonus for activities that help fairness
        """
        # Calculate current happiness debt
        debts = []
        for user in users:
            user_happiness = happiness_tracker.get(user['id'], [])
            if user_happiness:
                avg_happiness = np.mean(user_happiness)
                debt = 1.0 - avg_happiness
                debts.append(debt)
        
        if not debts:
            return 0
        
        # Bonus for activities that help users with highest debt
        max_debt = max(debts)
        return max_debt * 0.2  # Max 20% bonus
    
    def _calculate_fairness_metrics(self,
                                   users: List[Dict],
                                   itinerary: List[Dict]) -> Dict:
        """
        Calculate fairness metrics for the group
        """
        # Calculate happiness per user
        happiness = defaultdict(list)
        
        for day in itinerary:
            for activity in day.get('activities', []):
                if 'scores' in activity:
                    for user_name, score in activity.get('scores', {}).items():
                        happiness[user_name].append(score)
        
        # Average happiness per user
        avg_happiness = {
            user: np.mean(scores) if scores else 0
            for user, scores in happiness.items()
        }
        
        # Calculate fairness score (lower std deviation = more fair)
        if avg_happiness:
            happiness_values = list(avg_happiness.values())
            fairness_score = 1.0 - np.std(happiness_values)
        else:
            fairness_score = 0
        
        # Generate recommendations for fairness improvement
        recommendations = self._generate_fairness_recommendations(
            avg_happiness,
            itinerary
        )
        
        return {
            'score': float(fairness_score),
            'happiness': avg_happiness,
            'std_deviation': float(np.std(list(avg_happiness.values()))) if avg_happiness else 0,
            'recommendations': recommendations
        }
    
    def _generate_fairness_recommendations(self,
                                         happiness: Dict,
                                         itinerary: List[Dict]) -> List[str]:
        """
        Generate recommendations to improve fairness
        """
        recommendations = []
        
        if not happiness:
            return recommendations
        
        # Find who's least happy
        least_happy = min(happiness.items(), key=lambda x: x[1])
        if least_happy[1] < 0.5:
            recommendations.append(
                f"💡 {least_happy[0]} seems less happy. Consider letting them choose tomorrow's activity."
            )
        
        # Check if anyone is dominating
        happiest = max(happiness.items(), key=lambda x: x[1])
        if happiest[1] > 0.9 and len(happiness) > 1:
            recommendations.append(
                f"💡 {happiest[0]} is very happy! Make sure others get their turns."
            )
        
        return recommendations
    
    def _generate_group_summary(self, users: List[Dict], fairness: Dict) -> str:
        """
        Generate human-readable group summary
        """
        summary = f"Group of {len(users)} travelers. "
        
        happiness = fairness.get('happiness', {})
        if happiness:
            avg_happiness = np.mean(list(happiness.values()))
            summary += f"Average happiness: {avg_happiness*100:.0f}%. "
        
        fairness_score = fairness.get('score', 0)
        if fairness_score > 0.8:
            summary += "Everyone is enjoying the trip fairly! 🎉"
        elif fairness_score > 0.6:
            summary += "Trip is reasonably balanced. 😊"
        else:
            summary += "Some travelers might need more attention. 🤔"
        
        return summary
    
    def _calculate_priority_distribution(self,
                                        itinerary: List[Dict],
                                        users: List[Dict]) -> Dict:
        """
        Calculate who got priority on which days
        """
        distribution = {user['name']: 0 for user in users}
        
        for day in itinerary:
            priority_user = day.get('priority_user')
            if priority_user in distribution:
                distribution[priority_user] += 1
        
        return distribution
    
    def _get_activities_for_destination(self, destination: str) -> List[Dict]:
        """
        Get available activities for a destination
        """
        # Use recommender's destinations filtered by city
        return [
            d for d in self.recommender.destinations
            if d.get('city', '').lower() == destination.lower()
        ] or self.recommender.destinations  # Fallback to all if none found
    
    def _get_filler_activities(self, day: int) -> List[Dict]:
        """
        Get standard filler activities (meals, breaks, etc.)
        """
        return [
            {
                'name': 'Lunch Break',
                'type': 'filler',
                'duration': 1,
                'cost': 20,
                'fixed': True
            },
            {
                'name': 'Dinner',
                'type': 'filler',
                'duration': 1.5,
                'cost': 30,
                'fixed': True
            }
        ]
    
    def reset_happiness_debt(self):
        """Reset happiness tracking for new group"""
        self.happiness_debt.clear()
        logger.info("🔄 Happiness debt reset")