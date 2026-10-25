# Przebieg zapytania DNS (bez cache)

Przykład: wpisujesz `example.com` w przeglądarce.

## Uczestnicy

| Rola | Co robi | Przykład |
|---|---|---|
| **Stub resolver** | Przekazuje pytanie do domyślnego serwera DNS | `127.0.0.53` |
| **Domyślny serwer DNS** | Przekazuje dalej (forwarder) | router `192.168.1.1` |
| **Resolver rekurencyjny** | Sam odpytuje kolejne serwery aż do wyniku | DNS dostawcy lub np. `1.1.1.1` |
| **Serwer root** | Wie, kto obsługuje dany TLD | `a.root-servers.net` |
| **Serwer TLD** | Wie, kto obsługuje domenę w danym TLD | `a.gtld-servers.net` |
| **Serwer autorytatywny** | Ma rekordy domeny, podaje IP | `hera.ns.cloudflare.com` |

## Krok po kroku

0. **Start:** resolver rekurencyjny zna adresy serwerów root z góry (*root hints*).
1. **Przeglądarka → stub:** "Jaki IP ma `example.com`?"
2. **Stub → domyślny serwer DNS (router):** brak w cache, pytanie idzie dalej.
3. **Router → resolver rekurencyjny:** brak w cache, pytanie idzie dalej.
4. **Resolver → root:** "Jaki IP ma `example.com`?"
   Odpowiedź: *"Nie wiem, ale `.com` obsługują te serwery TLD."*
5. **Resolver → serwer TLD (`.com`):** to samo pytanie.
   Odpowiedź: *"Nie wiem, ale domenę obsługują te serwery NS, np. `hera.ns.cloudflare.com`."*
6. **Resolver → serwer autorytatywny:** to samo pytanie.
   Odpowiedź: *"IP to X.X.X.X, TTL 3600."* (flaga `aa`)
7. **Odpowiedź wraca:** resolver (cache) → router (cache) → stub (cache) → przeglądarka.
8. **Przeglądarka łączy się z IP** przez HTTP/HTTPS. DNS jest już zakończony.

## Schemat

```
przeglądarka → stub → router → resolver rekurencyjny
                                      │
                                      ├─1→ root          → "TLD .com obsługują ci"
                                      ├─2→ TLD (.com)    → "domenę obsługują ci (NS)"
                                      └─3→ autorytatywny → "IP to X.X.X.X"
                                      │
przeglądarka ← stub ← router ←────────┘
```

## Co kto wie

```
root           →  "TLD obsługują ci"
TLD            →  "domenę obsługują ci (rekordy NS)"
autorytatywny  →  "IP to ..."
```

## Najważniejsze

- **Rekurencję wykonuje tylko resolver rekurencyjny.** Root, TLD i autorytatywne tylko odpowiadają.
- **Cache** działa na każdym etapie (stub, router, resolver), dlatego w praktyce rzadko przechodzi się całą ścieżkę.
- **Podgląd w praktyce:** `dig example.com +trace`

# dig 

## Flagi

| Flaga | Rozwinięcie | Kto ustawia | Znaczenie |
|---|---|---|---|
| `qr` | **Query Response** | serwer (w odpowiedzi) | to jest odpowiedź, a nie pytanie |
| `rd` | **Recursion Desired** | **dig** (w pytaniu), serwer kopiuje do odpowiedzi | "szukaj za mnie" |
| `ra` | **Recursion Available** | serwer (w odpowiedzi) | "potrafię szukać rekurencyjnie" |
| `aa` | **Authoritative Answer** | serwer (w odpowiedzi) | odpowiedź prosto od serwera autorytatywnego |

## Sekcje

| Sekcja | Co zawiera | Przykład  |
|---|---|---|
| **QUESTION** | Powtórzone pytanie: nazwa, klasa i typ rekordu | `example.com. IN A` |
| **ANSWER** | Właściwa odpowiedź: rekordy z nazwą, TTL, typem i wartością | dwa adresy IPv4 (`104.20.23.154`, `172.66.147.243`) |
| **AUTHORITY** | Serwery autorytatywne (NS)  | `AUTHORITY: 0`, pusta przy kompletnej odpowiedzi ze stuba |
| **ADDITIONAL** | Dodatkowe rekordy oszczędzające kolejne zapytania (np. adresy serwerów NS) oraz pseudosekcja OPT (EDNS) | `ADDITIONAL: 1`, to tylko OPT (`udp: 65494`) |
| **Stopka** | Informacje o samym zapytaniu: `Query time`, `SERVER`, `WHEN`, `MSG SIZE` | `42 msec`, `127.0.0.53#53`, `Sun Oct 25 11:53:54 CET 2026`, `72` |


# cache

**TTL (Time To Live)** to czas w sekundach, przez jaki cache może uznawać rekord za aktualny i zwracać go bez pytania serwera autorytatywnego.

| # | Poziom | Przykład | Uwagi |
|---|---|---|---|
| 1 | **Przeglądarka** | Chrome/Firefox | Własny, krótki cache DNS. `dig` go nie używa, bo nie jest przeglądarką. |
| 2 | **System (stub resolver)** | `127.0.0.53` (systemd-resolved) | Cache całego komputera. To pierwsze miejsce, które widzisz w `dig`. |
| 3 | **Router** | `192.168.1.1` | Zwykle mały cache (forwarder), ale część routerów w ogóle nie cache'uje. |
| 4 | **Resolver rekurencyjny** | DNS dostawcy lub np. `1.1.1.1` | Największy cache, współdzielony przez tysiące lub miliony użytkowników. |

```
Jak TTL sie skończy to nie zostanie wykorzystny cache (bedzie nieaktualny) wiec zaptyanie zostanie przesłąne dalej. Moze trafic sie tak, że sotanie pobrane z sache na innym poziome(pobierze jego TTL).
Jesli cache na reslolverze rekurencyjnym też bedzie nieauktualny to pytanie pojdzie dalej do servera, a TTL zostanie zresetowany.
```
