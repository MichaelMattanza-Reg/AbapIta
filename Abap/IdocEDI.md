<h1>Idoc / EDI</h1>

<br>
Per estendere un idoc si parte da un tipo base 
<br><br>
Extension -> Si crea estensione e aggiungere il campo<br>
Una volta scelto il segmento si aggiunge il tipo segmento con un minimo ed un massimo.
<br>
<br>
Selezionare il flag ISO per le unità di misura.
<br>
<br>
Per configurarlo: set realase da sm20.
<br>
<br>
Tramite le user exit aggiungere i campi all'idoc



Edi ha una struttura fissa e non è legato alla logica
Idoc ha una struttura collegata al tipo base e può essere lavorato. Servono da intermediari e hanno una struttura XML. 

Le informazioni di un idoc sono contenute nel suo EDI.
Oltre ai dati interni (EDI) ci sono dati esterni**, popolati per ogni segmento dell'idoc. Questi dati esterni contengono il nome idoc, il livello e il campo sdata, quest'ultimo contiene i dati che vogliamo passare.

\* Controllare struttura edidc <br>
\* Controllare struttura edid4 per data records e edids per status record
\** Controllare sdata contenuta in edid4

<b>Stati Idoc</b>
<br>
Gli idoc possiedono degli stati di elaborazione. Questi stati possono essere visti tramite la transazione we47.

<b>Ampliare un Idoc</b><br>
Per ampliare un Idoc è necessario creare un nuovo segmento tramite la transazione <i>WE31</i>.<br>
Una volta creato il segmento è necessario andare in <i>WE30</i> per creare un Idoc con riferimento ad un tipo base. Una volta creato aggiungere il segmento creato precedentemente. <br>
E' poi possibile collegare l'idoc ad un messaggio tramite la <i>WE82</i> ed ad una FM tramite la transazione <i>WE57</i>. Scrivere infine il codice in una exit o nella function creata tramite le transazioni <i>WE41 / WE42</i>. 
