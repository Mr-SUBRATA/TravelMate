# app/core/recommender.py
"""
Core recommendation engine for travel planning
This is YOUR intellectual property
"""

import numpy as np
import json
from typing import List, Dict, Optional
from sklearn.metrics.pairwise import cosine_similarity
import logging
from app.utils.constants import SCORING_WEIGHTS

logger = logging.getLogger(__name__)

class TravelRecommender:
    """
    Production-ready recommendation engine
    Uses hybrid scoring combining multiple factors
    """
    
    def __init__(self, destinations_path: str):
        """
        Initialize recommender with destination data
        
        Args:
            destinations_path: Path to destination vectors JSON
        """
        self.destinations = self._load_destinations(destinations_path)
        self.destination_vectors = np.array([
            d['vector'] for d in self.destinations
        ])
        
        logger.info(f"✅ Loaded {len(self.destinations)} destinations")
        
        # Scoring weights from constants
        self.weights = SCORING_WEIGHTS
    
    def _load_destinations(self, path: str) -> List[Dict]:
        """Load destination data from JSON"""
        try:
            with open(path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                logger.info(f"✅ Loaded destinations from {path}")
                return data
        except FileNotFoundError:
            logger.warning(f"⚠️ Destinations file not found: {path}")
            logger.info("📝 Creating sample destinations for development")
            return self._create_sample_destinations()
        except json.JSONDecodeError:
            logger.error(f"❌ Invalid JSON in {path}")
            return self._create_sample_destinations()
    
    def _create_sample_destinations(self) -> List[Dict]:
        """Create sample destinations for development"""
        return [
            {
                'id': 'louvre',
                'name': 'Louvre Museum',
                'vector': [0.9, 0.8, 0.7, 0.2, 0.3, 0.1, 0.2, 0.3, 0.4, 0.5] + [0.1]*40,
                'categories': ['art', 'history', 'museum'],
                'cost': 17,
                'outdoor': False,
                'city': 'Paris',
                'rating': 4.8,
                'popularity': 0.95,
                'review_count': 287543,
                'best_time': 'morning',
                'hidden_gem': False
            },
            {
                'id': 'eiffel',
                'name': 'Eiffel Tower',
                'vector': [0.3, 0.2, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1] + [0.1]*40,
                'categories': ['landmark', 'views', 'outdoor'],
                'cost': 25,
                'outdoor': True,
                'city': 'Paris',
                'rating': 4.7,
                'popularity': 0.98,
                'review_count': 412876,
                'best_time': 'evening',
                'hidden_gem': False
            },
            {
                'id': 'orsay',
                'name': 'Musée d\'Orsay',
                'vector': [0.8, 0.7, 0.6, 0.3, 0.2, 0.2, 0.3, 0.4, 0.5, 0.3] + [0.1]*40,
                'categories': ['art', 'museum', 'impressionist'],
                'cost': 16,
                'outdoor': False,
                'city': 'Paris',
                'rating': 4.6,
                'popularity': 0.85,
                'review_count': 198765,
                'best_time': 'afternoon',
                'hidden_gem': False
            },
            {
                'id': 'notre_dame',
                'name': 'Notre-Dame Cathedral',
                'vector': [0.4, 0.3, 0.7, 0.5, 0.4, 0.3, 0.6, 0.5, 0.2, 0.1] + [0.1]*40,
                'categories': ['history', 'architecture', 'religious'],
                'cost': 0,
                'outdoor': False,
                'city': 'Paris',
                'rating': 4.8,
                'popularity': 0.92,
                'review_count': 156432,
                'best_time': 'morning',
                'hidden_gem': False
            },
            {
                'id': 'montmartre',
                'name': 'Montmartre',
                'vector': [0.5, 0.4, 0.6, 0.6, 0.5, 0.7, 0.4, 0.3, 0.2, 0.1] + [0.1]*40,
                'categories': ['neighborhood', 'art', 'views', 'outdoor'],
                'cost': 0,
                'outdoor': True,
                'city': 'Paris',
                'rating': 4.7,
                'popularity': 0.88,
                'review_count': 245678,
                'best_time': 'evening',
                'hidden_gem': False
            },
            {
                'id': 'sainte_chapelle',
                'name': 'Sainte-Chapelle',
                'vector': [0.7, 0.6, 0.5, 0.8, 0.4, 0.3, 0.6, 0.5, 0.4, 0.3] + [0.1]*40,
                'categories': ['history', 'architecture', 'religious', 'art'],
                'cost': 11.5,
                'outdoor': False,
                'city': 'Paris',
                'rating': 4.7,
                'popularity': 0.78,
                'review_count': 87654,
                'best_time': 'morning',
                'hidden_gem': True
            }
        ]
    
    def recommend(self,
                  user_vector: np.ndarray,
                  weather_data: Optional[Dict] = None,
                  crowd_data: Optional[Dict] = None,
                  budget_data: Optional[Dict] = None,
                  top_k: int = 5) -> List[Dict]:
        """
        Generate personalized recommendations
        
        Args:
            user_vector: 50-dim user preference vector
            weather_data: Optional weather info
            crowd_data: Optional crowd info
            budget_data: Optional budget info
            top_k: Number of recommendations
            
        Returns:
            List of recommended destinations with scores
        """
        recommendations = []
        
        for idx, dest in enumerate(self.destinations):
            # Base similarity score
            similarity = cosine_similarity(
                user_vector.reshape(1, -1),
                self.destination_vectors[idx].reshape(1, -1)
            )[0][0]
            
            # Calculate component scores
            scores = {
                'similarity': similarity,
                'weather': self._calculate_weather_score(dest, weather_data),
                'crowd': self._calculate_crowd_score(dest, crowd_data),
                'budget': self._calculate_budget_score(dest, budget_data),
                'time': self._calculate_time_score(dest),
                'popularity': self._calculate_popularity_score(dest)
            }
            
            # Weighted final score
            final_score = sum(
                scores[k] * self.weights.get(k, 0.1) 
                for k in scores.keys()
            )
            
            # Ensure score is between 0 and 1
            final_score = min(1.0, max(0.0, final_score))
            
            recommendations.append({
                'id': dest['id'],
                'name': dest['name'],
                'categories': dest['categories'],
                'cost': dest['cost'],
                'outdoor': dest.get('outdoor', False),
                'city': dest.get('city', 'Paris'),
                'rating': dest.get('rating', 0),
                'review_count': dest.get('review_count', 0),
                'popularity': dest.get('popularity', 0),
                'best_time': dest.get('best_time', 'flexible'),
                'hidden_gem': dest.get('hidden_gem', False),
                'scores': scores,
                'final_score': float(final_score)
            })
        
        # Sort by final score (highest first)
        recommendations.sort(key=lambda x: x['final_score'], reverse=True)
        
        logger.info(f"📊 Generated {len(recommendations)} recommendations")
        
        return recommendations[:top_k]
    
    def _calculate_weather_score(self, 
                                 destination: Dict, 
                                 weather: Optional[Dict]) -> float:
        """Calculate weather suitability score (0-1)"""
        if not weather:
            return 0.8  # Default if no weather data
        
        rain_prob = weather.get('rain_prob', 0)
        temp = weather.get('temp', 20)
        
        if destination.get('outdoor', False):
            # Outdoor activities: penalize rain and extreme temps
            if rain_prob > 0.6:
                return 0.3
            elif rain_prob > 0.3:
                return 0.6
            else:
                return 0.9
        else:
            # Indoor activities: bonus for bad weather
            if rain_prob > 0.6:
                return 1.0
            elif rain_prob > 0.3:
                return 0.9
            else:
                return 0.7
    
    def _calculate_crowd_score(self,
                               destination: Dict,
                               crowd: Optional[Dict]) -> float:
        """Calculate crowd avoidance score (0-1)"""
        if not crowd:
            return 0.7  # Default
        
        crowd_density = crowd.get('density', 0.5)
        
        # Lower score for crowded places
        return max(0.3, 1.0 - crowd_density)
    
    def _calculate_budget_score(self,
                                destination: Dict,
                                budget: Optional[Dict]) -> float:
        """Calculate budget fit score (0-1)"""
        if not budget:
            return 0.8  # Default
        
        dest_cost = destination.get('cost', 50)
        daily_budget = budget.get('daily', 100)
        
        ratio = dest_cost / daily_budget
        
        if ratio <= 0.5:
            return 1.0  # Well under budget
        elif ratio <= 1.0:
            return 0.8  # Within budget
        elif ratio <= 1.5:
            return 0.5  # Over budget
        else:
            return 0.2  # Way over budget
    
    def _calculate_time_score(self, destination: Dict) -> float:
        """Calculate time suitability score (0-1)"""
        # Default implementation - can be enhanced later
        return 0.8
    
    def _calculate_popularity_score(self, destination: Dict) -> float:
        """Calculate popularity/reputation score (0-1)"""
        rating = destination.get('rating', 4.0)
        # Normalize rating (assuming 0-5 scale)
        return min(1.0, rating / 5.0)
    
    # ============================================
    # NEW METHODS ADDED FOR EXPLANATIONS
    # ============================================
    
    def get_recommendation_by_id(self, dest_id: str) -> Optional[Dict]:
        """
        Get a specific destination by ID
        Used by explanation endpoint to fetch details
        """
        for dest in self.destinations:
            if dest['id'] == dest_id:
                return dest
        return None
    
    def get_similar_destinations(self, dest_id: str, top_k: int = 3) -> List[Dict]:
        """
        Find similar destinations to a given one
        Used to suggest alternatives in explanations
        """
        source_dest = self.get_recommendation_by_id(dest_id)
        if not source_dest:
            return []
        
        # Find index of source destination
        source_idx = None
        for i, dest in enumerate(self.destinations):
            if dest['id'] == dest_id:
                source_idx = i
                break
        
        if source_idx is None:
            return []
        
        source_vector = self.destination_vectors[source_idx].reshape(1, -1)
        
        similarities = []
        for idx, dest in enumerate(self.destinations):
            if idx == source_idx:
                continue
            
            similarity = cosine_similarity(
                source_vector,
                self.destination_vectors[idx].reshape(1, -1)
            )[0][0]
            
            similarities.append({
                'destination': dest,
                'similarity': float(similarity)
            })
        
        # Sort by similarity (highest first)
        similarities.sort(key=lambda x: x['similarity'], reverse=True)
        
        return [s['destination'] for s in similarities[:top_k]]
    
    def get_destinations_by_category(self, category: str) -> List[Dict]:
        """
        Get all destinations in a specific category
        Useful for filtering
        """
        return [
            dest for dest in self.destinations
            if category in dest.get('categories', [])
        ]
    
    def get_top_rated_destinations(self, min_rating: float = 4.5, top_k: int = 10) -> List[Dict]:
        """
        Get top rated destinations
        """
        rated = [d for d in self.destinations if d.get('rating', 0) >= min_rating]
        rated.sort(key=lambda x: x.get('rating', 0), reverse=True)
        return rated[:top_k]
    
    def get_hidden_gems(self, top_k: int = 5) -> List[Dict]:
        """
        Get hidden gem destinations (less touristy but highly rated)
        """
        gems = [d for d in self.destinations if d.get('hidden_gem', False)]
        gems.sort(key=lambda x: x.get('rating', 0), reverse=True)
        return gems[:top_k]
    
    def search_destinations(self, query: str) -> List[Dict]:
        """
        Simple search by name or category
        """
        query = query.lower()
        results = []
        
        for dest in self.destinations:
            if query in dest['name'].lower():
                results.append(dest)
            elif any(query in cat.lower() for cat in dest.get('categories', [])):
                results.append(dest)
        
        return results
    
    def get_destination_stats(self) -> Dict:
        """
        Get statistics about the destination database
        """
        categories = set()
        for dest in self.destinations:
            for cat in dest.get('categories', []):
                categories.add(cat)
        
        return {
            'total_destinations': len(self.destinations),
            'unique_categories': list(categories),
            'avg_rating': np.mean([d.get('rating', 0) for d in self.destinations]),
            'price_range': {
                'min': min(d.get('cost', 0) for d in self.destinations),
                'max': max(d.get('cost', 0) for d in self.destinations),
                'avg': np.mean([d.get('cost', 0) for d in self.destinations])
            }
        }
    
    # ============================================
    # NEW METHODS FOR LIVE DATA (ADD THESE!)
    # ============================================
    
    async def recommend_from_live_data(self,
                                 user_vector: np.ndarray,
                                 places: List[Dict],
                                 weather_data: Optional[Dict] = None,
                                 top_k: int = 5) -> List[Dict]:
        """
        Handle NEW unknown places from backend
        This works for ANY places - India, Pakistan, anywhere!
        """
        recommendations = []
        
        for place in places:  # ← Loop through whatever backend sent
            # Convert place categories to vector on-the-fly
            place_vector = self._categories_to_vector(place.get('categories', []))
            
            # Calculate similarity with user
            similarity = cosine_similarity(
                user_vector.reshape(1, -1),
                place_vector.reshape(1, -1)
            )[0][0]
            
            # Weather adaptation
            weather_score = 0.8
            if weather_data:
                is_outdoor = 'outdoor' in place.get('categories', [])
                if is_outdoor and weather_data.get('rain_prob', 0) > 0.6:
                    similarity *= 0.3
                    weather_score = 0.3
            
            # Estimate cost from price_level
            price_level = place.get('price_level', 1)
            cost = price_level * 15
            
            recommendations.append({
                'id': place.get('place_id', f"place_{len(recommendations)}"),
                'name': place.get('name', 'Unknown'),
                'categories': place.get('categories', []),
                'cost': cost,
                'outdoor': 'outdoor' in place.get('categories', []),
                'city': place.get('city', 'Unknown'),
                'final_score': float(similarity),
                'scores': {
                    'similarity': float(similarity),
                    'weather': weather_score,
                    'crowd': 0.7,
                    'budget': 0.8,
                    'time': 0.8,
                    'popularity': place.get('rating', 4.0) / 5.0
                }
            })
        
        # Sort by score and return top_k
        recommendations.sort(key=lambda x: x['final_score'], reverse=True)
        return recommendations[:top_k]
    
    def _categories_to_vector(self, categories: List[str]) -> np.ndarray:
        """Convert ANY categories to a vector"""
        vector = np.zeros(50)
        
        category_map = {
            'art': (0, 10), 'museum': (0, 10), 'gallery': (0, 10),
            'food': (10, 20), 'restaurant': (10, 20), 'cafe': (10, 20),
            'biryani': (10, 20), 'street_food': (10, 20),
            'outdoor': (20, 30), 'park': (20, 30), 'nature': (20, 30),
            'beach': (20, 30), 'mountain': (20, 30),
            'history': (30, 40), 'historical': (30, 40), 'monument': (30, 40),
            'fort': (30, 40), 'palace': (30, 40), 'unesco': (30, 40),
            'spiritual': (40, 45), 'religious': (40, 45), 'temple': (40, 45),
            'mosque': (40, 45), 'church': (40, 45),
            'shopping': (45, 48), 'market': (45, 48),
            'adventure': (48, 50), 'trekking': (48, 50), 'hiking': (48, 50)
        }
        
        for cat in categories:
            cat_lower = cat.lower()
            for key, (start, end) in category_map.items():
                if key in cat_lower:
                    vector[start:end] += 0.5
        
        # Normalize
        norm = np.linalg.norm(vector)
        if norm > 0:
            vector = vector / norm
        return vector