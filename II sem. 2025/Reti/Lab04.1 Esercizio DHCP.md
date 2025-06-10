## Reference scenario
![](Images/Pasted%20image%2020250401174522.png)
## Solution
Client 3
`hwaddress ether 02:04:06:11:22:33`
Permette di riscrivere l'indirizzo MAC, in quanto Marionnet solitamente lo assegna in maniera automatica.
![](Images/Pasted%20image%2020250401163119.png)
Il server DHCP **deve** avere un indirizzo statico:
![](Images/Pasted%20image%2020250401163211.png)
Questo perché si ha bisogno che abbia una scheda di rete già configurata all'avvio per ascoltare il resto della rete.
![](Images/Pasted%20image%2020250401163437.png)
Il protocollo DHCP serve a configurare gli host. All'interno del file quindi andremo a trovare alcune regole che gli indirizzi degli host dovranno avere al momento dell'assegnamento.
![](Images/Pasted%20image%2020250401164425.png)
Il numero 3 non viene utilizzato in presenza di DHCPv6, e quindi IPv6, in quanto si usa il ***parameter discovery***
![](Images/Pasted%20image%2020250401164737.png)
Per gli indirizzi riservati viene utilizzata la configurazione statica, mentre per il resto è possibile utilizzare l'opzione di ***DHCP range***. 
Posso sfruttare il fatto di avere accesso al DNS per togliere l'accesso a link con nomi noti (vedi l'ultima opzione).
### Metodo con l'utilizzo di host e ethers
![](Images/Pasted%20image%2020250401165138.png)
Il primo comando permette di avviare dnsmasq all'avvio della macchina, mentre il secondo permette di avviarlo in maniera manuale.
Una volta che abbiamo scritto tutto quindi, possiamo avviare prima il DHCP e poi andare ad avviare le schede di rete delle macchine (così da potergli assegnare dinamicamente un indirizzo IP).
Andremo a verificare l'effettivo funzionamento del tutto utilizzando il comando `ip addr show dev eth0`.