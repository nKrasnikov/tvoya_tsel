import time
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas
from ..database import get_db
from ..dependencies import get_current_user
from ..services import llm_service
from ..services.goal_service import update_goal_progress

router = APIRouter()

@router.get("/", response_model=List[schemas.GoalOut])
def get_goals(
    archived: bool = False,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Получение списка целей пользователя (активные или архивные)"""
    goals = db.query(models.Goal).filter(
        models.Goal.user_id == current_user.id,
        models.Goal.is_archived == archived
    ).order_by(models.Goal.deadline.asc()).all()
    return goals


@router.post("/", response_model=schemas.GoalOut)
def create_goal(
    goal_data: schemas.GoalCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Создание новой цели"""
    new_goal = models.Goal(**goal_data.dict(), user_id=current_user.id)
    db.add(new_goal)
    db.commit()
    db.refresh(new_goal)
    return new_goal


@router.get("/{goal_id}", response_model=schemas.GoalOut)
def get_goal(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Получение детальной информации о цели (включая шаги)"""
    goal = db.query(models.Goal).filter(
        models.Goal.id == goal_id,
        models.Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    return goal


@router.put("/{goal_id}", response_model=schemas.GoalOut)
def update_goal(
    goal_id: int,
    update_data: schemas.GoalUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Редактирование цели"""
    goal = db.query(models.Goal).filter(
        models.Goal.id == goal_id,
        models.Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    for key, value in update_data.dict(exclude_unset=True).items():
        setattr(goal, key, value)
    db.commit()
    db.refresh(goal)
    return goal


@router.delete("/{goal_id}")
def delete_goal(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Удаление цели (каскадно удаляет шаги)"""
    goal = db.query(models.Goal).filter(
        models.Goal.id == goal_id,
        models.Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    db.delete(goal)
    db.commit()
    return {"message": "Цель удалена"}

@router.post("/{goal_id}/generate-steps", response_model=List[schemas.StepOut])
async def generate_steps(
    goal_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Генерация шагов для цели с помощью Yandex GPT (с кэшированием и логированием)"""

    goal = db.query(models.Goal).filter(
        models.Goal.id == goal_id,
        models.Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")

    start_time = time.time()
    success = True
    error_msg = None
    steps_text_list = []
    prompt = f"Разбей цель \"{goal.title}\" (описание: {goal.description or ''}) на конкретные, измеримые шаги. Каждый шаг начинается с глагола. Выведи нумерованный список (не более 10 шагов)."

    try:
        steps_text_list = await llm_service.generate_steps_for_goal(goal.title, goal.description or "")
    except Exception as e:
        success = False
        error_msg = str(e)
        raise HTTPException(status_code=503, detail="Сервис генерации временно недоступен. Добавьте шаги вручную.")
    finally:
        duration = int((time.time() - start_time) * 1000)
        # Логируем вызов LLM
        log_entry = models.LLMLog(
            user_id=current_user.id,
            request_type="generate_steps",
            prompt=prompt,
            response="\n".join(steps_text_list) if success else error_msg,
            duration_ms=duration,
            success=success,
            error_message=error_msg if not success else None
        )
        db.add(log_entry)
        db.commit()

    db.query(models.Step).filter(models.Step.goal_id == goal_id).delete()

    new_steps = []
    for idx, text in enumerate(steps_text_list):
        step = models.Step(goal_id=goal_id, text=text, order=idx)
        db.add(step)
        new_steps.append(step)
    db.commit()

    update_goal_progress(goal_id, db)

    return new_steps

@router.post("/{goal_id}/advice", response_model=schemas.AdviceResponse)
async def get_advice(
    goal_id: int,
    request: schemas.AdviceRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Получение мотивационного совета от LLM с контекстом цели"""
    goal = db.query(models.Goal).filter(
        models.Goal.id == goal_id,
        models.Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")

    steps = goal.steps
    steps_str = "\n".join([f"- {s.text} [{'выполнен' if s.is_completed else 'не выполнен'}]" for s in steps])
    prompt = f"""Цель: {goal.title}
Описание: {goal.description or ''}
Прогресс: {goal.progress}%
Шаги:
{steps_str}
Вопрос пользователя: {request.question}
Дай короткий мотивационный совет (1-2 предложения)."""

    start_time = time.time()
    success = True
    error_msg = None
    advice_text = ""

    try:
        advice_text = await llm_service.get_advice_from_llm(goal.title, goal.description or "", steps, goal.progress, request.question)
    except Exception as e:
        success = False
        error_msg = str(e)
        raise HTTPException(status_code=503, detail="Не удалось получить совет. Попробуйте позже.")
    finally:
        duration = int((time.time() - start_time) * 1000)
        log_entry = models.LLMLog(
            user_id=current_user.id,
            request_type="advice",
            prompt=prompt,
            response=advice_text if success else error_msg,
            duration_ms=duration,
            success=success,
            error_message=error_msg if not success else None
        )
        db.add(log_entry)
        db.commit()

    return schemas.AdviceResponse(advice=advice_text)

@router.post("/{goal_id}/steps", response_model=schemas.StepOut)
def add_step(
    goal_id: int,
    step_data: schemas.StepCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """Ручное добавление шага к цели"""
    goal = db.query(models.Goal).filter(
        models.Goal.id == goal_id,
        models.Goal.user_id == current_user.id
    ).first()
    if not goal:
        raise HTTPException(status_code=404, detail="Цель не найдена")
    order = db.query(models.Step).filter(models.Step.goal_id == goal_id).count()
    new_step = models.Step(goal_id=goal_id, text=step_data.text, order=order)
    db.add(new_step)
    db.commit()
    db.refresh(new_step)
    update_goal_progress(goal_id, db)
    return new_step