<div align="center">

# ✈️ TravelMate AI

**AI-powered travel planning for the modern explorer**

*Generate personalised day-by-day itineraries, budget breakdowns, and curated place recommendations — all from a single form, powered by Google Gemini 2.5 Flash.*

---

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104-009688?style=flat-square&logo=fastapi)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat-square&logo=python)
![Gemini](https://img.shields.io/badge/Gemini-2.5_Flash-4285F4?style=flat-square&logo=google)
![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?style=flat-square&logo=firebase)
![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?style=flat-square&logo=mongodb)

</div>

---

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Tech Stack](#tech-stack)
- [Database Schema](#database-schema)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Firebase Setup](#0-firebase-setup)
  - [MongoDB Atlas Setup](#1-mongodb-atlas-setup)
  - [Flutter App Setup](#2-flutter-app-setup)
  - [ML Service Setup](#3-ml-service-setup)
  - [Running Locally](#4-running-locally)
- [Environment Variables](#environment-variables)
- [Authentication Flow](#authentication-flow)
- [API Reference](#api-reference)
  - [Auth Endpoints](#auth-endpoints)
  - [Primary ML Endpoint](#primary-ml-endpoint--post-apimlplan)
  - [Supporting ML Endpoints](#supporting-ml-endpoints)
- [Application Features](#application-features)
- [ML Engine](#ml-engine)
- [Design System](#design-system)
- [Known Issues](#known-issues)
- [Roadmap](#roadmap)
- [Testing](#testing)
- [Deployment](#deployment)

---

## Overview

TravelMate AI is a cross-platform mobile application (iOS & Android) that turns a simple trip description into a fully detailed travel plan. The user signs in with Firebase Auth, specifies a source city, destination, budget, duration, and travel style. The app orchestrates a Python FastAPI ML backend — which calls Google Gemini 2.5 Flash to discover places, builds a day-by-day schedule, calculates cost breakdowns, and persists everything to MongoDB Atlas — all rendered in a polished, dark-mode-ready Flutter UI.

**What makes it different:**
- Plans are not templated — every itinerary is generated fresh by Gemini against the user's specific inputs
- Firebase Auth handles identity; MongoDB Atlas stores all user data, preferences, trips, and feedback
- A custom cosine-similarity recommendation engine matches destinations to user preference vectors built from an onboarding quiz
- Budget optimisation, weather adaptation, group harmony blending, and risk classification all run as separate ML modules at inference time

---

## System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      Flutter App (Client)                    │
│                                                              │
│  SplashPage → Firebase Auth → Onboarding Quiz                │
│       ↓                                                      │
│  BottomNavBar                                                │
│  ├── HomePage          (discovery feed)                      │
│  ├── PlannerPage  ────────────────────────────────────────┐  │
│  │     ↓ animated loading overlay                         │  │
│  │   TripResultPage  (Itinerary / Places / Budget)        │  │
│  │     ↓ Save button  ──────────────────────────────┐    │  │
│  ├── BookmarkPage  ←─────────────────────────────────┘    │  │
│  └── ProfilePage                                          │  │
│                                                           │  │
│  ApiService (Dio singleton + Firebase ID token injection) │  │
└───────────────────────────────────────────────────────────┘  │
           │                          ▲                         │
           │ HTTP + Bearer token      │ JSON response           │
           ▼                          │                         │
┌──────────────────────────────────────────────────────────┐   │
│              FastAPI ML Service (Python)                 │   │
│                                                          │   │
│  Middleware                                              │   │
│  ├── Firebase token verification (every request)        │   │
│  ├── CORS + GZip                                        │   │
│  └── Request logging                                    │   │
│                                                          │   │
│  Routers (/api/*)                                        │   │
│  ├── /api/user/sync      → MongoDB users collection      │   │
│  ├── /api/preferences/*  → MongoDB preferences          │   │
│  ├── /api/trips/*        → MongoDB trips collection      │   │
│  ├── /api/feedback/*     → MongoDB feedback collection   │   │
│  └── /api/ml/*                                           │   │
│        ├── /plan  →  quick_test.py pipeline              │   │
│        │     ├─ GeminiPlaceService  (Gemini 2.5 Flash)   │   │
│        │     ├─ TravelRecommender   (cosine similarity)  │   │
│        │     ├─ BudgetOptimizer     (allocation engine)  │   │
│        │     ├─ TransportRouter     (multi-modal)        │   │
│        │     ├─ WeatherAdapter      (forecast)           │   │
│        │     ├─ GroupHarmonyOptimizer                    │   │
│        │     └─ RiskClassifier                           │   │
│        └── /recommend, /explain, /adapt-weather, …       │   │
│                                                          │   │
└──────────────────────────────────────────────────────────┘   │
           │                                                    │
           │  read / write                                      │
           ▼                                                    │
┌──────────────────────────────────────────────────────────┐   │
│                  MongoDB Atlas                           │   │
│                                                          │   │
│  Database: travelmate                                    │   │
│  ├── users          { uid, name, email, createdAt }      │   │
│  ├── preferences    { uid, quizAnswers, travelPace, … }  │   │
│  ├── trips          { uid, destination, itinerary, … }   │   │
│  └── feedback       { uid, tripId, rating, comment }     │   │
└──────────────────────────────────────────────────────────┘   │
                                                               │
┌──────────────────────────────────────────────────────────┐   │
│                  Firebase Auth                           │───┘
│  Email/Password · Google Sign-In · Anonymous            │
│  Issues Firebase ID tokens → verified by ML service     │
└──────────────────────────────────────────────────────────┘
```

**Data flow summary:**
1. User signs in via Firebase Auth (email/password or Google) — Flutter receives a Firebase ID token
2. Every API request from Flutter sends `Authorization: Bearer <firebase_id_token>` in the header
3. FastAPI middleware verifies the token against Firebase, extracts `uid`, rejects invalid tokens with `401`
4. `POST /api/user/sync` is called once after login — creates or updates the user document in MongoDB
5. Onboarding quiz results are saved to MongoDB via `POST /api/preferences/save`
6. User fills the planner form, taps **Generate My Itinerary** — `POST /api/ml/plan` fires
7. ML service generates the itinerary via Gemini, returns structured JSON to Flutter
8. Flutter renders the result; user taps **Save** — `POST /api/trips/save` persists to MongoDB
9. `BookmarkPage` calls `GET /api/trips/mytrips` — retrieves this user's trips from MongoDB

---

## Tech Stack

### Flutter App

| Package | Version | Purpose |
|---|---|---|
| `flutter` | ≥ 3.16 | UI framework |
| `dio` | latest | HTTP client — API calls, Firebase token injection |
| `firebase_core` | latest | Firebase SDK initialisation |
| `firebase_auth` | latest | Firebase Authentication — sign-in, token retrieval |
| `google_sign_in` | latest | Google OAuth sign-in flow |
| `shared_preferences` | latest | Local cache — offline trip fallback |

### Python ML Service

| Package | Version | Purpose |
|---|---|---|
| `fastapi` | 0.104.1 | REST API framework |
| `uvicorn[standard]` | 0.24.0 | ASGI server |
| `pydantic` | 2.5.0 | Request / response schema validation |
| `pydantic-settings` | 2.1.0 | Environment variable management |
| `python-dotenv` | 1.0.0 | `.env` file loading |
| `motor` | 3.3.2 | Async MongoDB driver (Motor = async PyMongo) |
| `pymongo` | 4.6.1 | MongoDB sync driver (used for migrations/scripts) |
| `firebase-admin` | 6.2.0 | Firebase token verification on the server |
| `google-genai` | ≥ 1.0.0 | Gemini 2.5 Flash SDK (primary) |
| `google-generativeai` | ≥ 0.3.0 | Gemini legacy SDK (fallback) |
| `scikit-learn` | 1.3.2 | Cosine similarity for recommendation engine |
| `numpy` | 1.24.3 | Numerical operations on preference vectors |
| `pandas` | 2.1.3 | Data manipulation |
| `scipy` | 1.11.4 | Scientific computing utilities |
| `joblib` | 1.3.2 | Model serialisation / parallel processing |
| `httpx` | 0.25.1 | Async HTTP for weather / external API calls |
| `loguru` | 0.7.2 | Structured logging |
| `pytest` + `pytest-asyncio` | 7.4.3 | Test suite |

---

## Database Schema

All collections live in the `travelmate` database on MongoDB Atlas.

### `users`
Created/updated by `POST /api/user/sync` after every login.

```json
{
  "_id": ObjectId,
  "uid": "firebase_uid_string",
  "name": "Abhradip Seth",
  "email": "user@example.com",
  "photoUrl": "https://...",
  "createdAt": ISODate,
  "updatedAt": ISODate
}
```

### `preferences`
One document per user. Replaced on every onboarding re-run.

```json
{
  "_id": ObjectId,
  "uid": "firebase_uid_string",
  "quizAnswers": ["adventure", "trekking", "mountain"],
  "travelPace": "Balanced",
  "crowdTolerance": "medium",
  "budgetRange": { "min": 5000, "max": 50000 },
  "groupSizePreference": "2",
  "dealBreakers": ["crowds", "extreme heat"],
  "updatedAt": ISODate
}
```

### `trips`
One document per saved itinerary. Full `planData` JSON stored as a sub-document.

```json
{
  "_id": ObjectId,
  "uid": "firebase_uid_string",
  "destinationCity": "Himachal Pradesh",
  "destinationCountry": "India",
  "startDate": ISODate,
  "endDate": ISODate,
  "groupSize": 2,
  "totalBudget": 45000,
  "status": "upcoming",
  "planData": { "...full itinerary JSON from /api/ml/plan..." },
  "createdAt": ISODate
}
```

### `feedback`
Ratings and comments submitted after a trip.

```json
{
  "_id": ObjectId,
  "uid": "firebase_uid_string",
  "tripId": "ObjectId reference to trips",
  "rating": 4,
  "comment": "Great itinerary, Solang Valley was perfect",
  "createdAt": ISODate
}
```

**Indexes:**
```js
db.users.createIndex({ "uid": 1 }, { unique: true })
db.preferences.createIndex({ "uid": 1 }, { unique: true })
db.trips.createIndex({ "uid": 1, "createdAt": -1 })
db.feedback.createIndex({ "uid": 1, "tripId": 1 })
```

---

## Project Structure

```
travelmate-ai/
│
├── README.md
│
├── lib/                                    # Flutter application source
│   ├── main.dart                           # App entry — Firebase init, theme, orientation lock
│   ├── firebase_options.dart               # Auto-generated Firebase platform config
│   ├── bottomNavBar.dart                   # Persistent bottom navigation (4 tabs)
│   │
│   ├── theme/
│   │   └── app_theme.dart                  # TravelMateColors, TravelMateTheme (light/dark),
│   │                                       # TravelMateGradients, BuildContext extensions
│   │
│   ├── services/
│   │   └── Api_services.dart               # ApiConfig (base URLs), ApiService (Dio singleton,
│   │                                       # Firebase ID token injection), ApiResult<T> wrapper
│   │
│   └── features/
│       ├── splashPage.dart                 # Animated splash — checks Firebase auth state
│       │
│       ├── auth/
│       │   ├── welcome_page.dart           # Landing — Sign in with Google / Email buttons
│       │   ├── login_page.dart             # Firebase email/password sign-in
│       │   ├── signup_page.dart            # Firebase account creation
│       │   └── authentication_page.dart    # StreamBuilder on FirebaseAuth.authStateChanges()
│       │                                   # → calls /api/user/sync, routes to onboarding/home
│       │
│       ├── onboarding/
│       │   └── onboardingPage.dart         # Travel DNA quiz → POST /api/preferences/save
│       │
│       ├── home/
│       │   └── homepage.dart               # Discovery feed, destination cards
│       │
│       ├── planning/
│       │   ├── plannerPage.dart            # Trip form + _LoadingOverlay widget
│       │   │                               # Calls POST /api/ml/plan → navigates to result
│       │   └── tripResultPage.dart         # Three-tab result view:
│       │                                   #   Itinerary — collapsible day cards with timeline
│       │                                   #   Places    — hero strip + 2-col grid
│       │                                   #   Budget    — segmented bar + stat cards
│       │                                   # Save button → POST /api/trips/save (MongoDB)
│       │
│       ├── bookmark/
│       │   └── bookmarkPage.dart           # GET /api/trips/mytrips from MongoDB
│       │                                   # Tab filters: All / Upcoming / Past / Draft
│       │                                   # Swipe-to-delete → DELETE /api/trips/:id
│       │                                   # Tap card → TripResultPage with full planData
│       │
│       └── user/
│           └── profilePage.dart            # Firebase user info, sign-out, theme toggle
│
└── ml-service/                             # Python FastAPI ML + backend API
    ├── .env                                # Local secrets — NOT committed
    ├── .env.example                        # Template — copy to .env and fill values
    ├── requirements.txt                    # Python dependencies
    ├── quick_test.py                       # Standalone Gemini plan generation pipeline
    ├── serviceAccountKey.json              # Firebase Admin SDK key — NOT committed
    │
    └── app/
        ├── main.py                         # FastAPI factory — middleware, lifespan, routers
        ├── config.py                       # Pydantic Settings — reads from .env
        │
        ├── db/
        │   ├── __init__.py
        │   ├── mongodb.py                  # Motor async client, database/collection getters
        │   └── indexes.py                  # Index creation run on startup
        │
        ├── auth/
        │   ├── __init__.py
        │   └── firebase_auth.py            # Firebase Admin SDK init, verify_token() dependency
        │                                   # Raises HTTP 401 on invalid/expired tokens
        │
        ├── api/
        │   └── endpoints/
        │       ├── user.py                 # POST /api/user/sync
        │       ├── preferences.py          # POST /api/preferences/save
        │       │                           # GET  /api/preferences
        │       ├── trips.py                # POST /api/trips/save
        │       │                           # GET  /api/trips/mytrips
        │       │                           # DELETE /api/trips/:id
        │       ├── feedback.py             # POST /api/feedback/save
        │       │                           # GET  /api/feedback
        │       ├── plan.py                 # POST /api/ml/plan
        │       ├── recommend.py            # POST /api/ml/recommend
        │       ├── explain.py              # POST /api/ml/explain
        │       ├── adapt.py                # POST /api/ml/adapt-weather
        │       ├── group.py                # POST /api/ml/group-harmony
        │       ├── budget.py               # POST /api/ml/optimize-budget
        │       ├── route.py                # POST /api/ml/route
        │       ├── risk.py                 # POST /api/ml/assess-risk
        │       ├── transport.py            # POST /api/ml/transport
        │       ├── gemini_generate.py      # POST /api/ml/generate-places
        │       └── health.py               # GET  /api/ml/health
        │
        ├── core/                           # ML engine — original intellectual property
        │   ├── recommender.py              # Hybrid cosine-similarity destination recommender
        │   ├── vectorizer.py               # User quiz → 50-dimensional preference vector
        │   ├── budget_optimizer.py         # Budget allocation across trip components
        │   ├── weather_adapter.py          # Weather-aware itinerary adjustments
        │   ├── group_harmony.py            # Multi-traveller preference blending
        │   ├── risk_classifier.py          # Destination safety / risk scoring
        │   ├── transport_router.py         # Multi-modal journey planning
        │   ├── transport_costs.py          # Per-mode cost estimation
        │   └── explanations.py             # Human-readable recommendation explanations
        │
        ├── services/
        │   ├── gemini_place_service.py     # Gemini API wrapper — place generation
        │   ├── places_service.py           # Place data helpers
        │   ├── weather_service.py          # OpenWeatherMap integration
        │   └── cache_service.py            # In-memory TTL response cache
        │
        ├── models/
        │   ├── request_models.py           # Pydantic schemas for all incoming requests
        │   └── response_models.py          # Pydantic schemas for all outgoing responses
        │
        ├── data/
        │   ├── destination_vectors.json    # Pre-computed 50-dim destination embeddings
        │   └── category_weights.json       # Scoring weights per interest category
        │
        ├── utils/
        │   ├── constants.py                # SCORING_WEIGHTS, DIMENSION_MAP, DEFAULT_VALUES
        │   └── helpers.py                  # Shared utility functions
        │
        └── tests/
            ├── test_recommender.py
            ├── test_vectorizer.py
            ├── test_budget_optimizer.py
            ├── test_group_harmony.py
            ├── test_weather_adapter.py
            ├── test_explanations.py
            ├── test_adapt.py
            └── test_all.py
```

---

## Getting Started

### Prerequisites

| Tool | Minimum version | Check |
|---|---|---|
| Flutter SDK | 3.16 | `flutter --version` |
| Dart | 3.2 | Bundled with Flutter |
| Python | 3.11 | `python --version` |
| Xcode | 15 | iOS builds — macOS only |
| Android Studio | Hedgehog | Android builds |
| Git | any | `git --version` |

External services required:

| Service | Purpose | Free tier |
|---|---|---|
| [Firebase Console](https://console.firebase.google.com) | Authentication | Yes |
| [MongoDB Atlas](https://cloud.mongodb.com) | Database | Yes (512 MB) |
| [Google AI Studio](https://aistudio.google.com) | Gemini API key | Yes |

---

### 0. Firebase Setup

1. Go to the [Firebase Console](https://console.firebase.google.com) and create a new project named `travelmate-ai`
2. Enable **Authentication** → Sign-in methods → enable **Email/Password** and **Google**
3. Register your iOS and Android apps under **Project Settings → Your apps**
4. Download `google-services.json` → place in `android/app/`
5. Download `GoogleService-Info.plist` → place in `ios/Runner/`
6. Run `flutterfire configure` to regenerate `lib/firebase_options.dart`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=your-firebase-project-id
```

7. **Generate the Admin SDK key** for the backend:
   - Firebase Console → Project Settings → **Service accounts**
   - Click **Generate new private key** → save as `ml-service/serviceAccountKey.json`
   - This file is listed in `.gitignore` — never commit it

---

### 1. MongoDB Atlas Setup

1. Create a free cluster at [cloud.mongodb.com](https://cloud.mongodb.com)
2. Create a database user: **Database Access → Add new database user**
   - Username: `travelmate_user`
   - Password: generate a strong password
   - Role: `readWrite` on database `travelmate`
3. Whitelist your IP: **Network Access → Add IP Address**
   - For development: add your current IP or `0.0.0.0/0` (restrict this in production)
4. Get the connection string: **Clusters → Connect → Connect your application**
   - Copy the string — it looks like:
   ```
   mongodb+srv://travelmate_user:<password>@cluster0.xxxxx.mongodb.net/travelmate?retryWrites=true&w=majority
   ```
5. Paste it into `MONGO_URI` in your `.env` file (see [Environment Variables](#environment-variables))

The application creates all indexes automatically on startup via `app/db/indexes.py`.

---

### 2. Flutter App Setup

```bash
# Clone the repository
git clone https://github.com/your-username/travelmate-ai.git
cd travelmate-ai

# Install Flutter dependencies
flutter pub get

# Verify setup — all checks should pass
flutter doctor
```

**Update `pubspec.yaml`** to include Firebase Auth packages:

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  google_sign_in: ^6.2.1
  shared_preferences: ^2.2.2
```

**Configure the ML service URL** in `lib/services/Api_services.dart`:

```dart
class ApiConfig {
  // Simulator on the same Mac — localhost works
  static const String baseUrl   = 'http://127.0.0.1:7000';
  static const String mlBaseUrl = 'http://127.0.0.1:7000/api/ml';

  // ⚠️ Physical device: use your Mac's LAN IP instead
  // Find it: ifconfig | grep "inet " | grep -v 127   (macOS/Linux)
  //          ipconfig                                  (Windows)
}
```

> Physical devices cannot reach `127.0.0.1`. Both your machine and device must be on the same Wi-Fi. Use `--host 0.0.0.0` when starting uvicorn.

**Update `ApiService`** to inject Firebase ID tokens:

```dart
Future<Options> _authOpts() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Options();
  final token = await user.getIdToken();   // auto-refreshes when expired
  return Options(headers: {'Authorization': 'Bearer $token'});
}
```

---

### 3. ML Service Setup

```bash
cd ml-service

# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate        # macOS / Linux
.venv\Scripts\activate           # Windows PowerShell

# Install all dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.example .env
# Fill in GEMINI_API_KEY, MONGO_URI, and PORT at minimum
```

**Create `app/db/mongodb.py`:**

```python
from motor.motor_asyncio import AsyncIOMotorClient
from app.config import settings

_client: AsyncIOMotorClient | None = None

def get_client() -> AsyncIOMotorClient:
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(settings.MONGO_URI)
    return _client

def get_db():
    return get_client()[settings.MONGO_DB_NAME]

def get_collection(name: str):
    return get_db()[name]
```

**Create `app/auth/firebase_auth.py`:**

```python
import firebase_admin
from firebase_admin import credentials, auth
from fastapi import HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

# Initialise Firebase Admin SDK once
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

security = HTTPBearer()

async def verify_token(
    credentials: HTTPAuthorizationCredentials = Security(security)
) -> dict:
    """FastAPI dependency — verifies Firebase ID token, returns decoded claims."""
    try:
        decoded = auth.verify_id_token(credentials.credentials)
        return decoded
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
```

**Register all routers in `app/main.py`:**

```python
from app.api.endpoints import (
    user, preferences, trips, feedback,
    plan, recommend, explain, adapt,
    group, budget, health, route, risk,
    transport, gemini_generate
)

# Data endpoints
app.include_router(user.router,        prefix="/api",    tags=["User"])
app.include_router(preferences.router, prefix="/api",    tags=["Preferences"])
app.include_router(trips.router,       prefix="/api",    tags=["Trips"])
app.include_router(feedback.router,    prefix="/api",    tags=["Feedback"])

# ML endpoints
app.include_router(plan.router,        prefix="/api/ml", tags=["Plan"])
app.include_router(recommend.router,   prefix="/api/ml", tags=["Recommendations"])
# ... etc
```

---

### 4. Running Locally

**Terminal 1 — ML service:**

```bash
cd ml-service
source .venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 7000 --reload
```

Verify health:
```bash
curl http://localhost:7000/api/ml/health
# {"status":"healthy","version":"1.0.0","environment":"development",...}
```

Interactive docs: `http://localhost:7000/api/docs`

**Terminal 2 — Flutter app:**

```bash
flutter run
```

---

## Environment Variables

All secrets live in `ml-service/.env`. Never commit this file or `serviceAccountKey.json`.

```env
# ── Required ──────────────────────────────────────────────────────────────────
GEMINI_API_KEY=AIza...              # Google Gemini 2.5 Flash
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/travelmate?retryWrites=true&w=majority
MONGO_DB_NAME=travelmate            # Database name inside the cluster

# ── Service configuration ─────────────────────────────────────────────────────
PORT=7000
ENVIRONMENT=development             # development | staging | production
DEBUG=true                          # Enables /api/docs, DEBUG logging
API_PREFIX=/api/ml                  # ML endpoint prefix
VERSION=1.0.0

# ── Firebase Admin (path to service account JSON) ────────────────────────────
FIREBASE_CREDENTIALS_PATH=serviceAccountKey.json

# ── CORS ──────────────────────────────────────────────────────────────────────
# Use "*" in development; replace with explicit origins in production
ALLOWED_ORIGINS=*

# ── Optional — image enrichment ───────────────────────────────────────────────
PEXELS_API_KEY=
PIXABAY_API_KEY=
UNSPLASH_ACCESS_KEY=

# ── Optional — weather adaptation ────────────────────────────────────────────
WEATHER_API_KEY=                    # OpenWeatherMap API key
```

> `serviceAccountKey.json` must exist at the path specified by `FIREBASE_CREDENTIALS_PATH`. Generate it from Firebase Console → Project Settings → Service accounts → Generate new private key.

---

## Authentication Flow

TravelMate uses **Firebase Authentication** exclusively for identity. The FastAPI backend never stores passwords — it only verifies Firebase-issued tokens.

```
Flutter                        Firebase Auth              FastAPI + MongoDB
  │                                 │                           │
  │── signInWithEmailAndPassword ──▶│                           │
  │◀─ UserCredential + ID token ────│                           │
  │                                 │                           │
  │── POST /api/user/sync ──────────────────────────────────────▶│
  │   Header: Authorization: Bearer <id_token>                  │
  │                                 │   verify_token(token) ───▶│ Firebase
  │                                 │◀─ decoded { uid, email } ─│
  │                                 │                           │
  │                                 │   upsert users collection │
  │◀─ { user: {...} } ──────────────────────────────────────────│
  │                                 │                           │
  │   (every subsequent request)    │                           │
  │── GET /api/trips/mytrips ───────────────────────────────────▶│
  │   Header: Authorization: Bearer <id_token>                  │
  │                                 │   Token auto-refreshes    │
  │                                 │   via getIdToken()        │
  │◀─ [ trip, trip, … ] ────────────────────────────────────────│
```

**Key points:**
- Flutter calls `FirebaseAuth.instance.currentUser.getIdToken()` before every API request — Firebase SDK refreshes the token automatically when it's within 5 minutes of expiry (tokens last 1 hour)
- The FastAPI `verify_token` dependency is injected into every protected route — unauthenticated requests receive `HTTP 401` immediately
- The MongoDB `uid` field on every document equals the Firebase `uid` — no separate user ID system
- Sign-out calls `FirebaseAuth.instance.signOut()` on the Flutter side; no server-side session to invalidate

---

## API Reference

All endpoints require `Authorization: Bearer <firebase_id_token>` unless marked as public.

### Auth Endpoints

#### `POST /api/user/sync`
Called once after every successful Firebase sign-in. Creates the user document if it doesn't exist, or updates `name`, `email`, `photoUrl`, and `updatedAt`.

```json
// Request body
{ "name": "Abhradip Seth", "email": "user@example.com" }

// Response
{ "success": true, "user": { "uid": "...", "name": "...", "email": "...", "createdAt": "..." } }
```

#### `POST /api/preferences/save`
Saves onboarding quiz results. Upserts — safe to call multiple times.

```json
// Request body
{
  "quizAnswers": ["adventure", "mountain", "trekking"],
  "travelPace": "Balanced",
  "crowdTolerance": "medium",
  "budgetRange": { "min": 5000, "max": 50000 },
  "groupSizePreference": "2",
  "dealBreakers": ["crowds"]
}
```

#### `GET /api/preferences`
Returns the authenticated user's saved preferences.

#### `POST /api/trips/save`
Persists a generated itinerary to MongoDB.

```json
// Request body
{
  "destinationCity": "Himachal Pradesh",
  "destinationCountry": "India",
  "startDate": "2025-06-10",
  "endDate": "2025-06-17",
  "groupSize": 2,
  "totalBudget": 45000,
  "planData": { "...full response from /api/ml/plan..." }
}
```

#### `GET /api/trips/mytrips`
Returns all trips belonging to the authenticated user, sorted by `createdAt` descending.

#### `DELETE /api/trips/:id`
Deletes a trip by MongoDB `_id`. Returns `403` if the trip belongs to a different user.

#### `POST /api/feedback/save`
Submits a rating and comment for a completed trip.

---

### Primary ML Endpoint — `POST /api/ml/plan`

The main itinerary generation endpoint. Called by `plannerPage.dart` on every trip request.

**Request:**

```json
{
  "source": "Kolkata",
  "destination": "Himachal Pradesh",
  "budget": 45000,
  "days": 7,
  "month": "June",
  "members": 2,
  "preferences": "vegetarian food, moderate fitness",
  "categories": ["adventure", "trekking", "mountain"]
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `source` | string | ✅ | Departure city |
| `destination` | string | ✅ | Target city or region |
| `budget` | integer | ✅ | Total budget in INR |
| `days` | integer | ✅ | Trip duration in days |
| `month` | string | ❌ | Travel month (affects weather logic) |
| `members` | integer | ❌ | Group size, default 1 |
| `preferences` | string | ❌ | Free-text special requests |
| `categories` | string[] | ❌ | Interest tags mapped from travel style |

**Response:**

```json
{
  "trip_request": {
    "source": "Kolkata",
    "destination": "Himachal Pradesh",
    "budget": 45000,
    "days": 7,
    "categories": ["adventure", "trekking", "mountain"],
    "timestamp": "2025-03-15T09:00:00"
  },
  "journey": {
    "from": "Kolkata",
    "to": "Manali",
    "transport": {
      "mode": "Flight + Volvo Bus",
      "emoji": "✈️",
      "duration": "13–15 hours",
      "distance": "1,980 km",
      "cost": 7200
    },
    "route_stops": ["Kolkata (CCU)", "Delhi (DEL)", "Manali Bus Stand"],
    "summary": "Fly Kolkata → Delhi, then overnight Volvo bus to Manali."
  },
  "budget_breakdown": {
    "total_budget": 45000,
    "transport_cost": 7200,
    "remaining_for_activities": 37800,
    "daily_budget": 5400.0,
    "actual_activities_cost": 41800,
    "remaining_buffer": 3200.0
  },
  "destination_info": {
    "city": "Himachal Pradesh",
    "total_places_found": 21,
    "places": [
      {
        "place_id": "hp_01",
        "name": "Rohtang Pass",
        "categories": ["mountain", "adventure"],
        "price_level": 2,
        "rating": 4.9,
        "description": "High-altitude pass at 3,978m with glaciers.",
        "duration_hours": 4,
        "image_url": "https://..."
      }
    ],
    "top_rated": [ "...same shape, top 3 by rating..." ]
  },
  "itinerary": [
    {
      "day": 1,
      "activities": [
        {
          "time": "06:00 – 08:00",
          "name": "Arrival at Manali",
          "categories": ["travel"],
          "cost": 0,
          "rating": 0.0,
          "description": "Check into hotel in Old Manali.",
          "image_url": ""
        }
      ],
      "total_cost": 1250,
      "within_budget": true
    }
  ],
  "metadata": {
    "generated_by": "TravelMate ML Service",
    "ai_model": "Google Gemini 2.5 Flash",
    "generated_at": "2025-03-15T09:00:00",
    "version": "2.0.0"
  }
}
```

### Supporting ML Endpoints

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/ml/health` | Service health — public, no auth required |
| `POST` | `/api/ml/recommend` | Top-K destination recommendations from preference vectors |
| `POST` | `/api/ml/explain` | Human-readable explanation of a recommendation |
| `POST` | `/api/ml/adapt-weather` | Re-rank activities based on weather forecast |
| `POST` | `/api/ml/group-harmony` | Blend preference vectors for multi-traveller groups |
| `POST` | `/api/ml/optimize-budget` | Reallocate budget across trip components |
| `POST` | `/api/ml/route` | Optimal routing between destinations |
| `POST` | `/api/ml/assess-risk` | Safety and risk scoring for a destination |
| `POST` | `/api/ml/transport` | Transport options and cost estimates |
| `POST` | `/api/ml/generate-places` | On-demand Gemini place generation |

---

## Application Features

- **Splash screen** — brand gradient animation; checks `FirebaseAuth.authStateChanges()` to skip login if already signed in
- **Firebase Auth** — email/password and Google Sign-In; tokens auto-refresh every hour
- **User sync** — `POST /api/user/sync` called on every login to upsert the MongoDB user document
- **Onboarding quiz** — Travel DNA questionnaire; results saved to MongoDB via `POST /api/preferences/save`
- **Planner form** — Autocomplete source/destination, month picker, duration + budget sliders, group size counter, 8 travel style presets, free-text requests
- **Loading animation** — Full-screen gradient overlay with pulsing Gemini icon, 5-step fade-cycling status labels, live progress bar 0→100%
- **Itinerary tab** — Collapsible day cards, timeline with coloured activity dots, cost badges, per-category colour chips
- **Places tab** — Horizontal hero strip for top-3 rated places, 2-column grid with initials fallback for missing images
- **Budget tab** — 3-segment stacked bar, emoji line items, 2×2 stat cards
- **Save to MongoDB** — `POST /api/trips/save` persists full `planData`; button animates to "Saved!"; deduplicates by destination
- **Bookmark page** — `GET /api/trips/mytrips` loads user's trips from MongoDB; tab filters (All / Upcoming / Past / Draft); swipe-to-delete calls `DELETE /api/trips/:id`; tap reopens full plan
- **Sign-out** — `FirebaseAuth.instance.signOut()` clears local state, routes to welcome screen

---

## ML Engine

The ML service loads six specialised modules into `app.state` at startup via the FastAPI lifespan context:

**Preference vectoriser** (`core/vectorizer.py`) — Converts quiz answers into a 50-dimensional numerical vector capturing art interest, foodie score, adventure seeking, crowd tolerance, budget consciousness, travel pace, and more.

**Destination recommender** (`core/recommender.py`) — Calculates cosine similarity between the user vector and pre-computed destination embeddings in `destination_vectors.json`. A hybrid scoring layer adds weights for budget fit, seasonal relevance, and category overlap.

**Budget optimiser** (`core/budget_optimizer.py`) — Allocates a total budget across transport, accommodation, food, activities, and miscellaneous. Applies destination-specific cost baselines, adjusts for group size and duration.

**Weather adapter** (`core/weather_adapter.py`) — Fetches forecast for the destination and dates. Deprioritises outdoor activities during predicted rain; boosts indoor cultural activities.

**Group harmony optimiser** (`core/group_harmony.py`) — For multi-traveller groups, finds the vector-space point that minimises aggregate distance from all individual preference vectors — the group compromise destination.

**Risk classifier** (`core/risk_classifier.py`) — Scores a destination across safety, political stability, health infrastructure, and natural disaster frequency. Returns a composite score and per-dimension breakdown.

---

## Design System

All tokens are defined in `lib/theme/app_theme.dart` and consumed via `BuildContext` extensions.

### Colour palette

| Token | Light | Dark | Usage |
|---|---|---|---|
| `teal` | `#00B89C` | — | Primary brand, buttons, accents |
| `tealDark` | `#00897B` | — | Gradient end, pressed states |
| `amber` | `#FFA726` | — | Secondary CTA, cost highlights |
| `error` | `#EF5350` | — | Over-budget, delete actions |
| `lBackground` | `#F0FAF8` | `#040C0B` | Scaffold background |
| `lCard` | `#FFFFFF` | `#143530` | Card surfaces |
| `lText` | `#1A3C38` | `#E8F5F3` | Primary text |
| `lTextSub` | `#4A7B74` | `#7DBFB8` | Secondary / muted text |
| `lBorder` | `#B2DFDB` | `#1E4D47` | Card and divider borders |

### Context extensions

```dart
context.wBg        // scaffold background (auto light/dark)
context.wCard      // card surface
context.wText      // primary text colour
context.wTextSub   // secondary text colour
context.wBorder    // border colour
context.wDivider   // divider colour
context.isDark     // bool — current brightness
```

### Gradients

```dart
TravelMateGradients.brand    // top-left → bottom-right: gradStart → gradEnd
TravelMateGradients.brandV   // top → bottom: gradStart → gradEnd
```

---

## Known Issues

Demo mode is fully functional. These issues affect the live backend integration.

### Blocks real-device + backend testing

| # | Issue | Location | Fix |
|---|---|---|---|
| 1 | ML service URL hardcoded to `127.0.0.1` — unreachable on physical devices | `lib/services/Api_services.dart` | Change to LAN IP; start uvicorn with `--host 0.0.0.0` |
| 2 | Port mismatch — `.env` sets `PORT=7000`, Flutter points to `8000` | `.env` + `Api_services.dart` | Align both to the same port |
| 3 | `plan.py` router not registered in `main.py` | `ml-service/app/main.py` | Add `from app.api.endpoints import plan` and `app.include_router(...)` |
| 4 | Firebase token injection not wired — `_authOpts()` uses stored `clerk_token` | `lib/services/Api_services.dart` | Replace with `FirebaseAuth.instance.currentUser.getIdToken()` |
| 5 | `user/sync` endpoint never called after Firebase login | `lib/features/auth/authentication_page.dart` | Call `ApiService.instance.syncUser()` in `authStateChanges` listener |

### Non-critical

| # | Issue | Notes |
|---|---|---|
| 6 | `quick_test.py` imported via `sys.path` hack | Move into `app/services/` |
| 7 | `quick_test()` returns `None` on Gemini failure | Add null guard → `HTTPException(503)` |
| 8 | Image URLs from Gemini often 404 | Integrate Unsplash / Pexels API |
| 9 | `BookmarkPage` still reads from `SharedPreferences` demo data | Wire to `GET /api/trips/mytrips` |
| 10 | No MongoDB connection error handling on startup | Wrap Motor client init in try/catch, fail fast with clear message |

---

## Roadmap

**Phase 1 — Auth + database wiring (next sprint)**
- [ ] Wire Firebase ID token injection into `ApiService._authOpts()`
- [ ] Call `syncUser()` in `authStateChanges` listener after login
- [ ] Implement `app/db/mongodb.py` and `app/auth/firebase_auth.py`
- [ ] Implement `user.py`, `preferences.py`, `trips.py`, `feedback.py` endpoints
- [ ] Wire `BookmarkPage` to `GET /api/trips/mytrips` instead of `SharedPreferences`
- [ ] Wire Save button to `POST /api/trips/save` instead of `SharedPreferences`

**Phase 2 — ML service connection**
- [ ] Register `plan.py` in `main.py`, remove demo bypass in `plannerPage.dart`
- [ ] Fix port/URL config — move to `--dart-define` or `flutter_dotenv`
- [ ] Add `plan.py` null guard — return `HTTP 503` on Gemini failure

**Phase 3 — Data quality**
- [ ] Replace Gemini-fabricated image URLs with Unsplash API
- [ ] Seed `destination_vectors.json` with 200+ destinations
- [ ] Add proper CORS origin whitelist per environment

**Phase 4 — User experience**
- [ ] Offline mode — cache trips in `SharedPreferences` as fallback
- [ ] Share trip — export as PDF or shareable deep link
- [ ] Push notifications — day-before reminders via Firebase Cloud Messaging
- [ ] Map view — Google Maps integration for route visualisation

**Phase 5 — Production infrastructure**
- [ ] Containerise ML service with Docker
- [ ] Deploy to Railway / Render / GCP Cloud Run
- [ ] GitHub Actions CI — `flutter analyze` + `pytest` on every PR
- [ ] Add Sentry for error tracking on both Flutter and Python

---

## Testing

### Flutter

```bash
# Static analysis — zero warnings policy
flutter analyze

# Unit tests
flutter test

# Run on device
flutter run -d "iPhone 17"
```

### Python ML Service

```bash
cd ml-service
source .venv/bin/activate

# Full test suite
pytest tests/ -v

# Specific module
pytest tests/test_recommender.py -v

# With coverage
pytest tests/ --cov=app --cov-report=term-missing
```

| File | Coverage |
|---|---|
| `test_recommender.py` | Cosine similarity scoring, top-K selection |
| `test_vectorizer.py` | Quiz → vector conversion |
| `test_budget_optimizer.py` | Budget allocation accuracy |
| `test_group_harmony.py` | Multi-traveller blending |
| `test_weather_adapter.py` | Activity re-ranking |
| `test_explanations.py` | Explanation generation |
| `test_adapt.py` | Weather adaptation endpoint |
| `test_all.py` | Full integration suite |

---

## Deployment

### ML Service (Docker)

```dockerfile
# Dockerfile — place in ml-service/
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# serviceAccountKey.json must be injected at runtime via secret mount
EXPOSE 7000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "7000"]
```

```bash
# Build
docker build -t travelmate-ml .

# Run — inject secrets at runtime, never bake them into the image
docker run -p 7000:7000 \
  --env-file .env \
  -v $(pwd)/serviceAccountKey.json:/app/serviceAccountKey.json:ro \
  travelmate-ml
```

> In production (Railway / Render / Cloud Run), inject `serviceAccountKey.json` contents as a secret environment variable and write it to a temp file at startup, rather than mounting a file.

**Recommended platforms:**
- [Railway](https://railway.app) — simplest setup, free tier available
- [Render](https://render.com) — supports Docker, free tier
- [GCP Cloud Run](https://cloud.run) — serverless, scales to zero, native Firebase integration

### Flutter App

```bash
# iOS
flutter build ipa

# Android
flutter build appbundle --release    # preferred for Play Store
flutter build apk --release          # direct APK
```

---

## Acknowledgements

- **Google Gemini 2.5 Flash** — LLM backbone for place generation and itinerary writing
- **Firebase Authentication** — identity layer, token issuance and verification
- **MongoDB Atlas** — managed document database for all user and trip data
- **Motor** — async Python driver making MongoDB play nicely with FastAPI
- **FastAPI** — clean async Python API framework
- **Flutter** — cross-platform UI toolkit

---

<div align="center">

*Built with Flutter · FastAPI · Firebase Auth · MongoDB Atlas · Google Gemini 2.5 Flash*

</div>
