 > *Laboratorio del 11/03/2025*

Linux permette di associare dei link ad una specifica VLAN. E' possibile farlo tramite command line in questo modo:
```
ip link add link <physif> <virtif> type vlan id <N>
vconfig add <physif> <N>
```
Dal punto di vista di Linux, queste sono delle vere e proprie interfacce di rete, quindi sarà possibile configurarle e utilizzarle all'interno del file `interfaces`, nonostante non siano delle schede di rete.
```
auto <physif>.<N>
iface <physif>.<N> inet static
	address <ip_address>
	netmask <netmask>
	gateway <ip_addr_gateway>
```
## VDE switch
Ogni switch ha le proprie interfacce e il proprio modo di configurare le cose rispetto ad altri tipi di switch. Come detto in precedenza, in marionnet l'impostazione "Show VDE terminal" mi consente di aprire il terminale dove andare a vedere come sta funzionando lo switch, mentre "Startup configuration" ci permette di andare ad indicare uno script da eseguire nel momento in cui lo switch sarà avviato.
I comandi principali sono:
- **port**: gestione delle porte
- **vlan**: gestione delle VLAN
- **hash**: va a lavorare su quella che è la filtering table dello switch; associazioni tra MAC address noti e numeri di porte
- **help**: comando di aiuto
Se ci concentriamo sulle VLAN, ci sono 3 comandi che è essenziale sapere:
- `vlan/create <vlan number>`: creazione di una vlan
- `port/setvlan <port number> <vlan number>`: dichiarazione di porte dello switch che lavorano in modalità access (senza tag)
- `vlan/addport <vlan number> <port numeber>`: dichiarazione di porte dello switch che lavorano in modalità trunk (con tag)
Normalmente si comporta come uno switch normale, senza mettere nessun tag alle connessioni. E' possibile utilizzare entrambi comandi su una porta così da creare porte che lavorano in modalità ibrida.
Il comando `vlan/print` permette di visualizzare quali vlan sono state create e le informazioni in merito (porte assegnatigli e tipo di link usati).

 > Esercitazione odierna:
 > - H1 192.168.1.1
 > - H2 192.168.1.2

CTRL M macchina
CTRL S switch
CTRL D diretto

## VLAN via access links
![](Images/Pasted%20image%2020250311164006.png)
1. **Configurazione delle macchine**: andiamo ad assegnare ad ogni macchina il link riportato sopra attraverso il file `/etc/network/interfaces` (guarda lezione precedente)
2. Spegniamo le macchine e attacchiamo tra di loro i due switch attraverso un cavo cross
![](Images/Pasted%20image%2020250311164854.png)
Grazie a questa situazione, ci sarà possibile configurare uno solo degli switch, per poi copiare e incollare la configurazione sull'altro. Il tutto dovrebbe in questo modo funzionare.
Grazie al cavo cross, in questo momento:
- tra H1 e H2, H3 E H4 è possibile visualizzare sia query che risposte tra loro
- H3 e H4 possono vedere le query su H1 e H2 e viceversa, ma non possono ancora rispondere
Andiamo adesso a lavorare sugli switch tramite **startup configuration** e terminale VDE:
``` title="Startup configuration per S1"
vlan/create 10
vlan/create 20
port/setvlan 1 10
port/setvlan 2 20
vlan/addport 10 3
vlan/addport 20 3
```
- Creo le due VLAN
- Sulla porta 1 e 2 andiamo ad indicare che le VLAN 10 e 20 lavorano in modalità port based
- Sulla porta 3 andiamo ad indicare che comunicano entrambe la VLAN in modalità tagged
- Copiamo e incolliamo la seguente configurazione anche per S2
Facendo così abbiamo essenzialmente diviso il dominio di broadcast: H2 e H4 non possono vedere ciò che viene comunicato tra H1 e H3 e viceversa, essendo su VLAN diverse (H2 e H4 sulla VLAN 20, mentre H1 e H3 sulla VLAN 10).

==**N.B.** Colleghiamo gli switch S1 e S2 attraverso una comunicazione tag based in quanto è l'unica che ci permette di avere due connessioni VLAN sullo stesso cavo.== Se avessimo voluto usare una connessione port based anche per i due switch avremmo dovuto tirare invece due cavi su due porte diverse (vedi anche [02. Livello host to network](02.%20Livello%20host%20to%20network.md) nella sezione VLAN).
## VLAN via trunk links
Aggiungiamo adesso un terminale H5 che comunica tramite trunk links con il terminale H1 su una nuova VLAN.
Per fare ciò:
- creiamo e configuriamo H5
- colleghiamo H5 tramite cavo diretto ad S2 sulla porta 4
![](Images/Pasted%20image%2020250311182234.png)
- configuriamo S2 aggiungendo la VLAN 30 e in modalità tag aggiungendo le seguenti linee:
```
vlan/create 30
port/setvlan 4 30
vlan/addport 30 3
```
- configuriamo anche S1:
```
vlan/create 30
vlan/addport 30 1
vlan/addport 30 3
```
- La porta 1 per l'host H1 lavorerà infatti in modalità ibrida. Per questo motivo dobbiamo configurare anche una scheda di rete virtuale per la VLAN 30 su tale host:
```
auto eth0.30
iface eth0.30 inet static
	address 192.168.2.1
```
A questo punto:
- H1 e H5 possono comunicare senza che nessun altro host guardi la stessa comunicazione broadcast
- `eth0.30` risponderà anche per l'arping su `192.168.1.1` come una normale interfaccia di rete