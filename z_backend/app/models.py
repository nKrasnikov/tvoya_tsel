#app/models.py - модели SQLAlchemy
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Enum
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from .database import Base
import enum

class UserRole(str, enum.Enum):
    USER = "user"
    ADMIN = "admin"

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100))
    telegram_chat_id = Column(String(50), unique=True, nullable=True)
    role = Column(Enum(UserRole), default=UserRole.USER)
    is_blocked = Column(Boolean, default=False)
    reminder_enabled = Column(Boolean, default=True)
    reminder_time = Column(String(5), default="09:00")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    goals = relationship("Goal", back_populates="user", cascade="all, delete-orphan")
    llm_logs = relationship("LLMLog", back_populates="user", cascade="all, delete-orphan")

class Goal(Base):
    __tablename__ = "goals"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    deadline = Column(DateTime(timezone=True), nullable=True)
    priority = Column(Integer, default=1)  # 1-низкий, 2-средний, 3-высокий
    progress = Column(Integer, default=0)
    is_archived = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="goals")
    steps = relationship("Step", back_populates="goal", cascade="all, delete-orphan")

class Step(Base):
    __tablename__ = "steps"
    
    id = Column(Integer, primary_key=True, index=True)
    goal_id = Column(Integer, ForeignKey("goals.id"), nullable=False)
    text = Column(Text, nullable=False)
    is_completed = Column(Boolean, default=False)
    order = Column(Integer, default=0)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    goal = relationship("Goal", back_populates="steps")

class LLMLog(Base):
    __tablename__ = "llm_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    request_type = Column(String(50))  # "generate_steps", "advice"
    prompt = Column(Text)
    response = Column(Text)
    duration_ms = Column(Integer)
    success = Column(Boolean)
    error_message = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="llm_logs")