Le interazioni tra processi dipendono da tre elementi principiali:
1. Processi comunicanti:
	- Figli che comunicano dal padre, e viceversa
	- Figli che inviano pipeline al padre o si fermano all'ultimo figlio
	- Figli che comunicano con i nipoti o viceversa
	- Nipoti che comunicano direttamente col padre o viceversa
	- Figli a coppie (Figlio pari/dispari, Figlio Pi/Pi+N, Figlio Pi/P2\*N-1-i. Il primo avviene solo con N pari, il secondo con 2\*N figli generati)
	- Figli che comunicano secondo uno schema a ring (il padre può essere o non essere compreso nella comunicazione, aggiungendo o togliendo una pipe al numero totale di pipe generate)
	Tali processi possono sia scambiarsi informazioni effettive o anche semplici "token" per la sincronizzazione. Per tale scopo potrebbero essere utilizzati anche i segnali, seppur questi potrebbero complicare il codice. A meno che non venga specificato quindi (ad esempio, terminazione dei processi tramite `SIGKILL`) è preferibile usare semplici caratteri di verifica come "token"
2. Numero di informazioni scambiate:
	- Solo un'informazione
	- Più informazioni di numero noto
	- Più informazioni di numero non noto
3. Ordine di recupero delle informazioni:
	E' qualcosa che solitamente affronta il padre, ma non è una cosa esclusiva:
	- In ordine dei file
	- Primo figlio, ultimo figlio, secondo figlio, penultimo figlio...
	- Figlio pari, figlio dispari

## Esempi visti a lezione
- 26 Maggio 2017: A2a B1 C1
- 12 Febbraio 2016: A2a B2 C2
- 12 Luglio 2017: A3 B3, A1 B3 C3
- 11 Luglio 2018: A1 B3 C2, A1 B3
- 17 Febbraio 2021: A6a B3 C1
- 19 Gennaio 2022:
- 8 Giugno 2016: A1 B2 C1, A1 B2