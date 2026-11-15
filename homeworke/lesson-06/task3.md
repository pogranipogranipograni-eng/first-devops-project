# Ściągawka: typy rekordów DNS

Format rekordu: `nazwa  TTL  IN  TYP  wartość`
Przykłady używają tylko `example.com`, `example.net`, `192.0.2.0/24` i `2001:db8::/32`.

| Typ | Przykład | Zastosowanie | Pułapka |
|---|---|---|---|
| **A** | `example.com. 300 IN A 192.0.2.10` | Zamienia nazwę na adres IPv4. | Długi TTL opóźnia widoczność zmiany adresu. |
| **AAAA** | `example.com. 300 IN AAAA 2001:db8::10` | Zamienia nazwę na adres IPv6. | Wpis AAAA do hosta, który nie słucha na IPv6, psuje stronę tylko klientom z IPv6. |
| **CNAME** | `www.example.com. 300 IN CNAME example.com.` | Alias: jedna nazwa wskazuje na inną nazwę. | Nie może współistnieć z innymi rekordami na tej samej nazwie, więc nie da się go ustawić na samej domenie (`example.com`). |
| **MX** | `example.com. 300 IN MX 10 mail.example.com.` | Wskazuje serwery poczty, niższy priorytet = ważniejszy. | Wartością musi być nazwa (nie adres IP) i nie powinna wskazywać na CNAME. |
| **TXT** | `example.com. 300 IN TXT "v=spf1 ip4:192.0.2.25 -all"` | Przechowuje tekst, m.in. SPF i weryfikacje domeny. | Na jednej nazwie może być tylko jeden rekord SPF, a pojedynczy ciąg ma limit 255 znaków. |
| **NS** | `example.com. 86400 IN NS ns1.example.net.` | Wskazuje serwery autorytatywne domeny. | Lista NS w strefie musi zgadzać się z delegacją u rejestratora, inaczej część klientów dostaje stare dane. |
| **SOA** | `example.com. 3600 IN SOA ns1.example.net. hostmaster.example.com. 2026102501 7200 3600 1209600 300` | Metryczka strefy: serwer główny, kontakt, serial, czasy, TTL negatywny. | Brak zwiększenia numeru seryjnego po zmianie sprawia, że serwery zapasowe nie pobierają nowej wersji. |
| **PTR** | `10.2.0.192.in-addr.arpa. 3600 IN PTR host.example.com.` | Odwrotne zapytanie: z adresu IP na nazwę. | Leży w strefie odwrotnej, którą zarządza właściciel adresu IP (np. dostawca), a nie właściciel domeny. Oktety adresu są zapisane w odwrotnej kolejności. |
| **SRV** | `_sip._tcp.example.com. 300 IN SRV 10 60 5060 sip.example.com.` | Wskazuje host i port usługi (priorytet, waga, port, cel). | Cel musi być nazwą z rekordem A/AAAA, nie aliasem CNAME. |
| **CAA** | `example.com. 3600 IN CAA 0 issue "ca.example.net"` | Określa, które urzędy certyfikacji mogą wystawiać certyfikaty dla domeny. | Zbyt restrykcyjny lub błędny wpis blokuje wydanie certyfikatu, także dla subdomen. |

## Szybkie przypomnienie

- **Nazwa → adres:** A, AAAA
- **Alias:** CNAME
- **Poczta:** MX
- **Tekst i weryfikacje:** TXT
- **Delegacja i strefa:** NS, SOA
- **Adres → nazwa:** PTR
- **Usługa i port:** SRV
- **Bezpieczeństwo certyfikatów:** CAA
