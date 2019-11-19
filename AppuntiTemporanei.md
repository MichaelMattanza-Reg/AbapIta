Lista oggetti in CR -> Tabella E071 E070

Scoprire che stampe utilizza un messaggio -> TNAPR 

Tab. DWINACTIV

-----------------------------------
Tab. modsap -> da un ampliamento si trova il nome della exit da implementare

FM per trovare badi coinvolte in un evento: SXV_GET_CLIF_BY_NAME

-------------------------------------------

Mapping dinamico


    CREATE DATA dref TYPE ('ty_file').
    ASSIGN dref->* TO <fs_dref>.
    fs_desc ?=  cl_abap_structdescr=>describe_by_data( <fs_dref> ) .
    lt_component = fs_desc->components.

    DO lv_count_key TIMES.
      ADD 1 TO lv_counter.

      LOOP AT lt_exc_file ASSIGNING FIELD-SYMBOL(<fs_file>) WHERE row = lv_counter.
        DATA(lv_fname) = COND #( WHEN line_exists( lt_component[ <fs_file>-col ] ) THEN lt_component[ <fs_file>-col ]-name ).
        ASSIGN COMPONENT lv_fname OF STRUCTURE gs_file TO FIELD-SYMBOL(<fs_fld_struct>).
        IF sy-subrc EQ 0.
          <fs_fld_struct> = <fs_file>-value.
        ENDIF.
      ENDLOOP.
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ENDDO.
