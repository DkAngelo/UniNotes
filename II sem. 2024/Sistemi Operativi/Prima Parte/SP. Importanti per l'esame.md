- Se viene richiesto di trovare directory che contengono un file di nome "S.txt" non c'è bisogno di fare un for. Ad esempio, nel caso sia richiesto che il file sia anche leggibile e scrivibile:
```
if test -f $2.txt -a -r $2.txt -a -w $2.txt
then
	#fai cose
fi
```
- Se viene richiesto di trovare directory che contengono file che hanno per nome un numero di caratteri specifico, bisogna usare il seguente case (es. con 2 caratteri)
```
case $F in
	??)#caso giusto
		#ulteriori controlli;;
	*) #non si deve fare nulla;;
esac
```
 - per scrivere la directory corrente nel file temporaneo basta eseguire un pwd
```
pwd >> file-temporaneo
```
- per controllare che un parametro passato come stringa vada bene, bisogna eseguire tale controllo:
```
case $S in
	*/*)
		echo Errore: $S contiene il carattere '\'
		exit 4
		;;
	*) ;;
esac
```
- se come parametri abbiamo prima delle directory e poi altri parametri:
```
for i
do
	if test $count -ne $# (se ce n'e' solo uno)
	if test $count -lt `expr $# - 1` (se ce ne sono 2 alla fine)
	then
		#controllo sulle directory
	else
		#controllo sul parametro se ce n'e' solo uno
		if test $count -eq `expr $# - 1`
		then
			#controllo sul penultimo
		else
			#controllo sull'ultimo
		fi
	fi
done
```
- se abbiamo prima altri parametri e poi directory, controlliamo `$1 $2 ...` in base a quanti ne abbiamo prima, dopodiché eseguiamo n `shift` in base a quanti parametri abbiamo controllato. Proseguiamo con un `for G [in $*]` per controllare le directory