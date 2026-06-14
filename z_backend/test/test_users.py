def test_get_me(client, auth_headers):
    response = client.get("/api/v1/users/me", headers=auth_headers)
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "test@test.com"

def test_update_profile(client, auth_headers):
    response = client.put("/api/v1/users/me", headers=auth_headers, json={
        "full_name": "Updated Name",
        "reminder_enabled": False,
        "reminder_time": "10:30"
    })
    assert response.status_code == 200
    assert response.json()["full_name"] == "Updated Name"

def test_change_password_success(client, auth_headers):
    response = client.put("/api/v1/users/me/password", headers=auth_headers, json={
        "old_password": "123456Aa",
        "new_password": "NewPass789!"
    })
    assert response.status_code == 200
    # Проверяем, что можно войти с новым паролем
    login = client.post("/api/v1/auth/login", json={
        "email": "test@test.com",
        "password": "NewPass789!"
    })
    assert login.status_code == 200

def test_change_password_wrong_old(client, auth_headers):
    response = client.put("/api/v1/users/me/password", headers=auth_headers, json={
        "old_password": "wrong",
        "new_password": "NewPass789!"
    })
    assert response.status_code == 400
    assert "Неверный старый пароль" in response.text
