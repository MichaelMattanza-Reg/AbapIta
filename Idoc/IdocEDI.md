<h1>Idoc / EDI</h1>

Gli IDOC sono il mezzo di scambio dei dati all'interno dell'ale. E' riconosciuto da: messaggio logico (nome identificativo), tipo base (che ne definisce i segmenti interni e a sua volta i campi) e un opzionale ampliamento. Possono essere inbound o outbound. In sap vengono salvati su DB su varie tabelle. Ogni segmento generato crea una struttura a dictionary. 
Gli idoc inbound vengono elaborati da function module (collegato al process code) e wkf task.

Gli idoc sono divisi in tre sezioni principali:
- *Control record*: dati testata e instradamento
- *Payload*: dati dell'oggetto
- *Stati*: record riportanti dei cambi di stato

La trasmissione di idoc può essere gestita alla creazione accordo partner e pò essere:   
- trasmissione idoc immediata
- trasmissione idoc tramite job

**ALE**    
ALE ( Application Link Enabling ) è una tecnologia sap per scambiare dati tra sap e un altro sistema (esterno oppure sap):
- *Application Layer*: tool messi a disposizione tramite un'interfaccia.
- *Distribution layer*: gestisce filtri e conversioni basate su regole custom. Possono anche essere conversioni di adattamento a sistemi di versioni differenti
- *Communication Layer*: gestisce la comunicazione in modo sincrono/asincrono con gli altri sistemi. 

**EDI**   
Struttura utilizzata per lo scambio e la gestione tra fornitore e cliente di documenti elettronici secondo tracciati standard.
I documenti scambiati tramite EDI hanno valenza cartacea.

**Creare estensione idoc**   
Per estendere un idoc si parte da un tipo base    
Extension -> Si crea estensione e aggiungere i campi che si vogliono aggiungere al tipo base.   
Una volta scelto il segmento si aggiunge il tipo segmento con un minimo ed un massimo.   
Selezionare il flag ISO per le unità di misura.   
Per configurarlo: set realase da sm20.   
Tramite le user exit aggiungere i campi all'idoc

**Ampliare un Idoc**   
Per ampliare un Idoc è necessario creare un nuovo segmento tramite la transazione *WE31*.   
Una volta creato il segmento è necessario andare in *WE30* per creare un Idoc con riferimento ad un tipo base. Una volta creato aggiungere il segmento creato precedentemente.   
E' poi possibile collegare l'idoc ad un messaggio tramite la *WE82* ed ad una FM tramite la transazione *WE57*. Scrivere infine il codice in una exit o nella function creata tramite le transazioni *WE41 / WE42*. 


-------------------------------------------------------------------------------
Gli IDOC



Tipo base: WE30
visualizzare idoc scambiati: WE05 
Stato msg ale: BD87

variante messaggio: Bolla
funzione messaggio: bolla ingl, bolla ita

Il sistema logico è il sistema che manda o riceve.

Tipo messaggio: rappresenta il messaggio scambiato tra i sistemi ed è collegato al tipo idoc.

Variante messaggio: variante che indica step eseguibili solo il determinate condizioni

Modello di distribuzione: contenitore delle informazioni che indicano il flusso che possono avere i tipi di messaggio -> definire elenco messaggi logici che si vuole scambiare

Change pointer: i change pointer servono per propagare una modifica fatta a sistema a sistemi ad esso connessi. Intercettano modifiche a business object collegati ad un messaggio logico

Destinazione rfc: informazioni tecniche del sistema ricevente (ip + porta + info varie )

Porta: rappresentazione di un canale di comunicazione (per idoc usare RFC)

Accordi partner: Contenitore in cui vengono specificati tutti i tipi messaggio scambiabili in entrata/uscita con un determinato destinatario -> definire l'instradamento di un determinato idoc inbound/outbound

Codice processo: codice che indica il functiom module o api da richiamare per il processo dell'idoc

Processing
- Step generici
    - definizione sistema logico destinazione (SALE)
    - creazione dest RFC
    - creazione porta
    - creazione segmenti idoc
    - creazione tipo idoc
    - creazione tipo messaggio
    - collegamento fra msg e tipo idoc

- Outbound
    - configurazione accordi partner
    - chiamata functio per estrazione dati
    - conversione dati in idoc 
    - invio idoc

- Inbound
    - creazione function module
    - creazione codice di processamento
    - configurazione accordi partner

Se un idoc va in errore si può riprocessare (WE19), lanciare tramite un report apposito oppure cambiargli stato a mano e metterlo in stato "Da elaborare"
Vengono creati tanti segmenti idoc di errore quanti errori trovati. Le bapi al contrario danno un errore alla volta 

*aleaud01* conferma idoc in entrata a sistema sender. Puoi impostare quali messaggio intercettare e per quali partner questo idoc può essere triggerato



edidc -> info testata
edid4 (cambia in base alla versione del sistema) -> payload
edid -> record stati 