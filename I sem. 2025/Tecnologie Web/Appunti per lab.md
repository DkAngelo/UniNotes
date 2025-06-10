**Ricorda:** se vuoi provare qualcosa di React, commenta tutto cio' che non usi. Per vedere quali problemi ha la pagina, nel caso non si carica, fai `F12` e apri la console del browser.
### Esame del 9/01
1. Scrivere una funzione che restituisca tutti gli eventi presenti nel file `events.csv`.

**Soluzione:** nell'`app.py` scrivere:
```python
def load_events():  
    events = []  
    csv_path = os.path.join(os.path.dirname(__file__), 'data/events.csv')  
  
    try:  
        with open(csv_path, mode='r', encoding='utf-8') as csv_file:  
            csv_reader = csv.DictReader(csv_file)  
            for row in csv_reader:  
                events.append(row)  
        return events  
    except FileNotFoundError:  
        print('File not found:', csv_path)  
        return []  
    except Exception as e:  
        print('Error loading data: ', e)  
        return []
```

2. Modificare la route `/index` per renderizzare un template `index.html`, che estende il template di base. Il template deve visualizzare una tabella con gli eventi sportivi disponibili. Se non ci sono eventi, mostrare il messaggio “Nessun evento disponibile”.

**Soluzione:** in `app.py` scrivere il seguente codice:
```python
@app.route('/index') 
def index():  
    return render_template('index.html', events=load_events())
```
**Nota:** se vogliamo far visualizzare questa pagina in maniera diretta, evitiamo di scrivere *index*. Tuttavia, la soluzione proposta segue effettivamente la traccia.

Si crea poi un file `index.html` nella cartella dei template e al suo interno scrivi il seguente codice:
```html title=index.html
{% extends "base.html" %}  
  
{% block title %} Index {% endblock %}  
  
{% block content %}  
  
        {% if not events %}  
  
            <h1>Nessun evento disponibile</h1>  
  
        {% else %}  
             <table>  
                <thead>
	                <th>Codice Evento</th>  
                    <th>Nome Evento</th>  
                    <th>Sport</th>  
                    <th>Data</th>  
                    <th>Luogo</th>  
                    <th>Posti disponibili</th>  
                </thead>                
                <tbody>                    
                {% for event in events %}
                        <tr> <!-- Esercizio 3 a + app-->  
                            <td> <a href="{{ url_for('event', event_id=event['code']) }}"> {{ event['code'] }}</a></td>  
                            <td> <a href="{{ url_for('event', event_id=event['code']) }}"> {{ event['name'] }} </a></td>  
                            <td> <a href="{{ url_for('event', event_id=event['code']) }}"> {{ event['sport'] }} </a></td>  
                            <td> <a href="{{ url_for('event', event_id=event['code']) }}"> {{ event['date'] }} </a></td>  
                            <td> <a href="{{ url_for('event', event_id=event['code']) }}"> {{ event['place'] }} </a></td>  
                            <td> <a href="{{ url_for('event', event_id=event['code']) }}"> {{ event['available_places'] }} </a></td>  
                        </tr>                    
                {% endfor %}  
                </tbody>  
            </table>        
        {% endif %}  
  
{% endblock %}
```
Dove `<thead>` permette di raggruppare diversi header `<th>` e `<tbody>` le diverse `<tr>` (table row) con i relativi `<td>` (table data) al suo interno. Viene messo un `<th>` e un `<td>` per ogni proprieta' specificata nella traccia per gli oggetti da tabellare. Nel nostro caso infatti, ogni evento aveva un codice, un nome, uno sport, una data, un luogo e un numero di posti disponibili.
`events` e' la lista di eventi passata come input (importante che abbia lo stesso nome nei parametri del return). 

3. Rendere cliccabile ogni riga della tabella. Quando un utente clicca su un evento, reindirizzarlo a una pagina dedicata `/event/<event_code>` che mostri i dettagli dell’evento corrispondente al codice, formattati in modo chiaro e leggibile.

**Soluzione:** per rendere cliccabili gli eventi, si inserisce un `<a>` che riporta alla pagina con link `"{{ url_for('event', event_id=event['code']) }}"` per ogni dato da inserire in tabella. Dopodiché:
- in `app.py` inseriamo il seguente codice:
```python
@app.route('/event/<event_id>')  
def event(event_id):  
    events = load_events()  
    for e in events:  
        if e['code'] == event_id:  
            return render_template('event.html', event=e)
```
(creiamo la lista degli eventi, creata grazie alla funzione del primo esercizio, e cerchiamo l'evento su cui abbiamo cliccato, e quindi per il quale passiamo l'`event_id` definito come variabile nelle `<a>` di `index.html`. Se la troviamo, creiamo una nuova pagina che ha come input l'evento trovato)
- Per creare la nuova pagina, avremo bisogno quindi di un template `event.html` (cosi' come definito nella funzione di render) con il seguente codice:
```html title=event.html
{% extends "base.html" %}  
  
{% block title %} Dettagli Evento {% endblock %}  
  
{% block content %}  
    <h1>Dettagli Evento: {{ event['name'] }}</h1>  
    <p><strong>Codice Evento:</strong> {{ event['code'] }}</p>  
    <p><strong>Sport:</strong> {{ event['sport'] }}</p>  
    <p><strong>Luogo:</strong> {{ event['place'] }}</p>  
    <p><strong>Data:</strong> {{ event['date'] }}</p>  
    <p><strong>Posti Disponibili:</strong> {{ event['available_places'] }}</p> 
{% endblock %}
```
**Nota:** il tag `<strong>` serve a definire parti di testo importanti e quindi scritte in grassetto

4. Nella pagina evento, aggiungere un pulsante per prenotare un posto all’evento. Il pulsante deve chiamare un’API Flask `/api/book/<event_code>` tramite il metodo POST. Ridurre di uno il numero di posti disponibili nel file `events.csv`. Gestire eventuali errori, come posti esauriti, mostrando messaggi appropriati all’utente.

**Soluzione:** si crea l'API all'interno dell'`app.py`:
```python
@app.route('/api/book/<event_code>', methods=['GET','POST']) 
def book(event_code):
    # Prova ad aggiornare i posti disponibili  
    result = update_event(event_code)  
    if result is False:  
        # Se non c'è posto disponibile, ritorna un errore  
        return jsonify({"error": "Posti esauriti"}), 400  
    else:  
        return jsonify({"message": "Prenotazione effettuata con successo!"}), 200
```
`update_event` e' una funziona da noi costruita per provare ad aggiornare i posti dell'evento dato e riscrivere il file `csv`:
```python title="Funzione per modificare il numero di posti"
def update_event(event_code):  
    events = load_events()  
    csv_path = os.path.join(os.path.dirname(__file__), 'data/events.csv')  
    # Trova l'evento e aggiorna i posti disponibili  
    for event in events:  
        if event['code'] == event_code:  
            if int(event['available_places'])==0:  
                return False  
            else:  
                event['available_places'] = str(int(event['available_places']) - 1)  
                # Riscrivi il file CSV con i nuovi dati  
                try:  
                    with open(csv_path, mode='w', encoding='utf-8', newline='') as csv_file:  
                        fieldnames = ['code', 'name', 'sport', 'place', 'date', 'available_places']  
                        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)  
                        writer.writeheader()  
                        writer.writerows(events)  
                except FileNotFoundError:  
                    print('File not found:', csv_path)  
                    return []  
                except Exception as e:  
                    print('Error loading data: ', e)  
                    return []  
                return True  
    return False
```
Dopodiché si modifica il file `event.html` aggiungendo il seguente codice:
```html
<!--Esercizio 4-->  
{% if  event['available_places']|int > 0 %}  
    <form action="{{ url_for('book', event_code=event['code']) }}" method="post">  
        <button type="submit">Prenota un posto</button>  
    </form>  
{% else %}  
    <h1>Posti esauriti, non è possibile prenotare</h1>  
{% endif %}
```
(`event_code`, riferito alla codice dell'evento, viene richiamato anche nell'API. Bisogna fare attenzione quindi che il nome utilizzato sia sempre lo stesso)

5. Creare due API: 
	- Una per restituire tutti gli eventi in formato JSON 
	- Una per restituire i dettagli di un singolo evento basandosi sul codice dell’evento

**Soluzione:** all'interno dell'`app.py` andiamo a definire le due API in questo modo:
```python title="API per la restituzione degli eventi"
@app.route('/api/event', methods=['GET', 'POST'])  
def get_eventi(): #Restituisce gli eventi in formato JSON  
    events = load_events()  
    if not events:  
        return jsonify([])  # Ritorna un array vuoto se non ci sono eventi  
  
    return jsonify(events)
```

```python title="API dettagli evento singolo"
@app.route('/api/events/<event_code>', methods=['GET', 'POST'])  
def get_evento(event_code):  
    for e in load_events():  
        if e['code'] == event_code:  
            return jsonify(e)  
    return jsonify("Errore, Evento non trovato")
```

6. Creare una route `/react` lato Flask per renderizzare il template `index_react.html` dove costruire una SPA con React. Tutte le route da impostate con react dovranno sottostare al path `/react`. Ad esempio, `/react/event_detail`, `/react/book`, ecc.

**Soluzione:** nell'`app.py` inserire il seguente codice:
```python
@app.route('/react')  
def react():  
    events = load_events()  
    return render_template('index_react.html', events=events)
```

7. Creare una componente React `EventList` per visualizzare la lista di eventi in una tabella analoga a quella del punto 3. Associare questa componente alla route `/react`. Diversamente dalla tabella precedente, ogni riga deve avere un pulsante per prenotare un posto, che richiami una conferma prima di effettuare l’azione. Aggiornare i posti disponibili in tempo reale.

**Soluzione:** nel file `index_react.html` aggiungere il seguente codice:
```jsx title=index_react.html
function EventList(props) {  
    const [eventsData, setEventsData] = React.useState([]);  
  
    function handleBooking(evento) {  
        event.preventDefault()  
        const confirmed = window.confirm("Sei sicuro di voler prenotare un posto?");  
        if (confirmed) {  
            // Richiesta di prenotazione tramite l'API del punto 4  
            fetch(`/api/book/${evento.code}`, {  
                method: 'POST',  
                headers: {  
                    'Content-Type': 'application/json'  
                },  
                body: JSON.stringify()  
            })  
                .then(function (response) {  
                    return response.json().then(function (result) {  
                        if (response.ok) {  
                            alert('Prenotazione effettuata');  
                            fetchEvents()  
                        } else {  
                            alert("Error: " + result.error);  
                        }  
                    });  
                })  
                .catch(function (error) {  
                    console.error('Error during booking:', error);  
                    alert("Error: " + error.message);  
                });  
        }  
}  
  
  
    function fetchEvents() {  
        fetch('api/event') //funzione che restituisce gli eventi in formato json, punto prec.  
            .then(function(response){return response.json();})  
            .then(function(data){ setEventsData(data)})  
           .catch(function(error){ console.error(error)});  
    }  
    // Fetch events from the API  
    React.useEffect(function () {  
        fetchEvents()  
    }, []);  
  
    return React.createElement(  
        'table',  
        null,  
        React.createElement(  
            'thead',  
            null,  
            React.createElement(  
                'tr',  
                null,  
                React.createElement('th', null, 'Codice Evento'),  
                React.createElement('th', null, 'Nome Evento'),  
                React.createElement('th', null, 'Sport'),  
                React.createElement('th', null, 'Data'),  
                React.createElement('th', null, 'Luogo'),  
                React.createElement('th', null, 'Posti disponibili'),  
                React.createElement('th', null, '')  
            )  
        ),  
        React.createElement(  
            'tbody',  
            null,  
            eventsData.map(evento => React.createElement(  
                'tr',  
                { key: evento.code },  
                React.createElement('td', null, evento.code),  
                React.createElement('td', null, evento.name),  
                React.createElement('td', null, evento.sport),  
                React.createElement('td', null, evento.date),  
                React.createElement('td', null, evento.place),  
                React.createElement('td', null, evento.available_places),  
                React.createElement('td', null,  
                    React.createElement('button', { onClick: () => handleBooking(evento) }, 'Prenota posto')  
                )  
            ))  
        )  
    );  
}
```
sempre nello stesso file, aggiungere nel componente principale (dato di base) la seguente dichiarazione dopo lo `Switch`:
```jsx
React.createElement(Route, { exact: true, path: '/react', component: EventList }),
```

8.  Rendere cliccabile il nome dell'evento nella tabella React per navigare verso una route `/react/event/:id`. associare una componente `EventDetail` per visualizzare i dettagli dell’evento selezionato

**Soluzione:** lavoriamo sul file `index_react.html`. Per rendere cliccabile il nome dell'evento, al posto di  `React.createElement('td', null, evento.name)` andiamo a sostituire la seguente dichiarazione:
```jsx
React.createElement('td', null, 
	React.createElement(Link, {to: `react/event/${evento.code}`, evento.name),)
```
Dopodiché creiamo il nuovo componente:
```jsx title="Componente EventDetail"
function EventDetail({ match }) {  
    const [eventDetail, setEventDetail] = React.useState(null);  
    const eventId = match.params.id; // Ottieni l'id dell'evento dalla route  
  
    React.useEffect(() => {  
        // Recupera i dettagli dell'evento da un'API o un'altra sorgente  
        fetch(`/api/events/${eventId}`, {  
            method: 'GET',  // Usato GET senza body  
            headers: {  
                'Content-Type': 'application/json'  
            }  
        })  
        .then(response => {  
            if (!response.ok) {  
                throw new Error('Evento non trovato');  
            }  
            return response.json();  
        })  
        .then(data => {  
            setEventDetail(data); // Aggiorna lo stato con i dettagli dell'evento  
        })  
        .catch(error => {  
            console.error('Error fetching event details:', error);  
            alert('Errore: ' + error.message);  // Mostra un errore all'utente  
        });  
    }, [eventId]);  
  
    if (!eventDetail) {  
        return React.createElement('div', null, 'Loading event details...');  
    }  
  
    return React.createElement(  
        'div',  
        null,  
        React.createElement('h1', null, `Dettagli dell'evento: ${eventDetail.name}`),  
        React.createElement('p', null, `Codice Evento: ${eventDetail.code}`),  
        React.createElement('p', null, `Sport: ${eventDetail.sport}`),  
        React.createElement('p', null, `Data: ${eventDetail.date}`),  
        React.createElement('p', null, `Luogo: ${eventDetail.place}`),  
        React.createElement('p', null, `Posti disponibili: ${eventDetail.available_places}`),  
    );  
}
```
Infine, nello switch del componente principale, andiamo ad aggiungere la seguente dichiarazione:
```jsx
React.createElement(Route, { path: '/react/event/:id', component: EventDetail }
```

### Simulazione 1
1. Nella pagina prodotto creare un pulsante elimina (dove si ritiene opportuno) che elimini il prodotto dal file `magazzino.csv` utilizzando il codice JavaScript dedicato, che richiami l’API `/api/elimina/` con metodo DELETE.

**Soluzione:** per quanto riguarda l'API andremo a scrivere il seguente codice:
```python
@app.route('/api/elimina/<prodotto_codice>', methods=['DELETE'])  
def book(prodotto_codice):  
    # Prova ad aggiornare i prodotti disponibili  
    result = update_prodotti(prodotto_codice)  
    if result is False:  
        # Qualcosa è andato storto  
        return jsonify({"errore nell'eliminazione del prodotto"}), 400  
    else:  
        return jsonify({"message": "Eliminazione effettuata con successo!"}), 200
```

Dove `update_prodotti` e' la seguente funzione:
```python title=update_prodotti
def update_prodotti(prodotto_codice):  
    prodotti = load_prodotti()  
    csv_path = os.path.join(os.path.dirname(__file__), 'data/magazzino.csv')  
    try:  
        with open(csv_path, mode='w', encoding='utf-8', newline='') as csv_file:  
            fieldnames = ['codice', 'nome', 'quantita', 'prezzo']  
            writer = csv.DictWriter(csv_file, fieldnames=fieldnames)  
            writer.writeheader()  
            for prodotto in prodotti:  
                if prodotto_codice != prodotto['codice']:  
                    writer.writerow(prodotto)  
        return True  
    except FileNotFoundError:  
        print('File not found:', csv_path)  
        return []  
    except Exception as e:  
        print('Error loading data: ', e)  
        return []
```

Per quanto riguarda il file `prodotto.html` (gia') creato in un esercizio precedente, andremo ad aggiungere il bottone per l'eliminazione del prodotto in questo modo:
```javascript
<script>  
    document.addEventListener('DOMContentLoaded', function () {  
        const deleteButton = document.getElementById('delete-button');  
        prodotto_codice = document.getElementById('{{ prodotto.codice }}').textContent.split(':')[1].trim();  
        console.log(prodotto_codice);  
        deleteButton.addEventListener('click', function () {  
            fetch(`/api/elimina/${prodotto_codice}`, {  
                method: 'DELETE',  
                headers: {  
                    'Content-Type': 'application/json',  
                },  
            })  
                .then(response => {  
                    if (response.ok) {  
                        alert('Prodotto eliminato con successo.');  
                        window.location.href = '/';  
                    } else {  
                        alert('Errore durante l\'eliminazione del prodotto.');  
                    }  
                })  
                .catch(error => {  
                    console.error('Errore:', error);  
                    alert('Errore durante l\'eliminazione del prodotto.');  
                });  
  
        });  
    });  
</script>
```
Fai attenzione ad aggiungere l'id `delete-button` al bottone e l'id `{{ prodotto.codice }}` al paragrafo con il codice dell'elemento creati nello stesso file, altrimenti non funziona.

2. Creare una componente React `ProductList` per renderizzare una tabella dei prodotti analoga quella del punto 2. Associare questa componente alla route `/react`. Rispetto alla sua variante precedente, ogni riga della tabella dovrà contenere un **bottone rosso di classe** per eliminare il prodotto corrispondente. Chiedere conferma all’utente prima di cancellare il prodotto usando un `confirmDialog`.

**Soluzione**: molto simile al precedente esercizio 7, andiamo a creare il seguente componente (fai attenzione a come chiami i vari fetch, e al `classname` del bottone)
```jsx
function ProductList(){  
    const [productsData, setProductsData] = React.useState([]);  
  
    function handleDelete(prodotto){  
        event.preventDefault()  
        const confirmed = window.confirm("Sei sicuro di voler eliminare il prodotto selezionato?")  
        if(confirmed){  
            //Richiesta eliminazione tramite l'API del punto 4  
            fetch(`/api/elimina/${prodotto.codice}`,{  
                method: 'DELETE',  
                headers: {  
                    'Content-Type':'application/json'  
                }  
            })  
            .then(function (response) {  
            return response.json().then(function (result) {  
                if (response.ok) {  
                    alert('Eliminazione effettuata');  
                    fetchProdotti()  
                } else {  
                    alert("Error: " + result.error);  
                }  
            });  
        })  
        .catch(function (error) {  
            console.error('Error during delete:', error);  
            alert("Error: " + error.message);  
        });  
        }  
    }  
    function fetchProdotti() {  
        fetch('api/prodotto') //funzione che restituisce i prodotti in formato json, punto prec.  
        .then(function(response){return response.json();})  
        .then(function(data){ setProductsData(data)})  
        .catch(function(error){ console.error(error)});  
    }  
    // Fetch events from the API  
    React.useEffect(function () {  
        fetchProdotti()  
    }, []);  
  
    return React.createElement(  
        'table',  
        null,  
        React.createElement(  
            'thead',  
            null,  
            React.createElement(  
                'tr',  
                null,  
                React.createElement('th', null, 'Codice'),  
                React.createElement('th', null, 'Nome'),  
                React.createElement('th', null, 'Quantita\''),  
                React.createElement('th', null, 'Prezzo'),  
                React.createElement('th', null, '')  
            )  
        ),  
        React.createElement(  
            'tbody',  
            null,  
            productsData.map(prodotto => React.createElement(  
            'tr',  
             { key: prodotto['codice'] },  
                React.createElement('td', null, prodotto.codice),  
                React.createElement('td', null, prodotto.nome),  
                React.createElement('td', null, prodotto.quantita),  
                React.createElement('td', null, prodotto.prezzo),  
                React.createElement('td', null,  
                React.createElement('button', {  className: "btn btn-danger mt-3", onClick: () => handleDelete(prodotto) }, 'Elimina Prodotto')  
                )))));  
}
```
### Esame 12/02

1. Nella pagina del video, aggiungere un textbox e un bottone "Aggiungi". Il bottone deve chiamare un'API Flask tramite metodo POST per aggiungere un commento nuovo al video. Aggiungere nel file `comments.csv` il nuovo commento associato al codice del video

**Soluzione**: creare l'API lato flask in questo modo:
```python title="API per aggiungere istanze al file csv tramite form"
@app.route('/api/newComment/<video_code>', methods=["POST"])  
def newComment(video_code):  
    newComment = request.form['new_comment']  
    csv_path = os.path.join(os.path.dirname(__file__), 'data/comments.csv')  
    try:  
        with open(csv_path, mode='a', encoding='utf-8', newline='') as csv_file:  
            writer = csv.writer(csv_file)  
            writer.writerow([video_code, newComment])  
            return jsonify({'success': True})  
    except FileNotFoundError:  
        print('File not found: ', csv_path)  
    except Exception as e:  
        print('Error loading data: ', e)
```
Nel file `video.html` (ossia il template per i dettagli) aggiungere il seguente codice:
```html title="Invio istanza tramite form"
<div>  
    <form action="/api/newComment/{{ video['video_code'] }}" method="post">  
        <label for="new_comment">New Comment:</label>  
        <input type="text" id="new_comment" name="new_comment"><br>  
        <input type="submit" value="Aggiungi">  
    </form>
    </div>
```
**ATTENZIONE**: per far si' che Flask riceva effettivamente cio' che gli si invia tramite il form, c'e' bisogno che i campi di input abbiano il campo `name` corrispondente alla dichiarazione tra quadre in `request.form[]`.

2. Nella pagina aggiungere un bottone che permette di ritornare ad `index.html`
**Soluzione:** basta indicare un anchor nel bottone per la route `index` in questo modo:
```html
<a href="{{ url_for('index') }}"><button class="btn btn-primary">Torna indietro</button></a>
```

3. Modificare la route `/index` per renderizzare un template `index.html` che estenda il template di base. Il template mostra una tabella con l'elenco dei video disponibile, con nome del video e numero di commenti associati ad esso

**Soluzione:** di per se' e' molto simile alle altre tabelle fatte. Per ottenere il numero di commenti di un video e permetterne la visualizzazione si fa in questo modo:
```python title="Route lato flask"
@app.route('/index')  
def index():  
    videos=load_video()  
    for video in videos:  
        video['num_commenti'] = comments_num(video['video_code'])  
    return render_template('index.html', videos=videos)
```
Dove `comments_num` e' la seguente funzione (i commenti si riferivano al video attraverso il codice dello stesso):
```python
def comments_num(video_code):  
    comments = load_comments()  
    num = 0  
    for comment in comments:  
        if comment['video_code'] == video_code:  
           num+=1  
    return num
```
All'interno del file HTML era quindi possibile usare l'espressione `{{ video['num_commenti'] }}` per usare la variabile e visualizzare il numero di commenti associato al video stesso.
### Bootstrap
- Card per i dettagli: un `<div class=card style="margin 0 auto">`, poi crei un altro `<div class=card-body>` dove inserire tutte le informazioni. Le informazioni avranno `<p class="card-text">`, mentre il titolo `<h1 class="card-title">` oppure `card-header`.
- Bottone rosso:`<button class="btn btn-danger mt-4">` (mt-4 e' la dimensione)
- Tabella: `<table class="table table-hover">`
A qualsiasi elemento potra' comunque essere inserito un id cosi' da modificarne colore, grandezza del font ecc.
Per usare Bootstrap includi questo all'interno dell'header:
```html
<!-- Bootstrap CSS -->  
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
```