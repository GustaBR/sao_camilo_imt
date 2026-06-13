from fastapi import APIRouter, HTTPException
from sqlalchemy import text

router = APIRouter(tags=["health"])


@router.get("/")
def health_check():
    return {"status": "ok"}


@router.get("/db")
def database_health_check():
    from backend.config.database import engine

    try:
        with engine.connect() as connection:
            connection.execute(text("select 1"))
        return {"database": "connected"}
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail="Nao foi possivel conectar ao banco de dados.",
        ) from exc
