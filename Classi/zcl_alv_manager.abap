CLASS zcl_alv_manager DEFINITION
 PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_fc_custom,
        fieldname    TYPE char255,
        fc_component TYPE char255,
        value        TYPE char255,
      END OF ty_fc_custom,
      tty_fc_custom TYPE TABLE OF ty_fc_custom.

    DATA go_alv TYPE REF TO cl_gui_alv_grid .
    DATA go_second_alv TYPE REF TO cl_gui_alv_grid .
    DATA gv_program_name TYPE string .
    DATA gt_fcat TYPE lvc_t_fcat .
    DATA gt_second_fcat TYPE lvc_t_fcat .

    METHODS constructor
      IMPORTING
        VALUE(iv_program_name) TYPE string
        VALUE(iv_cds_name)     TYPE string OPTIONAL
        VALUE(iv_charact_fc)   TYPE flag OPTIONAL
        VALUE(it_outtab)       TYPE any
        VALUE(io_alv)          TYPE REF TO cl_gui_alv_grid OPTIONAL
        VALUE(it_custom_fc)    TYPE tty_fc_custom OPTIONAL .
    METHODS get_fcat
      RETURNING
        VALUE(rt_fcat) TYPE lvc_t_fcat .

    METHODS set_second_table
      IMPORTING
        VALUE(it_outtab)     TYPE any
        VALUE(it_custom_fc)  TYPE tty_fc_custom OPTIONAL
        VALUE(iv_cds_name)   TYPE string OPTIONAL
        VALUE(iv_charact_fc) TYPE flag OPTIONAL .

    METHODS display_data
      IMPORTING
        VALUE(is_variant_ft) TYPE disvariant OPTIONAL
        VALUE(iv_save_ft)    TYPE char01 OPTIONAL
        VALUE(is_layout_ft)  TYPE lvc_s_layo OPTIONAL
        VALUE(is_variant_st) TYPE disvariant OPTIONAL
        VALUE(iv_save_st)    TYPE char01 OPTIONAL
        VALUE(is_layout_st)  TYPE lvc_s_layo OPTIONAL
        VALUE(iv_vertical)   TYPE flag OPTIONAL .

    METHODS get_output_tables
      EXPORTING
        !et_table_ft TYPE REF TO data
        !et_table_st TYPE REF TO data.

  PROTECTED SECTION.
    DATA gref_outtab TYPE REF TO data .
    DATA gref_second_outtab TYPE REF TO data .

  PRIVATE SECTION.
    METHODS create_dyn_fc
      IMPORTING
        VALUE(is_outtab)    TYPE data
        VALUE(it_custom_fc) TYPE tty_fc_custom OPTIONAL
      RETURNING
        VALUE(ct_fieldcat)  TYPE lvc_t_fcat .

    METHODS create_fc_from_cds
      IMPORTING
        VALUE(iv_entity_name) TYPE string
        VALUE(is_outtab)      TYPE data
        VALUE(it_custom_fc)   TYPE tty_fc_custom OPTIONAL
      RETURNING
        VALUE(ct_fieldcat)    TYPE lvc_t_fcat .

    METHODS create_fc_from_charact
      IMPORTING
        VALUE(is_outtab)    TYPE data
        VALUE(it_custom_fc) TYPE tty_fc_custom OPTIONAL
      RETURNING
        VALUE(ct_fieldcat)  TYPE lvc_t_fcat .

    METHODS set_handler_first_alv.
    METHODS set_handler_second_alv.

    " Handler Prima alv
    METHODS handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        !e_object
        !e_interactive .
    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
        !e_ucomm .
    METHODS handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        !e_row_id
        !e_column_id
        !es_row_no .
    METHODS handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        !er_data_changed .
    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        !e_row
        !e_column .

    " Handler Seconda alv
    METHODS handle_toolbar_st
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        !e_object
        !e_interactive .

    METHODS handle_user_command_st
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
        !e_ucomm .

    METHODS handle_hotspot_click_st
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        !e_row_id
        !e_column_id
        !es_row_no .

    METHODS handle_data_changed_st
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        !er_data_changed .

    METHODS handle_double_click_st
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        !e_row
        !e_column .


ENDCLASS.



CLASS ZCL_ALV_MANAGER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PROGRAM_NAME                TYPE        STRING
* | [--->] IV_CDS_NAME                    TYPE        STRING(optional)
* | [--->] IV_CHARACT_FC                  TYPE        FLAG(optional)
* | [--->] IT_OUTTAB                      TYPE        ANY
* | [--->] IO_ALV                         TYPE REF TO CL_GUI_ALV_GRID(optional)
* | [--->] IT_CUSTOM_FC                   TYPE        TTY_FC_CUSTOM(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    DATA: lref_row_outtab     TYPE REF TO data.

    FIELD-SYMBOLS: <fs_outtab_row> TYPE any,
                   <fs_outtab>     TYPE INDEX TABLE.

    gv_program_name = iv_program_name.

    " Creo una tabella indicizzata
    CREATE DATA gref_outtab LIKE it_outtab.
    ASSIGN gref_outtab->* TO <fs_outtab>.

    " Creo una struttura basata sulla tabella
    CREATE DATA lref_row_outtab LIKE LINE OF <fs_outtab>.
    ASSIGN lref_row_outtab->* TO <fs_outtab_row>.

    " Passo i dati in input alla tabella
    MOVE-CORRESPONDING it_outtab TO <fs_outtab>.

    " Creo il fc della tabella ricevuta
    IF iv_cds_name IS NOT INITIAL.
      gt_fcat = create_fc_from_cds( iv_entity_name = iv_cds_name is_outtab = <fs_outtab_row> it_custom_fc = it_custom_fc ).
    ELSE.
      gt_fcat = create_dyn_fc( EXPORTING is_outtab = <fs_outtab_row> it_custom_fc = it_custom_fc ).
    ENDIF.

    IF iv_charact_fc EQ abap_true.
      gt_fcat = create_fc_from_charact( is_outtab = <fs_outtab_row> it_custom_fc = it_custom_fc ).
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->CREATE_DYN_FC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_OUTTAB                      TYPE        DATA
* | [--->] IT_CUSTOM_FC                   TYPE        TTY_FC_CUSTOM(optional)
* | [<-()] CT_FIELDCAT                    TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_dyn_fc.
    TYPES: BEGIN OF ty_dd04t,
             rollname  TYPE rollname,
             scrtext_m TYPE scrtext_m,
           END OF ty_dd04t,
           BEGIN OF ty_dd01l,
             domname  TYPE dd01l-domname,
             convexit TYPE dd01l-convexit,
           END OF ty_dd01l.

    DATA : lo_ref_descr   TYPE REF TO cl_abap_structdescr,
           lt_detail      TYPE abap_compdescr_tab,
           lt_field_det   TYPE REF TO cl_abap_structdescr,
           lt_coldescr    TYPE TABLE OF ty_dd04t,
           lt_dd01l       TYPE TABLE OF ty_dd01l,
           lref_typedescr TYPE REF TO cl_abap_typedescr,
           lref_elemdescr TYPE REF TO cl_abap_elemdescr,
           lv_counter     TYPE i VALUE 0.

    FIELD-SYMBOLS: <fs_dref>  TYPE any,
                   <fs_fname> TYPE any.

    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( is_outtab ). "Chiamare metodo statico su una struttura
    lt_detail[] = lo_ref_descr->components.

    " Loop sui componenti della struttura - Creo fc
    LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).
      ASSIGN COMPONENT <fs_detail>-name OF STRUCTURE is_outtab TO FIELD-SYMBOL(<fs_outtab_comp>).

      IF <fs_outtab_comp> IS ASSIGNED.

        lref_typedescr = cl_abap_typedescr=>describe_by_data( <fs_outtab_comp> ) .
        lref_elemdescr ?= cl_abap_typedescr=>describe_by_data( <fs_outtab_comp> ) .

        APPEND VALUE #(
          ref_field = lref_typedescr->absolute_name+6
          fieldname = <fs_detail>-name
          outputlen = COND #( WHEN lref_typedescr->type_kind EQ 'P' THEN lref_elemdescr->output_length ELSE lref_typedescr->length )
          decimals_o = lref_typedescr->decimals
          col_opt = 'X'
        ) TO ct_fieldcat.

      ENDIF.
    ENDLOOP.

    " Estraggo descrizioni colonne std
    SELECT rollname, scrtext_m
     FROM dd04t
     INTO TABLE @lt_coldescr
     FOR ALL ENTRIES IN @ct_fieldcat
     WHERE rollname EQ @ct_fieldcat-ref_field
     AND ddlanguage EQ @sy-langu.

    SELECT domname, convexit
     FROM dd01l
     INTO CORRESPONDING FIELDS OF TABLE @lt_dd01l
     FOR ALL ENTRIES IN @ct_fieldcat
     WHERE domname EQ @ct_fieldcat-fieldname
     AND as4local EQ 'A'
     AND as4vers EQ ' '.

    SELECT fieldname, ddtext
    FROM dd03t
    WHERE tabname EQ @lo_ref_descr->absolute_name+6(30)
    AND ddlanguage EQ @sy-langu
    AND as4local EQ 'A'
    INTO TABLE @DATA(lt_dd03t).


    " Trasformo i campi inseriti dall'utente in upper case per evitare errori
    LOOP AT it_custom_fc REFERENCE INTO DATA(lr_cust_fc).
      TRANSLATE lr_cust_fc->fieldname TO UPPER CASE.
    ENDLOOP.

    " Applico le modifiche custom ai campi del fc
    LOOP AT ct_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

      READ TABLE lt_dd03t INTO DATA(ls_dd03t) WITH KEY fieldname = <fs_fcat>-fieldname.
      IF sy-subrc EQ 0.
        <fs_fcat>-coltext = <fs_fcat>-scrtext_m = ls_dd03t-ddtext.
      ELSE.
        " Inserisco la descrizione del dominio nella colonna
        READ TABLE lt_coldescr INTO DATA(ls_coldescr) WITH KEY rollname = <fs_fcat>-ref_field.
        <fs_fcat>-coltext = <fs_fcat>-scrtext_m = ls_coldescr-scrtext_m.
      ENDIF.

      READ TABLE lt_dd01l INTO DATA(ls_dd01l) WITH KEY domname = <fs_fcat>-fieldname.
      <fs_fcat>-convexit = ls_dd01l-convexit.

      LOOP AT it_custom_fc ASSIGNING FIELD-SYMBOL(<fs_custom_fc>)
        WHERE fieldname EQ <fs_fcat>-fieldname OR fieldname EQ '*'.

        ASSIGN COMPONENT <fs_custom_fc>-fc_component OF STRUCTURE <fs_fcat> TO FIELD-SYMBOL(<fs_comp>).
        IF sy-subrc EQ 0.
          <fs_comp> =  <fs_custom_fc>-value.
        ENDIF.
      ENDLOOP.

      IF <fs_fcat>-col_id IS INITIAL.
        lv_counter += 1.
        <fs_fcat>-col_id = <fs_fcat>-col_pos = lv_counter.
      ENDIF.

      CLEAR: ls_dd01l, ls_coldescr.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->CREATE_FC_FROM_CDS
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_ENTITY_NAME                 TYPE        STRING
* | [--->] IS_OUTTAB                      TYPE        DATA
* | [--->] IT_CUSTOM_FC                   TYPE        TTY_FC_CUSTOM(optional)
* | [<-()] CT_FIELDCAT                    TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_fc_from_cds.

    DATA : lo_ref_descr   TYPE REF TO cl_abap_structdescr,
           lt_detail      TYPE abap_compdescr_tab,
           lt_field_det   TYPE REF TO cl_abap_structdescr,
           lref_typedescr TYPE REF TO cl_abap_typedescr,
           lref_elemdescr TYPE REF TO cl_abap_elemdescr.

    cl_dd_ddl_annotation_service=>get_annos(
      EXPORTING
        entityname      = CONV #( iv_entity_name )
      IMPORTING
        element_annos   = DATA(element_annos)
        entity_annos    = DATA(entity_annos)
        parameter_annos = DATA(parameter_annos)
        annos_tstmp     = DATA(annos_tstmp)
    ).

    DATA(lv_counter) = 0.
    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( is_outtab ). "Chiamare metodo statico su una struttura
    lt_detail[] = lo_ref_descr->components.

    LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).
      ASSIGN COMPONENT <fs_detail>-name OF STRUCTURE is_outtab TO FIELD-SYMBOL(<fs_comp>).
      DATA(ls_col_text) = VALUE #(  element_annos[ elementname = <fs_detail>-name annoname = 'ENDUSERTEXT.LABEL' ] OPTIONAL ).

      IF <fs_comp> IS ASSIGNED.

        lref_typedescr = cl_abap_typedescr=>describe_by_data( <fs_comp> ) .
        lref_elemdescr ?= cl_abap_typedescr=>describe_by_data( <fs_comp> ) .

        APPEND VALUE #(
          ref_field = lref_typedescr->absolute_name+6
          fieldname = <fs_detail>-name
          outputlen = COND #( WHEN lref_typedescr->type_kind EQ 'P' THEN lref_elemdescr->output_length ELSE lref_typedescr->length )
          decimals_o = lref_typedescr->decimals
          col_opt = 'X'
        ) TO ct_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

        <fs_fcat>-coltext = <fs_fcat>-scrtext_m = ls_col_text-value.
      ENDIF.
      LOOP AT it_custom_fc ASSIGNING FIELD-SYMBOL(<fs_custom_fc>)
        WHERE fieldname EQ <fs_fcat>-fieldname OR fieldname EQ '*'.

        ASSIGN COMPONENT <fs_custom_fc>-fc_component OF STRUCTURE <fs_fcat> TO FIELD-SYMBOL(<fs_comp_fcat>).
        IF sy-subrc EQ 0.
          <fs_comp_fcat> =  <fs_custom_fc>-value.
        ENDIF.
      ENDLOOP.

      IF <fs_fcat>-col_id IS INITIAL.
        lv_counter += 1.
        <fs_fcat>-col_id = <fs_fcat>-col_pos = lv_counter.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->CREATE_FC_FROM_CHARACT
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_OUTTAB                      TYPE        DATA
* | [--->] IT_CUSTOM_FC                   TYPE        TTY_FC_CUSTOM(optional)
* | [<-()] CT_FIELDCAT                    TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD create_fc_from_charact.
    DATA : lo_ref_descr         TYPE REF TO cl_abap_structdescr,
           lref_typedescr       TYPE REF TO cl_abap_typedescr,
           lt_detail            TYPE abap_compdescr_tab,
           lt_chardescr         TYPE TABLE OF bapicharactdescr,
           lt_bapiret           TYPE TABLE OF bapiret2,
           ls_bapicharactdetail TYPE bapicharactdetail.

    DATA(lv_counter) = 0.
    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( is_outtab ). "Chiamare metodo statico su una struttura
    lt_detail[] = lo_ref_descr->components.

    LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).
      lv_counter += 1.

      CALL FUNCTION 'BAPI_CHARACT_GETDETAIL'
        EXPORTING
          charactname   = <fs_detail>-name
          keydate       = sy-datum
        IMPORTING
          charactdetail = ls_bapicharactdetail
        TABLES
          charactdescr  = lt_chardescr
          return        = lt_bapiret.

      CHECK ls_bapicharactdetail IS NOT INITIAL.
      ASSIGN COMPONENT <fs_detail>-name OF STRUCTURE is_outtab TO FIELD-SYMBOL(<fs_comp>).

      IF <fs_comp> IS ASSIGNED.
        lref_typedescr = cl_abap_typedescr=>describe_by_data( <fs_comp> ) .

        DATA(ls_chardescr) = VALUE #( lt_chardescr[ 1 ] OPTIONAL ).
        APPEND VALUE #(
            inttype = COND #( WHEN ls_bapicharactdetail-data_type EQ 'CHAR' THEN 'C' ELSE 'P' ) "lref_typedescr->absolute_name+6
            fieldname = <fs_detail>-name
            outputlen = ls_bapicharactdetail-length
            col_id    = lv_counter
            decimals_o = ls_bapicharactdetail-decimals
            coltext = ls_chardescr-description
            scrtext_m = ls_chardescr-description
          ) TO ct_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).

        LOOP AT it_custom_fc ASSIGNING FIELD-SYMBOL(<fs_custom_fc>)
          WHERE fieldname EQ <fs_fcat>-fieldname OR fieldname EQ '*'.

          ASSIGN COMPONENT <fs_custom_fc>-fc_component OF STRUCTURE <fs_fcat> TO FIELD-SYMBOL(<fs_comp_fcat>).
          IF sy-subrc EQ 0.
            <fs_comp_fcat> =  <fs_custom_fc>-value.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->DISPLAY_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_VARIANT_FT                  TYPE        DISVARIANT(optional)
* | [--->] IV_SAVE_FT                     TYPE        CHAR01(optional)
* | [--->] IS_LAYOUT_FT                   TYPE        LVC_S_LAYO(optional)
* | [--->] IS_VARIANT_ST                  TYPE        DISVARIANT(optional)
* | [--->] IV_SAVE_ST                     TYPE        CHAR01(optional)
* | [--->] IS_LAYOUT_ST                   TYPE        LVC_S_LAYO(optional)
* | [--->] IV_VERTICAL                    TYPE        FLAG(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD display_data.
    FIELD-SYMBOLS: <fs_outtab>        TYPE ANY TABLE,
                   <fs_second_outtab> TYPE ANY TABLE.

    IF gt_second_fcat IS NOT INITIAL.

      DATA(lo_cont_docking) = NEW cl_gui_docking_container(
        parent = cl_gui_container=>screen0
        ratio  = 90
      ).
      lo_cont_docking->set_extension( EXPORTING extension = 99999 EXCEPTIONS cntl_error = 1 OTHERS = 2 ).

      DATA(lo_split_container) = NEW cl_gui_splitter_container(
        parent  = lo_cont_docking
        rows    = COND #( WHEN iv_vertical EQ abap_true THEN '1' ELSE '2' )
        columns = COND #( WHEN iv_vertical EQ abap_true THEN '2' ELSE '1' )
      ).

      lo_split_container->get_container(
        EXPORTING
          row       = 1                 " Row
          column    = 1                " Column
        RECEIVING
          container = DATA(lo_first_container)                 " Container
      ).

      lo_split_container->get_container(
        EXPORTING
          row       = COND #( WHEN iv_vertical EQ abap_true THEN '1' ELSE '2' )                 " Row
          column    = COND #( WHEN iv_vertical EQ abap_true THEN '2' ELSE '1' )                " Column
        RECEIVING
          container = DATA(lo_second_container)                 " Container
      ).

      go_alv = NEW cl_gui_alv_grid( i_parent = lo_first_container ).
      go_second_alv = NEW cl_gui_alv_grid( i_parent = lo_second_container ).

      set_handler_first_alv( ).
      set_handler_second_alv( ).

      ASSIGN gref_outtab->* TO <fs_outtab>.
      ASSIGN gref_second_outtab->* TO <fs_second_outtab>.

      go_alv->set_table_for_first_display(
        EXPORTING
          is_layout       = is_layout_ft
          is_variant      = is_variant_ft
          i_save          = iv_save_ft
        CHANGING
          it_outtab       = <fs_outtab>
          it_fieldcatalog = gt_fcat
      ).

      go_second_alv->set_table_for_first_display(
        EXPORTING
          is_layout       = is_layout_st
          is_variant      = is_variant_st
          i_save          = iv_save_st
        CHANGING
          it_outtab       = <fs_second_outtab>
          it_fieldcatalog = gt_second_fcat
      ).

      DATA(lt_empty_cell) = VALUE lvc_t_cell( ( row_id = VALUE #( index = 0 ) ) ).
      go_second_alv->set_selected_cells( it_cells = lt_empty_cell ).

    ELSE.
      go_alv = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen ).
      set_handler_first_alv( ).

      ASSIGN gref_outtab->* TO <fs_outtab>.

      go_alv->set_table_for_first_display(
        EXPORTING
          is_layout       = is_layout_ft
          is_variant      = is_variant_ft
          i_save          = iv_save_ft
        CHANGING
          it_outtab       = <fs_outtab>
          it_fieldcatalog = gt_fcat
      ).
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->GET_FCAT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_FCAT                        TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_fcat.
    " Ritorno all'utente il fc creato nel costruttore
    rt_fcat = gt_fcat.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_DATA_CHANGED
* +-------------------------------------------------------------------------------------------------+
* | [--->] ER_DATA_CHANGED                LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_data_changed.
    PERFORM handle_data_changed IN PROGRAM (gv_program_name) IF FOUND USING er_data_changed.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_DOUBLE_CLICK
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_ROW                          LIKE
* | [--->] E_COLUMN                       LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_double_click.
    PERFORM handle_double_click IN PROGRAM (gv_program_name) IF FOUND USING e_row e_column.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_HOTSPOT_CLICK
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_ROW_ID                       LIKE
* | [--->] E_COLUMN_ID                    LIKE
* | [--->] ES_ROW_NO                      LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_hotspot_click.
    PERFORM handle_hotspot_click IN PROGRAM (gv_program_name) IF FOUND USING e_row_id e_column_id es_row_no.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_TOOLBAR
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_OBJECT                       LIKE
* | [--->] E_INTERACTIVE                  LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_toolbar.
    PERFORM handle_toolbar IN PROGRAM (gv_program_name) IF FOUND USING e_object e_interactive.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_USER_COMMAND
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_user_command.
    DATA: lt_rows     TYPE lvc_t_row.
    go_alv->get_selected_rows(
      IMPORTING
        et_index_rows = lt_rows
    ).
    PERFORM handle_user_command IN PROGRAM (gv_program_name) IF FOUND USING e_ucomm lt_rows.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->SET_SECOND_TABLE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_OUTTAB                      TYPE        ANY
* | [--->] IT_CUSTOM_FC                   TYPE        TTY_FC_CUSTOM(optional)
* | [--->] IV_CDS_NAME                    TYPE        STRING(optional)
* | [--->] IV_CHARACT_FC                  TYPE        FLAG(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_second_table.
    DATA: lref_row_outtab TYPE REF TO data.

    FIELD-SYMBOLS: <fs_outtab_row> TYPE any,
                   <fs_outtab>     TYPE INDEX TABLE.

    " Creo una tabella indicizzata
    CREATE DATA gref_second_outtab LIKE it_outtab.
    ASSIGN gref_second_outtab->* TO <fs_outtab>.

    " Creo una struttura basata sulla tabella
    CREATE DATA lref_row_outtab LIKE LINE OF <fs_outtab>.
    ASSIGN lref_row_outtab->* TO <fs_outtab_row>.

    MOVE-CORRESPONDING it_outtab TO <fs_outtab>.

    IF iv_cds_name IS NOT INITIAL.
      gt_second_fcat = create_fc_from_cds( iv_entity_name = iv_cds_name is_outtab = <fs_outtab_row> it_custom_fc = it_custom_fc ).
    ELSE.
      gt_second_fcat = create_dyn_fc( EXPORTING is_outtab = <fs_outtab_row> it_custom_fc = it_custom_fc ).
    ENDIF.

    IF iv_charact_fc EQ abap_true.
      gt_second_fcat = create_fc_from_charact( is_outtab = <fs_outtab_row> it_custom_fc = it_custom_fc ).
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->GET_OUTPUT_TABLES
* +-------------------------------------------------------------------------------------------------+
* | [<---] ET_TABLE_FT                    TYPE REF TO DATA
* | [<---] ET_TABLE_ST                    TYPE REF TO DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_output_tables.
    et_table_ft = gref_outtab.
    et_table_st = gref_second_outtab.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->SET_HANDLER_FIRST_ALV
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_handler_first_alv.

    SET HANDLER me->handle_toolbar FOR go_alv.
    SET HANDLER me->handle_user_command FOR go_alv.
    SET HANDLER me->handle_hotspot_click FOR go_alv.
    SET HANDLER me->handle_data_changed FOR go_alv.
    SET HANDLER me->handle_double_click FOR go_alv.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->SET_HANDLER_SECOND_ALV
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD set_handler_second_alv.
    SET HANDLER me->handle_toolbar_st FOR go_second_alv.
    SET HANDLER me->handle_user_command_st FOR go_second_alv.
    SET HANDLER me->handle_hotspot_click_st FOR go_second_alv.
    SET HANDLER me->handle_data_changed_st FOR go_second_alv.
    SET HANDLER me->handle_double_click_st FOR go_second_alv.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_DATA_CHANGED_ST
* +-------------------------------------------------------------------------------------------------+
* | [--->] ER_DATA_CHANGED                LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_data_changed_st.
    PERFORM handle_data_changed_st IN PROGRAM (gv_program_name) IF FOUND USING er_data_changed.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_DOUBLE_CLICK_ST
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_ROW                          LIKE
* | [--->] E_COLUMN                       LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_double_click_st.
    PERFORM handle_double_click_st IN PROGRAM (gv_program_name) IF FOUND USING e_row e_column.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_HOTSPOT_CLICK_ST
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_ROW_ID                       LIKE
* | [--->] E_COLUMN_ID                    LIKE
* | [--->] ES_ROW_NO                      LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_hotspot_click_st.
    PERFORM handle_hotspot_click_st IN PROGRAM (gv_program_name) IF FOUND USING  e_row_id e_column_id es_row_no.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_TOOLBAR_ST
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_OBJECT                       LIKE
* | [--->] E_INTERACTIVE                  LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_toolbar_st.
    PERFORM handle_toolbar_st IN PROGRAM (gv_program_name) IF FOUND USING e_object e_interactive.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->HANDLE_USER_COMMAND_ST
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_user_command_st.
    DATA: lt_rows     TYPE lvc_t_row.
    go_second_alv->get_selected_rows(
      IMPORTING
        et_index_rows = lt_rows
    ).
    PERFORM handle_user_command_st IN PROGRAM (gv_program_name) IF FOUND USING  e_ucomm lt_rows.
  ENDMETHOD.
ENDCLASS.
