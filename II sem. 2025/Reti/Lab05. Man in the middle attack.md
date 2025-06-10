 > *Laboratorio del 08/04/2025*

Non posso avere host che sono nella stessa LAN se sono in broadcast diversi, perché per la comunicazione serve il MAC address, conosciuto attraverso il nome, che viene tradotto prima in IP e poi in MAC address attraverso una ARP request, mandata in broadcast.
Il dominio di broadcast non è isolato da switch e host. I primi rispetto ai secondi però evitano domini di conflitto.
Le hub sono dispositivi che ripetono il traffico su tutte le proprie porte. Gli switch sono più intelligenti: se ad una rete collego uno switch, se mi metto in ascolto non vedo tutto il traffico che viene generato su questa.
In realtà le cose sono comunque un po' più complesso. Tutti questi meccanismi sono meccanismi infatti dinamici. Quanto però tali servizi sono effettivamente affidabili?
L'assunzione di base che faremo oggi è che l'attaccante è nello stesso dominio di broadcast della rete attaccata.

Per realizzare un man in the middle l'obiettivo che si vuole raggiungere è la seguente:
![](Images/Pasted%20image%2020250408163534.png)
- Tutto il traffico generato da *Alice* non può passare direttamente verso nessun host, ma viene ascoltato da qualcuno "*che sta nel mezzo*" (**man in the middle half duplex**)
![](Images/Pasted%20image%2020250408163640.png)
- In questo caso il traffico viene intercettato in entrambe le direzioni (**full duplex**)
Se le comunicazioni tra i due host sono cifrati end to end, vedo poco, altrimenti vedo tutto. 
Dal punto di vista informatico, in questo modo riesco a violare:
- confidenzialità (riesco a vedere il traffico)
- integrità (modifico il traffico)
- disponibilità (rendo impossibile la comunicazione tra due host)
Se l'attaccante si limita alle prime due, gli host non si accorgeranno della presenza del nodo intermedio, nonostante aggiunga qualche millisecondo di latenza. 
A seconda della tipologia d'attacco può essere che se qualcuno monitori a basso livello la rete si può provare che qualcosa non vada.
### Reference network
![](Images/Pasted%20image%2020250408164608.png)
# ARP spoofing
- Obiettivo: intercettare le comunicazioni tra alice e bob
- Riuscire a convincere il sistema operativo di Alice a mandare tutti i pacchetti che manda a Bob a mandarli ad Eve
Alice, per mandare i pacchetti a Bob, sa come mandare pacchetti attraverso una cache locale, dove sono memorizzate ARP request precedenti e quindi l'indirizzo MAC, e quindi l'indirizzo IP, collegato al nome DNS *bob*.
La cosa interessante è che si possono mandare ARP reply anche se nessuno le chiede: possono sfruttarle in maniera tale da mandare tanti messaggi nei quali collego l'indirizzo MAC malevolo al nome che ci interessa fino a che il sistema operativo "non ci casca".
Per farlo utilizzeremo uno strumento chiamato ***ettercap***. Di per sé è uno strumento obsoleto (versione aggiornata: ***bettercap***), ma consente di fare attacchi anche in rete locali vere e se non viene usato correttamente potrebbe creare **GROSSI** malfunzionamenti (non utilizzatelo per LAN fisiche quindi).
Per mandare l'attacco avanti quindi utilizzeremo il seguente comando:
```
ettercap -T -M apr /192.168.1.1//
```
- `-M` sta per "man in the middle"
- `arp` sta per il tipo di attacco MITM che si vuole eseguire
- La prima parte tra gli slash `/` indica l'obiettivo primario
- Se la seconda parte tra slash `/` è vuota, significa che tutti gli altri nodi presenti sul broadcast sono un obiettivo secondario
- Così sono in grado di intercettare tutte le comunicazioni che escono ed entrano dall'host *Alice*
Da queste comando succede questo:
![](Images/Pasted%20image%2020250408170542.png)
Eve sta infatti cercando di dire sia ad alice che a bob che gli IP contenuti nella propria tabella di routing corrispondono al proprio indirizzo MAC (`ba:de:7e:ba:de:7e`):
##### Tabella ARP di Alice dopo l'attacco
![](Images/Pasted%20image%2020250408170927.png)
A questo punto, se da Alice provo a fare ping a Bob, tutto funziona, ma l'attaccante riesce ad intercettare tali pacchetti prima di inoltrarli a Bob e viceversa.
Nel momento in cui Eve termina l'attacco, permette attraverso altre reply alle tabelle degli host attaccati di ritornare alla situazione precedente.
##### Come ci si difende?
Non c'è molto che è possibile fare: qualunque protocollo che non abbia modo di autenticarsi in maniera applicativa, rimane sensibile a questo tipo di attacchi, essendo configurazioni dinamiche basate sulla fiducia.
Una cosa che è possibile fare è passare da un popolamento dinamico ad uno statico della tabella ARP, in maniera tale che si è sicuri che tale entry non possa essere cambiata.
```
apr -s 193.168.1.2 b0:bb:0b:b0:bb:0b
```
Tale entry non può inoltre scadere; nel momento in cui faremo ARP spoofing, le reply di Eve verranno ignorate in quanto, come detto in precedenza, tale corrispondenza tra il MAC address e l'indirizzo IP è stata immessa manualmente.
Tuttavia, non esiste una rete fisica completamente statica, in quanto richiederebbe uno sforzo inimmaginabile. Altre contromisure possono essere sistemi di monitoraggio (sistemi simili sono a livello degli internet access point e switch di fascia medio-alta).
# Port stealing
- Possiamo fare qualcosa di simile non a livello host, ma alla tabella di forwarding dello switch: convincere che alla porta a cui è associato Bob è in realtà associato il nostro host malevolo.
- Lo switch sa quali MAC address sono associati alle porte in maniera dinamica: a switch acceso, se degli host comunicano attraverso il broadcast lo switch riceve frame ethernet con MAC address che va ad inserire nella propria tabella in maniera dinamica, associando l'indirizzo MAC sorgente alla porta da cui l'ha ricevuto
E' possibile quindi usare *ettercap* per mandare frame ethernet allo switch dove il MAC address assegnato alla porta di altri host viene assegnato al MAC address malevolo:
```
ettercap -T -M port /192.168.1.1//
```
Se si invia il comando infatti, frame ethernet con MAC address sorgente degli host vengono mandati allo switch tramite Eve, che ovviamente è collegato ad una sola porta. Tutti i MAC address vengono quindi associati, ad esempio, alla porta 3.
Nel momento in cui Alice prova a comunicare verso Bob, quindi, lo switch invia il messaggio ad Eve in quanto nella sua tabella di inoltro il MAC address di Bob è associato alla porta dov'è collegato l'attaccante.
Per fare un full duplex, adesso Eve dovrebbe mandare a Bob il frame ottenuto, ma l'inoltro non avviene in quanto la porta associata a Bob è in r
In generale, se ho una rete per la quale Bob produce traffico "per fatti suoi", la porta di Bob oscilla in continuazione, quindi tale inoltre potrebbe funzionare, ma non è una cosa su cui contare, soprattutto in reti in cui non c'è tanto traffico.
Alice quindi: non riesce a pingare Bob e non riesce a risolvere il suo nome in quanto non riesce a contattare il DNS.
Tale attacco quindi ha probabilità più basse di successo, ma se vogliamo causare un problema ad una rete locale facendo impazzire uno switch o un MAC address specifico è molto utile.
Nel momento in cui l'attacco termina, nel momento in cui gli host rigenerano traffico, tutto funzionerà di nuovo correttamente.
##### Soluzioni
Alcuni switch consentono di settare manualmente le porte alle quali sono associati alcuni MAC address, ed è una cosa che si fa molto spesso, anche se rimane una soluzione complessa ed onerosa da implementare.
# DHCP poisoning
Se tutto viene configurato staticamente, chiunque generi traffico broadcast questo viene comunque ricevuto dall'host dell'attaccante e potrebbe essere sfruttato in maniera malevola. Quando un computer viene acceso, infatti, se le interfacce di rete vengono configurate in maniera dinamica, la richiesta DHCP da esso mandata viene vista in broadcast. Se riceve diverse risposte, non sa neanche quale sia quella reale.
Possiamo usare quindi ettercap per far finta di essere un server DHCP:
```
ettercap -T -M dhcp:192.168.1.5-10/255.255.255.0/192.168.1.3
```
- Questo permette di dire che il server DNS che le altre macchine possono utilizzare per il resolve dei nomi è quello con l'IP dell'host malevolo.
Con questa modalità di attacco ettercap non sta proattivamente mandando traffico, ma rimane in ascolto. Nel momento in cui viene mandata una richiesta DHCP, l'host che la manda riceverà due risposte: una dal vero DNS e una da Eve. Vince essenzialmente chi arriva prima tra questi due messaggi: se siamo fortunati, la nostra reply vince su quella del vero DNS e quindi l'host viene configurato come richiesto dal comando ettercap.
A questo punto, una volta acceso il fake server DNS, questo può ascoltare le comunicazioni tra Alice e Bob.
In linea di principio sarebbe stato possibile anche cambiargli il default gateway dell'host, così da intercettare tutto il suo traffico, e tante altre cose.
Tra le contromisure è ovviamente presente l'evitare una configurazione dinamica, ma non è una configurazione molto pratica

Tutti i meccanismi utilizzati per il MitM sfruttano configurazioni dinamiche non sicure all'interno delle reti locali. Per questo è consigliato mantenere reti locali molto piccole o utilizzare protocolli sicuri e VPN.