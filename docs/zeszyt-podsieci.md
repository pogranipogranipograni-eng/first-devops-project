## Zeszyt podsieci

### Parametry sieci przyjmyje:

1) maska binarnie
2) maska dziesietnie
3) adres sieci	
4) adres broadcast	ostatni adres bloku, wszystkie bity hosta = 1 (Broadcast to specjalny adres, pod który wysłany pakiet trafia do wszystkich urządzeń w danej sieci naraz, a nie do jednego konkretnego.)
5) pierwszy host	adres sieci + 1 
6) ostatni host	broadcast - 1 
7) liczba hostów


```
192.168.50.77/26
1) 11111111.11111111.11111111.11000000
2) 255.255.255.192
3) 192.168.50.77/26 -> 128 + 64.     128 + 32 + 8.     32 + 16 + 2.     64 + 8 + 4 + 1 
                       11000000.     10100000.     00110010.        01001101
adres binarnie                  11000000.10101000.00110010.01001101   -> 192.160.50.77
maska binarnie                  11111111.11111111.11111111.11000000   -> 255.255.255.192
adres podsieci                  11000000.10100000.00110010.01000000   -> 192.160.50.64
ostatni adres bloku (broadcast) 11000000.10100000.00110010.01111111   -> 192.160.50.127
piewszy host                    11000000.10100000.00110010.01000001   -> 192.160.50.65
ostatni host                    11000000.10100000.00110010.01111110   -> 192.160.50.126
liczba hostow                   62

10.10.10.200/25
1) 11111111.11111111.11111111.10000000
2) 255.255.255.128
3) 10.10.10.200/25 -> 8 + 2.        8 + 2.           8 + 2.       128 + 64 + 8 
adres binarnie                  00001010.00001010.00001010.11001000
maska binarnie                  11111111.11111111.11111111.10000000
adres podsieci                  00001010.00001010.00001010.10000000
ostatni adres bloku (broadcast) 00001010.00001010.00001010.11111111
piewszy host                    00001010.00001010.00001010.10000001
ostatni host                    00001010.00001010.00001010.11111110
liczba hostow                   126

172.16.5.130/23
1) 11111111.11111111.111111110.0000000
2) 255.255.254.0
3) 172.16.5.130 -> 128 + 32 + 8 + 4.      16.     4 + 1.     0
adres binarnie                  10101100.00010000.00000101.00000000
maska binarnie                  11111111.11111111.11111110.00000000
adres podsieci                  10101100.00010000.00000100.00000000
ostatni adres bloku (broadcast) 10101100.00010000.00000101.11111111
piewszy host                    10101100.00010000.00000101.00000000
ostatni host                    10101100.00010000.00000101.11111111
liczba hostow                   510

192.0.2.9/30
1) 11111111.11111111.11111111.11111100
2) 255.255.255.152
3) 192.0.2.9 -> 11000000.00000000.00000010.00001001
adres binarnie                  11000000.00000000.00000010.00001001
maska binarnie                  11111111.11111111.11111111.11111100
adres podsieci                  11000000.00000000.00000010.00001000
ostatni adres bloku (broadcast) 11000000.00000000.00000010.00001011
piewszy host                    11000000.00000000.00000010.00001001
ostatni host                    11000000.00000000.00000010.00001010
liczba hostow                   2
```

### Podział na podsieci

W celu podziału sieci na podsieci musimy rozszerzyć maske a wiec zweikszyć prefix
do podziłu na 8 podsieci potrzebujemy 3 bitów 

```
192.168.200.0/24 
podział na osiem sieci:
192.168.200.0/27

```
| Podsieć | Parametry sieci |
|---|---|
| Podsieć 1 | Sieć: `192.168.200.0/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.1` – `192.168.200.30`, Broadcast: `192.168.200.31` |
| Podsieć 2 | Sieć: `192.168.200.32/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.33` – `192.168.200.62`, Broadcast: `192.168.200.63` |
| Podsieć 3 | Sieć: `192.168.200.64/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.65` – `192.168.200.94`, Broadcast: `192.168.200.95` |
| Podsieć 4 | Sieć: `192.168.200.96/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.97` – `192.168.200.126`, Broadcast: `192.168.200.127` |
| Podsieć 5 | Sieć: `192.168.200.128/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.129` – `192.168.200.158`, Broadcast: `192.168.200.159` |
| Podsieć 6 | Sieć: `192.168.200.160/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.161` – `192.168.200.190`, Broadcast: `192.168.200.191` |
| Podsieć 7 | Sieć: `192.168.200.192/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.193` – `192.168.200.222`, Broadcast: `192.168.200.223` |
| Podsieć 8 | Sieć: `192.168.200.224/27`, Maska: `255.255.255.224`, Hosty: `192.168.200.225` – `192.168.200.254`, Broadcast: `192.168.200.255` |

```
10.50.0.0/16
podzał na cztery podseici
10.50.0.0/10
```

| Podsieć | Parametry sieci |
|---|---|
| Podsieć 1 | Sieć: `10.50.0.0/18`, Maska: `255.255.192.0`, Hosty: `10.50.0.1` – `10.50.63.254`, Broadcast: `10.50.63.255` |
| Podsieć 2 | Sieć: `10.50.64.0/18`, Maska: `255.255.192.0`, Hosty: `10.50.64.1` – `10.50.127.254`, Broadcast: `10.50.127.255` |
| Podsieć 3 | Sieć: `10.50.128.0/18`, Maska: `255.255.192.0`, Hosty: `10.50.128.1` – `10.50.191.254`, Broadcast: `10.50.191.255` |
| Podsieć 4 | Sieć: `10.50.192.0/18`, Maska: `255.255.192.0`, Hosty: `10.50.192.1` – `10.50.255.254`, Broadcast: `10.50.255.255` |
