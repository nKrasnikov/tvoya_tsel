import httpx
import hashlib
import redis.asyncio as redis
import time
from typing import List
from ..config import settings

redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

async def generate_steps_for_goal(title: str, description: str) -> List[str]:
    # Проверка кэша
    cache_key = f"llm:steps:{hashlib.md5(f'{title}|{description}'.encode()).hexdigest()}"
    cached = await redis_client.get(cache_key)
    if cached:
        return cached.split("||")
    
    prompt = f"""Ты — ассистент по достижению целей. Разбей цель "{title}" (описание: {description}) на конкретные, измеримые шаги. Каждый шаг начинается с глагола. Выведи нумерованный список (не более 10 шагов)."""
    
    headers = {
        "Authorization": f"Api-Key {settings.YANDEX_GPT_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "modelUri": f"gpt://{settings.YANDEX_FOLDER_ID}/yandexgpt/lite",
        "completionOptions": {"stream": False, "temperature": 0.7},
        "messages": [{"role": "user", "content": prompt}]
    }
    start = time.time()
    async with httpx.AsyncClient() as client:
        response = await client.post(settings.YANDEX_GPT_URL, json=payload, headers=headers, timeout=10)
    duration = int((time.time() - start) * 1000)
    if response.status_code != 200:
        raise Exception(f"LLM API error: {response.text}")
    data = response.json()
    result = data["result"]["alternatives"][0]["message"]["content"]
    # Парсинг
    steps = []
    for line in result.strip().split("\n"):
        line = line.strip()
        if line and line[0].isdigit() and ". " in line:
            steps.append(line.split(". ", 1)[1])
    if steps:
        await redis_client.setex(cache_key, 3600, "||".join(steps))
    return steps

async def get_advice_from_llm(title: str, description: str, steps, progress: int, question: str) -> str:
    steps_str = "\n".join([f"- {s.text} [{'выполнен' if s.is_completed else 'не выполнен'}]" for s in steps])
    prompt = f"""Цель: {title}\nОписание: {description}\nПрогресс: {progress}%\nШаги:\n{steps_str}\nВопрос: {question}\nДай короткий мотивационный совет."""
    headers = {"Authorization": f"Api-Key {settings.YANDEX_GPT_API_KEY}"}
    payload = {
        "modelUri": f"gpt://{settings.YANDEX_FOLDER_ID}/yandexgpt/lite",
        "completionOptions": {"stream": False, "temperature": 0.8},
        "messages": [{"role": "user", "content": prompt}]
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(settings.YANDEX_GPT_URL, json=payload, headers=headers, timeout=10)
    if response.status_code != 200:
        return "Не удалось получить совет. Попробуйте позже."
    data = response.json()
    return data["result"]["alternatives"][0]["message"]["content"]