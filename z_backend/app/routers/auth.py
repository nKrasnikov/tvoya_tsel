#app/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .. import models, schemas, auth
from ..database import get_db

router = APIRouter()

@router.post("/register", response_model=schemas.UserOut)
def register(user_data: schemas.UserCreate, db: Session = Depends(get_db)):
    existing = db.query(models.User).filter(models.User.email == user_data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email уже зарегистрирован")
    hashed = auth.get_password_hash(user_data.password)
    new_user = models.User(
        email=user_data.email,
        hashed_password=hashed,
        full_name=user_data.full_name,
        role=models.UserRole.USER
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.post("/login", response_model=schemas.Token)
def login(user_data: schemas.UserLogin, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == user_data.email).first()
    if not user or not auth.verify_password(user_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Неверный email или пароль")
    if user.is_blocked:
        raise HTTPException(status_code=403, detail="Пользователь заблокирован")
    access_token = auth.create_access_token(data={"sub": str(user.id), "role": user.role})
    refresh_token = auth.create_refresh_token(data={"sub": str(user.id)})
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role,
            "is_blocked": user.is_blocked,
            "telegram_chat_id": user.telegram_chat_id,
        }
}

@router.post("/refresh", response_model=schemas.Token)
def refresh(refresh_token: str, db: Session = Depends(get_db)):
    payload = auth.verify_token(refresh_token)
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Недействительный refresh токен")
    user = db.query(models.User).filter(models.User.id == int(user_id)).first()
    if not user or user.is_blocked:
        raise HTTPException(status_code=403, detail="Пользователь недоступен")
    access_token = auth.create_access_token(data={"sub": str(user.id), "role": user.role})
    new_refresh = auth.create_refresh_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "refresh_token": new_refresh, "token_type": "bearer"}