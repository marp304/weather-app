# Aplikacja Pogodowa - System CI/CD

Projekt zaliczeniowy przedstawiajacy aplikacje pogodowa (Python/Flask) wraz z pelnym lancuchem automatyzacji (CI/CD) do budowania, skanowania i publikacji obrazow kontenerowych.

## O projekcie
Aplikacja pozwala na pobieranie aktualnych danych pogodowych (temperatura, wiatr) dla wybranych miast za pomoca darmowego API Open-Meteo. Zostala skonteneryzowana przy uzyciu lekkiego obrazu Alpine Linux z zastosowaniem najlepszych praktyk bezpieczenstwa (wieloetapowe budowanie, uzytkownik non-root, eliminacja systemowych narzedzi instalacyjnych).

## Automatyzacja (GitHub Actions)
Repozytorium wykorzystuje pipeline, ktory po kazdym pushu do galezi `main` realizuje nastepujace kroki:
1. **Zarzadzanie cache:** Wykorzystuje DockerHub jako zewnetrzny backend do optymalizacji czasu budowania.
2. **Skanowanie CVE:** Buduje lokalny obraz i skanuje go narzedziem **Trivy**. Proces zostaje natychmiastowo przerwany (exit-code 1) w przypadku wykrycia luk bezpieczenstwa oznaczonych jako HIGH lub CRITICAL.
3. **Multi-architektura:** Buduje bezpieczny i wolny od podatnosci obraz dla architektur `linux/amd64` oraz `linux/arm64`.
4. **Publikacja:** Przesyla gotowy obraz do GitHub Container Registry (GHCR).

## Strategia tagowania
* **Obrazy w GHCR:** Publikowane obrazy otrzymuja dwa tagi: `latest` oraz unikalny tag bazujacy na kalce commita Git (`github.sha`). Gwarantuje to niezmiennosc (immutability) i pozwala na precyzyjne powiazanie kontenera z konkretna wersja kodu zrodlowego.
* **Cache w DockerHub:** Dane cache zapisywane sa w odrebnych repozytoriach pod tagiem `:main`. Separacja ta chroni ostateczny obraz przed zanieczyszczeniem (cache poisoning) w trakcie cyklu zycia aplikacji.

## Uruchomienie lokalne
Aby uruchomic aplikacje na wlasnym srodowisku Docker:

```bash
# Zbudowanie obrazu
docker build -t weather-app .

# Uruchomienie kontenera w tle na porcie 8080
docker run -d -p 8080:8080 --name weather weather-app
