# quick_test.py
import asyncio
import sys
import json
import argparse
import os
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import the NEW SDK
try:
    import google.genai as genai
    from google.genai import types
    GENAI_AVAILABLE = True
except ImportError:
    print("❌ google.genai not installed. Run: pip install google-genai")
    GENAI_AVAILABLE = False
    sys.exit(1)

class RealGeminiService:
    """Real Gemini service - NO MOCK DATA"""
    
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if not self.api_key:
            print("❌ GEMINI_API_KEY not found in .env file")
            print("   Please add: GEMINI_API_KEY=your_key_here")
            self.available = False
            return
            
        try:
            self.client = genai.Client(api_key=self.api_key)
            self.available = True
            print("✅ Gemini API connected successfully!")
        except Exception as e:
            print(f"❌ Gemini connection error: {e}")
            self.available = False
    
    async def generate_places(self, destination, count=10, categories=None):
        """Generate REAL places using Gemini API"""
        
        if not self.available:
            print("❌ Gemini not available")
            return []
        
        # Build prompt based on categories
        category_text = f" focusing on these categories: {', '.join(categories)}" if categories else ""
        
        prompt = f"""Generate a list of {count} tourist attractions, restaurants, and points of interest in {destination}{category_text}.

IMPORTANT: Return ONLY a valid JSON array. No markdown, no explanations, no additional text.

Each place must have this exact structure:
{{
    "place_id": "unique_id_here",
    "name": "Place Name",
    "categories": ["category1", "category2"],
    "price_level": 2,
    "rating": 4.5,
    "description": "Brief description of the place",
    "city": "{destination}",
    "best_time_to_visit": "morning/afternoon/evening",
    "duration_hours": 2,
    "address": "Full address if available",
    "image_url": "URL to a high-quality image of this place"
}}

Category options: museum, art, historical, landmark, food, restaurant, outdoor, nature, shopping, religious, entertainment, nightlife, adventure, fort, palace, garden, temple, church, mosque, market, beach, mountain, trekking

Price level: 1 (budget), 2 (moderate), 3 (expensive), 4 (luxury)
Rating: between 3.0 and 5.0, with one decimal place

For the image_url field, include authentic-looking URLs from reputable sources like Wikimedia Commons, Pexels, or Pixabay. Make sure the URLs are accessible and appropriate.

Generate exactly {count} places. Return ONLY the JSON array."""
        
        try:
            # Call Gemini with new SDK
            response = self.client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
                config=types.GenerateContentConfig(
                    temperature=0.7,
                    max_output_tokens=4096,
                )
            )
            
            # Parse response
            places = self._parse_response(response.text, destination)
            print(f"✅ Gemini generated {len(places)} places for {destination}")
            return places
            
        except Exception as e:
            print(f"❌ Gemini API error: {e}")
            return []
    
    def _parse_response(self, text, destination):
        """Parse Gemini response"""
        # Clean the text
        text = text.strip()
        
        # Remove markdown if present
        if text.startswith("```json"):
            text = text[7:]
        if text.startswith("```"):
            text = text[3:]
        if text.endswith("```"):
            text = text[:-3]
        
        text = text.strip()
        
        try:
            places = json.loads(text)
            
            # Validate and ensure all fields exist
            validated = []
            for p in places:
                validated.append({
                    'place_id': p.get('place_id', f"{destination}_{len(validated)}"),
                    'name': p.get('name', f"Place in {destination}"),
                    'categories': p.get('categories', ['tourist_attraction']),
                    'price_level': min(4, max(1, p.get('price_level', 2))),
                    'rating': min(5.0, max(3.0, p.get('rating', 4.0))),
                    'description': p.get('description', f"Visit this place in {destination}"),
                    'city': destination,
                    'best_time_to_visit': p.get('best_time_to_visit', 'anytime'),
                    'duration_hours': p.get('duration_hours', 2),
                    'address': p.get('address', f"{destination}"),
                    'image_url': p.get('image_url', f"https://via.placeholder.com/400x300?text={p.get('name', destination).replace(' ', '+')}")  # Fallback image
                })
            return validated
            
        except json.JSONDecodeError as e:
            print(f"❌ Failed to parse Gemini response: {e}")
            return []

# Transport data for common routes
TRANSPORT_ROUTES = {
    ("Delhi", "Agra"): {
        "mode": "train",
        "emoji": "🚂",
        "duration": "2-3 hours",
        "cost": 15,
        "stops": ["Delhi → New Delhi Railway Station", "Gatimaan Express", "Agra Cantonment"],
        "distance": "230 km"
    },
    ("Mumbai", "Goa"): {
        "mode": "flight",
        "emoji": "✈️",
        "duration": "1 hour",
        "cost": 80,
        "stops": ["Mumbai Airport (BOM)", "Direct Flight", "Goa Airport (GOI)"],
        "distance": "450 km"
    },
    ("Lahore", "Hunza"): {
        "mode": "bus/car",
        "emoji": "🚌",
        "duration": "14-16 hours",
        "cost": 30,
        "stops": ["Lahore", "Islamabad", "Karakuram Highway", "Hunza Valley"],
        "distance": "800 km"
    },
    ("Paris", "Lyon"): {
        "mode": "train",
        "emoji": "🚄",
        "duration": "2 hours",
        "cost": 60,
        "stops": ["Paris Gare de Lyon", "TGV", "Lyon Part-Dieu"],
        "distance": "470 km"
    }
}

def get_transport_info(source, destination):
    """Get transport info between cities"""
    # Check direct route
    if (source, destination) in TRANSPORT_ROUTES:
        return TRANSPORT_ROUTES[(source, destination)]
    if (destination, source) in TRANSPORT_ROUTES:
        route = TRANSPORT_ROUTES[(destination, source)]
        # Reverse stops for return journey
        return {
            **route,
            "stops": route["stops"][::-1]
        }
    
    # Default for unknown routes
    return {
        "mode": "train/bus",
        "emoji": "🚂",
        "duration": "4-6 hours",
        "cost": 40,
        "stops": [source, "→", "Transfer", "→", destination],
        "distance": "300 km"
    }

async def quick_test(source, destination, budget, days, categories=None):
    print(f"\n🔍 GENERATING COMPLETE TRAVEL PLAN WITH REAL GEMINI DATA")
    print("="*80)
    
    # Display input parameters
    print("\n📋 YOUR INPUT:")
    print(f"   🏁 Source: {source}")
    print(f"   🎯 Destination: {destination}")
    print(f"   💰 Budget: ${budget}")
    print(f"   📅 Days: {days}")
    if categories:
        print(f"   🏷️ Categories: {', '.join(categories)}")
    print("="*80)
    
    # Initialize REAL Gemini service
    gemini = RealGeminiService()
    
    if not gemini.available:
        print("❌ Cannot proceed without Gemini API")
        return
    
    # STEP 1: Get transport info
    print(f"\n🚗 PLANNING JOURNEY FROM {source} TO {destination}...")
    transport = get_transport_info(source, destination)
    
    print(f"\n✅ JOURNEY PLAN:")
    print(f"   Mode: {transport['emoji']} {transport['mode']}")
    print(f"   Duration: {transport['duration']}")
    print(f"   Distance: {transport['distance']}")
    print(f"   Cost: ${transport['cost']}")
    print(f"\n   Route Stops:")
    for i, stop in enumerate(transport['stops'], 1):
        print(f"      {i}. {stop}")
    
    # Calculate remaining budget
    remaining_budget = budget - transport['cost']
    daily_budget = remaining_budget / days
    
    print(f"\n💰 Budget after travel: ${remaining_budget:.2f} (${daily_budget:.2f}/day)")
    
    # STEP 2: Generate REAL places from Gemini
    print(f"\n🤖 Calling Gemini API for {destination}...")
    places = await gemini.generate_places(
        destination=destination,
        count=days * 3,  # 3 places per day
        categories=categories
    )
    
    if not places:
        print("❌ No places generated")
        return
    
    # Display the REAL places
    print(f"\n✅ RECEIVED {len(places)} REAL PLACES FROM GEMINI:\n")
    
    for i, place in enumerate(places[:5], 1):  # Show first 5
        print(f"{i}. {place['name']}")
        print(f"   📍 Categories: {', '.join(place['categories'])}")
        print(f"   💰 Price Level: {'$' * place['price_level']} (${place['price_level'] * 15})")
        print(f"   ⭐ Rating: {place['rating']}")
        print(f"   ⏱️ Best time: {place['best_time_to_visit']}")
        print(f"   🖼️ Image: {place['image_url'][:50]}...")
        print(f"   📝 {place['description'][:100]}...")
        print()
    
    # STEP 3: Create day-by-day itinerary
    print("\n" + "="*80)
    print(f"🗓️ YOUR {days}-DAY ITINERARY IN {destination.upper()}")
    print("="*80)
    
    itinerary = []
    total_activities_cost = 0
    
    for day in range(1, days + 1):
        day_places = places[(day-1)*3 : day*3]
        if not day_places:
            break
            
        print(f"\n📅 DAY {day}")
        print("-"*60)
        
        day_activities = []
        day_cost = 0
        current_time = 9  # Start at 9 AM
        
        for idx, place in enumerate(day_places):
            place_cost = place['price_level'] * 15
            day_cost += place_cost
            end_time = current_time + place['duration_hours']
            
            activity = {
                "time": f"{current_time:02.0f}:00 - {end_time:02.0f}:00",
                "name": place['name'],
                "categories": place['categories'],
                "cost": place_cost,
                "rating": place['rating'],
                "description": place['description'],
                "address": place['address'],
                "image_url": place['image_url']
            }
            day_activities.append(activity)
            
            print(f"\n   {activity['time']} ── {place['name']}")
            print(f"        💰 ${place_cost} | ⭐ {place['rating']}")
            print(f"        📍 {', '.join(place['categories'])}")
            
            current_time = end_time + 1  # Add 1 hour break
        
        print(f"\n   Day {day} total: ${day_cost} (Budget: ${daily_budget:.2f})")
        print(f"   {'✅ Within budget' if day_cost <= daily_budget else '⚠️ Over budget by $' + str(round(day_cost - daily_budget, 2))}")
        
        itinerary.append({
            "day": day,
            "activities": day_activities,
            "total_cost": day_cost,
            "within_budget": day_cost <= daily_budget
        })
        total_activities_cost += day_cost
    
    # STEP 4: Create COMPLETE JSON response
    print("\n" + "="*80)
    print("📦 GENERATING COMPLETE JSON RESPONSE")
    print("="*80)
    
    response = {
        "trip_request": {
            "source": source,
            "destination": destination,
            "budget": budget,
            "days": days,
            "categories": categories if categories else ["all"],
            "timestamp": datetime.now().isoformat()
        },
        "journey": {
            "from": source,
            "to": destination,
            "transport": {
                "mode": transport['mode'],
                "emoji": transport['emoji'],
                "duration": transport['duration'],
                "distance": transport['distance'],
                "cost": transport['cost']
            },
            "route_stops": transport['stops'],
            "summary": f"Travel from {source} to {destination} by {transport['mode']}. Duration: {transport['duration']}. Cost: ${transport['cost']}"
        },
        "budget_breakdown": {
            "total_budget": budget,
            "transport_cost": transport['cost'],
            "remaining_for_activities": remaining_budget,
            "daily_budget": round(daily_budget, 2),
            "actual_activities_cost": round(total_activities_cost, 2),
            "remaining_buffer": round(remaining_budget - total_activities_cost, 2)
        },
        "destination_info": {
            "city": destination,
            "total_places_found": len(places),
            "places": places,
            "top_rated": sorted(places, key=lambda x: x['rating'], reverse=True)[:3]
        },
        "itinerary": itinerary,
        "metadata": {
            "generated_by": "TravelMate ML Service",
            "ai_model": "Google Gemini 2.5 Flash",
            "generated_at": datetime.now().isoformat(),
            "version": "2.0.0"
        }
    }
    
    # Save to file
    filename = f"{source}_to_{destination}_complete_plan.json"
    with open(filename, "w", encoding='utf-8') as f:
        json.dump(response, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ COMPLETE TRAVEL PLAN SAVED TO: {filename}")
    print("\n📁 JSON FILE CONTAINS:")
    print("   • Trip request parameters (source, destination, budget, days)")
    print("   • Journey details with route stops")
    print("   • Budget breakdown")
    print("   • All REAL places from Gemini with ratings, prices, and IMAGES")
    print("   • Day-by-day itinerary with timings")
    print("   • Metadata about the generation")
    
    return response

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate complete travel plan with REAL Gemini data')
    
    # Required parameters
    parser.add_argument('source', help='Starting city (e.g., Delhi)')
    parser.add_argument('destination', help='Destination city (e.g., Agra)')
    parser.add_argument('--budget', type=int, default=500, help='Total budget in USD')
    parser.add_argument('--days', type=int, default=2, help='Number of days at destination')
    parser.add_argument('--categories', type=str, help='Comma-separated categories (e.g., "historical,monument,food")')
    
    args = parser.parse_args()
    
    # Parse categories
    categories = [c.strip() for c in args.categories.split(',')] if args.categories else None
    
    # Run the test
    asyncio.run(quick_test(
        source=args.source,
        destination=args.destination,
        budget=args.budget,
        days=args.days,
        categories=categories
    ))