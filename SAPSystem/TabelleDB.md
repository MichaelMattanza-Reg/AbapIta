Le tabelle servono per il salvataggio permanente di dati. Possono esserci tabelle standard (ekko, ekpo ...) e tabelle Z, 
utilizzate per salvare dati scelti da noi. 

**Creare una tabella z**</br>
Lanciare la transazione <i>SE11</i> ed inserire il nome della tabella desiderata nel campo <i>Tabella database</i>, cliccare quindi su 
<i>Creare</i>. Inserire i nomi delle colonne e il tipo dati, con una descrizione. 
> NB </br> I campi divisa e quantità devono fare riferimento ad un altro campo.
</br>
Una volta creata la tabella andare su <i>Utilities -> Generatore agg. tabella</i> per creare la view di mantenimento, con la quale potrai 
interagire con i dati attraverso la <i>SM30</i>. </br></br>

**Impostazioni classiche view**</br>
Per generare la view deve essere creato un gruppo funzioni (indifferente crearne uno o utilizzarne un altro).
Nella schermata di generazione view inserire:
</br>**Gruppo autorizzazione: &NC&**
</br>**Tipo aggiornamento: 1 livello**
</br>**Videata riepilogo: 1** </br>

**Impostazioni layout view** </br>
Per modificare il layout della view, affinche non venga vista schiacciata, andare nella voce <i>Ambiente -> Modificazione -> Videate di agg</i>
</br>**Righe e colonne: 200 e 250** 
</br></br>
Durante i vari processi verrà richiesta più volte la cr, di salvare e di attivare i vari elementi.


<i>Vedere link esterni per approfondimenti</i>
