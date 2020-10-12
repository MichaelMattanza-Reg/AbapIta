<h1>WKF SAP</h1>

I workflow sono una serie di passi svolti per compiere un'azione complessa ( documento, informazione, ecc... ).
Il primo passo è creare un metodo per ogni step che il wkf deve fare. E' consigliato creare una classe per ogni wkf in modo che ogni implementazione sia a se stante. Inserire nella classe un evento che sarà il trigger del wkf con i parametri da passare al contenitore del wkf stesso.

Una volta creati i metodi, andare in *PFTC* e creare un Task Workflow (TS) al quale legare il metodo creato.
Selezionare quindi la categoria oggetto Classe, legare il metodo creato, fare il binding del contenitore con i parametri del metodo ed infine flaggare la voce "Metodo oggetto sincrono".

Una volta creato un task per ogni step del wkf, creare un Modello wkf nuovo (sempre da *PFTC*, tipo WS).   
Nella sezione di trigger del wkf inserire la classe e l'evento sopra citato.   
Andare quindi nella sezione del wkf builder e aggiungere il nodo attività: indicare quindi nella voce Task: TS + num. task creato.
Impostare quindi i dati di passaggio cliccando sul bottone "Flusso di dati", creando nel container del wkf le variabili che dovete lavorare.

**Chiamare un wkf**   
Creare nella classe un metodo che fa il raise del wkf.   
```abap
  method RAISE_WKF.
    " WS 900000000
     CONSTANTS: lc_objtype TYPE sibftypeid VALUE '', " Classe che contiene l'evento del wkf
                lc_event   TYPE sibfevent  VALUE ''. " Nome dell'evento che avvia il wkf

    DATA: lv_param_name       TYPE swfdname,
          lv_objkey           TYPE sweinstcou-objkey,
          lref_event_parameters TYPE REF TO if_swf_ifs_parameter_container.

    TRY.
        CALL METHOD cl_swf_evt_event=>get_event_container
          EXPORTING
            im_objcateg  = cl_swf_evt_event=>mc_objcateg_cl
            im_objtype   = lc_objtype
            im_event     = lc_event
          RECEIVING
            re_reference = lref_event_parameters.

        lref_event_parameters->set( EXPORTING name = 'CT_MSEG' value = it_mseg ).

        CALL METHOD cl_swf_evt_event=>raise_in_update_task
          EXPORTING
            im_objcateg        = cl_swf_evt_event=>mc_objcateg_cl
            im_objtype         = lc_objtype
            im_event           = lc_event
            im_objkey          = lv_objkey
            im_event_container = lref_event_parameters.

      CATCH cx_swf_evt_invalid_objtype .
      CATCH cx_swf_evt_invalid_event .
      CATCH cx_swf_cnt_cont_access_denied.
      CATCH cx_swf_cnt_elem_access_denied.
      CATCH cx_swf_cnt_elem_not_found.
      CATCH cx_swf_cnt_elem_type_conflict.
      CATCH cx_swf_cnt_unit_type_conflict.
      CATCH cx_swf_cnt_elem_def_invalid.
      CATCH cx_swf_cnt_container.

    ENDTRY.
    COMMIT WORK.
  endmethod.
```

