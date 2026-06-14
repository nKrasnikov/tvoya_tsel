import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.database import Base, get_db
from app.models import User
from app.auth import get_password_hash

# Тестовая БД
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(scope="session")
def db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    yield db
    db.close()
    Base.metadata.drop_all(bind=engine)

@pytest.fixture
def client(db):
    return TestClient(app)

@pytest.fixture
def auth_headers(client):
    # Создаём тестового пользователя
    user_data = {
        "email": "test@test.com",
        "password": "123456Aa",
        "full_name": "Test User"
    }
    client.post("/api/v1/auth/register", json=user_data)
    response = client.post("/api/v1/auth/login", json={
        "email": "test@test.com",
        "password": "123456Aa"
    })
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}

@pytest.fixture
def admin_headers(client):
    # Создаём администратора (вручную в БД)
    db = TestingSessionLocal()
    hashed = get_password_hash("admin123")
    admin = User(
        email="admin@example.com",
        hashed_password=hashed,
        full_name="Admin",
        role="admin"
    )
    db.add(admin)
    db.commit()
    db.refresh(admin)
    db.close()
    response = client.post("/api/v1/auth/login", json={
        "email": "admin@example.com",
        "password": "admin123"
    })
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}
