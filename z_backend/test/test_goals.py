def test_create_goal(client, auth_headers):
    response = client.post("/api/v1/goals/", headers=auth_headers, json={
        "title": "Test Goal",
        "description": "Test description",
        "deadline": "2026-12-31T00:00:00",
        "priority": 2
    })
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Goal"
    assert data["progress"] == 0

def test_get_goals(client, auth_headers):
    response = client.get("/api/v1/goals/", headers=auth_headers)
    assert response.status_code == 200
    goals = response.json()
    assert isinstance(goals, list)

def test_update_goal(client, auth_headers):
    # Сначала создадим
    create_resp = client.post("/api/v1/goals/", headers=auth_headers, json={
        "title": "To Update",
        "description": "desc",
        "priority": 1
    })
    goal_id = create_resp.json()["id"]
    update_resp = client.put(f"/api/v1/goals/{goal_id}", headers=auth_headers, json={
        "title": "Updated Title",
        "description": "new desc",
        "priority": 3
    })
    assert update_resp.status_code == 200
    assert update_resp.json()["title"] == "Updated Title"

def test_delete_goal(client, auth_headers):
    create_resp = client.post("/api/v1/goals/", headers=auth_headers, json={
        "title": "To Delete",
        "description": "desc"
    })
    goal_id = create_resp.json()["id"]
    delete_resp = client.delete(f"/api/v1/goals/{goal_id}", headers=auth_headers)
    assert delete_resp.status_code == 200
    # Проверяем, что цели больше нет
    get_resp = client.get(f"/api/v1/goals/{goal_id}", headers=auth_headers)
    assert get_resp.status_code == 404
