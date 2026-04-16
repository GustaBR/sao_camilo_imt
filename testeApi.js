require("dotenv").config(); // Carrega as variáveis do arquivo .env
API_KEY = process.env.API_KEY; // Chave de API declarada no .env

const URL = (key, latitude=48.8584, longitude=2.2945) => {
    return `https://weather.googleapis.com/v1/currentConditions:lookup?key=${key}&location.latitude=${latitude}&location.longitude=${longitude}`;
}

fetch(URL(API_KEY))
.then((res) => res.json())
.then((data) => console.log(data));