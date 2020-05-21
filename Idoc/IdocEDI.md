<h1>Idoc / EDI</h1>

Gli IDOC sono il mezzo di scambio dei dati all'interno dell'ale con una struttura riconducibile a un file XML. Un idoc è riconosciuto da: messaggio logico (nome identificativo), tipo base (che ne definisce i segmenti interni e a sua volta i campi) e un opzionale ampliamento. Possono essere inbound o outbound. In sap vengono salvati su DB su varie tabelle. Ogni segmento generato crea una struttura a dictionary. 
Gli idoc inbound vengono elaborati da function module (collegato al process code) e wkf task.

Gli idoc sono divisi in tre sezioni principali:
- *Control record*: dati testata e instradamento
- *Payload*: dati dell'oggetto
- *Stati*: record riportanti dei cambi di stato

La trasmissione di idoc può essere gestita alla creazione accordo partner e pò essere:   
- trasmissione idoc immediata
- trasmissione idoc tramite job

**Concetti di base**   
*ALE*    
ALE ( Application Link Enabling ) è una tecnologia sap per scambiare dati tra sap e un altro sistema (esterno oppure sap):
- *Application Layer*: tool messi a disposizione tramite un'interfaccia.
- *Distribution layer*: gestisce filtri e conversioni basate su regole custom. Possono anche essere conversioni di adattamento a sistemi di versioni differenti
- *Communication Layer*: gestisce la comunicazione in modo sincrono/asincrono con gli altri sistemi. 

*EDI*   
Struttura utilizzata per lo scambio e la gestione tra fornitore e cliente di documenti elettronici secondo tracciati standard.
I documenti scambiati tramite EDI hanno valenza cartacea.

*Tipo messaggio*   
Rappresenta il messaggio scambiato tra i sistemi ed è collegato al tipo idoc.

*Variante messaggio*   
Rappresenta step alternativi al messaggio originale in determinate condizioni.

*Funzione messaggio*   
Alternativa di un messaggio principale. Medesimo oggetto lavorato ma con qualcosa di differente (es. lingua diversa)

*Sistema logico*   
Sistema che manda/riceve gli idoc

*Modello di distribuzione*   
Il modello di distrbuzione definisce l'elenco dei messaggi logici che il sistema scambia con un determinato sistema logico. Ogni messaggio logico ha detrminati filtri che lo descrivono. 

*Change pointer*   
I change pointer servono per propagare una modifica fatta a sistema su oggetti di business. Intercettano modifiche dei dati che possiamo definire "a noi interessanti" in modo che venga propagata solo la modifica dei dati fondamentali.

*Accordi partner*   
Oggetto di customizing obbligatorio. Viene definito per ogni comunicazione punto-punto. E' come un contenitore in cui vengono specificati tutti i tipi messaggio scambiabili in entrata/uscita con un determinato destinatario.
Serve definire l'instradamento di un determinato idoc inbound/outbound.

*Destinazione rfc*   
Informazioni tecniche del sistema ricevente (ip + porta + info varie )

*Porta*   
Rappresentazione di un canale di comunicazione (per idoc usare RFC)

*Codice processo*   
Codice che indica il functiom module o api da richiamare per il processo dell'idoc

**Configurare e ampliare un IDOC - Step by Step**   
 
 - *SALE*   
    - Andare in *Parametrizzazione di base > Installare sistemi logici > Denominare sistema logico* e inserire il nome del sistema logico.

 - *WE81*
    - Aggiungere il tipo di messaggio che si vuole utilizzare per l'idoc

 - *BD56*
    - Aggiungere i segmenti che vuoi filtrare considerando mittente, destinatario e le loro rispettive categorie

 - *BD61*
   - Attivare change pointers

 - *BD50*
    - Attivazione dei change pointers per il tipo di messaggio

 - *BD64*   
    - Creare un sistema di distribuzione fittizio e aggiungere il filtro sul messaggio creato

 - *WE31*
    - Creare il segmento custom che vuoi aggiungere al'idoc. Una volta creato il segmento impostarlo in tipo rilasciato.

 - *WE30*
    - Creare un ampliamento scegliendo il tipo base idoc da cui partire. Aggiungere poi il segmento custom creato tramite la we31 impostando l'obbligatorietà, il numero min/max del segmento e il livello. 

 - *WE82*
    - Inserire in questa view un record per collegare Tipo messaggio, tipo base dell'idoc, ampliamento, release ( inserire * )

 - *BD60*
    - Collegare al messaggio custom dell'idoc il messaggio di riferimento e il function module.

 - *WE21*
    - Creare porta per l'elaborazione dell'idoc ( solitamente RFC )

 - *WE20*
    - Creare un accordo partner per un determinato tipo. Inserire i dati relativi all'idoc tra i parametri di uscita/entrata

 - *Codice*
    - Implementare una function o una exit per inserire i dati e il segmento custom nell'idoc

**Creare IDOC da Change pointer**
Lanciare il report RBDMIDOC da *SE38*. Inserendo il tipo messaggio, il report standard genererà n idoc in base alle modifiche tenute dai Change pointer in base ai record. Questo report accorpa gli idoc in base alla chiave: se è stato modificato più volte un oggetto verrà creato un solo idoc. 

**Tabelle fondamentali**
- *Edidc*: Informazioni di testata 
- *Edid4*: Payload. (potrebbe cambiare in base alla versione del sistema)
- *Edids*: Record stati idoc 

**Transazioni**
- *WE19*: Riprocessare Idoc in errore
- *WE30*: Tipo base 
- *WE05*: Visualizzare idoc scambiati 
- *BD87*: Stato msg ale 

**Idoc std**   
*aleaud01*   
Conferma idoc in entrata a sistema sender. Puoi impostare quali messaggio intercettare e per quali partner questo idoc può essere triggerato
