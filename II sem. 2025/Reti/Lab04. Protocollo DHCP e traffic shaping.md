 > *Laboratorio del 01/04/2025*

Ogni nodo della rete bisogna che sia configurato con:
- un IP
- una Netmask
- un gateway per comunicare con le altre macchine, anche il default
- un server DNS
Tali informazioni possono essere configurate:
- a mano
- con un meccanismo dinamico
La configurazione statica viene utilizzata quando siamo indipendenti o in un contesto simulativo. Se c'è bisogno di sincronizzazione, l'errore però cresce con il numero di nodi da configurare. Ogni volta che cambia qualcosa bisogna infatti che tale cambiamento sia consistente all'interno della rete (e quindi effettiva anche all'interno delle altre macchine).
La situazione è impossibile da gestire a livello statico con la presenza di nodi mobili.
Questo tipo di problemi vengono risolti creando un sistema centrale che gestisce il tutto in maniera dinamica. Il nodo centrale andrà a dare una configurazione a nuovi nodi che si connettono alla rete e conosce quali nodi sono connessi. Ciò permette un minimo di controllo sugli accessi alla rete, in quanto se un nodo non è autorizzato a connettersi non avrà accesso ad una configurazione all'interno di quella rete.
Ci sono una serie di protocolli per fare questo. Il più antico è il protocollo RAR. 
# Protocollo DHCP
L'idea è che il client parte senza sapere niente, viene fatta una query in broadcast per la richiesta della configurazione e il server risponde fornendogliela.
I messaggi in realtà sono di più:
- durante la fase di assegnazione il client assegna un indirizzo temporaneo al server
- il primo messaggio sarà un DHCP_DISCOVER, chiedendo se ci sono indirizzi disponibili
- DHCP:OFFER, offre una possibile configurazione
- DHCP_REQUEST richiede uno degli indirizzi richiesti
- DHCP...
Il server deve garantire che non ci siano conflitti: il server avrà una lista degli indirizzi IP che ha già occupato.
Se un client si disconnette dalla rete, il protocollo DHCP prevede una fase di release dell'indirizzo IP, ma **non è detto che succeda**. Per questo, ad ogni indirizzo viene aggiunto un **tempo di "validità"** (*lease time*). Scaduto tale tempo, il client dovrà fare il rinnovo del proprio indirizzo. Se questo non avviene, il server sa che questo indirizzo potrà essere assegnato a nuovi client.

Di solito esiste un solo server DHCP all'interno della rete. Le interazioni arrivano su un livello H2N e non attraversano nessun router. Ci sono diversi software per utilizzare tale protocollo. Nel nostro caso utilizzeremo ***DNSMasq*** (utilizzato solitamente per i router di casa, il quale offre anche la possibilità di configurare server DNS, il quale ci consente di risolvere i *nomi* degli indirizzi IP).
### Caratteristiche della configurazione DHCP
- Server DNS
- Gateway
- WINS server (per reti Microsoft)
- Lease time
Altri elementi importanti della configurazione sono una lista delle macchine note e/o un range di indirizzi da assegnare ad uno specifico nodo.
Fai riferimento a [Lab04.1 Esercizio DHCP](Lab04.1%20Esercizio%20DHCP.md) per vedere la parte pratica.

---
# Traffic shaping
Nonostante tutte le promesse di neutralità della rete, in realtà il traffico non è tutto uguale. 
Quando il traffico è nelle code di router quindi, esistono alcuni casi (sensati) in cui il router non ragiona in maniera FIFO (*first in first out*). Tipicamente questo avviene per:
- prioritizzazione del traffico
- traffico critico
- limiti di banda
Quando ho qualcosa in attesa di essere spedito nella rete decido se riscrivere la coda: questa situazione viene definita ***disciplina di coda***, e permette di scartare, riordinare o ritardare delle code.
Si dividono essenzialmente in:
- **discipline classful**: categorizzano il traffico in base a delle classi e applicano regole differenti in base alla classe. Sono organizzate in maniera gerarchica (il traffico arriva, viene classificato, vengono applicate le regole). Per utilizzare
- **discipline classless**
Le discipline di coda sono solitamente utilizzate da un handle nella forma mahor:minor
[1:53]
`tc qdisc show dev <iface>` permette di vedere le discipline di coda del dispositivo.
Sono utili per distinguere essenzialmente il traffico, ad esempio:
![](Images/Pasted%20image%2020250401180920.png)
- Questo tipo di "filtro" mi permette di indicare che il traffico destinato all'IP `192.168.1.2` è limitata, mentre le altre no.
E' possibile fare **traffic shaping** laddove abbiamo traffico **IN USCITA**.
## Token Bucket filter
Idealmente immagino di avere un secchio in cui butto dei gettoni ad un ritmo stabilito. Quando devo trasmettere del traffico, pesco il numero di gettoni da dover mandare via e trasmetto. Se non ne ho, aspetto che il secchio abbia il numero di gettoni da trasmettere prima di farlo.
Il risultato è che il traffico non può essere più veloce del tasso di arrivo dei gettoni.
Il TBF ha quindi i seguenti parametri:
- **rate**: limitazione di banda (misurata in kb/s), numero di gettoni ogni tot che andiamo ad inserire nel secchio
- **burst**: grandezza del secchio (deve essere maggiore uguale di latency per rate, altrimenti diventa un'ulteriore limitazione di banda)
- **latency**: delay tra due aggiornamenti del contenuto del secchio
Per configurarlo utilizziamo la suite `tc`:
```
tc qdisc add dev <iface>
	[root,parent <handle>] tbf
	rate <rate>
	burst <burst>
	latency <latency>
```

![](Images/Pasted%20image%2020250401181838.png)
