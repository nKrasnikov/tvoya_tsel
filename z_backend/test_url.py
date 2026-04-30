from dotenv import load_dotenv
import os

load_dotenv()
url = os.getenv("DATABASE_URL")
print("URL repr:", repr(url))
print("URL text:", url)

import psycopg2
try:
    conn = psycopg2.connect(url)
    print("OK")
    conn.close()
except Exception as e:
    print(e)