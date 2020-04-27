Gli smartforms sono stampe strutturate in modo simile ai pdf form, con la differenza che è tutto racchiuso in una schermata. E' possibile anche per gli smartforms ricevere i dati direttamente da un report. 
 ```abap
data: l_fm type rs38l_fnam.
call function 'SSF_FUNCTION_MODULE_NAME'
exporting
formname = 'ZSMARTFROM'
importing
fm_name = l_fm.

call function l_fm
exporting
data = ls_data.
 ```
 La grafica di componimento è diversa da quella dei PDF form ma l'idea è molto simile. La variabile per stampare il numero della pagina attuale è <i>SFSY-PAGE</i>.
 

 Negli smartforms vengono utilizzati i template ( da non confondere graficamente con le tabelle ) e consentono di "disegnare" una struttura per organizzare la stampa dei dati. 
 
  Se uno smartform viene lanciato ma va in errore è possibile debuggare l'errore andando in:
  *SE37 -> FM SSFRT_READ_ERROR -> METTERE DEBUG ALLA RIGA 16 -> LEGGERE TABELLA errortab*. Dopo aver trovato il messaggio confrontarlo con quello nella SE91 con la classe nel *msgid* e il numero messaggio *msgno*.
  
<i>Vedere link esterni per approfondimenti</i>
