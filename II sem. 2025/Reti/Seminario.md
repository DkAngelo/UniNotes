 > *Seminario del 30/04/2025*

Reti TCP/IP:
- conosciamo il mondo TCP e le differenze con UDP
- ci focalizzeremo sullo stack in generale, vedendo come questo sia implementata su Linux
- vedremo gli algoritmi TCP BBR, TSQ and Pacing, FQ-CoDel. Questi se non vengono implementati tutti e tre contemporaneamente hanno difficoltà nella gestione della congestione
##### Piccolo recap
- TCP è un protocollo di livello 4 connection oriented che si occupa del trasporto di dati
- ha un buffer di ricezione e trasmissione che tiene traccia dei pacchetti
- ha un meccanismo di acknowledgment abbastanza trasversale che gestiscono solo gli end nodes
- il TCP si occupa sia del controllo congestione che del controllo di flusso
- durante la vita di un algoritmo TCP, abbiamo un momento di slow start e un altro momento dove cerca di evitare la congestione. Il tipo di comportamento potrebbe variare in base a come opera l'algoritmo stesso
Andando nel merito degli algoritmi, abbiamo visto diversi algoritmi di congestion control, tra i quali:
- Tahoe
- Reno e New Reno
- Bic e CuBic (algoritmo di default su tantissime macchine)
- Vegas
Ci sono moduli che non sono esattamente TCP, ma collaborano con tale livello, quali:
- UDP: più leggero, poco overhead, ma nessun feedback
- protocolli e tecnologie che mitigano i problemi della rete stessa, quali CoDel e BufferBloat
# TCP/IP Linux kernel stack
L'obiettivo di oggi è comprendere il ruolo dei moduli che Linux ha inserito nella main line del kernel per sviluppare nuovi algoritmi di congestion control.
![](Images/Pasted%20image%2020250430122524.png)
- l'hop di livello 2 è molto significativo in quanto è l'ultimo hop software e permette di compiere decisioni importanti prima del rilascio di un qualsiasi pacchetto
L'obiettivo del TCP in generale è cercare di:
- essere efficiente: devo usare il massimo della banda disponibile senza andare oltre, senza congestionare la rete
- essere *fair*: faccio le cose bene senza disturbare le altre sessioni dello stesso nodo e cercando di dividere la banda equamente tra le sessioni
- fairness e friendliness, il primo tra algoritmi uguali e la seconda tra algoritmi diversi
![](Images/Pasted%20image%2020250430123220.png)

Tra CUBIC e Reno c'è una differenza sostanziale nel proprio comportamento, nonostante siano ***loss based*** (cambiano comportamento quando avviene una perdita di pacchetti):
![](Images/Pasted%20image%2020250430123600.png)
Tuttavia ho dei picchi per quanto riguarda la pienezza della coda e nella latenza: [immagine]

CUBIC è l'implementazione migliore vista fino ad adesso:
-  reagisce velocemente alle condizioni variabili di una rete
- l'essere ***loss based*** 
- ignora l'RTT e si comporta molto bene con buffer relativamente piccoli
## Famiglie di algoritmi di congestion control
- ***loss based***: algoritmi nati e cresciuti con la convinzione che prima o poi arriverà un feedback dovuto alla perdita di pacchetti (Reno)
- ***time based***: il feedback viene basato sull'RTT (Vegas)
- l'unico algoritmo **model based**, che guarda tutto l'insieme delle informazioni end-to-end, è **BBR**. Monitora RTT, banda e ulteriori informazioni

Per comprendere bene a modo come facciamo ad ottimizzare una rete, bisogna prima parlare di BDP parameter (Bandwidth Delay Product): qual è il numero di dati che il mittente deve trasmettere sulla rete per essere ottimi, conoscendo la larghezza di banda e l'RTT (ad esempio, 10Mbps e 100ms).
![](Images/Pasted%20image%2020250430124454.png)
In questo caso devo avere almeno 10Mb sulla rete (***data inflight***) per essere sicuri che la rete stessa sia utilizzata (RTT/BW). Quindi ogni secondo dovrei mandare 1Kb

La storia della latenza e dell'RTT sembra avere un ruolo per quanto riguarda la congestione della rete quindi. 
![](Images/Pasted%20image%2020250430130010.png)
- si mettono in evidenza dei momenti evidenti della vita di una rete
- quando inizio non mando niente, non ho RTT
- quando mando i dati, l'RTT viene calcolato e aumenta linearmente con il numero di pacchetti che mando
- questo cresce fino al BDP: se mando più dati di quanto la rete possa digerire, creo delle code. L'RTT continua a salire, ma la banda rimane la stessa, fino a che non mando talmente tanta roba che mi fa arrivare al massimo delle capacità dei buffer: incominciano le *loss* (dove si attivano gli algoritmi ***loss based***).
- il BDP diventa un punto ottimo: dovremmo posizionarci lì e scoprire dove e quando si cominciano a creare delle code, cosa che si scopre attraverso l'RTT e la sua crescita. E' così che lavora **BBR**.
# BBR: bottleneck bandwidth RTT
E' stato creato da Google ed è disponibile dal kernel 5.0 di Linux.
- si mette nel BDP
- se c'è della banda nuova cerca di usarla
- cerca di vedere se l'RTT possa essere diminuito
![](Images/Pasted%20image%2020250430130939.png)
Il suo modello quindi si basa sul vedere e monitorare lo stato della rete guardando agli ACK:
- aggiorna MaxBw ad ogni ACK
- aggiorna minRTT ad ogni ACK
- include un meccanismo di **pacing**
- ha una fase di slow-start, chiamato **warm-up**, come gli altri algoritmi
- nella fase di steady state cerco di migliorare il BDP calcolato nella prima fase
![](Images/Pasted%20image%2020250430131240.png)
![](Images/Pasted%20image%2020250430131408.png)
![](Images/Pasted%20image%2020250430131430.png)
![](Images/Pasted%20image%2020250430131443.png)
![](Images/Pasted%20image%2020250430131503.png)
![](Images/Pasted%20image%2020250430131540.png)
![](Images/Pasted%20image%2020250430131627.png)
Funziona molto bene ed è molto stabile, e questo si riesce a notare soprattutto quando messo a confronto con altri algoritmi come Reno:
![](Images/Pasted%20image%2020250430131811.png)
La fairness viene raggiunta dopo diversi secondi ma viene comunque raggiunta:
![](Images/Pasted%20image%2020250430131952.png)
- Se fossero partite tutte le sessioni allo stesso momento, la fairness sarebbe stata raggiunta più in là nel tempo, in quanto hanno tutti gli stessi *cycle gain*
![](Images/Pasted%20image%2020250430132124.png)
- CUBIC, nonostante sia un competitore molto forte, incomincia ad essere in difficoltà molto presto
BBR inoltre è molto bravo a non riempire le code, al contrario di CUBIC, che sfrutta al massimo la grandezza dei buffer, facendo aumentare così l'RTT:
![](Images/Pasted%20image%2020250430132258.png)
BBR tuttavia ha avuto e ha tutt'ota dei problemi proprio per la sua natura: mandando 5 pacchetti ogni *ms*, spesso questi potrebbero essere troppo pochi
![](Images/Pasted%20image%2020250430132702.png)
- rimane bravo sotto il punto di vista del ping, ma non sfrutta l'intera banda. Questo perché il pacing non era troppo aggressivo per sfruttarla:
![](Images/Pasted%20image%2020250430132815.png)

Adesso che abbiamo un idea su come funzioni il pacing BBR, possiamo vedere come funzionano TCP pacing e TCP small queues. 
# TCP pacing
![](Images/Pasted%20image%2020250430133329.png)
[1:26]
- questo mi dice la velocità con cui dovrei mandare i pacchetti
# TCP Small Queues
![](Images/Pasted%20image%2020250430133530.png)
- *ms* è una quantità che dipende da un tempo. Se prendo il TCP pacing rate e lo divido per mille, mi dice una quantità di byte che devo trasmettere ogni millisecondo per mantenere quella velocità
- la TCP small queue mi dice essenzialmente la quantità di dati che devo mandare in un millisecondo per non riempire le code e sporcare le misure temporali

Il meccanismo di TSQ comprende un cross-layering, cosa che però apre la discussione a dei rischi. I problemi di frame aggregation che BBR non riesce a fare, rimangono anche in TSQ e Pacing.
![](Images/Pasted%20image%2020250430134040.png)
![](Images/Pasted%20image%2020250430134129.png)
- nessuno degli algoritmi arriva alla banda massima! La crescita della banda viene infatti limitata da TSQ per il semplice fatto che frame aggregation e il comportamento di TSQ stesso non vanno d'accordo. Variando la quantità di millisecondi disponibili nel calcolo, la situazione migliora per tutti tranne che per BBR (che non migliora per colpa del solo algoritmo stesso):
![](Images/Pasted%20image%2020250430134515.png)
# Queueing layer
Algoritmi di gestione delle code:
- FIFO
- FQ-CoDel: 
![](Images/Pasted%20image%2020250430134904.png)
- i pacchetti arrivano, vengono marcati per dividerli in code diverse e vengono gestiti da uno scheduler
CoDel è molto bravo ad ignorare le dimensioni effettive della coda
![](Images/Pasted%20image%2020250430135131.png)

![](Images/Pasted%20image%2020250430135223.png)
![](Images/Pasted%20image%2020250430135523.png)
- Se il bottleneck è locale, TSQ è molto impattante
Adesso analizziamo tutte le configurazioni, con e senza TSQ: continuiamo a vedere come se il bottleneck è locale, TSQ diminuisce molto le latenze.
![](Images/Pasted%20image%2020250430135736.png)

Vediamo adesso come lavorano le configurazioni usando BBR al posto di CUBIC:
![](Images/Pasted%20image%2020250430135903.png)
- essendo che BBR fa di tutto per non far aumentare l'RTT, la latenza diminuisce di tantissimo rispetto a CUBIC. Possiamo anche vedere come se il bottleneck non sia in locale, si comporta quasi meglio
Utilizzando anche CoDel, possiamo vedere come la latenza massima scende a 10ms.
![](Images/Pasted%20image%2020250430140056.png)