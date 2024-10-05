```
def check_type(var, type):
    if(isinstance(var, type)):
      print("{} è un'istanza di {}".format(var, type));
    else:
      print("{} non è un'istanza di {}".format(var, type));

a = "ciao"
check_type(a, str);
```

```
def check_type(var, type):
    if(isinstance(var, type)):
     return "Il tipo è giusto"
    else:
     raise TypeError(f"Il tipo non è giusto");

try:
  print(check_type("32", str))
except TypeError as e:
  print(f'{e}');
```

```
libri = {
    "Il Signore degli Anelli": "J.R.R. Tolkien",
    "1984": "George Orwell",
    "Il piccolo principe": "Antoine de Saint-Exupéry",
    "Orgoglio e pregiudizio": "Jane Austen"
}

for i, j in libri.items():
  print(i, ': ', j)
```