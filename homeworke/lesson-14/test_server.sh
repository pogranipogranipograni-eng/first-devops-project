#!/bin/bash
# test_server.sh - mierzy wydajność serwera przy rosnącej konkurencji.
# Użycie: ./test_server.sh [adres] [liczba_zadan_na_krok]
set -uo pipefail

URL="${1:-http://localhost/}"
ZADANIA="${2:-2000}"
POZIOMY=(10 25 50 100 200 400)
WYNIKI="wyniki-$(date +%Y%m%d-%H%M%S).csv"
KATALOG_SUROWY="surowe-$(date +%Y%m%d-%H%M%S)"

command -v ab >/dev/null || { echo "brak ab: sudo apt install apache2-utils" >&2; exit 1; }
mkdir -p "$KATALOG_SUROWY"

echo "konkurencja,zadania,czas_s,rps,p50_ms,p95_ms,p99_ms,nieudane,kod_niepowodzenia" > "$WYNIKI"

echo "Cel: $URL"
echo "Rozgrzewka..."
ab -k -n 500 -c 10 "$URL" > /dev/null 2>&1

for c in "${POZIOMY[@]}"; do
  printf 'Test przy konkurencji %s... ' "$c"
  plik="${KATALOG_SUROWY}/ab-c${c}.txt"
  ab -k -n "$ZADANIA" -c "$c" "$URL" > "$plik" 2>&1

  czas=$(awk '/^Time taken for tests:/ {print $5}' "$plik")
  rps=$(awk '/^Requests per second:/ {print $4}' "$plik")
  nieudane=$(awk '/^Failed requests:/ {print $3}' "$plik")
  nieoczek=$(awk '/^Non-2xx responses:/ {print $3}' "$plik")
  p50=$(awk '/^    50%/ {print $2}' "$plik")
  p95=$(awk '/^    95%/ {print $2}' "$plik")
  p99=$(awk '/^    99%/ {print $2}' "$plik")

  : "${czas:=0}" "${rps:=0}" "${nieudane:=0}" "${nieoczek:=0}"
  : "${p50:=0}" "${p95:=0}" "${p99:=0}"

  echo "${c},${ZADANIA},${czas},${rps},${p50},${p95},${p99},${nieudane},${nieoczek}" >> "$WYNIKI"
  printf 'RPS=%s p95=%sms błędy=%s\n' "$rps" "$p95" "$nieudane"

  sleep 5   # przerwa na opadnięcie gniazd TIME_WAIT
done

echo
echo "Surowe wyjścia: $KATALOG_SUROWY/"
echo "Podsumowanie:    $WYNIKI"
column -s, -t "$WYNIKI" 2>/dev/null || cat "$WYNIKI"
