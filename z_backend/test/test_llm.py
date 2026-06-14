import pytest
from unittest.mock import patch
from app.services.llm_service import generate_steps_for_goal

@patch("app.services.llm_service._call_yandex_gpt")
def test_generate_steps_parsing(mock_call):
    mock_call.return_value = "1. Изучить основы\n2. Написать код\n3. Протестировать"
    steps = generate_steps_for_goal("Программирование", "Выучить Python")
    assert steps == ["Изучить основы", "Написать код", "Протестировать"]

@patch("app.services.llm_service._call_yandex_gpt")
def test_generate_steps_fallback_on_bad_format(mock_call):
    mock_call.return_value = "Просто текст без нумерации"
    steps = generate_steps_for_goal("Цель", "")
    assert len(steps) == 1
    assert steps[0] == "Просто текст без нумерации"

def test_generate_steps_without_llm_mock(monkeypatch):
    # Заглушка, чтобы не вызывать реальный API
    async def fake_generate(title, desc):
        return ["Mock step 1", "Mock step 2"]
    monkeypatch.setattr("app.services.llm_service.generate_steps_for_goal", fake_generate)
    steps = generate_steps_for_goal("Test", "")
    assert len(steps) == 2
