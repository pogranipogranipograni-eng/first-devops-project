#!/bin/bash
# generate_report.sh - zamienia CSV z test_server.sh na raport w Markdownie.
# Użycie: ./generate_report.sh wyniki-20260819-101500.csv [prog_p95_ms] > raport.md
set -uo pipefail

CSV="${1:?podaj plik CSV z wynikami}"
PROG_P95="${2:-400}"
[[ -r "$CSV" ]] || { echo "nie mogę odczytać $CSV" >&2; exit 1; }

echo "# Raport z testu wydajności serwera WWW"
echo
echo "- **Data wykonania**: $(date '+%Y-%m-%d %H:%M:%S')"
echo "- **Maszyna testowa**: $(hostname), $(nproc) rdzeni, $(free -h | awk '/^Mem:/ {print $2}') RAM"
echo "- **Plik danych**: \`${CSV}\`"
echo "- **Kryterium zaliczenia**: p95 poniżej ${PROG_P95} ms przy zerowej liczbie błędów"
echo
echo "## Wyniki pomiarów"
echo
echo "| Konkurencja | RPS | p50 [ms] | p95 [ms] | p99 [ms] | Błędy | Ocena |"
echo "|---|---|---|---|---|---|---|"

awk -F, -v prog="$PROG_P95" 'NR > 1 {
  ocena = ($4 > 0 && $6 <= prog && $8 == 0 && $9 == 0) ? "zaliczony" : "NIEZALICZONY";
  printf "| %s | %.1f | %s | %s | %s | %d | %s |\n", $1, $4, $5, $6, $7, $8 + $9, ocena;
}' "$CSV"

echo
echo "## Wnioski automatyczne"
echo

awk -F, -v prog="$PROG_P95" '
NR > 1 {
  c[NR] = $1; rps[NR] = $4 + 0; p95[NR] = $6 + 0; bledy[NR] = $8 + $9;
  if (rps[NR] > maxrps) { maxrps = rps[NR]; maxc = $1; }
  if (p95[NR] <= prog && bledy[NR] == 0 && $1 + 0 > bezpieczna) bezpieczna = $1 + 0;
  if (bledy[NR] > 0 && pierwszy_blad == "") pierwszy_blad = $1;
  n = NR;
}
END {
  printf "- Maksymalna zmierzona przepustowość: **%.1f RPS** przy konkurencji %s.\n", maxrps, maxc;
  if (bezpieczna > 0)
    printf "- Najwyższa konkurencja spełniająca kryterium (p95 < %d ms, 0 błędów): **%d**.\n", prog, bezpieczna;
  else
    printf "- **Żaden** poziom konkurencji nie spełnił kryterium p95 < %d ms.\n", prog;
  if (pierwszy_blad != "")
    printf "- Pierwsze błędy pojawiły się przy konkurencji **%s** - to punkt załamania.\n", pierwszy_blad;
  else
    print "- W całym zakresie testu nie wystąpił ani jeden błąd.";
  if (n > 2 && rps[n] < maxrps * 0.9)
    printf "- Przepustowość przy najwyższej konkurencji spadła o %.0f%% względem maksimum - system jest za punktem załamania.\n", (1 - rps[n] / maxrps) * 100;
}' "$CSV"

echo
echo "## Zalecenia"
echo
echo "1. Za pojemność operacyjną przyjmij konkurencję o jeden poziom niższą od najwyższej zaliczonej."
echo "2. Powtórz pomiar trzykrotnie i porównaj mediany, zanim uznasz wynik za wiążący."
echo "3. Przed zmianą konfiguracji zapisz obecne wartości jako punkt odniesienia (baseline)."
