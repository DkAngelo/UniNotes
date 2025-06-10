 > *Lezione del 23/04/2025*

Tipicamente quando si lavora sulla rete si hanno a disposizione i protocolli TCP, UDP e altri meccanismi (*rogue socket*, permettono di bypassare il protocollo e creare datagram IP, ma si ha bisogno di essere admin). 
Per utilizzare i ***socket*** si utilizzano le API standard, e questi ci permettono di avere accesso ai protocolli descritti.
### Socket statistics
Per raccogliere informazioni sullo stack di trasporto, prassi anche di igiene informatica (ad esempio, capire quali server sono in ascolto), si utilizza **SS**, che sta per ***socket statistics***. Ha i seguenti parametri:
`ss [-parametri][-query]`
- se non si specifica nessun parametro ci dà informazioni su tutte le connessioni create
- `-t` TCP connections
- `-u` UDP connections
- `-l` socket in stato di attesa
- `-a` qualsiasi cosa
- `-p` mostra qual è il processo associato alla connessione
In output, troveremo alcuni casi con IP `0.0.0.0` e altri con `127.0.0.1`: i secondi si aspettano connessioni che arrivino da interfacce locali, mentre gli altri accettano connessioni da qualsiasi indirizzo. Molto spesso, se abbiamo un DBMS, la prima norma di igiene è quello di avere server in ascolto attraverso indirizzi `127.0.0.1`, a meno che non vogliamo che questo accetti connessioni da fuori; a questo punto, sarebbe buona prassi comunque configurare un firewall.
## Netcat
***Netcat*** permette di fare un sacco di cose simpatiche: nella sua versione più semplice, permette di collegare il suo input e output a flussi UDP o TCP.
Ha due grosse modalità di funzionamento, una per lavorare come server e una come client:
```
nc -l -p port #utilizzo server
nc hostname port #utilizzo client
```
Ha anche una modalità di funzionamento -u, che usa UDP al posto di TCP.
-n permette di non fare risoluzioni di DNS, mentre nel caso client -s permette di specificare un IP address di partenza.
***Netcat*** ci permette di collegare due macchine attraverso una rete ed eventualmente scambiare dei file:
![](Images/Pasted%20image%2020250423123030.png)
![](Images/Pasted%20image%2020250423123145.png)Essendo le connessioni TCP bidirezionali, niente ci vieta di avere il client che apre la connessione e il server che manda qualcosa. L'unica accortezza è l'opzione -q, che ci permette di chiudere la connessione dopo tot secondi dopo aver incontrato l'EOF:
![](Images/Pasted%20image%2020250423123735.png)L'opzione -c permette di eseguire un comando una volta creata una connessione, ad esempio:
```
nc -l -p 4444 -c /bin/bash #esegue
```
Tale opzione tuttavia è disponibile solo nella versione normale di Netcat, e non nella versione BSD. Per vedere quale versione abbiamo installato basta utilizzare il comando `nc -h` o `nc --version`

---
# Socket programming
Siccome la logica della applicazioni gira in user space, ma il protocollo TCP e UDP fanno parte del kernel operativo, abbiamo bisogno di una serie di librerie e funzioni che si mappano su una serie di system call: queste si chiamano ***Socket API***. BSD è lo standard di riferimento.
Ci sono tanti tipi di socket che si possono creare, ma quelli che ci interessano sono quelli **stream (TCP) e datagram (UDP)**. Quello che ci viene messo a disposizione è un handle, un file descriptor che andremo a modificare con le system call.
Dal punto di vista della programmazione, le socket sono molto eleganti. Sono implementate in C, ma con una sorta di programmazione ad oggetti. Il primo parametro delle funzioni è infatti il socket stesso con cui vogliamo lavorare:
- socket() crea un socket, ritorna il file descriptor dello stesso
- Chiamate tipiche del lato server:
	- bind() associa un socket ad un indirizzo o ad una porta
	- listen() durante l'handshake non posso aprire altre connessioni sulla stessa porta, quindi eventuali tentativi di connessioni vengono messi in una coda. Per questo, uno dei parametri di listen è la lunghezza di questa coda
	- accept() è una funzione bloccante, che permette al server di mettersi in ascolto e accettare una connessione. Ritornerà un nuovo FD.
- Lato client:
	- potrei chiamare bind anche lato client, ma di solito non si fa
	- connect() permette di far partire l'handshake e connettersi al server
	- read() e write() leggo e scrivo sul socket
- close() chiude la connessione. Può essere utilizzato da entrambi i lati della stessa
L'oggetto socket è quindi un intero, e come i FD possono essere passati tra processi collegati tra di loro.
### Socket operations
![](Images/Pasted%20image%2020250423130744.png)
![](Images/Pasted%20image%2020250423130803.png)
![](Images/Pasted%20image%2020250423130816.png)

![](Images/Pasted%20image%2020250423131340.png)
- L'identificatore di una connessione è la quadrupla indirizzo IP, porta, mittente e destinatario. Nel momento in cui mando il three-way handshake ho un nuovo identificatore: viene sostanzialmente creato un nuovo socket, chiamato ***connection socket***; il ***welcoming socket*** viene messo in attesa, e aspetterà nuove connessioni.
- `caddress` è una struttura di output che permette di avere le informazioni del client una volta creata una connessione 
![](Images/Pasted%20image%2020250423131744.png)
##### Sequenza tipica:
![](Images/Pasted%20image%2020250423131616.png)
Niente vieta di avere che questo ciclo sia eseguito da un altro thread. Dal punto di vista prestazionale, creare un nuovo processo per ogni richiesta richiede molto tempo, quindi non sempre ha senso fare questa cosa.

Quando lavoro con le reti lavoro con macchine diverse. Questo potrebbe portare a diversi problemi, quali per esempio avere endian diversi: per questo vengono utilizzate funzioni `htons()` e `ntohs()`, ossia host to network e network to host, il quale permette di convertire ciò che viene dato in input in maniera tale che questo venga interpretato nel giusto modo da chi riceve il parametro.