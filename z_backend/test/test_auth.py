def test_register_success(client):
    response = client.post("/api/v1/auth/register", json={
        "email": "new@test.com",
        "password": "Pass1234!",
        "full_name": "New User"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "new@test.com"

def test_register_duplicate_email(client):
    # Предварительно создаём пользователя
    client.post("/api/v1/auth/register", json={
        "email": "dup@test.com",
        "password": "Pass1234!",
        "full_name": "Dup"
    })
    response = client.post("/api/v1/auth/register", json={
        "email": "dup@test.com",
        "password": "Pass1234!",
        "full_name": "Dup2"
    })
    assert response.status_code == 400
    assert "already registered" in response.text

def test_login_success(client):
    client.post("/api/v1/auth/register", json={
        "email": "login@test.com",
        "password": "123456Aa",
        "full_name": "Login User"
    })
    response = client.post("/api/v1/auth/login", json={
        "email": "login@test.com",
        "password": "123456Aa"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert "refresh_token" in response.json()

def test_login_wrong_password(client):
    client.post("/api/v1/auth/register", json={
        "email": "wrongpass@test.com",
        "password": "123456Aa",
        "full_name": "Wrong"
    })
    response = client.post("/api/v1/auth/login", json={
        "email": "wrongpass@test.com",
        "password": "wrong"
    })
    assert response.status_code == 401
    assert "Неверный email или пароль" in response.text
