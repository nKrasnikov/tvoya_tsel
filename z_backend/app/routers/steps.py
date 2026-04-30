from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas
from ..database import get_db
from ..dependencies import get_current_user
from ..services.goal_service import update_goal_progress

router = APIRouter()

@router.patch("/{step_id}", response_model=schemas.StepOut)
def update_step(step_id: int, update: dict, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    step = db.query(models.Step).filter(models.Step.id == step_id).first()
    if not step:
        raise HTTPException(status_code=404, detail="Шаг не найден")
    goal = db.query(models.Goal).filter(models.Goal.id == step.goal_id, models.Goal.user_id == current_user.id).first()
    if not goal:
        raise HTTPException(status_code=403, detail="Нет доступа")
    if "is_completed" in update:
        step.is_completed = update["is_completed"]
        step.completed_at = db.func.now() if update["is_completed"] else None
    if "text" in update:
        step.text = update["text"]
    db.commit()
    db.refresh(step)
    update_goal_progress(goal.id, db)
    return step

@router.delete("/{step_id}")
def delete_step(step_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    step = db.query(models.Step).filter(models.Step.id == step_id).first()
    if not step:
        raise HTTPException(status_code=404)
    goal = db.query(models.Goal).filter(models.Goal.id == step.goal_id, models.Goal.user_id == current_user.id).first()
    if not goal:
        raise HTTPException(status_code=403)
    db.delete(step)
    db.commit()
    update_goal_progress(goal.id, db)
    return {"message": "Шаг удалён"}