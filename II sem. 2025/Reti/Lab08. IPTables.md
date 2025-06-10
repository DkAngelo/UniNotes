 >*Lezione del 09/05/2025*

IPTables lo strumento Linux utilizzato per l'implementazione di firewall. A livello di tassonomia:
- è un filtro di pacchetto dinamico, 
- supporta ispezioni del payload, 
- può essere sia personale che aziendale, 
- è implementato a livello del kernel come software.
I pacchetti non vengono filtrati da iptables, ma da ***netfilter***, implementato a livello kernel e preinstallato. Netfilter usa i cosiddetti **hooks** per creare le regole di filtraggio.
### Path di un pacchetto all'interno del kernel
![](Images/Pasted%20image%2020250509120158.png)
Netfilter mette su ognuno di tali percorsi degli hook, che permettono sia di filtrare i pacchetti che di modificarli quando vorremmo fare NAT:
![](Images/Pasted%20image%2020250509120528.png)
1. `NFIPprerouting`: i pacchetti vengono filtrati o cambiati prima della logica di routing
2. `NFIPlocalin`: qualunque pacchetto destinato a processi locali viene passato attraverso questo hook, quindi è utile per esempio per firewall di tipo personale
3. `NFIPforward`: utilizzato per i firewall di tipo aziendale
4. `NFIPpostrouting`: i pacchetti vengono filtrati o cambiato dopo la logica di routing (utile per il source NATting)
5. `NFIPlocalout`: anche questo viene utilizzato per firewall di tipo personale
Le azioni che Netfilter può fare su un pacchetto sono principalmente:
- NF_ACCEPT accetta il pacchetto
- NF_DROP il pacchetto viene deallocato
- NF_STOLEN prende il pacchetto per ulteriori elaborazioni da fare all'interno del kernel prima di rimetterlo potenzialmente in coda
- NF_QUEUE prende il pacchetto per elaborarlo in user space

IPTables usa un'astrazione di netfilter che mette a disposizione delle tabelle di cinque tipi:
- FILTER: per implementare regole di filtraggio
- NAT: per implementare regole di NATting
- MANGLE: permette di cambiare arbitrariamente ai campi del campo TCP/IP di un pacchetto
- RAW: esclude i pacchetti dal tracciamento delle connessioni
- SECURITY: estende i controlli di Mandatory access control di SELinux anche sui pacchetti in rete
Noi ci concentreremo su FILTER e NAT. Con il primo posso agire su NFIPFORWARD, NFIPLOCALIN e NFIPLOCALOUT, mentre il secondo su NFIPPREROUTING, NFIPPOSTROUTING e NFIPFORWARD.
L'astrazione che mette a disposizione IPTables per agire su tali hooks sono delle cosiddette **catene**:
- tabella FILTER: catene di default sono INPUT OUTPUT e FORWARD
- tabella NAT: catene di default sono OUTPUT, PREROUTING e POSTROUTING
---
# Filtro di pacchetto
Lavoro sulla tabella filter.
La prima cosa da fare è definire la politica di default. E' possibile definire una politica per ogni catena della tabella.
```
iptables [-t <table>] -P <chain> {ACCEPT|DROP}
```
Ad esempio:
```
iptables -t filter -P INPUT ACCEPT
```
Per vedere la configurazione attuale del firewall si usa il comando: `iptables -L` oppure `iptables -t`.
 Come detto, una regola è fatta da due parti (descrizione e azione) e viene aggiunge ad una catena. Per aggiungere una regola di usa l'opzione -A
```
iptables [-t <table>] -A <chain> <matching criteria> -j <action>
```
Le azioni possibili sono:
- DROP: il pacchetto scompare dal kernel senza notificarlo
- REJECT: il pacchetto scompare notificando il mittente
- ACCEPT: il pacchetto viene accettato da questa catena e continua il suo percorso nel kernel
- QUEUE: il pacchetto viene spostato in user space per ulteriori modifiche
- LOG
- chain-created-by-user: permette di creare una nuova catena. Viene utilizzato in firewall già molto pieni dove voglio inserire una serie di regole in sequenza.
##### Semplici regole statiche:
![](Images/Pasted%20image%2020250509123012.png)
- Nel secondo viene utilizzata l'impostazione `--dport` in quanto il protocollo di trasporto TCP utilizza le porte: se un protocollo non le utilizza, non potremmo utilizzarla. Quando si usa il `--`, infatti, ci si riferisce a impostazioni che dipendono da altre impostazioni descritte nella regola.
- L'opzione -i consente di specificare l'interfaccia di input alla quale applicare la regola (nel caso si tratti di un filtraggio INPUT), mentre -o l'interfaccia di output (in un filtraggio ovviamente OUTPUT).
#### Regole dinamiche
Per fare delle regole dinamiche devo utilizzare il modulo **state**, che permette di utilizzare dei nuovi qualificatori dipendenti:
- NEW matcha tutti i pacchetti che creano una nuova connessione
- ESTABILISHED matcha tutti i pacchetti che appartengono ad una connessione aperta
- RELATED matcha tutti i pacchetti che non appartengono ad una connessione aperta ma comunque vi sono relazionati in qualche modo (gestione del protocollo FTP, ad esempio)
##### Esempio di regole dinamiche per la gestione di una connessione FTP:
![](Images/Pasted%20image%2020250509124114.png)

Ci sono anche altri moduli per i firewall stateful, come per esempio **limit**, il quale mi permette di fare rate limiting sul la quantità di pacchetti di un certo tipo ricevuti in un certo periodo di tempo.

 > *Lezione del 13/05/2025*

Masquerade va a prendere l'indirizzo IP in uso mentre il pacchetto esce, ed è utile in quanto l'indirizzo IP potrebbe essere un indirizzo dinamico che cambia di volta in volta. 

### Destination NAT (DNAT)
Supponiamo che un indirizzo privato esegue un web server che ascolta sull'indirizzo 80. 
Dobbiamo agire tramite pre-routing, traducendo l'indirizzo privato in un indirizzo pubblico. Tale regola si applica non a tutti i pacchetti che arrivano da internet, ma solo a pacchetti TCP che arrivano alla porta ottanta e all'indirizzo IP della scheda di rete del firewall. Per applicare destination NAT si usa il seguente codice:
```
```
Se volessi cambiare anche la porta (il server viene eseguito su una porta non standard), il firewall applicherà una direzione su quella porta:
```
iptables -nat -A PREROUTING -p tcp -d 155.185.54.185 
```
## Marking  e mangling
Utilizzando la tabella **mangle** si può lavorare su tutti i filtri di netfilter e applicare dei *marchi* ai pacchetti per avere dei filtri o politiche di routing avanzate, destinguendo il traffico in base al marchio. E' possibile tramite mangle anche applicare un differente *time to live* ai diversi pacchetti. 
Solitamente non viene utilizzata, ma è utile per alcune situazioni particolari.
## Comandi e management
Posso creare delle nuove catene, definite dall'utente, con l'opzione `-N`, solitamente per dare un senso logico alle politiche.
Per sapere le regole delle catene in uso e non basta utilizzare `-L`. Per non far trasformare gli indirizzi IP in nomi utilizzo `-n`. 
Per eliminare una regola si usa l'opzione `-D`:
![](Images/Pasted%20image%2020250513164805.png)
Le regole vengono aggiunte in maniera sequenziale, quindi la seconda regola è semplicemente la seconda regola che era stata aggiunta alla catena. Se però vogliamo eliminare tutte le regole di una catena, utilizziamo `-F <catena>`, se invece vogliamo farlo per tutte le catene allora non esplicitiamo la catena.

Tutte le regole scritte da riga di comando fanno parte di una configurazione dinamica, e in quanto regole dinamiche **NON sopravvivono** al reboot della macchina. Per renderle permanenti è possibile utilizzare *iptabbles-save e iptables-restore*:
- salvataggio della configurazione
![](Images/Pasted%20image%2020250513165203.png)
- ristabilizzazione della configurazione
![](Images/Pasted%20image%2020250513165211.png)