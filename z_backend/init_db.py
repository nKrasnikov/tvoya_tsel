from app.database import engine, Base
from app import models  # импортируем все модели

if __name__ == "__main__":
    Base.metadata.create_all(bind=engine)
    print("Таблицы созданы успешно!")