## Situazione iniziale
![](Images/Pasted%20image%2020250513165548.png)
- nella rete dell'azienda FAKE, rete da proteggere, ci sono sia indirizzi pubblici che privati
- il server DHCP fa sia da server DHCP che da server DNS
- il firewall è implementato sul router di border e:
	- implementa ciò che è necessario per surfare l'internet
	- implementa le regole di filtro descritte nel file a pag.3 ![](Files/I-Firewall1.pdf) 
Per ogni politica è descritta una regola da implementare. La si implementa e si cerca di capire cos'è che fanno.
- Dopo l’inserimento di una nuova regola di filtraggio o di nat, verificate che la regola sia stata effettivamente aggiunta nella tabella e nella catena corrette utilizzando l’opzione `-L`. Verificatene inoltre gli effetti sulla raggiungibilità delle macchine e sulla fruibilità dei loro servizi.
### Policy particolari
- Consentire flussi di comunicazione UDP provenienti dalla DMZ e diretti al server DHCP relay in esecuzione sul firewall: per la comunicazione tra server DHCP e host vengono utilizzate le porte 68 e 67 (68 è chi richiede l'IP, 67 il server)
```
iptables -t filter -A INPUT -i eth0 -p udp --sport 68 --dport 67 -j ACCEPT
```