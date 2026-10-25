## Porównanie trzech przypadków

| | 1. Nazwa z rekordem A | 2. Nazwa bez rekordu AAAA | 3. Nazwa nieistniejąca |
|---|---|---|---|
| **Zapytanie** | `dig onet.pl` | `dig onet.pl AAAA` | `dig notexist.pl` |
| **Status** | `NOERROR` | `NOERROR` | `NXDOMAIN` |
| **ANSWER** | 4 rekordy A (`143.204.238.28`, `.74`, `.76`, `.117`), TTL 29 | pusta (`ANSWER: 0`) | pusta (`ANSWER: 0`) |
| **AUTHORITY** | `0` (brak) | `0` przez stub, SOA: `...` | `0` przez stub, SOA: `...` |
| **TTL odpowiedzi negatywnej** | nie dotyczy | `...` s | `...` s |

## Dodatkowe pomiary (pełna odpowiedź, z pominięciem stuba)

Stub `127.0.0.53` nie zwraca sekcji AUTHORITY przy odpowiedziach negatywnych, dlatego do odczytu SOA i TTL użyto publicznego resolvera:

```
dig @1.1.1.1 onet.pl AAAA
dig @1.1.1.1 notexist.pl
dig @1.1.1.1 nieistnieje-xyz.onet.pl
dig onet.pl SOA
```

Wartości do uzupełnienia: rekord SOA z sekcji AUTHORITY, jego TTL oraz pole `minimum` z rekordu SOA strefy.

## Wyjaśnienie

### Dlaczego przypadek 2 zwraca NOERROR mimo pustej sekcji ANSWER

Nazwa `onet.pl` **istnieje** w DNS (ma rekordy A, MX i inne). Pytanie dotyczyło tylko jednego typu, `AAAA`, którego nie ma. `NOERROR` znaczy: "zapytanie zostało poprawnie obsłużone, nazwa istnieje". Pusty ANSWER znaczy: "nie ma rekordu tego typu" (tzw. **NODATA**). Serwer nie zgłasza błędu, bo nic złego się nie stało.

### Różnica między przypadkami 2 i 3

| | NODATA (przypadek 2) | NXDOMAIN (przypadek 3) |
|---|---|---|
| Nazwa istnieje | **tak** | **nie** |
| Status | `NOERROR` | `NXDOMAIN` |
| Znaczenie | "jest nazwa, nie ma tego typu rekordu" | "takiej nazwy w ogóle nie ma" |
| Przykład | `onet.pl` AAAA | `notexist.pl` |

Dowód z własnych wyników: `host onet.pl` zwraca adresy A i serwer poczty, więc nazwa istnieje, a `host notexist.pl` zwraca `not found: 3(NXDOMAIN)`.

### Skąd bierze się TTL odpowiedzi negatywnej

Odpowiedź negatywna (NODATA i NXDOMAIN) może być **cache'owana**, żeby resolver nie pytał w kółko o coś, czego nie ma. Jej czas życia nie jest zapisany w żadnym rekordzie "brak", tylko wynika z **rekordu SOA strefy** zwracanego w sekcji AUTHORITY (RFC 2308):

> TTL odpowiedzi negatywnej = mniejsza z wartości: **TTL rekordu SOA** oraz **pole `minimum` w SOA**.

Wartość, którą widzisz przy rekordzie SOA w AUTHORITY, jest więc czasem, przez jaki resolver może zapamiętać, że rekordu lub nazwy nie ma. Odlicza się ona tak samo jak TTL zwykłych rekordów.

### Dlaczego w moich wynikach nie ma AUTHORITY

Przy odpowiedziach przez stub `127.0.0.53` licznik pokazywał `AUTHORITY: 0`, mimo że odpowiedź była negatywna. To cecha lokalnego stuba systemd-resolved, a nie cecha DNS: pełną odpowiedź z SOA zwracają dopiero publiczne resolvery (`@1.1.1.1`).

## Wniosek

`NXDOMAIN` oznacza, że **nazwa nie istnieje**, a `NOERROR` z pustym ANSWER, że **nazwa istnieje, ale brakuje rekordu żądanego typu**. W obu przypadkach resolver zapamiętuje brak odpowiedzi na czas wynikający z rekordu SOA strefy.
