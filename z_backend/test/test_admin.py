def test_admin_list_users(client, admin_headers):
    response = client.get("/api/v1/admin/users", headers=admin_headers)
    assert response.status_code == 200
    users = response.json()
    assert isinstance(users, list)
    assert len(users) >= 1

def test_admin_block_user(client, admin_headers, auth_headers):
    # Получаем обычного пользователя (test@test.com)
    users_resp = client.get("/api/v1/admin/users", headers=admin_headers)
    users = users_resp.json()
    user_id = next(u["id"] for u in users if u["email"] == "test@test.com")
    block_resp = client.post(f"/api/v1/admin/users/{user_id}/block", headers=admin_headers)
    assert block_resp.status_code == 200
    # Проверяем, что пользователь заблокирован
    login_resp = client.post("/api/v1/auth/login", json={
        "email": "test@test.com",
        "password": "123456Aa"
    })
    assert login_resp.status_code == 403

def test_admin_llm_logs(client, admin_headers):
    response = client.get("/api/v1/admin/llm-logs?limit=10", headers=admin_headers)
    assert response.status_code == 200
    logs = response.json()
    assert isinstance(logs, list)
