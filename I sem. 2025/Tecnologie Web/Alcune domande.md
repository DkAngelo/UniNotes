1. **Quali sono i principali fattori che hanno contribuito alla rapida diffusione del Web rispetto ai precedenti sistemi di condivisione?**
	Principalmente l'ipertestualita', l'universalita', la standardizzazione, l'accesso globale e la scalabilita'

2. **Spiega il funzionamento del modello Client/Server nel contesto del Web e i suoi vantaggi rispetto ai modelli precedenti.**
	Tale modello si divide essenzialmente in due parti:
	- Il client invia le richieste al server e mostra i contenuti
	- Il server risponde alle richieste del client, elaborando dati e inviando risposte
	Questo permette di gestire una grande quantita' in maniera facile, efficiente ed efficace, grazie anche al fatto che i dati siano tutti contenuti in server geolocalizzati

3. **Spiega lo standard e il modello di interazione CGI.**
	CGI sta per Common Gateway Interface e permette essenzialmente una prima "dinamicizzazione" dell'internet grazie al fatto di poter interfacciare applicazioni con il web stesso attraverso tale modello

4. **Le stringhe in JavaScript sono dati primitivi o possono comportarsi come oggetti?**
	Le stringhe in JavaScript sono tipi primitivi. Tuttavia, possono essere trattate come oggetti attraverso un meccanismo di boxing presente nel linguaggio, il ché ci permette di usare metodi come `.toUpperCase()` o `.length`.

5. **In che modo il Virtual DOM migliora le prestazioni rispetto al DOM tradizionale in React.js?**
	React introduce il concetto di Virtual DOM, che altro non e' che una copia in locale del DOM del browser. Quando andiamo ad interagire con la pagina, il DOM che viene inizialmente modificato e' quello virtuale. Cosi' facendo, React e' in grado di confrontarlo col DOM del browser e comunicare a quest'ultimo solo le modifiche essenziale, permettendo cosi' migliori prestazioni nei riguardi del rendering

6. **Che cosa sono le API e qual è il loro scopo principale?**
	API sta per Application Programming Interface e il loro scopo principale e' far interfacciare diverse applicazioni l'una con l'altra, permettendo che le prime usino le seconde senza doverne conoscere dettagli e struttura interna

7. **Spiega il funzionamento dell’heading in HTML.**
	Il tag degli header e' `<h#>`, dove al posto del cancelletto andremo a scrivere un numero che va da 1 a 6. La loro funzione e' quella di andare ad immettere un titolo all'interno della pagina; piu' il numero e' grande, meno importante diventera' il titolo (e quindi sara' piu' piccolo)

8. **Quali sono le differenze tra URL relativi e assoluti?**
	Questi si differenziano essenzialmente nella loro struttura. Come si capisce dalla parola, quelli assoluti riportano il path completo di una risorsa, e quindi possiamo localizzarla ovunque ci troviamo, mentre quelli relativi sono descritti a partire da qualcosa (funzionano se quel qualcosa e' dove ci troviamo attualmente)

9. **Qual è il ruolo della funzione di callback in AJAX e perché è fondamentale nel ciclo di vita di una richiesta asincrona?**
	La funzione di callback in AJAX e' una funzione chiamata al fine di una richiesta asincrona. E' importante in quanto permette di gestire le risposte senza bloccare l'esecuzione degli script della pagina

10. **Quali sono le caratteristiche principali di React.js che lo rendono una libreria efficace per lo sviluppo di interfacce utente?**
	Le caratteristiche principali di React che lo rendono una libreria efficace per lo sviluppo front-end sono essenzialmente il virtual DOM e la presenza di componenti autonomi, indipendenti, modulari e riutilizzabili

11. **Descrivi la distribuzione verticale e orizzontale dei servizi nell'architettura a 3 tier utilizzata per le applicazioni web. Fornisci esempi di come vengono gestiti i vari livelli (presentazione, logica applicativa e dati) in ciascun tipo di distribuzione e spiega i vantaggi e gli svantaggi di ciascun approccio.**
	Il tipo di distribuzione dipende da come e dove andiamo ad allocare le risorse della nostra applicazione. Ad esempio, se andiamo collochiamo la nostra applicazione su un solo server e ne aumentiamo la potenza, allora questo si chiama distribuzione verticale. Il vantaggio e' che, rimanendo su una sola macchina, l'app rimane semplice da gestire e molto veloce, ma rimane poco scalabile e mantenibile.
	Se andiamo invece a dividere la nostra applicazione su piu' macchine, allora stiamo facendo una distribuzione orizzontale. Al contrario della precedente, ovviamente, abbiamo una maggiore latenza e complessita' del tutto, ma miglioriamo la tolleranza ai guasti e la scalabilita'