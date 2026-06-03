import os
import sys
import logging
import urllib.request
import json
from datetime import datetime
from flask import Flask, render_template_string, request

# Konfiguracja podstawowego mechanizmu logowania
logging.basicConfig(level=logging.INFO, stream=sys.stdout)
logger = logging.getLogger(__name__)

app = Flask(__name__)

PORT = 8080
AUTHOR = "Marcin Parlak"

# Predefiniowana baza lokalizacji do zapytan API
CITIES = {
    "Warszawa": {"lat": 52.2297, "lon": 21.0122},
    "Krakow": {"lat": 50.0614, "lon": 19.9366},
    "Gdansk": {"lat": 54.3520, "lon": 18.6466}
}

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>Aktualna Pogoda</title>
</head>
<body>
    <h2>Wybierz lokalizacje</h2>
    <form method="POST">
        <select name="city">
            {% for c in cities %}
                <option value="{{ c }}">{{ c }}</option>
            {% endfor %}
        </select>
        <button type="submit">Pokaz pogode</button>
    </form>
    
    {% if weather %}
        <h3>Pogoda dla: {{ selected }}</h3>
        <p>Temperatura: {{ weather.temp }} &deg;C</p>
        <p>Predkosc wiatru: {{ weather.wind }} km/h</p>
    {% endif %}
</body>
</html>
"""

@app.route("/", methods=["GET", "POST"])
def index():
    weather_data = None
    selected_city = None
    
    # Przetwarzanie formularza i pobranie danych pogodowych
    if request.method == "POST":
        selected_city = request.form.get("city")
        if selected_city in CITIES:
            coords = CITIES[selected_city]
            url = f"https://api.open-meteo.com/v1/forecast?latitude={coords['lat']}&longitude={coords['lon']}&current_weather=true"
            
            try:
                # Wykonanie zapytania do publicznego API i parsowanie odpowiedzi JSON
                req = urllib.request.urlopen(url)
                data = json.loads(req.read())
                
                weather_data = {
                    "temp": data["current_weather"]["temperature"],
                    "wind": data["current_weather"]["windspeed"]
                }
            except Exception as e:
                logger.error(f"Blad pobierania z API: {e}")

    return render_template_string(HTML_TEMPLATE, cities=CITIES.keys(), weather=weather_data, selected=selected_city)

if __name__ == "__main__":
    # Wypisanie informacji startowych w logach serwera
    start_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    logger.info(f"Data uruchomienia: {start_time}")
    logger.info(f"Autor programu: {AUTHOR}")
    logger.info(f"Aplikacja nasluchuje na porcie TCP: {PORT}")
    
    app.run(host="0.0.0.0", port=PORT)