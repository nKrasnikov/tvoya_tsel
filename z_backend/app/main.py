from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import auth, users, goals, steps, admin
from .database import engine, Base
import logging
logging.basicConfig(level=logging.INFO)

# Создаём таблицы (только для разработки, потом перейти на миграции)
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Твоя цель API", version="1.0")

# Разрешённые источники для CORS
origins = [
    "http://localhost:65146",   # фронтенд на Flutter
    "http://localhost:8000",   # сам бэкенд
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(users.router, prefix="/api/v1/users", tags=["users"])
app.include_router(goals.router, prefix="/api/v1/goals", tags=["goals"])
app.include_router(steps.router, prefix="/api/v1/steps", tags=["steps"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["admin"])

@app.get("/")
def root():
    return {"message": "Твоя цель API работает"}

@app.get("/health")
def health():
    return {"status": "ok"}