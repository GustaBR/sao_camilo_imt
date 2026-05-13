import os
from pathlib import Path
from urllib.parse import urlparse

from dotenv import load_dotenv
from sqlalchemy import URL, create_engine
from sqlalchemy.orm import sessionmaker

BASE_DIR = Path(__file__).resolve().parents[1]
load_dotenv(BASE_DIR / ".env")

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL nao foi configurada no arquivo backend/.env")

parsed_database_url = urlparse(DATABASE_URL)

database_url = URL.create(
    drivername="postgresql+psycopg",
    username=parsed_database_url.username,
    password=parsed_database_url.password,
    host=parsed_database_url.hostname,
    port=parsed_database_url.port,
    database=parsed_database_url.path.lstrip("/"),
)

engine = create_engine(
    database_url,
    pool_pre_ping=True,
    connect_args={"sslmode": "require"},
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
