from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional
from datetime import date
from .. import models, schemas, auth
from ..database import get_db
from ..dependencies import get_current_user

router = APIRouter()

@router.get("/me", response_model=schemas.UserOut)
def get_me(current_user: models.User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=schemas.UserOut)
def update_me(
    update: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Обновляем стандартные поля
    if update.full_name is not None:
        current_user.full_name = update.full_name
    if update.reminder_enabled is not None:
        current_user.reminder_enabled = update.reminder_enabled
    if update.reminder_time is not None:
        current_user.reminder_time = update.reminder_time
    
    # Новые поля профиля
    if update.birth_date is not None:
        current_user.birth_date = update.birth_date
    if update.gender is not None:
        current_user.gender = update.gender
    if update.city is not None:
        current_user.city = update.city
    if update.bio is not None:
        current_user.bio = update.bio
    if update.interests is not None:
        current_user.interests = update.interests

    db.commit()
    db.refresh(current_user)
    return current_user

@router.put("/me/password")
def change_password(
    data: schemas.ChangePassword,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Проверяем старый пароль
    if not auth.verify_password(data.old_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Неверный старый пароль")
    # Хешируем новый пароль
    current_user.hashed_password = auth.get_password_hash(data.new_password)
    db.commit()
    return {"message": "Пароль изменён"}