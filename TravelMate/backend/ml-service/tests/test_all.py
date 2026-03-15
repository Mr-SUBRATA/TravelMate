# test_all.py
import requests
import json

BASE_URL = "http://localhost:8000"

def test_health():
    r = requests.get(f"{BASE_URL}/api/ml/health")
    print(f"Health: {r.status_code} - {r.json()}")

def test_recommend():
    url = f"{BASE_URL}/api/ml/recommend"
    data = {
        "user_id": "test123",
        "quiz_answers": {
            "art_interest": 5,
            "foodie_score": 4,
            "adventure_seeking": 2,
            "crowd_tolerance": 3,
            "budget_conscious": 3,
            "travel_pace": "balanced",
            "interests": ["museum"],
            "deal_breakers": []
        },
        "destination": "Paris",
        "weather": {"rain_prob": 0.8, "temp": 18, "condition": "rainy"},
        "top_k": 3
    }
    r = requests.post(url, json=data)
    print(f"Recommend: {r.status_code}")
    if r.status_code == 200:
        print(json.dumps(r.json(), indent=2)[:500])

if __name__ == "__main__":
    test_health()
    test_recommend()