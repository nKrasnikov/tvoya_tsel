from pydantic import BaseModel, EmailStr
from datetime import datetime, date
from typing import Optional, List

# Auth
class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class UserOut(BaseModel):
    id: int
    email: str
    full_name: str
    role: str
    is_blocked: bool
    telegram_chat_id: Optional[str] = None
    reminder_enabled: bool
    reminder_time: str
    birth_date: Optional[date] = None
    gender: Optional[str] = None
    city: Optional[str] = None
    bio: Optional[str] = None
    interests: Optional[str] = None

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    reminder_enabled: Optional[bool] = None
    reminder_time: Optional[str] = None
    birth_date: Optional[date] = None
    gender: Optional[str] = None
    city: Optional[str] = None
    bio: Optional[str] = None
    interests: Optional[str] = None

class ChangePassword(BaseModel):
    old_password: str
    new_password: str

# Goals
class StepBase(BaseModel):
    text: str

class StepCreate(BaseModel):
    text: str

class StepOut(StepBase):
    id: int
    goal_id: int
    is_completed: bool
    order: int
    completed_at: Optional[datetime] = None
    created_at: datetime

    class Config:
        from_attributes = True

class GoalBase(BaseModel):
    title: str
    description: Optional[str] = None
    deadline: Optional[datetime] = None
    priority: int = 1

class GoalCreate(GoalBase):
    pass

class GoalUpdate(GoalBase):
    is_archived: Optional[bool] = None

class GoalOut(GoalBase):
    id: int
    user_id: int
    progress: int
    is_archived: bool
    created_at: datetime
    steps: List[StepOut] = []

    class Config:
        from_attributes = True

class GoalWithProgress(GoalOut):
    total_steps: int
    completed_steps: int

# LLM
class AdviceRequest(BaseModel):
    question: str

class AdviceResponse(BaseModel):
    advice: str

# Admin
class UserAdminOut(BaseModel):
    id: int
    email: str
    full_name: str
    role: str
    is_blocked: bool
    created_at: datetime

class LLMLogOut(BaseModel):
    id: int
    user_id: Optional[int]
    request_type: str
    prompt: str
    response: str
    duration_ms: int
    success: bool
    error_message: Optional[str]
    created_at: datetime