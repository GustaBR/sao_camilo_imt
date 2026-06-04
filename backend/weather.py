import httpx
from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/weather", tags=["weather"])

@router.get("/current")
async def get_current_weather(latitude: float, longitude: float):
    url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
    
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="Erro ao buscar clima")
    
    data = response.json()
    clima = data["current_weather"]
    
    return {
        "temperatura": clima["temperature"],
        "vento_velocidade": clima["windspeed"],
        "vento_direcao": clima["winddirection"],
        "latitude": latitude,
        "longitude": longitude,
    }

@router.get("/recomendacao")
async def get_recomendacao(latitude: float, longitude: float):
    url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
    
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="Erro ao buscar clima")
    
    temperatura = response.json()["current_weather"]["temperature"]
    
    if temperatura >= 30:
        recomendacao = "Clima muito quente! Beba pelo menos 3L de água hoje."
    elif temperatura >= 20:
        recomendacao = "Clima agradável. Beba pelo menos 2L de água hoje."
    else:
        recomendacao = "Clima frio. Beba pelo menos 1.5L de água hoje."
    
    return {
        "temperatura": temperatura,
        "recomendacao": recomendacao,
    }