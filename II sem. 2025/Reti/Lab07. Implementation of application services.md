 > *Laboratorio del 06/05/2025*
# HTTP protocol
Gli URL sono facilmente estensibili
Linguaggio per definire gli ipertesti: HTML. La sintassi è rimarcata dall'SGML
L'idea di un sistema di comunicazione ipertestuale non era una cosa nuova
Alcune ipotesi semplificative del protocollo HTTP sono:
- essere senza stato. Non c'è un concetto di sessione a livello dii protocollo HTTP
- si basa sulla definizione di due tipi di messaggi: messaggi di richiesta e di risposta. Vengono veicolati in modo molto efficace ma non efficiente
## HTTP Request
Il messaggio di richiesta ha un'intestazione e un corpo (usato però solo in alcune situazioni, come l'invio di un form). L'intestazione a sua volta ha una *request line* e una serie di righe con degli header che danno diverse informazioni. La request line è formata a sua volta da un *metodo* (quello che vogliamo fare con la risorsa), la parte path dell'URL e [17min]. Infine c'è una riga vuota, importante al server per far capire che l'intestazione della richiesta è finita: se non c'è corpo, può già processare la richiesta
 > **Ripasso**
	- l'URL è formato da:
		- schema, come accediamo all'host
		- host
		- se non si fa nient'altro, il numero di porta è legato al protocollo utilizzato
		- path
		- eventuale query string
![](II%20sem.%202025/Reti/Images/Pasted%20image%2020250506161717.png)
#### Metodi
- **GET**: scaricare dati
- **POST**: solitamente utilizzato per scaricare dati compilati all'interno di un form
- **HEAD**: scarica solo l'intestazione delle risorse richieste
- **PUT e DELETE**: caricano e cancellano risorse
- **LINK e UNLINK**: nati per definire legami tra risorse, ma tolti già dalla versione dell'HTTP 1.1
- TRACE, CONNECT, OPTIONS: il secondo serve per creare una connessione TCP e utilizzarla
#### Header lines
- **Connection**: determina il tipo di connessione richiesta dal client (persistente, non persistente)
- **User-Agent**: browser usato dal client
- **Accept**: contiene una lista di tipi di dato supportati dal browser del client
- **Accept-Language**: lista di linguaggi in ordine di preferenza, permettendo di prendere la pagina con la lingua più gradita dall'utente (Molti siti localizzano l'utente attraverso il suo indirizzo IP, ma non sempre funziona bene per l'esperienza utente)
- **Accept-encoding** e **Accept-charset**
- **Host**: serve per contenere l'indizazione dell'host contenuto nell'URL. Molti server web fanno ***virtual hosting***, quindi tramite questo so quali set di pagine andare a recuperare
- header che servono alla validazione delle informazioni (ad esempio, **If-Match** e **If-Modified-Since**)
## HTTP response
La prima linea della risposta, *response line*, è composta da:
- versione del protocollo
- codice di stato del protocollo con annessa *human readable sentence*
Dopodiché ci sono una serie di *response header*:
- **Date**
- **Last-Modified**
- **Connection**
- **Server**: Riga di presentazione del server (che oggi si tende a non mettere, soprattutto per motivi di sicurezza)
- Informazioni sulla risorsa che andiamo a fornire
Infine abbiamo una linea vuota, prima dei dati forniti.
#### Codici HTTP
Si chiamano status codes:
- `1xx` informazioni
- `2xx` successo
- `3xx` ridirezione
- `4xx` client error
- `5xx` server error
Oggi HTTP viene utilizzato anche per effettuare delle transazioni, quindi i response code utilizzati oggi sono veramente molti rispetto al passato. I più importanti sono:
- `200` OK
- `304` not modified
- `401` authorization required
- `403` forbidden
- `404` not found
- `500` internal server error
## Connessioni
Le connessioni non persistenti sono sempre nello stato iniziali e dal punto di vista prestazioni pesano per il Three-way handshake. Per non pesare, è possibile passare a connessioni persistenti, dov'è possibile fare diverse richieste prima ancora che la risposta ad altre richieste sia arrivata.

---
# Esercizio
Creare una richiesta verso il server *localhost*:
```
nc -C locahost 80 
GET / HTTP/1.1
Host: localhost
```
```
nc -C -l -P 8080
GET / HTTP/1.1
Host: localhost:8080
Connection: keep-alive
```
Codice client:
```c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

void error(char *msg){
    perror(msg);
    exit(0);
} 

int main(int argc, char *argv[]){
    int sockfd, portno, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;
    char buffer[256];
    
    if (argc < 3) {
       fprintf(stderr,"usage %s hostname port\n", argv[0]);
       exit(0);
    }

    portno = atoi(argv[2]);
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {error("ERROR opening socket");}
    
    server = gethostbyname(argv[1]);
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host\n");
        exit(0);
    }

    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr,
         (char *)&serv_addr.sin_addr.s_addr,
         server->h_length);

    serv_addr.sin_port = htons(portno);
    if (connect(sockfd,(const struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0)
        error("ERROR connecting");
    printf("Please enter the message: ");
    bzero(buffer, 256);
    fgets(buffer, 255, stdin);
    
    n = write(sockfd,buffer,st
    rlen(buffer));
    if (n < 0)
         error("ERROR writing to socket");
    
    bzero(buffer,256);
    n = read(sockfd,buffer,255);
    if (n < 0)
         error("ERROR reading from socket");

    printf("%s\n",buffer);
    return 0;
}
```

Codice server:
```C
/* A simple server in the internet domain using TCP
   The port number is passed as an argument */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

void error(char *msg){
    perror(msg);
    exit(1);
}

int main(int argc, char *argv[]){
     int sockfd, newsockfd, portno;
     socklen_t clilen;
     char buffer[256];
     struct sockaddr_in serv_addr, cli_addr;
     int n;

     if (argc < 2) {
         fprintf(stderr,"ERROR, no port provided\n");
         exit(1);
     }

     sockfd = socket(AF_INET, SOCK_STREAM, 0);
     if (sockfd < 0)
        error("ERROR opening socket");

     bzero((char *) &serv_addr, sizeof(serv_addr));
     portno = atoi(argv[1]);
     serv_addr.sin_family = AF_INET;
     serv_addr.sin_addr.s_addr = INADDR_ANY;
     serv_addr.sin_port = htons(portno);

     if (bind(sockfd, (struct sockaddr *) &serv_addr,
              sizeof(serv_addr)) < 0)
              error("ERROR on binding");

     listen(sockfd,5);
     clilen = sizeof(cli_addr);
     newsockfd = accept(sockfd,
                 (struct sockaddr *) &cli_addr,
                 &clilen);
     if (newsockfd < 0)
          error("ERROR on accept");

     bzero(buffer,256);
     n = read(newsockfd,buffer,255);
     if (n < 0) error("ERROR reading from socket");

     printf("Here is the message: %s\n",buffer);

     n = write(newsockfd,"I got your message",18);
     if (n < 0) error("ERROR writing to socket");

     return 0;
}
```
---
# Mail servers
Sono abbastanza interessanti in quanto la posta elettronica è un servizio un po' particolari: i vari nodi, ossia i server di posta, non hanno un ruolo ben definito. Ognuno di questi server può sia ricevere che spedire posta, giocando un ruolo sia da client che da server stesso. Ogni server quindi comprende due strutture per la gestione del traffico in entrata e in uscita:
![](Images/Pasted%20image%2020250506172559.png)
Il flusso in ingresso ha un punto importante di disaccoppiamento: le mail vengono ricevute ed inserite nelle mailbox degli utenti. L'elemento di disaccoppiamento esiste anche nel momento della ricezione, dov'è prevista una struttura dati che permette di attendere prima di mandarle effettivamente.
In realtà lo scenario della posta è molto più complesso. Possono esserci infatti  diversi nodi che fanno riferimento allo stesso utente, utile per distinguere ruoli diversi. Questo concetto è il concetto di ***alias***.
![](Images/Pasted%20image%2020250506173036.png)
Ognuno degli utenti, per mandare dei messaggi, utilizza un MDA. che permette di inserire la mail nello *spool* dei messaggi da inviare. Analogamente, questo messaggio viene inserito in una mailbox e viene poi visualizzato tramite un MUA (Mail User Agent). Tra questi c'è un MTA, Mail transmission agent, il quale comunica tra gli agenti del mittente e destinatario. 
![](Images/Pasted%20image%2020250506173545.png)
# SMTP protocol
SMTP significa ***Simple Mail Transfer Protocol*** e chiede una visione client (chi spedisce la mail) server (chi riceve la mail). Partiamo da una base abbastanza comoda, in quanto lo stack TCP/IP ci serve un sistema abbastanza reliable per la connessione tra due nodi.
Tutto lavora con codifica ASCII-7bit e utilizza la porta 25 per lo scambio di informazioni. Nel far questo, la dimensione di quello che viene spedito lievita del 30%. L'interazione prevede un protocollo stateful: la sessione creata prevede una successione di comandi e risposte.
Le risposte cominciano sempre con uno status code di tre caratteri da 0 a 9, mentre i comandi con quattro lettere. 
il trasferimento avviene seguendo tre fasi:
- dopo la creazione della connessione TCP, viene fatto un handshake anche in SMTP
- segue uno scambio di messaggi
- c'è infine una fase di chiusura della connessione
![](Images/Pasted%20image%2020250506174142.png)
- il primo che parla è il server, dove si presenta e dice "di essere pronto per la connessione", al contrario di altri tipi di connessioni
Ogni messaggio è composto da due parti:
- una serie di header
- una riga vuota
- il corpo della mail
Lo standard MIME nasce per inserire gli allegati all'interno delle mail. Questo elemento viene ripreso dall'HTTP e gli dà una grossa spinta.
#### Header classici:
- to
- from
- subject
- cc
Ci sono dei dati presenti sia nell'*envelope* che nell'header. Per questo a volte è possibile trovare *envelope from* e *header from*.
![](Images/Pasted%20image%2020250506174944.png)

---
# Esempio SMTP
```
nc -C servername 25
```
![](Images/Pasted%20image%2020250506175148.png)
```
mail #permette di vedere cosa c'è nella mailbox
```

Codice del client SMTP:
```python title=Client
#!/usr/bin/env python3 
import socket 
import os 
import sys 
import time 

HOST = '127.0.0.1' # (localhost) 
PORT = 25 # Port to connect to

def expect_response(s: str, exp_code: str): 
	data = s.splitlines() 
	for l in data: 
		print(l) 
	# data[last_line] -> response 
	rv = data[-1][0:3] 
	if rv != exp_code: 
	print('recv: "%s" instead of "%s"'%(rv, exp_code)) 
	sys.exit()
```

```python title=main 
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s: 
	s.connect((HOST, PORT)) 
	# Receive welcome message
	expect_response(s.recv(1024).decode('ascii'), '220') 
	# send HELO message 
	s.sendall('HELO localhost\r\n'.encode('ascii'))
	expect_response(s.recv(1024).decode('ascii'), '250') 
	# send MAIL envelope 
	s.sendall('MAIL FROM: \r\n' .encode('ascii'))
	expect_response(s.recv(1024).decode('ascii'), '250')
	s.sendall('RCPT TO: \r\n' .encode('ascii'))
	expect_response(s.recv(1024).decode('ascii'), '250')
	# send MAIL message (RFC822) 
	s.sendall('DATA\r\n'.encode('ascii')) 
	expect_response(s.recv(1024).decode('ascii'), '354') 
	s.sendall('From: riccardo \r\n'\ 'To: riccardo \r\n'\ 'Subject: prova\r\n\r\n'\ 'Messaggio di prova\r\n.\r\n'.encode('ascii'))
	expect_response(s.recv(1024).decode('ascii'), '250') 
	# Submit message 
	s.sendall('QUIT\r\n'.encode('ascii')) 
	expect_response(s.recv(1024).decode('ascii'), '221')
```

Codice server SMTP:
```python title=Server
#!/usr/bin/env python3 
import socket 
import sys 
import time 
import re 

HOST = '127.0.0.1' # Standard loopback interface (localhost) 
PORT = 2525 # Port to listen on (non-privileged ports are > 1023)
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
	s.bind((HOST, PORT)) 
	s.listen() 
	conn, addr = s.accept() 
	process_mail_request(conn)
	time.sleep(1)

def process_mail_request(conn): 
	# send welcome message 
	send_response(conn, '220', msg='Welcome from tinySMTP')
	msg = {} 
	rv = process_mail_command(conn, conn.recv(1024), msg) 
	# process commands, end when receiving QUIT 
	while rv != 'QUIT': 
		rv = process_mail_command(conn, conn.recv(1024), msg)
		if rv == 'DATA': 
		while not add_msg_body(conn.recv(1024), msg): pass 
		send_response(conn, '250', msg='Data received')

def process_mail_command(conn, data, msg): 
	if data is not None: 
		cmd=data[0:4].decode('ascii') 
		param=data[5:-1].decode('ascii').strip() 
		print('Mail command: cmd="%s", param="%s"'%(cmd, param)) 
		if cmd == 'QUIT': process_quit(conn, msg, msg='Goodbye') 
		if cmd == 'HELO': send_response(conn, '250') 
		if cmd == 'MAIL': process_envelope(conn, msg, cmd, param) 
		if cmd == 'RCPT': process_envelope(conn, msg, cmd, param) 
		if cmd == 'DATA': send_response(conn, '354') 
		return cmd

def send_response(conn, code, msg=''): 
resp=f'{code} {msg}\r\n' 
print('response is "%s"' % resp.splitlines()[0])
conn.sendall(resp.encode('ascii'))

def process_envelope(conn, msg, cmd, param):
	if cmd == 'MAIL': 
		m=re.search('FROM: <(.+)>', param) 
		msg['from'] = m.group(1) 
		print('add envelope sender %s' % msg['from'])
		send_response(conn, '250', msg='Sender OK') 
	if cmd == 'RCPT': m=re.search('TO: <(.+)>', param)
		msg['to'] = m.group(1) 
		print('add envelope recipient %s' % msg['to'])
		send_response(conn, '250', msg='Recipient OK')

def add_msg_body(data, msg): 
	data=data.decode('ascii') 
	if 'rfc822' not in msg.keys(): msg['rfc822']=''
	msg['rfc822'] += data 
	m=re.search('\r\n.\r\n', data) 
	print('adding data: "%s", rv: %r' % (data, bool(m)))
	return bool(m)
	
def process_quit(conn, msg): 
	print('submitting message %s', msg) 
	send_response(conn, '221')
```

La regular expression dice che mi aspetto di trovare un gruppo di caratteri che comprende uno o più caratteri che non sian [1h58]
[2h05]