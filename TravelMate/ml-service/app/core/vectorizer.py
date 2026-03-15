# ml-service/core/vectorizer.py
"""
Convert user quiz answers to ML vectors
This is YOUR intellectual property
"""

import numpy as np
from typing import Dict, List, Tuple
import json
from app.utils.constants import CATEGORY_WEIGHTS, DIMENSION_MAP, DEFAULT_VALUES

class PreferenceVectorizer:
    """
    Converts user preferences into 50-dimensional vectors
    Each dimension represents a specific aspect of travel preference
    """
    
    def __init__(self, weights_path: str = None):
        """
        Initialize vectorizer with category weights
        
        Args:
            weights_path: Optional path to custom weights JSON
        """
        if weights_path:
            with open(weights_path, 'r') as f:
                self.category_weights = json.load(f)
        else:
            self.category_weights = CATEGORY_WEIGHTS
        
        self.dimension_map = DIMENSION_MAP
        self.vector_size = 50
        
    def vectorize(self, quiz_answers: Dict) -> np.ndarray:
        """
        Convert quiz answers to 50-dim vector
        
        Args:
            quiz_answers: Dict containing user responses
                {
                    'art_interest': 5,  # 1-5 scale
                    'foodie_score': 4,
                    'adventure_seeking': 2,
                    'crowd_tolerance': 3,
                    'budget_conscious': 4,
                    'travel_pace': 'balanced',  # relaxed, balanced, intense
                    'preferred_atmosphere': 'cultural',
                    'interests': ['museums', 'local_food']
                }
        
        Returns:
            50-dim numpy array normalized to unit vector
        """
        vector = np.zeros(self.vector_size)
        
        # Fill dimensions based on answers
        vector = self._add_art_component(vector, quiz_answers)
        vector = self._add_food_component(vector, quiz_answers)
        vector = self._add_adventure_component(vector, quiz_answers)
        vector = self._add_relaxation_component(vector, quiz_answers)
        vector = self._add_history_component(vector, quiz_answers)
        vector = self._add_shopping_component(vector, quiz_answers)
        vector = self._add_personality_traits(vector, quiz_answers)
        
        # Normalize to unit vector
        norm = np.linalg.norm(vector)
        if norm > 0:
            vector = vector / norm
        
        return vector
    
    def _add_art_component(self, vector: np.ndarray, answers: Dict) -> np.ndarray:
        """Add art interest to vector"""
        art_interest = answers.get('art_interest', DEFAULT_VALUES['art_interest'])
        start, end = self.dimension_map['art']
        
        # Scale 1-5 to 0-1 range
        art_weight = (art_interest - 1) / 4
        
        # Distribute across art dimensions
        for i in range(start, end):
            vector[i] = art_weight * np.random.uniform(0.8, 1.0)
        
        # Specific art interests
        specific_interests = answers.get('interests', [])
        if 'museum' in specific_interests:
            vector[start:start+3] += 0.3
        if 'gallery' in specific_interests:
            vector[start+3:start+6] += 0.3
        
        return vector
    
    def _add_food_component(self, vector: np.ndarray, answers: Dict) -> np.ndarray:
        """Add food interest to vector"""
        foodie_score = answers.get('foodie_score', DEFAULT_VALUES['foodie_score'])
        start, end = self.dimension_map['food']
        
        food_weight = (foodie_score - 1) / 4
        
        for i in range(start, end):
            vector[i] = food_weight * np.random.uniform(0.7, 1.0)
        
        # Food preferences
        specific_interests = answers.get('interests', [])
        if 'street_food' in specific_interests:
            vector[start:start+5] += 0.4
        if 'fine_dining' in specific_interests:
            vector[start+5:start+10] += 0.4
        
        return vector
    
    def _add_adventure_component(self, vector: np.ndarray, answers: Dict) -> np.ndarray:
        """Add adventure seeking to vector"""
        adventure = answers.get('adventure_seeking', DEFAULT_VALUES['adventure_seeking'])
        start, end = self.dimension_map['adventure']
        
        adventure_weight = (adventure - 1) / 4
        vector[start:end] = adventure_weight
        
        return vector
    
    def _add_relaxation_component(self, vector: np.ndarray, answers: Dict) -> np.ndarray:
        """Add relaxation preference (inverse of adventure)"""
        adventure = answers.get('adventure_seeking', DEFAULT_VALUES['adventure_seeking'])
        start, end = self.dimension_map['relaxation']
        
        # Relaxation is inverse of adventure
        relaxation_weight = 1 - ((adventure - 1) / 4)
        vector[start:end] = relaxation_weight
        
        return vector
    
    def _add_history_component(self, vector: np.ndarray, answers: Dict) -> np.ndarray:
        """Add history/culture interest"""
        start, end = self.dimension_map['history']
        
        specific_interests = answers.get('interests', [])
        history_weight = 0.5  # Default
        
        if 'history' in specific_interests:
            history_weight = 0.9
        if 'archaeology' in specific_interests:
            history_weight = 0.8
        if 'cultural' in str(answers.get('preferred_atmosphere', '')):
            history_weight += 0.2
        
        vector[start:end] = min(history_weight, 1.0)
        
        return vector
    
    def _add_shopping_component(self, vector: np.ndarray, answers: Dict) -> np.ndarray:
        """Add shopping preference"""
        start, end = self.dimension_map['shopping']
        
        specific_interests = answers.get('interests', [])
        shopping_weight = 0.3  # Default
        
        if 'shopping' in specific_interests:
            shopping_weight = 0.8
        if 'luxury' in specific_interests:
            shopping_weight = 0.7
        if 'markets' in specific_interests:
            shopping_weight = 0.6
        
        vector[start:end] = shopping_weight
        
        return vector
    
    def _add_personality_traits(self, vector: np.ndarray, answers: Dict) -> np.ndarray:
        """Add personality traits to specific dimensions"""
        
        # Crowd tolerance (dimension 45)
        crowd_tolerance = answers.get('crowd_tolerance', DEFAULT_VALUES['crowd_tolerance'])
        vector[45] = (crowd_tolerance - 1) / 4
        
        # Budget sensitivity (dimension 46)
        budget_conscious = answers.get('budget_conscious', DEFAULT_VALUES['budget_conscious'])
        vector[46] = (budget_conscious - 1) / 4
        
        # Pace preference (dimension 47)
        pace = answers.get('travel_pace', DEFAULT_VALUES['travel_pace'])
        pace_map = {'relaxed': 0.3, 'balanced': 0.6, 'intense': 0.9}
        vector[47] = pace_map.get(pace, 0.6)
        
        # Social preference (dimension 48)
        group_size = answers.get('group_size', DEFAULT_VALUES['group_size'])
        vector[48] = min(group_size / 10, 1.0)  # Normalize to 0-1
        
        # Weather sensitivity (dimension 49)
        # Default: moderate sensitivity
        vector[49] = 0.6
        
        return vector
    
    def batch_vectorize(self, users: List[Dict]) -> np.ndarray:
        """Vectorize multiple users at once"""
        return np.array([self.vectorize(user) for user in users])
    
    def get_similarity(self, vector1: np.ndarray, vector2: np.ndarray) -> float:
        """Calculate cosine similarity between two vectors"""
        dot_product = np.dot(vector1, vector2)
        norm_product = np.linalg.norm(vector1) * np.linalg.norm(vector2)
        
        if norm_product == 0:
            return 0
        
        return float(dot_product / norm_product)