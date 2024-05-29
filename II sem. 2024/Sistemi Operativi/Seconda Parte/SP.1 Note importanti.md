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
	printf("Errore nell'allocazione della memoria\n"); 
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

## Comunicazione ring:
- con padre: bisogna allocare memoria per N+1 pipe
```
/* allochiamo memoria per il ring di pipe */
if ((pipes = (pipe_t *)malloc((Q + 1) * sizeof(pipe_t))) == NULL)
{
	printf("ERRORE - Allocazione di memoria non riuscita\n");
	exit(4);
}
/* creiamo le pipe */
for (i = 0; i <= Q; i++)
{
	if (pipe(pipes[i]) < 0)
	{
		printf("ERRORE - Pipe non generata\n");
		exit(5);
	}
}
...

/* ogni figlio legge da q e scrive su q+1 */
for (i = 0; i <= Q; i++)
{
	if ((i != q))
	{
	close(pipes[i][0]);
	}
	if (i != (q + 1))
	{
		close(pipes[i][1]);
	}
}
...

/* codice padre */
/* chiusura delle pipe non utilizzate */
for (i = 0; i <= Q; i++)
{
	if (i != Q)
	{
	close(pipes[i][0]);
	}
	if (i != 0)
	{
		close(pipes[i][1]);
	}
}
```

- senza padre
```
/* allocazione pipe */
if ((pipes=(pipe_t *)malloc(Q*sizeof(pipe_t))) == NULL)
{
	printf("Errore allocazione pipe\n");
	exit(2); 
}
/* creazione pipe */
for (q=0;q<Q;q++)
if(pipe(pipes[q])<0)
{
	printf("Errore creazione pipe\n");
	exit(3);
}
...
/*ogni processo figlio legge dalla pipe q e scrive sulla pipe (q+1)%Q */
for (j=0;j<Q;j++)
{
	if (j!=q)
		close (pipes[j][0]);
	if (j != (q+1)%Q)
		close (pipes[j][1]);
}
...

/*codice padre*/
/* chiusura di tutte le pipe che non usa, a parte la prima perche' il padre deve dare il primo OK al primo figlio. 
N.B. Si lascia aperto sia il lato di scrittura che viene usato (e poi in effetti chiuso) che il lato di lettura (che non verra' usato ma serve perche' non venga inviato il segnale SIGPIPE all'ultimo figlio che terminerebbe in modo anomalo)  */
for(q=1;q<Q;q++) 
{
	close (pipes[q][0]);
	close (pipes[q][1]); 
}
/* ora si deve mandare l'OK al primo figlio (P0): nota che il valore della variabile ok non ha importanza */
nw=write(pipes[0][1],&ok,sizeof(char));
/* anche in questo caso controlliamo il risultato della scrittura */
if (nw != sizeof(char))
{
	printf("Padre ha scritto un numero di byte sbagliati %d\n", nw);
    exit(5);
}

/* ora possiamo chiudere anche il lato di scrittura, ma ATTENZIONE NON QUELLO DI LETTURA! */
close(pipes[0][1]);
```