 > *Lezione del 04/06/2025*

Nella risposta, il sito web che vuole comunicare con noi, invia questo *Set-cookie*, generando il valore alfanumerico del cookie al client. Il client ripeterà quel valore in tutte le richieste che farà successivamente, facendo riconoscere al server che le richieste arrivano da una sessione con quel cookie specifico.

---
# Dynamic Web
Il web nasce per servire risorse statiche. In realtà però, nel tempo quasi tutte le applicazioni web sono dinamiche o hanno qualche elemento di dinamicità. Vale a dire che una risorsa richiesta causa l'esecuzione di qualcosa a lato server, il quale risultato corrisponde alla pagina visualizzata. Tale risultato sarà variabile, che sia in base al contesto o in base a dei parametri immessi dal client. Dal punto di vista dell'utente tale sistema è totalmente **trasparente**, in quanto non cambia nulla sotto il punto di vista della sua esperienza.
Esistono 4 livelli logici di un servizio web:
- **user interface**
- **presentation logic**
- **application logic**: cosa faccio con le richieste in arrivo
- **data logic**: mi dice come vengono gestiti i dati 
I livelli logici non corrispondono necessariamente ai livelli software o hardware.
Tutti i livelli possono essere implementati in una sola macchina oppure estendendo sia verticalmente che orizzontalmente. Al giorno d'oggi, si decide di spostare parte della logica di presentazione nel browser. Questo perché se l'interazione non causa una richiesta che viene gestita da un server molto lontano ma viene eseguita localmente, il sito sembra più responsivo interattivo e veloce.
in generale quindi, la presentation logic è un web server, la data logic è un database relazionale, mentre per l'application logic esistono diverse tecnologie.
- CGI (common gateway interfaces): manda in esecuzione ad ogni richiesta un processo esterno
- Linguaggi di scripting:
	- Linguaggi eseguiti direttamente dal web server (PHP)
	- Linguaggi eseguiti in processi esterni (Tomcat)
- Tecnologie ad oggetti distribuiti: è possibile invocare dei metodi su degli oggetti che magari si trovano su altri sistemi o servizi. Talvolta sono utilizzati in ambito enterprise per applicazioni di grande scala.
Le tecnologie possono essere classificate anche in base a cosa mi focalizzo quando sviluppo:
- **page-oriented**: sviluppo pagina per pagina. Le parti dinamiche possono essere descritte con PHP o JSP attraverso degli script descritti all'interno delle pagine
- **object-oriented**: ci si aspetta che la pagina chiami degli oggetti
- **MVC**: Model View Controller. Vede una differenza abbastanza distinta in base su come vengono gestiti i dati e come vengono usati.
L'ultimo modello è molto più presente in quanto si chiede sempre più spesso di creare applicazioni con sempre meno codice. Questo viene fatto utilizzando componenti pre-esistenti: applicazioni scritte in questo modo vengono chiamate **applicazioni mash-up**.
### Applicazioni con approccio Restful
Sempre più spesso possiamo accedere a dei dati con delle richieste HTTP. Si cerca tramite tale approccio di estenderlo con la modifica dei dati. Tali dati verranno messi a disposizione da delle API. Normalmente le **API Rest** permettono di modificare dati scritti in formato standard. Di solito vengono supportati metodi **CRUD**:
- **CREATE**: implementato attraverso POST, permette di aggiungere nuovi dati
- **READ**: implementato attraverso GET, permette di leggere i dati
- **UPDATE**: mappato su PUT, permette di aggiornare tuple di dati
- **DELETE**: mappato su DELETE, permette di eliminare delle tuple di dati
---
# Logging
Tutti i web server possono essere configurati per *loggare* le attività, il chè vuol dire che da qualche parte esiste un file dove vengono descritte delle righe di *log*. Normalmente, i server sono configurabili in maniera tale da descrivere solo i log che ci interessano, come ad esempio:
- quali file mantenere
- log di accesso
- quanto spazio deve occupare il file di log
- come gestire i file mantenuti
- quali informazioni loggare di richieste e risposte
#### Esempio di Apache access log
![](Images/Pasted%20image%2020250604124503.png)

I log servono a vedere se tutto va bene, quante richieste stanno arrivando, quanto "è pesante il carico", per fare attività di *billing* (servizi pay-to-use). Se non ho strumenti automatici per l'analisi dei log, possono essere visualizzati come file di testo oppure utilizzo degli strumenti software.