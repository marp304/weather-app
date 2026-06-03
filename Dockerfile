# ETAP 1: Budowanie zaleznosci
FROM python:3.11-alpine AS builder

# Konfiguracja srodowiska Pythona
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /install

# Kopiowanie pliku wymagan przed kodem (optymalizacja cache)
COPY requirements.txt .

# Instalacja zaleznosci
RUN pip install --no-cache-dir --prefix=/install/deps -r requirements.txt


# ETAP 2: Obraz docelowy
FROM python:3.11-alpine

# Metadane obrazu
LABEL org.opencontainers.image.authors="Marcin Parlak"
LABEL org.opencontainers.image.title="Aplikacja Pogodowa"

# Konfiguracja srodowiska Pythona
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

# Utworzenie uzytkownika bez uprawnien roota
RUN adduser -D weatheruser
WORKDIR /app

# Skopiowanie bibliotek z etapu buildera
COPY --from=builder /install/deps /usr/local

# Skopiowanie pliku aplikacji z odpowiednimi uprawnieniami
COPY --chown=weatheruser:weatheruser app.py .

# Uruchamianie kontenera jako uzytkownik non-root
USER weatheruser

# Zadeklarowanie portu nasluchu
EXPOSE 8080

# Konfiguracja mechanizmu sprawdzania stanu aplikacji
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Polecenie startowe
CMD ["python", "app.py"]