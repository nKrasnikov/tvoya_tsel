from sqlalchemy.orm import Session
from ..models import Goal, Step

def update_goal_progress(goal_id: int, db: Session):
    goal = db.query(Goal).filter(Goal.id == goal_id).first()
    if not goal:
        return
    steps = db.query(Step).filter(Step.goal_id == goal_id).all()
    if not steps:
        goal.progress = 0
    else:
        completed = sum(1 for s in steps if s.is_completed)
        goal.progress = int(completed / len(steps) * 100)
    db.commit()