**Situazione iniziale**
![](Images/Pasted%20image%2020250325161338.png)

I comandi che si possono utilizzare per configurare il routing sono i seguenti:
- **Aggiungere una regola di routing verso uno specifico host**
```
route add -host <> gw <gwaddr>
ip route add <ip/32> via <gwaddr>
```
Normalmente l'interfaccia di rete utilizzata per il routing non c'è bisogno di specificarla in quanto viene presa in base al next-hop router, ma se ci sono delle ambiguità è possibile specificarlo attraverso il seguente comando:
```
ip route add <ip/32> dev <ethX>
```
- Indirizzamento verso una certa subnet
```
route add -net <net> netmask <nm> gw <gw>
ip route add <net/cidr> via <gwaddr>
```
- Immettere un gateway di default
```
route add default gw <gw>
ip route default via <gwaddr>
```
Tali comandi possono essere indicati anche all'interno del file `/etc/network/interfaces`, ad esempio:
```
iface eth0 inet static 
	address 192.168.1.1 
	netmask 255.255.255.0 
	gateway 192.168.1.254 
	post-up ip route add 192.168.2.0/24 via 192.168.1.253
```

Procediamo quindi configurando le macchine nel seguente modo:
H2
```
auto eth0
iface eth0 inet static
	address 192.168.1.254/24
auto eth1
iface eth1 inet static
	address 192.168.2.254/24
```
H1:
```
auto eth0
iface eth0 inet static
	address 192.168.1.1/24
```
Questo tipo di dicitura (/24) da all'IP il primo disponibile della rete selezionata (nel nostro caso 192.168.1.0) in quanto configuriamo prima H2
H3:
```
auto eth0
iface eth0 inet static
	address 192.168.2.1/24
```
Così facendo, H2 si comporta come un AS multi-homed: H1 e H3 infatti non possono comunicare attraverso H2, ma H2 può comunicare ad entrambi.
Per permettere questo, dobbiamo:
- aggiungere una regola di default gateway ad H1 e H3: se non c'è nessuna possibilità, passa per H2. Si fa grazie al file /etc(network)interfaces aggiungendo la seguente riga:
```
gateway 192.168.2.254 per H3
gateway 192.168.1.254 per H1 
```
In questo modo, il traffico in uscita c'è, ma non abbiamo ancora nessuna risposta, in quanto H2 non accetta ancora di far transitare del traffico che non è per sé
- abilitiamo quindi l'IP forwarding:
```
echo 1 > /proc/sys/net/ipv4/ip_forward (sol. temporanea)
sysctl -w net.ipv4.ip_forward=1 (sol. permanente)
```

Tra l'uso del gateway e l'uso di una regola specifica aggiunta all'interno del file `/etc/network/interfaces` è che il default routing gestisce anche IP che non esistono (H2 leggerebbe anche traffico da H3 verso l'IP 192.168.3.1, per esempio). Quando inizio ad avere reti relativamente complesse devo quindi definire dei cammini.