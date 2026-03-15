# app/core/explanations.py
"""
Explanation generator - tells users WHY recommendations were made
This is YOUR transparency layer that builds trust!
"""

import numpy as np
from typing import Dict, List, Optional
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class ExplanationGenerator:
    """
    Generates human-readable explanations for ML recommendations
    """
    
    def __init__(self):
        self.reason_templates = {
            'preference': {
                'art': "You rated art interest {}/5",
                'food': "You're a foodie ({}/5)",
                'adventure': "You seek adventure ({}/5)",
                'history': "You love history ({}/5)",
                'shopping': "You enjoy shopping ({}/5)",
                'nature': "You appreciate nature ({}/5)",
                'nightlife': "You enjoy nightlife ({}/5)",
                'photography': "You love photography ({}/5)"
            },
            'weather': {
                'indoor_bonus': "Indoor activity - perfect for {condition} weather",
                'outdoor_penalty': "Outdoor activity - {condition} weather may affect experience",
                'rain_swap': "Swapped from outdoor to indoor due to {rain_prob}% rain chance",
                'heat_alert': "Cool indoor alternative for {temp}°C heat",
                'cold_alert': "Warm indoor option for {temp}°C weather"
            },
            'budget': {
                'under': "Under budget (${cost} < ${budget})",
                'within': "Within your ${budget}/day budget",
                'slightly_over': "Slightly over budget (+${extra})",
                'great_value': "Great value for money!",
                'splurge': "Special experience worth the splurge"
            },
            'crowd': {
                'quiet': "Quiet time - fewer crowds",
                'moderate': "Moderate crowds - manageable",
                'busy': "Popular spot - can be busy",
                'hidden_gem': "Hidden gem - loved by locals"
            },
            'time': {
                'morning': "Best experienced in the morning",
                'afternoon': "Ideal for afternoon visit",
                'evening': "Magical in the evening",
                'flexible': "Works any time of day"
            },
            'social': {
                'similar_travelers': "{percent}% of travelers like you loved this",
                'top_rated': "Top-rated among {category} lovers",
                'recommended': "Recommended by {count} similar users"
            }
        }
        
        logger.info("✅ Explanation Generator initialized")
    
    def generate_explanations(self,
                             recommendation: Dict,
                             user_vector: np.ndarray,
                             user_preferences: Dict,
                             context: Optional[Dict] = None) -> Dict:
        """
        Generate comprehensive explanations for a recommendation
        
        Args:
            recommendation: The recommended place/activity
            user_vector: User's 50-dim vector
            user_preferences: Raw quiz answers
            context: Optional context (weather, time, budget)
            
        Returns:
            Dictionary with explanations in different formats
        """
        reasons = []
        highlights = []
        details = {}
        
        # 1. Preference-based explanations
        pref_reasons = self._explain_preferences(recommendation, user_preferences)
        reasons.extend(pref_reasons)
        if pref_reasons:
            highlights.append(pref_reasons[0])  # Best reason as highlight
        
        # 2. Weather-based explanations (if context has weather)
        if context and context.get('weather'):
            weather_reasons = self._explain_weather(recommendation, context['weather'])
            reasons.extend(weather_reasons)
        
        # 3. Budget-based explanations
        if context and context.get('budget'):
            budget_reasons = self._explain_budget(recommendation, context['budget'])
            reasons.extend(budget_reasons)
        
        # 4. Crowd/timing explanations
        if context and context.get('crowd'):
            crowd_reasons = self._explain_crowd(recommendation, context['crowd'])
            reasons.extend(crowd_reasons)
        
        # 5. Social proof explanations
        social_reasons = self._explain_social_proof(recommendation)
        reasons.extend(social_reasons)
        
        # 6. Time-based explanations
        if context and context.get('time_of_day'):
            time_reasons = self._explain_timing(recommendation, context['time_of_day'])
            reasons.extend(time_reasons)
        
        # 7. Match score interpretation
        match_score = recommendation.get('final_score', 0)
        score_interpretation = self._interpret_score(match_score)
        
        # Generate short summary (for cards)
        short_summary = self._generate_short_summary(
            recommendation, 
            highlights[0] if highlights else "Matches your preferences"
        )
        
        # Generate detailed narrative (for explanation page)
        detailed_narrative = self._generate_detailed_narrative(
            recommendation,
            reasons,
            match_score
        )
        
        # Generate bullet points (for lists)
        bullet_points = self._format_bullet_points(reasons)
        
        return {
            'short_summary': short_summary,
            'detailed_narrative': detailed_narrative,
            'bullet_points': bullet_points,
            'highlights': highlights[:3],  # Top 3 reasons
            'match_interpretation': score_interpretation,
            'reasons_count': len(reasons),
            'all_reasons': reasons  # Raw list for debugging/flexibility
        }
    
    def _explain_preferences(self, recommendation: Dict, preferences: Dict) -> List[str]:
        """Explain based on user's stated preferences"""
        reasons = []
        
        # Map recommendation categories to preference types
        category_map = {
            'art': ['museum', 'gallery', 'art'],
            'food': ['restaurant', 'food', 'cafe', 'bakery'],
            'adventure': ['hiking', 'adventure', 'extreme', 'outdoor'],
            'history': ['historical', 'monument', 'heritage', 'ancient'],
            'shopping': ['mall', 'shop', 'boutique', 'market'],
            'nature': ['park', 'garden', 'nature', 'beach'],
            'nightlife': ['club', 'bar', 'nightlife', 'pub'],
            'photography': ['viewpoint', 'scenic', 'photography']
        }
        
        rec_categories = recommendation.get('categories', [])
        
        for pref_name, pref_value in preferences.items():
            if pref_name in category_map and pref_value >= 4:  # High interest (4-5)
                # Check if recommendation matches this preference
                if any(cat in rec_categories for cat in category_map[pref_name]):
                    template = self.reason_templates['preference'].get(pref_name)
                    if template:
                        reasons.append(template.format(pref_value))
        
        # If no specific matches, add general preference reason
        if not reasons and rec_categories:
            top_pref = max(preferences.items(), key=lambda x: x[1])
            if top_pref[1] >= 3:
                reasons.append(f"Matches your interest in {top_pref[0]}")
        
        return reasons
    
    def _explain_weather(self, recommendation: Dict, weather: Dict) -> List[str]:
        """Explain weather-related reasoning"""
        reasons = []
        
        is_outdoor = recommendation.get('outdoor', False)
        rain_prob = weather.get('rain_prob', 0)
        temp = weather.get('temp', 20)
        condition = weather.get('condition', 'clear')
        
        if is_outdoor:
            if rain_prob > 60:
                reasons.append(self.reason_templates['weather']['rain_swap'].format(
                    rain_prob=rain_prob
                ))
            elif rain_prob > 30:
                reasons.append(f"Light rain possible ({rain_prob}%) - bring umbrella")
            
            if temp > 35:
                reasons.append(self.reason_templates['weather']['heat_alert'].format(
                    temp=temp
                ))
            elif temp < 5:
                reasons.append(self.reason_templates['weather']['cold_alert'].format(
                    temp=temp
                ))
        else:
            # Indoor activity
            if rain_prob > 50:
                reasons.append(self.reason_templates['weather']['indoor_bonus'].format(
                    condition='rainy'
                ))
            elif temp > 35 or temp < 5:
                reasons.append(self.reason_templates['weather']['indoor_bonus'].format(
                    condition=condition
                ))
        
        return reasons
    
    def _explain_budget(self, recommendation: Dict, budget: Dict) -> List[str]:
        """Explain budget-related reasoning"""
        reasons = []
        
        cost = recommendation.get('cost', 0)
        daily_budget = budget.get('daily', 100)
        total_budget = budget.get('total', 1000)
        
        if cost == 0:
            reasons.append("Free activity!")
        elif cost < daily_budget * 0.5:
            reasons.append(self.reason_templates['budget']['under'].format(
                cost=cost,
                budget=daily_budget
            ))
            reasons.append(self.reason_templates['budget']['great_value'])
        elif cost <= daily_budget:
            reasons.append(self.reason_templates['budget']['within'].format(
                budget=daily_budget
            ))
        elif cost <= daily_budget * 1.2:
            extra = cost - daily_budget
            reasons.append(self.reason_templates['budget']['slightly_over'].format(
                extra=round(extra)
            ))
        else:
            reasons.append(self.reason_templates['budget']['splurge'])
        
        return reasons
    
    def _explain_crowd(self, recommendation: Dict, crowd: Dict) -> List[str]:
        """Explain crowd-related reasoning"""
        reasons = []
        
        crowd_level = crowd.get('level', 'moderate')
        is_hidden = recommendation.get('hidden_gem', False)
        
        if is_hidden:
            reasons.append(self.reason_templates['crowd']['hidden_gem'])
        
        reasons.append(self.reason_templates['crowd'].get(
            crowd_level, 
            self.reason_templates['crowd']['moderate']
        ))
        
        return reasons
    
    def _explain_social_proof(self, recommendation: Dict) -> List[str]:
        """Explain based on what similar users liked"""
        reasons = []
        
        rating = recommendation.get('rating', 0)
        review_count = recommendation.get('review_count', 0)
        popularity = recommendation.get('popularity', 0)
        
        if rating >= 4.5:
            reasons.append(f"Exceptional rating: {rating}/5")
        elif rating >= 4.0:
            reasons.append(f"Highly rated: {rating}/5")
        
        if review_count > 1000:
            reasons.append(f"Trusted by {review_count}+ visitors")
        
        if popularity > 0.9:
            reasons.append("One of the most popular attractions")
        
        return reasons
    
    def _explain_timing(self, recommendation: Dict, time_of_day: str) -> List[str]:
        """Explain based on time of day"""
        reasons = []
        
        best_time = recommendation.get('best_time', 'flexible')
        
        if best_time == time_of_day:
            template = self.reason_templates['time'].get(best_time)
            if template:
                reasons.append(template)
        elif best_time != 'flexible':
            reasons.append(f"Best experienced in the {best_time}")
        
        return reasons
    
    def _interpret_score(self, score: float) -> Dict:
        """Interpret what the match score means"""
        if score >= 0.95:
            return {
                'level': 'exceptional',
                'description': 'Perfect match!',
                'emoji': '🌟🌟🌟🌟🌟'
            }
        elif score >= 0.85:
            return {
                'level': 'excellent',
                'description': 'Excellent match',
                'emoji': '⭐⭐⭐⭐⭐'
            }
        elif score >= 0.75:
            return {
                'level': 'great',
                'description': 'Great match',
                'emoji': '⭐⭐⭐⭐'
            }
        elif score >= 0.6:
            return {
                'level': 'good',
                'description': 'Good match',
                'emoji': '⭐⭐⭐'
            }
        else:
            return {
                'level': 'moderate',
                'description': 'Moderate match',
                'emoji': '⭐⭐'
            }
    
    def _generate_short_summary(self, recommendation: Dict, highlight: str) -> str:
        """Generate a one-line summary"""
        name = recommendation.get('name', 'This place')
        score = recommendation.get('final_score', 0)
        
        if score >= 0.9:
            return f"{name} - Perfect for you! {highlight}"
        elif score >= 0.8:
            return f"{name} - Excellent choice! {highlight}"
        else:
            return f"{name} - {highlight}"
    
    def _generate_detailed_narrative(self, 
                                    recommendation: Dict, 
                                    reasons: List[str],
                                    score: float) -> str:
        """Generate a detailed narrative explanation"""
        name = recommendation.get('name', 'This place')
        
        narrative = f"**Why we recommend {name}**\n\n"
        narrative += f"With a {score*100:.0f}% match, this is a "
        narrative += f"{self._interpret_score(score)['description'].lower()} for you.\n\n"
        
        narrative += "**Key reasons:**\n"
        for i, reason in enumerate(reasons[:5], 1):
            narrative += f"{i}. {reason}\n"
        
        if len(reasons) > 5:
            narrative += f"\n... and {len(reasons)-5} more reasons!"
        
        return narrative
    
    def _format_bullet_points(self, reasons: List[str]) -> List[str]:
        """Format reasons as bullet points"""
        return [f"• {reason}" for reason in reasons]
    
    def get_weather_adaptation_explanation(self,
                                          original: str,
                                          alternative: str,
                                          weather: Dict) -> str:
        """Special explanation for weather adaptations"""
        rain_prob = weather.get('rain_prob', 0)
        condition = weather.get('condition', 'bad')
        
        return (
            f"We swapped {original} for {alternative} "
            f"due to {rain_prob}% chance of {condition}. "
            f"Don't worry - we found an indoor alternative you'll love!"
        )
    
    def get_group_compromise_explanation(self,
                                        activity: str,
                                        priority_user: str,
                                        happiness_scores: Dict) -> str:
        """Special explanation for group compromises"""
        return (
            f"{priority_user} gets to choose today! "
            f"Everyone else rated this at least 3/5, "
            f"so the whole group can enjoy it together."
        )
