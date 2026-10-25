| Narzędzie | Długość wyjścia (w liniach) | Czy widać TTL | Czy widać status odpowiedzi | Czy widać adres serwera, który odpowiedział |
|-----------|-----------------------------|---------------|-----------------------------|---------------------------------------------|
| dig       |              21             |     TAK       |        TAK                  |                     TAK                     |
| host      |               5             |     NIE       |        NIE                  |                     NIE                     |
| nslookup  |              13             |     NIE       |        NIE                  |                     TAK                     |

##### dig:
1. Zwraca znacznie wieczej informacji niż dwa pozostałe narzędzia.
2. (domyslnie zwraca informacjie o TCP/4 -> jest to typ A)
3. Jedna nazwa domeny moze mieć kilka adresow (resolver bedzie zwracał rozne adresy -> rozkładanie obciążenia)


##### host:
1. Zwraca jedynie adresy odpowiadajace nazwie domeny.
2. Domysllnie zwraca informacjie dla A, AAAA, MX(IPv/4, IPv/6, poczta)

#### nslookup:
1. Zwraca to co host + nazwa servera. 


#### Wnioski:
```
dig jest przydatnym narzędziem gdzy potrzebujemy wiecej informacji np przy rozwiazywaniu porblemow.
host i nslookup to proste porgramy słuzące do szybkiedo spawdzenia adresu na podstawie domeny. 
serverem odpowiadającym jest resolver (stubresolver)
