# tests/test_vectorizer.py
import sys
import os
import numpy as np

# Add the project root to Python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.core.vectorizer import PreferenceVectorizer

def test_vectorizer():
    """Test your vectorizer"""
    
    # Initialize
    vectorizer = PreferenceVectorizer()
    print("✅ Vectorizer initialized")
    
    # Test user
    test_user = {
        'art_interest': 5,
        'foodie_score': 4,
        'adventure_seeking': 2,
        'crowd_tolerance': 3,
        'budget_conscious': 4,
        'travel_pace': 'balanced',
        'interests': ['museum', 'local_food']
    }
    
    # Get vector
    vector = vectorizer.vectorize(test_user)
    
    print(f"\n📊 Vector shape: {vector.shape}")
    print(f"First 10 values: {vector[:10].round(3)}")
    print(f"Vector norm: {np.linalg.norm(vector):.3f}")
    
    # Verify
    assert vector.shape == (50,), f"Expected 50-dim, got {vector.shape}"
    assert abs(np.linalg.norm(vector) - 1.0) < 0.1, "Should be normalized"
    
    print("\n✅ All tests passed!")
    return vector

if __name__ == "__main__":
    test_vectorizer()