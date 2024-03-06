- ``cp <path>``: copy, permette di copiare file o directories
	- ``-r``: recursive; opzione valida solo con le directories, scende al loro interno proseguendo la copia anche per tutto ciò che è il contenuto delle directory
	- ``-p``: tiene intatte le informazioni per quanto riguarda i file copiati (owner, ultima data di modifica)
- ``rm <path>``: remove, rimuove **DEFINITIVAMENTE** il file descritto, senza possibilità di recupero (al contrario del cestino di Windows, per fare l'esempio, essendo che il comando viene eseguito tramite interfaccia testuale).  ``<path>`` si riferisce ai path relativi (dalla directory in cui siamo, segnalata con ``pwd``, fino al file)
	- ``-i``: nel comando remove permette di accertare che questa voglia essere effettivamente eseguita (nelle risposte deve essere utilizzato Y/N)
	- ``-r``: cancella tutta i file contenuti nella directory specificata (scende nella directory in maniera ricorsiva)
- ``rmdir <path>``: remove sulle directories; la rimozione può avvenire solo se la directory è vuota
- ``cat <path>``: permette di mostrare il contenuto di un file
- ``more <path>``: permette di  visualizzare più file in una volta sola (magari trovati attraverso matching con ``*`` o ``?``). Può agire anche su un singolo file, ma nel caso di un file molto corto non si apprezza la differenza tra i due file. Il ``more`` viene infatti utilizzato anche per visualizzare file molto lunghi, paginandolo in base alla grandezza del prompt in quel momento. La navigazione nel file avviene come nel comando ``man`` (quindi attraverso la spacebar o il tasto invio, se voglio scorrere rispettivamente le pagine o le righe). 

## Generalizzazione del concetto di file
Il fatto che anche le periferiche vengano trattate come file permette di utilizzare i comandi visti anche sulle periferiche, e questo è un grosso vantaggio dei sistemi operativi UNIX. Ad esempio, è possibile stampare un file semplicemente copiando il file cp nella directory che indica la stampante.

***Concetto di ridirezione dei comandi***
Possiamo fare sì che dei dati che un comando prenderebbe da tastiera o scriverebbe su video (rispettivamente *standard input* e *standard output*) venga preso da un file e riportato anche su un file. Questo sarà possibile solo attraverso l'utilizzo di *metacaratteri*:
- ``comando < nome-file`` indica la ridirezione del comando dallo standard input dal file
- ``comando > nome-file`` indica la ridirezione del comando dallo standard output ad un file, riscrivendone del contenuto
- ``comando >> nome-file`` al contrario del precedente, non viene perso il contenuto del file, con la ridirezione effettuata nello spazio presente dopo il contenuto presente in quest'ultimo.

> Nel caso di direzione dello standard output in cui il file non esista, ovviamente, questo viene creato e il risultato viene ridiretto nel file descritto.

## Comandi filtro
I comandi filtro sono programmi o comandi che ha bisogno di dati, forniti dallo standard input, riversa quei dati nello standard output e utilizza, nel caso ce ne sia il bisogno, anche lo standard error. Spesso e volentieri questi comandi filtro esistono anche in versione semplice (come ad es. il ``cat`` e il ``more``)

 > Nella versione filtro del `cat` e del `more` non è possibile utilizzare il pattern matching con `?` e `*`, a meno che questo non indichi uno ed un solo file

- ``cat``: usato da solo quindi, fa da "``echo`` continuato", fino alla chiusura del processo con *CTRL+D* (piccolo appunto: il *CTRL* viene indicato con ``^`` nel bash). 
- ``cat > nome-file``: scrive all'interno del file descritto ciò che scriviamo nel prompt fino alla conclusione del processo
- ``cat < nome-file1 > nome-file2``: riscrive nel *file2* il contenuto del *file1*