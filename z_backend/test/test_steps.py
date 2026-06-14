def test_add_step(client, auth_headers):
    # Создаём цель
    goal_resp = client.post("/api/v1/goals/", headers=auth_headers, json={
        "title": "Step Test Goal"
    })
    goal_id = goal_resp.json()["id"]
    step_resp = client.post(f"/api/v1/goals/{goal_id}/steps", headers=auth_headers, json={
        "text": "New step"
    })
    assert step_resp.status_code == 200
    assert step_resp.json()["text"] == "New step"

def test_toggle_step_updates_progress(client, auth_headers):
    goal_resp = client.post("/api/v1/goals/", headers=auth_headers, json={
        "title": "Progress Test"
    })
    goal_id = goal_resp.json()["id"]
    # Добавляем 2 шага
    client.post(f"/api/v1/goals/{goal_id}/steps", headers=auth_headers, json={"text": "Step1"})
    client.post(f"/api/v1/goals/{goal_id}/steps", headers=auth_headers, json={"text": "Step2"})
    # Получаем шаги
    goal_detail = client.get(f"/api/v1/goals/{goal_id}", headers=auth_headers)
    steps = goal_detail.json()["steps"]
    step_id = steps[0]["id"]
    # Отмечаем первый шаг выполненным
    patch_resp = client.patch(f"/api/v1/steps/{step_id}", headers=auth_headers, json={"is_completed": True})
    assert patch_resp.status_code == 200
    # Проверяем прогресс
    goal_after = client.get(f"/api/v1/goals/{goal_id}", headers=auth_headers)
    assert goal_after.json()["progress"] == 50  # 1 из 2 = 50%

def test_delete_step_updates_progress(client, auth_headers):
    goal_resp = client.post("/api/v1/goals/", headers=auth_headers, json={
        "title": "Delete Step Test"
    })
    goal_id = goal_resp.json()["id"]
    client.post(f"/api/v1/goals/{goal_id}/steps", headers=auth_headers, json={"text": "Only step"})
    goal_detail = client.get(f"/api/v1/goals/{goal_id}", headers=auth_headers)
    step_id = goal_detail.json()["steps"][0]["id"]
    # Удаляем шаг
    del_resp = client.delete(f"/api/v1/steps/{step_id}", headers=auth_headers)
    assert del_resp.status_code == 200
    goal_after = client.get(f"/api/v1/goals/{goal_id}", headers=auth_headers)
    assert goal_after.json()["steps"] == []
    assert goal_after.json()["progress"] == 0
