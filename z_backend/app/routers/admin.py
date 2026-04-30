from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas
from ..database import get_db
from ..dependencies import get_current_admin

router = APIRouter()

@router.get("/users", response_model=List[schemas.UserAdminOut])
def get_all_users(db: Session = Depends(get_db), admin=Depends(get_current_admin)):
    users = db.query(models.User).all()
    return users

@router.post("/users/{user_id}/block")
def block_user(user_id: int, db: Session = Depends(get_db), admin=Depends(get_current_admin)):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404)
    user.is_blocked = not user.is_blocked
    db.commit()
    return {"blocked": user.is_blocked}

@router.get("/llm-logs", response_model=List[schemas.LLMLogOut])
def get_llm_logs(limit: int = 100, db: Session = Depends(get_db), admin=Depends(get_current_admin)):
    logs = db.query(models.LLMLog).order_by(models.LLMLog.created_at.desc()).limit(limit).all()
    return logs