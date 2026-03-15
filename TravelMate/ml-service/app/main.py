# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from contextlib import asynccontextmanager
import logging
import time
from app.api.endpoints import gemini_generate

from app.config import settings
from app.api.endpoints import (
    recommend, explain, adapt,
    group, budget, health,
    route, risk, transport
)
from app.core.vectorizer import PreferenceVectorizer
from app.core.recommender import TravelRecommender
from app.core.weather_adapter import WeatherAdapter
from app.core.group_harmony import GroupHarmonyOptimizer
from app.core.budget_optimizer import BudgetOptimizer
from app.core.explanations import ExplanationGenerator

# Configure logging
logging.basicConfig(
    level=logging.INFO if not settings.DEBUG else logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    logger.info(f"🚀 Starting {settings.PROJECT_NAME} v{settings.VERSION}")
    logger.info(f"📊 Environment: {settings.ENVIRONMENT}")
    
    # Initialize ML models
    logger.info("📦 Loading ML models...")
    app.state.vectorizer = PreferenceVectorizer()
    app.state.recommender = TravelRecommender(settings.DESTINATION_VECTORS_PATH)
    app.state.explanation_generator = ExplanationGenerator()
    app.state.weather_adapter = WeatherAdapter(app.state.recommender)
    app.state.group_optimizer = GroupHarmonyOptimizer(
        app.state.recommender, 
        app.state.vectorizer
    )
    app.state.budget_optimizer = BudgetOptimizer(app.state.recommender)
    
    logger.info("✅ All ML models loaded successfully")
    
    yield
    
    # Cleanup
    logger.info("👋 Shutting down...")

# Create FastAPI app
# Show API docs in development so all endpoints are visible in Swagger UI
_show_docs = settings.DEBUG or settings.ENVIRONMENT == "development"
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Intelligent travel recommendation engine",
    docs_url="/api/docs" if _show_docs else None,
    redoc_url="/api/redoc" if _show_docs else None,
    lifespan=lifespan
)

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)

# Request logging middleware
@app.middleware("http")
async def log_requests(request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    logger.info(f"{request.method} {request.url.path} - {duration:.3f}s - {response.status_code}")
    return response

# Include routers
API_PREFIX = settings.API_PREFIX
app.include_router(recommend.router, prefix=API_PREFIX, tags=["Recommendations"])
app.include_router(explain.router, prefix=API_PREFIX, tags=["Explanations"])
app.include_router(adapt.router, prefix=API_PREFIX, tags=["Weather Adaptation"])
app.include_router(group.router, prefix=API_PREFIX, tags=["Group Harmony"])
app.include_router(budget.router, prefix=API_PREFIX, tags=["Budget Optimization"])
app.include_router(health.router, prefix=API_PREFIX, tags=["Health"])
app.include_router(route.router, prefix=API_PREFIX, tags=["Route Planning"])
app.include_router(risk.router, prefix=API_PREFIX, tags=["Risk Assessment"])
app.include_router(transport.router, prefix=API_PREFIX, tags=["Transport Options"])
app.include_router(gemini_generate.router, prefix="/api/ml", tags=["Place Generation"])

@app.get("/")
async def root():
    return {
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
        "status": "operational",
        "endpoints": {
            "recommend": f"{API_PREFIX}/recommend",
            "explain": f"{API_PREFIX}/explain",
            "adapt": f"{API_PREFIX}/adapt-weather",
            "group": f"{API_PREFIX}/group-harmony",
            "budget": f"{API_PREFIX}/optimize-budget",
            "health": f"{API_PREFIX}/health",
            "route": f"{API_PREFIX}/route",
            "risk": f"{API_PREFIX}/assess-risk",
            "transport": f"{API_PREFIX}/transport",
            "docs": "/api/docs",
            "redoc": "/api/redoc"
        }
    }