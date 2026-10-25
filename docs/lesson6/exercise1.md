## 1. Rozwiązywanie nazwy

**Polecenie:** `dig example.com`

**Wynik:**
```
status: NOERROR, ANSWER: 2
example.com.  255  IN  A  104.20.23.154
example.com.  255  IN  A  172.66.147.243
SERVER: 127.0.0.53, Query time: 42 msec
```

**Ocena:** nazwa rozwiązuje się poprawnie na dwa adresy IPv4.

## 2. Ślad od korzenia

**Polecenie:** `dig example.com +trace`

**Wynik (skrót):**
```
root (e.root-servers.net)      → serwery .com
TLD (d.gtld-servers.net)       → NS: hera / elliott.ns.cloudflare.com
autorytatywny (elliott...)     → A 104.20.23.154, 172.66.147.243
```

**Ocena:** łańcuch delegacji jest kompletny, serwery autorytatywne (Cloudflare) odpowiadają, a adresy zgadzają się z etapem 1. Komunikaty `network unreachable` dotyczyły tylko prób IPv6 po stronie stacji i nie są błędem DNS.

## 3. Rekordy MX

**Polecenie:** `dig example.com MX`

**Wynik:**
```
status: NOERROR
example.com.  112  IN  MX  0 .
```

**Ocena:** to **null MX** (RFC 7505): domena świadomie **nie przyjmuje poczty**. DNS domeny działa, ale rekord MX nie potwierdza zgłoszenia, że "poczta działa".

## 4. Dostępność portu

**Polecenia:** `nc -zv -4 example.com 80`, `nc -zv -4 example.com 443`, `nc -zv -6 ...`

**Wynik:**
```
IPv4 port 80:   succeeded!
IPv4 port 443:  succeeded!
IPv6 porty 80/443: Network is unreachable
```

**Ocena:** porty 80 i 443 są dostępne przez IPv4. Test IPv6 jest nierozstrzygający, bo stacja nie ma trasy IPv6 (ograniczenie po stronie klienta, a nie awaria serwera).

## 5. Odpowiedź HTTP

**Polecenia:** `curl -I -4 https://example.com`, `curl -I -4 http://example.com`

**Wynik (skrót):**
```
HTTPS: HTTP/2 200, server: cloudflare, cf-cache-status: HIT
HTTP:  HTTP/1.1 200 OK, server: cloudflare, cf-cache-status: HIT
```

**Ocena:** serwer zwraca `200` na obu portach, odpowiedzi pochodzą z cache Cloudflare (`HIT`).

## Wniosek

**Strona działa poprawnie z naszej stacji (DNS, sieć i aplikacja są w porządku), więc zgłoszonego problemu nie udało się odtworzyć i jego przyczyna leży po stronie sieci lub środowiska użytkownika, a nie w DNS ani w aplikacji.**

## Propozycja działań

1. Poprosić użytkownika o wynik `dig example.com` i `curl -I https://example.com` ze swojej maszyny oraz o treść komunikatu błędu z przeglądarki.
2. Sprawdzić u użytkownika wpisy w `/etc/hosts` (lokalne nadpisanie) i wyczyścić cache DNS (`resolvectl flush-caches`) oraz cache przeglądarki.
3. Sprawdzić, czy problem występuje przez IPv6 (`curl -6`) i w innej sieci (np. przez hotspot z telefonu).
4. Zweryfikować informację o poczcie, bo `example.com` ma null MX i poczty nie przyjmuje.
