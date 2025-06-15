## Codici di stato
Lo status code è un numero di tre cifre, di cui la prima indica la classe della risposta, mentre le altre due la risposta specifica. Sono presenti 5 classi:
- `1xx` **Informazionale**: risposta temporanea alla richiesta durante il suo svolgimento
- `2xx` **Successful**: il server ha ricevuto, capito e accettato la richiesta
- `3xx` **Redirection**: il server ha ricevuto e capito la richiesta, ma sono necessarie ulteriori azioni da parte del client per portare a termine la richiesta
- `4xx` **Client error**: la richiesta del client non può essere soddisfatta per un errore da parte del client (sintattico o una richiesta non autorizzata)
- `5xx` **Server error**: la richiesta del client può essere corretta, ma il server non è attualmente in grado di soddisfarla per un problema interno
Uno degli esempi è il codice 404.
Il REST è un'architettura che implementa e traduce tutte le richieste client server attraverso l'HTTP.