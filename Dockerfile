# ETAP 1: Budowanie zaleznosci
FROM python:3.11-alpine AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /install

COPY requirements.txt .

# Aktualizacja narzedzi bazowych Pythona aby wyeliminowac podatnosci
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Instalacja zaleznosci aplikacji
RUN pip install --no-cache-dir --prefix=/install/deps -r requirements.txt


# ETAP 2: Obraz docelowy
FROM python:3.11-alpine

LABEL org.opencontainers.image.authors="Marcin Parlak"
LABEL org.opencontainers.image.title="Aplikacja Pogodowa"

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/usr/local/lib/python3.11/site-packages

RUN adduser -D weatheruser
WORKDIR /app

COPY --from=builder /install/deps /usr/local
COPY --chown=weatheruser:weatheruser app.py .

USER weatheruser
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

CMD ["python", "app.py"]
