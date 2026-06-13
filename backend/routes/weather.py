import httpx
from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/weather", tags=["weather"])

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"


def _format_wind(speed: float | None, direction: float | None) -> str:
    if speed is None:
        return "Nao informado"

    if direction is None:
        return f"{speed:.1f} km/h"

    labels = ["N", "NE", "E", "SE", "S", "SO", "O", "NO"]
    index = int((direction + 22.5) // 45) % 8
    return f"{speed:.1f} km/h {labels[index]}"


def _solar_exposure_code(is_day: int | None, weather_code: int | None) -> str:
    if is_day != 1:
        return "sem_direta"

    if weather_code == 0:
        return "intensa"

    if weather_code in {1, 2}:
        return "moderada"

    if weather_code in {3, 45, 48}:
        return "leve"

    return "sem_direta"


def _solar_exposure_label(code: str) -> str:
    labels = {
        "sem_direta": "Sem exposicao direta",
        "leve": "Exposicao leve",
        "moderada": "Exposicao moderada",
        "intensa": "Exposicao intensa",
    }
    return labels[code]


async def _fetch_current_weather(latitude: float, longitude: float) -> dict:
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": ",".join(
            [
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "wind_speed_10m",
                "wind_direction_10m",
                "is_day",
                "weather_code",
            ],
        ),
        "timezone": "auto",
    }

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(OPEN_METEO_URL, params=params)
            response.raise_for_status()
    except httpx.HTTPStatusError as exc:
        raise HTTPException(
            status_code=exc.response.status_code,
            detail="Erro ao buscar clima.",
        ) from exc
    except httpx.HTTPError as exc:
        raise HTTPException(
            status_code=502,
            detail="Nao foi possivel consultar a API de clima.",
        ) from exc

    current = response.json().get("current")
    if not isinstance(current, dict):
        raise HTTPException(
            status_code=502,
            detail="Resposta inesperada da API de clima.",
        )

    return current


@router.get("/current")
async def get_current_weather(latitude: float, longitude: float):
    current = await _fetch_current_weather(latitude, longitude)

    temperature = current.get("temperature_2m")
    humidity = current.get("relative_humidity_2m")
    apparent_temperature = current.get("apparent_temperature")
    wind_speed = current.get("wind_speed_10m")
    wind_direction = current.get("wind_direction_10m")
    exposure_code = _solar_exposure_code(
        current.get("is_day"),
        current.get("weather_code"),
    )

    return {
        "temperatura": temperature,
        "umidade": humidity,
        "sensacao_termica": apparent_temperature,
        "vento_velocidade": wind_speed,
        "vento_direcao": wind_direction,
        "vento": _format_wind(wind_speed, wind_direction),
        "exposicao_solar_codigo": exposure_code,
        "exposicao_solar": _solar_exposure_label(exposure_code),
        "latitude": latitude,
        "longitude": longitude,
    }


@router.get("/recomendacao")
async def get_recomendacao(latitude: float, longitude: float):
    current = await _fetch_current_weather(latitude, longitude)
    temperature = current.get("temperature_2m")

    if temperature is None:
        raise HTTPException(
            status_code=502,
            detail="Temperatura nao encontrada na resposta da API de clima.",
        )

    if temperature >= 30:
        recommendation = "Clima muito quente! Beba pelo menos 3L de agua hoje."
    elif temperature >= 20:
        recommendation = "Clima agradavel. Beba pelo menos 2L de agua hoje."
    else:
        recommendation = "Clima frio. Beba pelo menos 1.5L de agua hoje."

    return {
        "temperatura": temperature,
        "recomendacao": recommendation,
    }
