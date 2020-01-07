<h1>ALV Manager</h1>
Questa classe può essere utilizzata per gestire toolbar e tabelle utilizzate da un’alv.
Occorre inserire tra i tipi della classe il TIPO TABELLA della tabella che si sta utilizzando e creare tra i dati globali la tabella nominata con GT_{nome report}. Quando si chiama il costruttore, passare la tabella di output, l’alv e il nome del report chiamante ( sy-cprog ). 
Nel costruttore passare la tabella di import alla tabella creata.
<br><br>
Per ogni metodo ci sarà un case when basato sul nome del programma chiamante. Inserire il when con il nome del programma chiamante e il proprio codice. <br><br>

- **Classe**: *ZCL_ALV_MANAGER*
- **Metodi**: 
  - *Handle_toolbar* ( aggiunge bottoni sulla toolbar )
  - *Handle_user_command* ( gestione dei vari bottoni )
  - *Top_of_page* ( Evento TOP_OF_PAGE )
  - *Create_dyn_fc* ( crea il field catalog dinamico )
  - *Constructor* ( costruttore )
  - *Get_view_data* ( Lavora i dati selezionati dalla alv )
  - *Save* ( Salvataggio dati )

ATTENZIONE
Il metodo create_dyn_fc riceve in input il tipo tabella ZT_FC_CUSTOM. Se si vuole modificare un componente del field catalog si può inserire la modifica in questa tabella valorizzando i campi:
  - *FIELDNAME:* nome del campo della tabella di output ( es. matnr )
  - *FC_COMPONENT:* nome del componente del field catalog da modificare ( es. no_out )
  - *VALUE:* valore che si vuole dare al componente del field catalog ( es. ‘X’ )
  <br><br>
  
- **Tabella:** *ZT_FC_CUSTOM*
- **Struttura:** *ZFC_CUSTOM*
- **CAMPI:**
  - *FIELDNAME*	    1 Type		CHAR	255	0	Nome campo tabella output
  - *FC_COMPONENT*	1 Type		CHAR	255	0	Nome componente FC da modificare
  - *VALUE*	        1 Type		CHAR	255	0	Valore componente FC da modificare

```abap
class ZCL_ALV_MANAGER definition
  public
  create public .

public section.

  data GO_ALV type ref to CL_GUI_ALV_GRID .
  data GT_VALUTAZIONE_FORN type ztab_outtab . " type table from se11
  data GV_PROGRAM_NAME type STRING .

  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_INTERACTIVE .
  methods HANDLE_USER_COMMAND
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods TOP_OF_PAGE
    for event TOP_OF_PAGE of CL_GUI_ALV_GRID
    importing
      !E_DYNDOC_ID .
  class-methods CREATE_DYN_FC
    importing
      value(IS_OUTTAB) type DATA
      value(IT_CUSTOM_FC) type ZT_FC_CUSTOM optional
    changing
      value(CT_FIELDCAT) type LVC_T_FCAT .
  methods CONSTRUCTOR
    importing
      value(IV_PROGRAM_NAME) type STRING
      value(IT_OUTTAB) type ANY
      value(IO_ALV) type ref to CL_GUI_ALV_GRID .
protected section.
private section.

  methods GET_VIEW_DATA
    importing
      value(I_ROW) type LVC_INDEX .
  methods SAVE
    importing
      value(IT_ROWS) type LVC_T_ROW optional .
ENDCLASS.



CLASS ZCL_ALV_MANAGER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PROGRAM_NAME                TYPE        STRING
* | [--->] IT_OUTTAB                      TYPE        ANY
* | [--->] IO_ALV                         TYPE REF TO CL_GUI_ALV_GRID
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CONSTRUCTOR.

    go_alv = io_alv.
    gv_program_name = iv_program_name.

    CASE gv_program_name.
      WHEN 'nome_prog'.
        MOVE-CORRESPONDING it_outtab TO gt_valutazione_forn.

    ENDCASE.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ALV_MANAGER=>CREATE_DYN_FC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_OUTTAB                      TYPE        DATA
* | [--->] IT_CUSTOM_FC                   TYPE        ZT_FC_CUSTOM(optional)
* | [<-->] CT_FIELDCAT                    TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CREATE_DYN_FC.

     DATA : lo_ref_descr TYPE REF TO cl_abap_structdescr,
            lt_detail    TYPE abap_compdescr_tab,
            ls_detail    LIKE LINE OF lt_detail,
            lr_typedescr TYPE REF TO cl_abap_typedescr,
            lv_counter   TYPE i VALUE 0.

  FIELD-SYMBOLS: <fs_dref>  TYPE any,
                 <fs_fname> TYPE any.

  lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( is_outtab ). "Chiamare metodo statico su una struttura
  lt_detail[] = lo_ref_descr->components.

  LOOP AT lt_detail INTO ls_detail.
    ASSIGN COMPONENT ls_detail-name OF STRUCTURE is_outtab TO FIELD-SYMBOL(<ls_comp>).

    IF <ls_comp> IS ASSIGNED.
      ADD 1 TO lv_counter.
      lr_typedescr = cl_abap_typedescr=>describe_by_data( <ls_comp> ) .

      APPEND VALUE #(
        ref_field = lr_typedescr->absolute_name+6
        fieldname = ls_detail-name
        outputlen = lr_typedescr->length
        col_id    = lv_counter
      ) TO ct_fieldcat.

    ENDIF.
  ENDLOOP.

   SELECT rollname, scrtext_m
    FROM dd04t
    INTO TABLE @DATA(lt_coldescr)
    FOR ALL ENTRIES IN @ct_fieldcat
    WHERE rollname EQ @ct_fieldcat-ref_field
    AND ddlanguage EQ @sy-langu.

  LOOP AT it_custom_fc REFERENCE INTO DATA(lr_cust_fc).
    TRANSLATE lr_cust_fc->fieldname TO UPPER CASE.
  ENDLOOP.

  LOOP AT ct_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    <fs_fcat>-scrtext_m = VALUE #( lt_coldescr[ rollname = <fs_fcat>-ref_field ]-scrtext_m OPTIONAL ).

    LOOP AT it_custom_fc ASSIGNING FIELD-SYMBOL(<fs_custom_fc>) WHERE fieldname EQ <fs_fcat>-fieldname.
      TRANSLATE <fs_custom_fc> TO LOWER CASE.
      ASSIGN COMPONENT <fs_custom_fc>-fc_component OF STRUCTURE <fs_fcat> TO FIELD-SYMBOL(<fs_comp>).
      IF sy-subrc EQ 0.
        <fs_comp> =  CONV #( <fs_custom_fc>-value ).
      ENDIF.
    ENDLOOP.

  ENDLOOP.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->GET_VIEW_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_ROW                          TYPE        LVC_INDEX
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_VIEW_DATA.

    DATA: lt_sel_rows TYPE TABLE OF se16n_seltab.

      CASE gv_program_name.
        WHEN 'nome_prog'.
          
      ENDCASE.


  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->HANDLE_TOOLBAR
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_OBJECT                       LIKE
* | [--->] E_INTERACTIVE                  LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
    METHOD HANDLE_TOOLBAR.

    CASE gv_program_name.
      WHEN 'nome_prog'.
        APPEND:
          VALUE #(
            butn_type = 3
          ) TO e_object->mt_toolbar,

          VALUE #(
            function = 'VIEW'
            icon = icon_employee
            quickinfo = 'Mostra storico'
            text = 'Storico'
            disabled = ' '
          ) TO e_object->mt_toolbar,

          VALUE #(
            function = 'SAVE'
            icon = icon_system_save
            quickinfo = 'Salva'
            text = 'Salva'
            disabled = ' '
          ) TO e_object->mt_toolbar.

      ENDCASE.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->HANDLE_USER_COMMAND
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD HANDLE_USER_COMMAND.

    DATA: lt_rows     TYPE lvc_t_row.

    CALL METHOD go_alv->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    CASE e_ucomm.
      WHEN 'VIEW'.
        IF lines( lt_rows ) EQ 1.
          get_view_data( i_row = lt_rows[ 1 ]-index ).
        ENDIF.

      WHEN 'SAVE'.
        save( it_rows = lt_rows ).

    ENDCASE.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->SAVE
* +-------------------------------------------------------------------------------------------------+
* | [--->] IT_ROWS                        TYPE        LVC_T_ROW(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method SAVE.

    CASE gv_program_name.
      WHEN 'nome_prog'.
        LOOP AT it_rows ASSIGNING FIELD-SYMBOL(<fs_rows>).
          gt_valutazione_forn[ <fs_rows>-index ]-sended = 'X'.
        ENDLOOP.
        PERFORM save_changes IN PROGRAM nome_prog IF FOUND USING it_rows .

    ENDCASE.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->TOP_OF_PAGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_DYNDOC_ID                    LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method TOP_OF_PAGE.

  CASE gv_program_name.
    WHEN 'nome_prog'.
      CALL METHOD e_dyndoc_id->add_text
       EXPORTING
         TEXT      = 'Legenda'
         SAP_STYLE = cl_dd_area=>heading.

  ENDCASE.


  endmethod.
ENDCLASS.
```
