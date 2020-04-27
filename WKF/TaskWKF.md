<h1>WKF</h1>

I workflow sono una serie di passi per costruire qualcosa ( documento, informazione, ecc... ). 
Il primo passo è trasformare i dati utili in un xml e costruire la chiamata che farà partire il workflow.
```abap
  CALL TRANSFORMATION id
      SOURCE date       = sy-datum
             batches    = lt_outtab
             user       = sy-uname
      RESULT XML lv_xml_data.


  TRY.
      CREATE OBJECT idoc_dom
        EXPORTING
          i_xstring_xml = lv_xml_data.
    CATCH /reg/cx_err_exc_with_message .
      WRITE 'Errore conversione xml'.
  ENDTRY.

  CREATE OBJECT lo_xml_doc .
  lo_xml_doc->create_with_dom( idoc_dom->acl_document ).
  lo_xml_doc->save( ).

  CREATE OBJECT atom_action
    EXPORTING
      i_bo_key = lo_xml_doc->ms_doc_key+10(32).

    APPEND VALUE #(
      element = 'gXMLMasterList'
      value = lo_xml_doc->ms_doc_key+10(32)
    ) TO lt_container ASSIGNING FIELD-SYMBOL(<fs_curr_line>).

    <fs_curr_line>-value+70 = '/REG/CL_ATOM_ACTION_BO          CL'.

    APPEND VALUE #(
      element = 'WORKFLOW'
      value = 'WS99000103'
    ) TO lt_container.

    APPEND VALUE #(
      element = 'I_VALUE'
      value = |Plant { gv_werks } Mag. { gv_lgort } Operatore: { sy-uname }|
    ) TO lt_container.
```
Dopo aver preparato il necessario, chiamare la function che avvia il workflow ( vedere nella sezione function ).
La funciton chiamerà a sua volta il metodo che possiede il nome del wkf e contiene i passi che ne creano i vari livelli con le informazioni necessarie.

<b>Creare un task</b><br>
Lanciando la transazione PFTC
