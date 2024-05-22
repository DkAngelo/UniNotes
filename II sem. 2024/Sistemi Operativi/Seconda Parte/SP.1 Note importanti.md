## Ottenimento di N pipe, con N non noto staticamente (cambia durante l'esecuzione)
1) Definizione di un array dinamico
```
/* definizione del TIPO pipe_t come array di 2 interi */
piped typedef int pipe_t[2]; 
...
/* array dinamico di pipe descriptors per comunicazioni figli-padre */
pipe_t *piped;  
```

2) Allocazione di un array dinamico "piped" di dimensione N (sempre da controllare)
```
/* Allocazione dell'array di N pipe descriptors */ 
piped = (pipe_t *) malloc (N*sizeof(pipe_t));
if (piped == NULL) 
{ 
	printf("Errore nella allocazione della memoria\n"); 
	exit(3);
}
```

3) Creazione delle N pipe per la comunicazione figli-padre
```
/* Creazione delle N pipe figli-padre */
for (j=0; j < N; j++) { 
	if(pipe(piped[j]) < 0) { 
		printf("Errore nella creazione della pipe\n");
		exit(); 
	} 
}
```

4) Chiusura pipe non utilizzate
```
/* Chiusura delle pipe non usate nella comunicazione con il padre */ 
for (k=0; k < N; k++) { 
	close(piped[k][0]); 
	if (k != i) 
		close(piped[k][1]); 
} 

/* padre chiude tutte le pipe che non usa */ 
for (k=0; k < N; k++) { close(piped[k][1]);}
```

## Comunicazione dal figlio 0 al figlio N-1, che comunica al padre
Le operazioni di close da fare sono le seguenti:
- **Figlio 0**: 
	- Chiude tutte le estremità di lettura (`pipefd[j][0]` per ogni `j`).
	- Chiude tutte le estremità di scrittura non necessarie (`pipefd[j][1]` per ogni `j` tranne `pipefd[0][1]`).
	- Scrive alla pipe `pipefd[0][1]` 
- **Figli i**:
	- Chiudono tutte le estremità di lettura non necessarie (`pipefd[j][0]` per ogni `j` tranne `pipefd[i-1][0]`).
	- Chiudono tutte le estremità di scrittura non necessarie (`pipefd[j][1]` per ogni `j` tranne `pipefd[i][1]`).
	- Leggono dalla pipe `pipefd[i-1][0]`
	- Scrivono alla pipe `pipefd[i][1]`
- **Padre**:
	- Chiude tutte le estremità di scrittura (`pipefd[i][1]`) delle pipe.
	- Chiude tutte le estremità di lettura (`pipefd[i][0]`) tranne l'ultima (`pipefd[NUM_CHILDREN-1][0]`).
	- Legge dall'ultima pipe (`pipefd[NUM_CHILDREN-1][0]`) 

## Se nell'argc c'è un carattere:
- Controllo che `strlen(argc[1]) == 1`
- Isolo il carattere come `char Cz = argv[1][0]`