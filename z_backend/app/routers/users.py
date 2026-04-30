from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas, auth
from ..database import get_db
from ..dependencies import get_current_user

router = APIRouter()

@router.get("/me", response_model=schemas.UserOut)
def get_me(current_user: models.User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=schemas.UserOut)
def update_me(update: schemas.UserUpdate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if update.full_name is not None:
        current_user.full_name = update.full_name
    if update.reminder_enabled is not None:
        current_user.reminder_enabled = update.reminder_enabled
    if update.reminder_time is not None:
        current_user.reminder_time = update.reminder_time
    db.commit()
    db.refresh(current_user)
    return current_user

@router.put("/me/password")
def change_password(pwd_data: schemas.ChangePassword, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if not auth.verify_password(pwd_data.old_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Неверный старый пароль")
    current_user.hashed_password = auth.get_password_hash(pwd_data.new_password)
    db.commit()
    return {"message": "Пароль изменён"}