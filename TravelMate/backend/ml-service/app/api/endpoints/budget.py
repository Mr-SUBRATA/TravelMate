# app/api/endpoints/budget.py
from fastapi import APIRouter, Depends, HTTPException, Request
import time
import logging

from app.models.request_models import BudgetRequest, SpendingPriority
from app.models.response_models import BudgetResponse, BudgetAllocation
from app.config import settings

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/optimize-budget", response_model=BudgetResponse)
async def optimize_budget(
    request: Request,
    budget_req: BudgetRequest
):
    """
    Optimize budget allocation and generate Pareto frontier
    """
    start_time = time.time()
    
    try:
        # Get ML components
        vectorizer = request.app.state.vectorizer
        recommender = request.app.state.recommender
        budget_optimizer = request.app.state.budget_optimizer
        
        logger.info(f"📥 Budget optimization request for user: {budget_req.user_id}")
        
        # Vectorize user preferences
        user_vector = vectorizer.vectorize(budget_req.quiz_answers.dict())
        
        # Optimize budget
        result = budget_optimizer.optimize_budget(
            user_vector=user_vector,
            total_budget=budget_req.total_budget,
            num_days=budget_req.num_days,
            destination=budget_req.destination,
            priority=SpendingPriority(budget_req.priority.value)
        )
        
        # Format allocation
        allocation = BudgetAllocation(
            daily=result['allocation']['daily'],
            total=result['allocation']['total'],
            percentages=result['allocation']['percentages']
        )
        
        processing_time = (time.time() - start_time) * 1000
        logger.info(f"📤 Budget optimization completed in {processing_time:.2f}ms")
        
        return BudgetResponse(
            total_budget=result['total_budget'],
            daily_budget=result['daily_budget'],
            num_days=result['num_days'],
            priority=result['priority'],
            optimal_scenario=result['optimal_scenario'],
            pareto_frontier=result['pareto_frontier'],
            allocation=allocation,
            recommendations=result['recommendations'],
            savings_potential=result['savings_potential'],
            upgrade_options=result['upgrade_options']
        )
        
    except Exception as e:
        logger.error(f"❌ Error optimizing budget: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))