# Network Passport: konrad-X870-Pro-RS-WiFi

Date: 2026-10-21

## 1. Network interfaces

A network interface is a point where the machine connects to a network.
It can be real hardware (Ethernet, Wi-Fi) or virtual (made by software).

### 1.1 Link layer: names, state, MAC addresses

```
$ ip -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
enp8s0           UP             9c:6b:00:c2:6e:05 <BROADCAST,MULTICAST,UP,LOWER_UP>
virbr0           DOWN           52:54:00:f0:a3:99 <NO-CARRIER,BROADCAST,MULTICAST,UP>
wlp7s0           DOWN           ac:f2:3c:62:22:99 <BROADCAST,MULTICAST>
br-d972e1b386a5  DOWN           aa:dd:b6:ac:d2:1f <NO-CARRIER,BROADCAST,MULTICAST,UP>
docker0          DOWN           52:a4:0f:dc:0c:39 <NO-CARRIER,BROADCAST,MULTICAST,UP>
```

**Comment:** `ip link` shows network interfaces (also called network devices)
at the link layer. The columns are: name, state, MAC address, flags.
A MAC address is the hardware address of an interface. It is used inside
one local network.

How to read the flags:
- `UP`: the interface is turned on in software.
- `LOWER_UP`: a physical signal is found (for example, a cable is plugged in
  and the other side answers).
- `NO-CARRIER`: the interface is on, but there is no signal.
- No `UP` flag (like `wlp7s0`): the interface is turned off in software.

What each interface is:
- `lo`: the loopback interface. The machine talks to itself through it.
  The MAC is all zeros because there is no hardware. State `UNKNOWN` is
  normal for `lo`.
- `enp8s0`: the Ethernet card. This is the only interface that is `UP` with a
  signal (`LOWER_UP`). The machine uses it to reach the real network.
- `virbr0`: a virtual bridge. The MAC prefix `52:54:00` and the network
  192.168.122.0/24 are typical for libvirt (KVM/QEMU virtual machines).
  It is `DOWN` because no virtual machine uses it now.
- `wlp7s0`: the Wi-Fi card. It is turned off, so the machine does not use Wi-Fi.
- `br-d972e1b386a5`: a bridge made by Docker for the `minikube` Docker network.
  Minikube (a tool for running a local Kubernetes cluster) uses this network
  for its node container. It is `DOWN` because the minikube cluster is not
  running now.
- `docker0`: the default Docker bridge. It is `DOWN` because no container
  is running on the default Docker network now.

### 1.2 Internet layer: IP addresses

```
$ ip -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp8s0           UP             192.168.1.243/24 fe80::f083:f1bc:912b:e4ed/64
virbr0           DOWN           192.168.122.1/24
wlp7s0           DOWN
br-d972e1b386a5  DOWN           192.168.49.1/24
docker0          DOWN           172.17.0.1/16
```

**Comment:** `ip addr` shows the IP addresses of each interface.
The number after `/` is the netmask. `/24` means the first 24 bits are the
network part (255.255.255.0). This gives 256 addresses in the network
(254 can be used by devices).

- `lo`: `127.0.0.1/8` is IPv4 and `::1/128` is IPv6. Traffic stays inside the
  machine and never goes out to the network.
- `enp8s0`: `192.168.1.243/24` is a private address in my local network.
  The router is in the same network (192.168.1.0/24).
  `fe80::.../64` is an IPv6 link-local address. It works only inside the
  local network and is created automatically.
- `virbr0`: `192.168.122.1/24` is the address of this machine in the
  virtual machine network.
- `wlp7s0`: no IP address, because the interface is off.
- `br-d972e1b386a5`: `192.168.49.1/24` is the address of this machine in the
  `minikube` Docker network. When the cluster runs, the minikube node gets an
  address in this network (usually 192.168.49.2).
- `docker0`: `172.17.0.1/16` is the default Docker network. Containers get
  addresses like 172.17.x.x, and this machine is their gateway.

### 1.3 Summary table

| Interface | State | IPv4 | IPv6 | MAC | Role |
|---|---|---|---|---|---|
| lo | UNKNOWN | 127.0.0.1/8 | ::1/128 | 00:00:00:00:00:00 | loopback, machine talks to itself |
| enp8s0 | UP | 192.168.1.243/24 | fe80::f083:f1bc:912b:e4ed/64 | 9c:6b:00:c2:6e:05 | Ethernet, link to the local network and router |
| virbr0 | DOWN | 192.168.122.1/24 | none | 52:54:00:f0:a3:99 | libvirt bridge for virtual machines |
| wlp7s0 | DOWN | none | none | ac:f2:3c:62:22:99 | Wi-Fi, turned off |
| br-d972e1b386a5 | DOWN | 192.168.49.1/24 | none | aa:dd:b6:ac:d2:1f | Docker bridge for the minikube network |
| docker0 | DOWN | 172.17.0.1/16 | none | 52:a4:0f:dc:0c:39 | default Docker bridge |

### 1.4 Docker networks

```
$ docker network ls
NETWORK ID     NAME       DRIVER    SCOPE
0f09b935e5af   bridge     bridge    local
64e6217e911d   host       host      local
d972e1b386a5   minikube   bridge    local
df48527c8ab5   none       null      local
```

**Comment:** this list shows the networks that Docker manages. It is a
different view from `ip link`: Docker names here, Linux interface names there.
- `bridge`: the default network. On the host it is the interface `docker0`.
- `minikube`: a custom network. On the host it is the interface
  `br-d972e1b386a5` (`br-` plus the first 12 characters of the network ID).
- `host`: a container uses the network of the machine directly. There is no
  separate interface for it.
- `none`: a container has no network at all, only `lo`.

### Conclusion

The machine has 6 interfaces, but only `enp8s0` is active and connected to a
real network (192.168.1.0/24). `lo` always works, but only inside the machine.
The other four (`virbr0`, `br-d972e1b386a5`, `docker0` and the Wi-Fi card
`wlp7s0`) are inactive, because there are no running containers or virtual
machines, and Wi-Fi is off.
