from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, services
from ..database import get_db
from ..dependencies import get_current_user
from ..services.llm_service import generate_steps_for_goal
from ..services.goal_service import update_goal_progress

router = APIRouter()

@router.get("/", response_model=List[schemas.GoalOut])
def get_goals(archived: bool = False, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    goals = db.query(models.Goal).filter(
        models.Goal.user_id == current_user.id,
        models.Goal.is_archived == archived
    ).order_by(models.Goal.deadline.asc()).all()
    return goals

@router.post("/", response_model=schemas.GoalOut)
def create_goal(goal_data: schemas.GoalCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    new_goal = models.Goal(**goal_data.dict(), user_id=current_user.id)
    db.add(new_goal)
    db.commit()
    db.refresh(new_goal)
    return new_goal

@router.get("/{goal_id}", response_model=schemas.GoalOut)
def get_goal(goal_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    goal = db.query(models.Goal).filter(models.Goal.id == goal_id, models.Goal.user_id == current_user.id).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    return goal

@router.put("/{goal_id}", response_model=schemas.GoalOut)
def update_goal(goal_id: int, update: schemas.GoalUpdate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    goal = db.query(models.Goal).filter(models.Goal.id == goal_id, models.Goal.user_id == current_user.id).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    for key, value in update.dict(exclude_unset=True).items():
        setattr(goal, key, value)
    db.commit()
    db.refresh(goal)
    return goal

@router.delete("/{goal_id}")
def delete_goal(goal_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    goal = db.query(models.Goal).filter(models.Goal.id == goal_id, models.Goal.user_id == current_user.id).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    db.delete(goal)
    db.commit()
    return {"message": "Цель удалена"}

@router.post("/{goal_id}/generate-steps", response_model=List[schemas.StepOut])
async def generate_steps(goal_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    goal = db.query(models.Goal).filter(models.Goal.id == goal_id, models.Goal.user_id == current_user.id).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    steps_text_list = await generate_steps_for_goal(goal.title, goal.description or "")
    # Удаляем старые шаги
    db.query(models.Step).filter(models.Step.goal_id == goal_id).delete()
    new_steps = []
    for idx, text in enumerate(steps_text_list):
        step = models.Step(goal_id=goal.id, text=text, order=idx)
        db.add(step)
        new_steps.append(step)
    db.commit()
    update_goal_progress(goal_id, db)
    return new_steps

@router.post("/{goal_id}/steps", response_model=schemas.StepOut)
def create_step(
    goal_id: int,
    step: schemas.StepCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Проверяем, что цель существует и принадлежит текущему пользователю
    goal = db.query(models.Goal).filter(
        models.Goal.id == goal_id,
        models.Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Goal not found")
    
    # Определяем порядковый номер нового шага
    order = db.query(models.Step).filter(models.Step.goal_id == goal_id).count()
    
    new_step = models.Step(
        goal_id=goal_id,
        text=step.text,
        order=order,
        is_completed=False
    )
    db.add(new_step)
    db.commit()
    db.refresh(new_step)
    
    # Пересчитываем прогресс цели
    update_goal_progress(goal_id, db)
    
    return new_step

@router.post("/{goal_id}/advice", response_model=schemas.AdviceResponse)
async def get_advice(goal_id: int, request: schemas.AdviceRequest, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    goal = db.query(models.Goal).filter(models.Goal.id == goal_id, models.Goal.user_id == current_user.id).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    steps = goal.steps
    advice = await services.llm_service.get_advice_from_llm(goal.title, goal.description or "", steps, goal.progress, request.question)
    return schemas.AdviceResponse(advice=advice)