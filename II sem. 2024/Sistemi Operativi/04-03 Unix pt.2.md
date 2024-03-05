## Shell
- *Bourne Again Shell (BASH)*: arricchimento della Bourne Shell (SH, prima shell di UNIX)
- *C shell*
- *Korn shell*
- *Almquist shell (ASH)*
- *Debian Almquist Shell (DASH)*
- *Shell POSIX*
I comandi che studieremo in questo momento sono standard, e quindi utilizzabili in qualsiasi shell.
Queste si distinguono per aspetti visibili e non visibili, quali la sintassi che sono in grado di interpretare.
E' possibile lanciare nuove shell attraverso dei comandi, ad esempio il comando ``sh`` ci permette di avviare la Bourne Shell, ``bash`` invece la Bourne Again Shell. La prima shell, avviata al login, nella lista dei processi (vedi #comandi in "[29-02 Unix pt.1](29-02%20Unix%20pt.1.md)") viene visualizzata con un meno davanti (es. ``-bash``).
Come per il logout, ``exit`` viene utilizzato anche per terminare shell avviate.

## Altri comandi
#comandi
- ``echo $HOME``: indipendentemente da dove mi trovo mi indica il path della mia home directory 
- ``cd``: change directory; usato da solo ci riporta alla home directory
- ``touch <nome-file>``: modifica il file, e quindi la data della sua ultima modifica
##### **IMPORTANTE**
I nomi dei file e delle directory, quando specificate all'interno dei comandi, possono essere abbreviate con due *metacaratteri*:
``*`` fa match con qualunque stringa anche vuota
``?`` fa match con un qualunque carattere (ne deve esistere almeno uno)
Es.
- ``$ls -l *ile`` visualizza tutti i file o le directory che hanno una stringa che finisce per "ile" o ha per nome proprio "ile"
- ``$ls -l ?ile`` visualizza tutti i file o le directory che hanno un carattere prima della stringa "ile"

- ``<nome shell> -x``: indica l'esecuzione espansa dei comandi che andremo a descrivere. Ad esempio, utilizzando asterisco e punto interrogativo per indicare dei file, ci indica i matching ottenuti

## Protezione
#protezione

Esistono tre categorie di possibili utilizzatori (*tripletta UGO*):
- il proprietario del file (*user*)
- il gruppo del proprietario (*group*)
- altri tipi di utilizzatori (*other*) 
Questi possono avere tre tipi di accesso: lettura (r), scrittura (w) ed esecuzione (x)
Ogni volta che si tenta di accedere ad un file quindi viene fatto un controllo preliminare sull'UID. Se si passa tale controllo, viene poi verificato se si è in possesso del diritto di accesso corrispondente (quindi r, w, o x).
Se non si passa il primo controllo, allora viene fatto il controllo sul GID, compreso dell'ulteriore controllo sui diritti. Se non si passa neanche questo controllo, si viene considerati come *others*.