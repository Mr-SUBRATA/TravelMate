# app/config.py
from pydantic_settings import BaseSettings
from pydantic import Field
from typing import List

class Settings(BaseSettings):
    """Application settings"""
    
    # App settings
    PROJECT_NAME: str = "TravelAI ML Service"
    VERSION: str = "1.0.0"
    ENVIRONMENT: str = Field("development", env="ENVIRONMENT")
    DEBUG: bool = Field(False, env="DEBUG")
    
    # API settings
    API_PREFIX: str = "/api/ml"
    
    # CORS
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:5000"]
    
    # Paths
    DESTINATION_VECTORS_PATH: str = "app/data/destination_vectors.json"
    CATEGORY_WEIGHTS_PATH: str = "app/data/category_weights.json"
    PORT: int = Field(8000, env="PORT")
    
    class Config:
        env_file = ".env"
        case_sensitive = True
        

settings = Settings()