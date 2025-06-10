 > *Laboratorio del 04/03/2025*

***Marionnet*** prevede una console che ci permette di creare macchine virtuale, route, switch, connessioni ecc.
Prevede inoltre due tipi di connessione:
- cavi dritti: connettono una scheda di rete ad uno switch
- cavo cross: due host o due switch tra di loro in maniera diretta
Se la connessione avviene con un cavo sbagliato ovviamente non funziona nulla.

 > **Obiettivo:** creare una connessione per due nodi attraverso uno switch.

Ogni cavo avrà un nome e due numeri tra parentesi quadre (una per l'host e una per lo switch). Il nostro obiettivo sarà eseguito attraverso il protocollo ARP. Vedremo di configurarare la nostra rete per vedere come funzionano le query ARP.
1. **Creo due macchine**, ognuna con il proprio nome
2. **Creo uno switch** e ne specifico le sue porte. L'impostazione "Show VDE terminal" mi consente di aprire un terminale dove andare a vedere come sta funzionando lo switch, mentre "Startup configuration" ci permette di andare ad indicare uno script da eseguire nel momento in cui lo switch sarà avviato.
   Nel nostro caso utilizzeremo solo il VDE.
3. **Creiamo i cavi dritti** per collegare i due host allo switch
**Risultato**:
![](../../Pasted%20image%2020250304162012.png)
4. Una volta creato il collegamento, possiamo far partire il tutto attraverso il bottone "Start all"
Possiamo quindi incominciare a lavorare attraverso `arping` da una parte, il quale ci permette quindi a fare delle query ARP, e attraverso `tcpdump` accogliere tali richieste.
` ip link show dev eth0` ci permette di visualizzare le informazioni della scheda di rete. Nel caso in cui lo ***state*** sia in DOWN, la scheda di rete bisogna avviarla.
LINK host network, ROUTE lavora sempre a livello di rete ma con le tabelle di routing, ADDR lavora a livello di rete
`ip link set dev eth0 up` accende la scheda di rete.

#### Arping
Serve per creare delle query ARP. Permette di fare delle query da un lato, così da poter analizzare cosa gira sulla rete dall'altro (quindi metteremo l’interfaccia di rete in attività promiscua per catturare campioni di traffico) attraverso il comando `tcpdump`.
Sintassi:
```
arping [-0][-i, <iface>]
```
Se la scheda di rete non ha un indirizzo di rete configurato, la prassi è quella di utilizzare un indirizzo convenzionale 0.0.0.0. Questo avviene attraverso l'opzione -0.
-i ci specifica l'interfaccia da utilizzare (e quindi la schede di rete da utilizzare, nel nostro caso -i eth0)
-B ci permette di recuperare un MAC address dato un indirizzo IP che voglio andare a risolvere. Se la macchina alla quale vogliamo recuperare il MAC address non ha un indirizzo IP, utilizzeremo l'IP 255.255.255.255
### TCPdump
Consente di capire cosa gira sulla rete, intercettando pacchetti di dati ecc.
```
tcpdump [-c count][-e algo:secret][-i interface][-X][-e][-n]
```
Può raccogliere dati di traffico infinito, ma con l'opazione -c ci permette di indicare quanti pacchetti vogliamo raccogliere.
-e permette di visualizzare le informazioni a livello host network.
Per avere cifratura a livello di rete possiamo utilizzare l'opzione -E, che ci permette di specificare l'algoritmo di decrittazione.
L'opzione -i specifica l'interfaccia di rete. E' molto preziosa per indicare, ad esempio, la porta dalla quale raccogliere pacchetti in un router con tante porte.
L'opzione -n permette di lavorare in modalità puramente numerica (senza tradurre quindi gli IP attraverso nomi assegnatigli)
L'opzione -F ci permette invece di lavorare su file, mentre -r ci permette di leggere contenuti da file. Infine -X ci permette di visualizzare i contenuti dei pacchetti attraverso codice ASCII.
Nel momento in cui tcpdump viene fermato ci dà idea di quello che è stato ricevuto.
E' importante sapere che tcpdump contiene delle impostazioni di filtro, che ci permette di indicare solo i pacchetti di nostro interesse che girano in rete.
Per definire tali filtri utilizziamo dei **qualificatori**, che sono:
- host, reti e porte: 
```
host 155.185.54.156
port 22
```
- tutto ciò che si origina da o è diretto verso (`src, dst, src or dst`)
- protocolli (`ether, fddi, ip, ip6, arp, rarp, tcp, udp`)
Tali qualificatori possono essere combinati: 
```
tcp port 21
```

A questo punto quindi utilizzeremo dal terminale di h1 una query sulla rete, intercettata attraverso tcpdump utilizzando il terminale di h2:
```
arping -0 -B -i eth0
tcpdump -n -E -i eth0 arp
```

### Configurazione di un nodo
Cominciamo a configurare uno dei due nodi, partendo da h2, la macchina rispondente.
Possiamo lavorare essenzialmente in due modi:
- do la configurazione tramite un comando
```
ip addr add dev eth0 192.168.1.2
```
Tale comando parte con l'idea che una scheda di rete possa avere diversi indirizzi IP (possibile in ipv6 ma non in ipv4) e ci permette di aggiungere quindi l'indirizzo IP descritto.

Avendo adesso un'indirizzo IP, la query può essere fatta sull'indirizzo descritto e non in broadcast (evitiamo quindi di aggiungere l'impostaizone -B). Questo ci permetterà di ricevere una risposta alla nostra query. 
### Creazione di file di configurazione
Una volta che le macchine saranno spente però, di tale configurazione rimarrà nulla. Possiamo aggiungere gli IP di nostro interesse al file `/etc/hosts`(semplicemente attraverso un editor di testo da linea di comando come vim). Ovviamente questo va fatto su ogni macchina, essendo quello un file locale. Questo comunque non ci permette di evitare il fatto che a macchine spente tutto questo verrà eliminato.
Per evitare tale situazione modificheremo il file`/etc/network/interfaces`:
```
iface <iface> inet <mode>
```
Mode sarà il modo in cui verrà utilizzata l'interfaccia di rete specificata al momento dell'accensione. Può essere:
- dhcp
- loopback (interfaccia locale). lo è una scheda di rete fittizia configurata in questo modo che permette di far comunicare processi sulla stessa macchina
- static: andremo di seguito a specificare tutte le proprietà per configurare l'interfaccia, quali
	- address: indirizzo IP
	- netmask
	- network
	- broadcast
	- gateway
Per la nostra esercitazione, ci basta sapere che possiamo specificare l'indirizzo IP
Scriviamo quindi una cosa di questo tipo:
``` title="Configurazione eth0 per h1"
auto eth0
iface eth0 inet static
	address 192.168.1.1
```
Ogni volta che creo una nuova configurazione, bisogna montarla sull'interfaccia di rete attraverso il comando `ifup`.

A questo punto, da h1 mi sarà possibile uscire verso h2 in questo modo:
```
arping -0 -i eth0 192.168.1.2
```
E vedremo nel `tcpdump` che la richiesta viene inviata da `192.168.1.1`.

Se qualcosa non funziona:
- non controllare direttamente il file di configurazione
- gioca con i comandi per ispezionare lo stato
- se ci sono errori nella configurazione, i comandi `ifup` e `ifdown` potrebbero dare problemi
##### Workflow consigliato:
1. `ifup`
2. Se ci sono errori controlli il file di configurazione
3. Se l'interfaccia è parzialmente configurata, è possibile che non possiamo disattivarla con `ifdown`. Per questo deconfiguriamo l'interfaccia con comandi `ifconfig` o `ifdown`
4. in caso di conflitti critici, possiamo restartare i servizi di rete usando `service networking restart`

 > Nel caso in cui aggiungiamo una nuova scheda di rete ad una macchina e la configuriamo, non servirà collegarla allo switch in quanto la scheda di rete preesistente si occuperà di rispondere anche alle query fatte per la nuova scheda di rete.
 > Nel caso la collegassimo tramite un cavo, infatti, risponderanno entrambe alla query (ad esempio, a 9 query riceverò 18 risposte).

#### Altri comandi
```
ifconfig eth0 0 down
```
E' un comando che permette di impostare l'indirizzo IP dell'interfaccia di rete a 0 prima di spegnerla.
```
ifup eth0
```
Accende l'interfaccia di rete e ne applica le configurazioni nel caso siano state modificate.

E' permesso vedere e modificare il comportamento del kernel Linux attraverso il comando `sysctl`. 
Per controllare il comportamento della macchina nei confronti del protocollo ARP utilizziamo i seguenti comandi:
```
sysctl net.ipv4.conf.all.arp.arp_announce (di default 0)
sysctl net.ipv4.conf.all.arp.arp_ignore (di default=0)
```
Il primo decide quale indirizzo IP utilizzare per annunci ARP, mentre il secondo come risponde a richieste ARP.
Per cambiare i parametri del kernel e permettere che nella situazione delle due schede di rete collegate allo switch risponda solo quella cui facciamo le query andremo a scrivere:
```
sysctl -w net.ipv4.conf.all.arp.arp_announce=0
sysctl -w net.ipv4.conf.all.arp.arp_ignore=1
```
Il parametro `1` infatti indica che il sistema risponde solo se l'IP richiesto è configurato sulla stessa interfaccia da cui arriva la richiesta.
Il parametro `0` nella prima richiesta invece indica che usa l'indirizzo IP della sorgente senza controllare se è associato all'interfaccia di uscita.