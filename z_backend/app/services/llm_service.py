import httpx
import hashlib
import redis.asyncio as redis
import time
from typing import List
from ..config import settings

redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

async def _call_yandex_gpt(prompt: str) -> str:
    import logging
    logger = logging.getLogger(__name__)

    logger.info(f"Sending prompt: {prompt[:100]}...")
    """Отправляет запрос к Yandex GPT и возвращает текст ответа."""
    headers = {
        "Authorization": f"Api-Key {settings.YANDEX_GPT_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": f"gpt://{settings.YANDEX_FOLDER_ID}/yandexgpt",
        "input": prompt
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "https://ai.api.cloud.yandex.net/v1/responses",
            json=payload,
            headers=headers,
            timeout=10.0
        )
        response.raise_for_status()
        data = response.json()
        # Извлекаем текст из ответа
        text = data["output"][0]["content"][0]["text"]
        logger.info(f"Extracted text: {text}")
        return text

async def generate_steps_for_goal(title: str, description: str) -> List[str]:
    # Кэширование
    cache_key = f"llm:steps:{hashlib.md5(f'{title}|{description}'.encode()).hexdigest()}"
    cached = await redis_client.get(cache_key)
    if cached:
        return cached.split("||")

    prompt = f"""Ты — ассистент по достижению целей. Разбей цель "{title}" (описание: {description}) на конкретные, измеримые шаги. Каждый шаг начинается с глагола. Выведи нумерованный список (не более 10 шагов)."""
    
    result = await _call_yandex_gpt(prompt)
    # Парсим ответ в список (ожидаем нумерованный список)
    steps = []
    for line in result.strip().split("\n"):
        line = line.strip()
        if line and line[0].isdigit() and ". " in line:
            steps.append(line.split(". ", 1)[1])
    if not steps:
        steps = [result.strip()]
    if steps:
        await redis_client.setex(cache_key, 3600, "||".join(steps))
    return steps

async def get_advice_from_llm(title: str, description: str, steps, progress: int, question: str) -> str:
    steps_str = "\n".join([f"- {s.text} [{'выполнен' if s.is_completed else 'не выполнен'}]" for s in steps])
    prompt = f"""Цель: {title}\nОписание: {description}\nПрогресс: {progress}%\nШаги:\n{steps_str}\nВопрос пользователя: {question}\nДай короткий мотивационный совет (1-2 предложения)."""
    return await _call_yandex_gpt(prompt)