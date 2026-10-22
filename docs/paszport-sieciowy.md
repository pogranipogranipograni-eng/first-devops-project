# Paszport sieciowy: konrad-X870-Pro-RS-WiFi

## Polecenie `ip`

`ip` to główne narzędzie w Linuxie do podglądu i zmiany ustawień sieci.
Samo nic nie robi. Potrzebuje **obiektu** (na co chcę patrzeć),
a opcjonalnie jeszcze akcji. Jeśli nie podam akcji, `ip` po prostu wyświetla listę obiektu.

```
ip [OPCJE] OBIEKT [AKCJA]
```

| Obiekt | Skrót | Co pokazuje | Warstwa OSI | Warstwa TCP/IP |
|---|---|---|---|---|
| `link` | `l` | interfejsy sieciowe, ich adresy MAC i stan (UP/DOWN) | 2 (łącza danych) | 1 (dostępu do sieci) |
| `address` | `a`, `addr` | adresy IP przypisane do interfejsów | 3 (sieciowa) | 2 (internetowa) |
| `route` | `r` | tablica routingu, brama domyślna | 3 (sieciowa) | 2 (internetowa) |
| `neighbour` | `n`, `neigh` | tablica ARP (IP i MAC pobliskich urządzeń) | 2/3 | 1/2 |
| `rule` | `ru` | reguły routingu zależnego od polityki | 3 (sieciowa) | 2 (internetowa) |
| `netns` | | przestrzenie nazw sieci (używane przez kontenery) | - | - |

Warstwy TCP/IP numeruję od dołu: 1 dostępu do sieci, 2 internetowa, 3 transportowa, 4 aplikacji.

Przydatna opcja: `-br` (brief) wypisuje jedną linię na interfejs.

## 1. Interfejsy sieciowe

Samo `ip a` pokazuje w jednym wyjściu zarówno adresy MAC, jak i adresy IP,
ale wypisuje wiele linii na interfejs i jest mniej czytelne. Dlatego używam
dwóch krótkich poleceń: `ip -br l` (adresy MAC, stan) oraz `ip -br a`
(adresy IP).

### Adresy MAC i stan

```
$ ip -br l
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
enp8s0           UP             9c:6b:00:c2:6e:05 <BROADCAST,MULTICAST,UP,LOWER_UP>
virbr0           DOWN           52:54:00:f0:a3:99 <NO-CARRIER,BROADCAST,MULTICAST,UP>
wlp7s0           DOWN           ac:f2:3c:62:22:99 <BROADCAST,MULTICAST>
docker0          DOWN           12:3c:32:69:fa:74 <NO-CARRIER,BROADCAST,MULTICAST,UP>
br-d972e1b386a5  DOWN           aa:40:f4:dd:88:09 <NO-CARRIER,BROADCAST,MULTICAST,UP>
```

- `lo` to interfejs pętli zwrotnej (komputer rozmawia sam ze sobą). Jego MAC to same zera, a stan UNKNOWN jest dla niego normalny.
- `enp8s0` to przewodowa karta Ethernet. Jako jedyna ma stan UP, więc to prawdziwe połączenie tej maszyny.
- `virbr0` to wirtualny mostek utworzony przez libvirt (maszyny wirtualne). Ma stan DOWN i NO-CARRIER, bo nic do niego teraz nie jest podłączone.
- `wlp7s0` to karta Wi-Fi. Ma stan DOWN i nie ma flagi `UP`, więc jest wyłączona albo nieużywana.
- `docker0` to domyślny mostek Dockera. DOWN i NO-CARRIER oznaczają, że żaden kontener go teraz nie używa.
- `br-d972e1b386a5` to mostek Dockera dla sieci `minikube`. Też jest DOWN, bo klaster minikube nie działa.

### Adresy IP

```
$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp8s0           UP             192.168.1.243/24 fe80::f083:f1bc:912b:e4ed/64
virbr0           DOWN           192.168.122.1/24
wlp7s0           DOWN
docker0          DOWN           172.17.0.1/16
br-d972e1b386a5  DOWN           192.168.49.1/24
```

- `lo` ma `127.0.0.1/8` (IPv4) i `::1/128` (IPv6). Te adresy działają tylko wewnątrz tej maszyny.
- `enp8s0` ma `192.168.1.243/24`. To prywatny adres z mojej sieci domowej, a `/24` oznacza sieć 192.168.1.0 z 254 możliwymi hostami. Adres `fe80::.../64` to IPv6 link-local, używany tylko w lokalnym segmencie sieci.
- `virbr0` ma `192.168.122.1/24`, domyślną sieć libvirt dla maszyn wirtualnych.
- `wlp7s0` nie ma adresu, co pasuje do stanu DOWN.
- `docker0` ma `172.17.0.1/16`, domyślną sieć Dockera.
- `br-d972e1b386a5` ma `192.168.49.1/24`, czyli sieć minikube

## 2. Tablica routingu

Tablica routingu mówi komputerowi, którędy wysłać pakiet do danego adresu.
Dla każdego pakietu system wybiera trasę, która najdokładniej pasuje do adresu
docelowego (najdłuższy prefiks). Jeśli nic nie pasuje, używana jest trasa `default`.

```
$ ip -br route
default via 192.168.1.1 dev enp8s0 proto dhcp src 192.168.1.243 metric 100
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown
192.168.1.0/24 dev enp8s0 proto kernel scope link src 192.168.1.243 metric 100
192.168.49.0/24 dev br-d972e1b386a5 proto kernel scope link src 192.168.49.1 linkdown
192.168.122.0/24 dev virbr0 proto kernel scope link src 192.168.122.1 linkdown
```

Znaczenie słów w tablicy:

| Słowo | Znaczenie |
|---|---|
| `via` | adres następnego przeskoku (router, do którego wysyłam pakiet) |
| `dev` | nazwa interfejsu (device), przez który pakiet wychodzi |
| `proto` | kto dodał trasę: `dhcp` (serwer DHCP), `kernel` (jądro, automatycznie przy nadaniu adresu) |
| `scope link` | cel jest bezpośrednio w sieci lokalnej, bez routera pośrodku |
| `src` | adres IP tego komputera, używany jako nadawca w tej trasie |
| `metric` | priorytet trasy, mniejsza liczba wygrywa, gdy jest kilka tras do tego samego celu |
| `linkdown` | interfejs jest DOWN, trasa istnieje, ale nie działa |

### Opis każdej linii

**`default via 192.168.1.1 dev enp8s0 proto dhcp src 192.168.1.243 metric 100`**
Trasa domyślna. Trafia tu cały ruch, który nie pasuje do żadnej innej linii,
czyli np. internet. Pakiety wychodzą przez interfejs `enp8s0` do routera
`192.168.1.1`. Trasę dodał serwer DHCP (`proto dhcp`), a jako nadawcy użyję
adresu `192.168.1.243`. Metryka 100 to priorytet, który miałby znaczenie, gdyby
było więcej aktywnych interfejsów z własną trasą domyślną.

**`172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown`**
Sieć domyślnego mostka Dockera. Trasę utworzyło jądro samo, gdy `docker0`
dostał adres. Cel jest bezpośrednio na mostku (`scope link`), bez routera.
`linkdown` znaczy, że trasa teraz nie działa, bo żaden kontener nie jest
podłączony.

**`192.168.1.0/24 dev enp8s0 proto kernel scope link src 192.168.1.243 metric 100`**
Moja sieć lokalna (domowa). Ruch do urządzeń z tej sieci idzie bezpośrednio
przez `enp8s0`, bez routera pośrodku. Trasa powstała automatycznie razem z
nadaniem adresu `192.168.1.243/24`. Ta linia nie ma `linkdown`, bo interfejs
działa.

**`192.168.49.0/24 dev br-d972e1b386a5 proto kernel scope link src 192.168.49.1 linkdown`**
Sieć minikube (mostek Dockera). Trasa jest nieaktywna (`linkdown`), bo klaster
minikube teraz nie działa.

**`192.168.122.0/24 dev virbr0 proto kernel scope link src 192.168.122.1 linkdown`**
Sieć libvirt dla maszyn wirtualnych. Też `linkdown`, bo żadna maszyna wirtualna
nie jest teraz podłączona.

**Wniosek:** tylko dwie trasy działają (`default` i sieć lokalna
`192.168.1.0/24`), obie przez `enp8s0`. Pozostałe trzy to sieci wirtualne,
nieaktywne, bo nic ich teraz nie używa.

## 3. Brama domyślna

Bramę domyślną widać w linii zaczynającej się od default, a adres po via to właśnie ona (192.168.1.1).
```
default via 192.168.1.1 dev enp8s0 proto dhcp src 192.168.1.243 metric 100
```

## 4. Adres publiczny
```
curl -4 ifconfig.me
5.xxx.xxx.x4   (zakodowany adres publiczny just in case)
 ```

## 5.Tabela Gniazd nasłuchujacych

ss -tulpn

### Przełączniki `ss -tulpn`

| Flaga | Znaczenie |
|---|---|
| `-t` | pokaż gniazda TCP |
| `-u` | pokaż gniazda UDP |
| `-l` | tylko nasłuchujące (listening), czyli czekające na połączenia |
| `-p` | pokaż proces, który otworzył gniazdo (pełne dane tylko z `sudo`) |
| `-n` | liczby zamiast nazw (port `22` zamiast `ssh`) |

### Kolumny w wyjściu `ss`

| Kolumna | Znaczenie |
|---|---|
| `Netid` | typ gniazda: `tcp` albo `udp` |
| `State` | stan gniazda: `LISTEN` (TCP czeka na połączenia), `UNCONN` (UDP otwarte, czeka na pakiety) |
| `Recv-Q` | dla `LISTEN`: połączenia czekające w kolejce na odebranie przez program; dla pozostałych: bajty odebrane, ale jeszcze nieodczytane. Normalnie `0` |
| `Send-Q` | dla `LISTEN`: maksymalna długość tej kolejki (backlog); dla pozostałych: bajty wysłane, ale niepotwierdzone |
| `Local Address:Port` | adres IP i port na tej maszynie, na którym gniazdo nasłuchuje |
| `Peer Address:Port` | adres zdalnej strony; przy nasłuchujących zawsze `0.0.0.0:*` lub `[::]:*` ("ktokolwiek"), bo nikt jeszcze nie jest połączony |
| `Process` | program, PID i deskryptor pliku (`fd`), np. `users:(("joplin",pid=8122,fd=80))` |

### Jak czytać adres nasłuchu

| Zapis | Znaczenie |
|---|---|
| `127.0.0.1`, `::1` | tylko ta maszyna (loopback) |
| `0.0.0.0`, `[::]`, `*` | wszystkie interfejsy |
| `192.168.122.1` | konkretny adres IP tej maszyny |
| `[::ffff:127.0.0.1]` | adres IPv4 zapisany w formie IPv6 (gniazdo IPv6 obsługujące też IPv4) |
| `127.0.0.53%lo`, `0.0.0.0%virbr0` | `%` oznacza gniazdo przypięte do konkretnego interfejsu (`lo`, `virbr0`) |

```


Netid   State    Recv-Q   Send-Q          Local Address:Port      Peer Address:Port   Process                                        
udp     UNCONN   0        0                     0.0.0.0:35530          0.0.0.0:*                                                     
udp     UNCONN   0        0                     0.0.0.0:5353           0.0.0.0:*                                                     
udp     UNCONN   0        0               192.168.122.1:53             0.0.0.0:*                                                     
udp     UNCONN   0        0                  127.0.0.54:53             0.0.0.0:*                                                     
udp     UNCONN   0        0               127.0.0.53%lo:53             0.0.0.0:*                                                     
udp     UNCONN   0        0              0.0.0.0%virbr0:67             0.0.0.0:*                                                     
udp     UNCONN   0        0                        [::]:5353              [::]:*                                                     
udp     UNCONN   0        0                        [::]:42461             [::]:*                                                     
tcp     LISTEN   0        1024                127.0.0.1:30000          0.0.0.0:*       users:(("cef_server",pid=10620,fd=82))        
tcp     LISTEN   0        32              192.168.122.1:53             0.0.0.0:*                                                     
tcp     LISTEN   0        4096            127.0.0.53%lo:53             0.0.0.0:*                                                     
tcp     LISTEN   0        4096               127.0.0.54:53             0.0.0.0:*                                                     
tcp     LISTEN   0        4096                127.0.0.1:35337          0.0.0.0:*                                                     
tcp     LISTEN   0        511                 127.0.0.1:2658           0.0.0.0:*       users:(("joplin",pid=8122,fd=80))             
tcp     LISTEN   0        4096                127.0.0.1:631            0.0.0.0:*                                                     
tcp     LISTEN   0        4096       [::ffff:127.0.0.1]:63342                *:*       users:(("idea",pid=10321,fd=43))              
tcp     LISTEN   0        50         [::ffff:127.0.0.1]:30001                *:*       users:(("idea",pid=10321,fd=540))             
tcp     LISTEN   0        50         [::ffff:127.0.0.1]:52829                *:*       users:(("jetbrains-toolb",pid=4442,fd=482))   
tcp     LISTEN   0        4096                    [::1]:631               [::]:*                                                     
tcp     LISTEN   0        4096       [::ffff:127.0.0.1]:37361                *:*       users:(("jetbrains-toolb",pid=4442,fd=494))   
```


| Proto | Port | Adres nasłuchu | Proces / usługa | Dostępne spoza maszyny? |
|---|---|---|---|---|
| TCP | 30000 | 127.0.0.1 | `cef_server` | nie, tylko lokalnie |
| TCP | 2658 | 127.0.0.1 | `joplin` | nie, tylko lokalnie |
| TCP | 63342 | 127.0.0.1 (IPv4-mapped) | `idea` (IntelliJ) | nie, tylko lokalnie |
| TCP | 30001 | 127.0.0.1 (IPv4-mapped) | `idea` (IntelliJ) | nie, tylko lokalnie |
| TCP | 52829 | 127.0.0.1 (IPv4-mapped) | `jetbrains-toolbox` | nie, tylko lokalnie |
| TCP | 37361 | 127.0.0.1 (IPv4-mapped) | `jetbrains-toolbox` | nie, tylko lokalnie |
| TCP | 35337 | 127.0.0.1 | nieznany (bez sudo) | nie, tylko lokalnie |
| TCP | 631 | 127.0.0.1 i ::1 | prawdopodobnie CUPS (drukowanie) | nie, tylko lokalnie |
| TCP/UDP | 53 | 127.0.0.53 i 127.0.0.54 | prawdopodobnie `systemd-resolved` (lokalny DNS) | nie, tylko lokalnie |
| TCP/UDP | 53 | 192.168.122.1 | prawdopodobnie DNS libvirt (`dnsmasq`) | tylko z sieci `virbr0` (maszyny wirtualne) |
| UDP | 67 | 0.0.0.0%virbr0 | prawdopodobnie DHCP libvirt | tylko z sieci `virbr0` |
| UDP | 5353 | 0.0.0.0 i [::] | prawdopodobnie mDNS (np. `avahi`) | tak, z sieci lokalnej |
| UDP | 35530 | 0.0.0.0 | nieznany (bez sudo) | tak, z sieci lokalnej |
| UDP | 42461 | [::] | nieznany (bez sudo) | tak, z sieci lokalnej (IPv6) |


## 6. Które usługi są dostępne spoza maszyny

### Metoda

Szukam w liście nasłuchujących gniazd (`ss -tulpn`) takich, których
**Local Address pokrywa się z adresem działającego interfejsu sieciowego**.
Działa tylko jeden interfejs (`enp8s0`, karta Ethernet, stan UP), więc
sprawdzam, które gniazda przyjmują pakiety zaadresowane na jego adresy.

Adresy interfejsu `enp8s0` (z `ip -br a`):

| Adres | Rodzaj |
|---|---|
| `192.168.1.243/24` | IPv4 |
| `fe80::f083:f1bc:912b:e4ed/64` | IPv6 link-local |

Gniazdo pasuje do adresu interfejsu na dwa sposoby:

1. **Konkretny adres**: Local Address jest równy adresowi interfejsu
   (np. `192.168.1.243:port`).
2. **Adres uniwersalny**: `0.0.0.0` (IPv4) lub `[::]` (IPv6) oznacza
   "wszystkie adresy tej maszyny", więc obejmuje też adresy z tabeli wyżej.

**Zastrzeżenie (kolejność dopasowania):** system najpierw szuka gniazda
z konkretnym adresem. Jeśli pakiet zaadresowany na `192.168.1.243:port`
pasuje do gniazda konkretnego, trafia do niego i **nie trafia** do
uniwersalnego `0.0.0.0:port` o tym samym porcie i protokole. Gniazdo uniwersalne
obsługuje tylko to, czego nie przechwyciło gniazdo konkretne.

### Gniazda konkretne na adresie `enp8s0`

Brak. Żadne gniazdo nie nasłuchuje na `192.168.1.243` ani na
`fe80::f083:f1bc:912b:e4ed`, więc nic nie przechwytuje ruchu przed
gniazdami uniwersalnymi i wszystkie z tabeli niżej obsługują pakiety w całości.

### Gniazda uniwersalne obejmujące adres `enp8s0`

| Proto | Local Address:Port | Obejmuje adres `enp8s0` | Przechwycone przez konkretne? |
|---|---|---|---|
| UDP | `0.0.0.0:5353` | `192.168.1.243` | nie |
| UDP | `0.0.0.0:35530` | `192.168.1.243` | nie |
| UDP | `[::]:5353` | `fe80::f083:f1bc:912b:e4ed` | nie |
| UDP | `[::]:42461` | `fe80::f083:f1bc:912b:e4ed` | nie |

### Gniazda, które nie spełniają kryterium

| Local Address | Dlaczego odpada |
|---|---|
| `127.0.0.1`, `::1`, `[::ffff:127.0.0.1]`, `127.0.0.53%lo`, `127.0.0.54` | loopback (`lo`), nie jest to adres `enp8s0` |
| `192.168.122.1` (TCP i UDP 53) | adres interfejsu `virbr0`, który jest DOWN |
| `0.0.0.0%virbr0` (UDP 67) | przypięte do `virbr0` (`%`), nie przyjmuje ruchu z `enp8s0` |

### Wniosek

Z sieci lokalnej (`192.168.1.0/24`) dostępne są **potencjalnie** tylko cztery
gniazda UDP na adresach uniwersalnych: 5353 (IPv4 i IPv6), 35530 i 42461.
Żadne gniazdo TCP nie spełnia kryterium.

Wniosek opiera się na adresach nasłuchu. Firewalla nie sprawdzałem, więc
te gniazda mogą być w praktyce zablokowane.
