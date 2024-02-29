Due tipi di processi
- processi di sistema: processi del S.O. che seguono codice di sistema
- processi utenti: eseguono codice utente
Vengono eseguiti concorrentemente
Funzione principale del gestore del kernel: scheduling dei processi
- creazione e distruzione
- sospensione e riattivazione
- strumenti per la sincronizzazione e comunicazione dei processi
- scheduling -> algoritmi vari in base alle esigenze del S.O. e/o degli utenti

**STATI DI PROCESSO**
Un processo viene rappresentato dal DESCRITTORE DI PROCESSO (PCB). Questo serve perché il processo è un'unità attiva, in quanto il S.O. ha assegnato parte di CPU a quest'ultimo, non potrà essere sempre in esecuzione, ma avrà momenti di sospensione. In tali momenti di sospensione, il PCB salva le informazioni del processo.
Dallo stato sospeso un processo non può tornare direttamente in esecuzione, in quanto sarà l'algoritmo di scheduling a decidere quale processo con stato PRONTO può essere eseguito.
CODE DI (descrittori di) PROCESSI (pronti e sospesi).
All'interno del PCB ci sono le seguenti informazioni:
- identità del processo (numero)
- info di chi ha creato il processo
- se il processo non è in esecuzione, tutte le informazioni che sono state salvate dalla nostra architetture durante le fasi di transizione (quando è stato sospeso o quando è stato rimesso nello stato pronto, *context switching*)

**CPU SCHEDULING**
Lo scheduler si occupa di gestire la coda dei processi pronti. Nel momento in cui la CPU sia libera, quindi, esso sceglie quale dei processi pronti va eseguito in base ad un algoritmo scelto in fase di progettazione.
- **Tipi di scheduling**
	Gli algoritmi di scheduling possono o meno prevedere la *prelazione*. Ciò permette al S.O. di poter far passare processi da uno stato esecutivo direttamente ad uno stato pronto forzatamente
	
	1. *ALGORITMI DI SHORT-TERM SCHEDULING*
	     Sono gli algoritmi di base
		1. **Round robin**: Permette la *preemption* . La coda dei processi pronti è di tipo FIFO, e ad ogni processo è assegnata la CPU per un quanto di tempo QT prefissato. Al termine di tale tempo prefissato, infatti, il processo in esecuzione viene forzato ad entrare in uno stato pronto. Il processo però potrebbe anche volontariamente passare ad uno stato sospeso prima della fine del QT. La scelta del QT dipende da quanto tempo l'architettura ci mette per eseguire il context switching. Tale tempo è quindi considerato overhead.
		2. **Scheduling a priorità**: deve essere importante per il S.O., per l'appunto, dare una certa priorità ad alcuni processi. A livello implementativo, quindi, la coda sarà splittata in più code, una per ogni livello di priorità. Ogni coda è singolarmente gestita attraverso un sistema FIFO. Potrebbe esserci un problema di *starving*, ossia che processi con bassa priorità, nonostante lo stato pronto, potrebbero non essere mai eseguiti. Per risolvere tale problema si potrebbe pensare di avere una gestione della priorità dinamica, capace di cambiare priorità ai processi in base a criteri prestabiliti (es. assegnazione alle code di quanti di tempo differenti, corti per priorità alte e lunghi per priorità basse)

**PROCESSI INTERAGENTI**
In generale, esistono due tipi di interazione:
- **indiretta o competizione**: due processi hanno bisogno di utilizzare lo stesso insieme di risorse (es. due processi devono usare la stampante contemporaneamente, oppure due processi che eseguono in modo ciclico un compito assegnato e ne devono tenere traccia, occupando insieme uno stesso contatore). Tali problemi vanno risolte con l'acquisizione della mutualità esclusiva delle risorse.
- **interazione diretta o cooperazione**: un processo comunica una o più informazioni complesse ad un altro processo.
Ci sono S.O. che consentono entrambi i tipi di interazione (modello di tipo globale) e S.O. con interazione solamente diretta (modello di tipo locale, Linux ne fa parte).
- **Deadlock**
	 E' un problema che si verifica in entrambi i tipi di interazione. Si manifesta quando processi interagenti si trovano ad essere bloccati in attesa del manifestarsi di condizioni che non possono verificarsi

**GESTIONE DELLA MEMORIA CENTRALE (RAM)** 
Gestione degli spazi di indirizzamento, gestione dell'allocazione e deallocazione della memoria, gestione della memoria virtuale
**Gestione della allocazione**
*Metodo della paginazione*
E' un metodo non contiguo di allocazione. La memoria è infatti paginata in tanti frame con la stessa dimensione, nelle quali andranno quindi ad essere memorizzati (sempre della stessa dimensione) le pagine logiche del nostro processo, in un frame qualsiasi.
Ogni processo ha quindi la propria *TABELLA DELLE PAGINE (TDP)* nella quale troveremo il numero del frame  fisico di memoria nel quale è contenuta la relativa pagina logica del processo
A tempo di esecuzione, ogni processo genera un indirizzo logico che viene tradotto in indirizzo fisico dall'hardware.
- Overhead del 100%: prima di leggere la TDP, bisogna fare un accesso preventivo in memoria. Per evitare tale problema, viene utilizzata la cache delle pagine, detta anche **TLB** (translation look-aside buffer), una memoria associativa che memorizza per un sottoinsieme dei numeri di pagina logica corrispondenti il numero di pagina fisica. Se l'accesso alla cache però non ha successo, allora l'overhead è assicurato (TLB miss).

**Gestione della memoria virtuale**
In genere in un programma ci possono essere delle condizioni, per esempio di errore, che potrebbero non verificarsi mai. Il codice di gestione di tali errori potrebbe quindi non essere caricata in memoria centrale. Questo è consentito grazie alla memoria virtuale. La memoria RAM, oltre che utilizzare la cache, usa una memoria di massa secondaria per ampliare la possibilità di memorizzazione del proprio S.O.
In particolare, UNIX usa la memoria virtuale che si appoggia a basso livello sulla paginazione, con lo spazio di indirizzamento logico che viene visto come segmenti (si suddivide in modulo dei dati, modulo dello stack ecc.).
La TDP viene quindi arricchita da un ulteriore bit, detto *bit di validità*, che ci permette di capire se la pagina corrisponde o meno ad un indirizzo in memoria centrale. 
Nel caso ci sia un eccezione quindi, il processo verrà in primis sospeso, così da permettere al S.O. di portare quella pagina in memoria centrale mentre viene eseguito uno dei processi con stato pronto. Il processo precedente torna in stato pronto solo nel momento in cui la pagina viene effettivamente portata in memoria centrale. Nel caso non ci sia più spazio, il S.O. attua un algoritmo di sostituzione, ricopiando la pagina sostituita su disco nel caso in cui non sia stata scritta o sovrascrivendola soltanto nel caso sia già stata scritta.

**GESTIONE INTERFACCIA UTENTE**
Si dividono in due grosse categorie:
- grafica
- testuale