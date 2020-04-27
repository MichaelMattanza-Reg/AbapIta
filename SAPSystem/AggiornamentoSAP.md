<b>SPAU E SPDD</b>
Sono transazioni utilizzate per un aggiornamento pesante di pacchetti sap. Servono per aggiornare sia oggetti dictionary che programmi
  attraverso la funzione di reset a standard o di modifica manuale, attraverso il quale si adatta l'oggetto modificato affinchè possa essere 
  consistente e non dia problemi.

- SPDD</br>
E' una transazione utilizzata in seguito ad un aggiornamento sistemistico. Serve per controllare la consistenza di oggetti a dictionary 
e decidere se mantenerli o resettarli. Nel caso delle note di solito si resetta. Devono essere fatti TUTTI gli oggetti.

- SPAU</br>
E' una transazione utilizzata per controllare la consistenza del codice custom. Come la spdd si può decidere se resettarlo o mantenerlo.
Nella spau esistono 5/6 sezioni: 

  - Notes: Ti mostra tutte le note e ti chiede cosa vuoi farne -> selezioni tutto -> prepare notes (aggiorna tutte le note) 
          ->se non funziona prepare notes seleziona tutte e cliccare su 'compute adjustment mode' 

  - with assistant: cose modificate con assistente -> se la modifica non è chiara bisogna CHIEDERE. 
                  Una volta ripristinato o applicate le modifiche devono essere attivati i cambiamenti. 
                  Reset se sono cambiamenti inutili (tipo testi delle note). Documentazione di solito si resetta.

  - without assistan

  - deletion: delete modification log a quasi tutto (vedere le custom)

  - translations: farle passare tutte

**NB**
- Esiste la SPAU_ENH per il mantenimento degli enanchement
- Fare sempre solo una CR per ogni transazione
- tenere traccia delle cose fatte tramite un file in cui si segnano le modifiche
- aggiornare in inglese con client 000

<i>Vedere link esterni per approfondimenti</i>
