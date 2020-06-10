<h1>ALV Manager</h1>
Questa classe può essere utilizzata per gestire toolbar e tabelle utilizzate da un’alv. E’ una classe generale quindi NON deve essere inserito del codice per un report specifico.
<br><br>

- **Classe**: *ZCL_ALV_MANAGER*
- **Metodi**: 
  - *Handle_toolbar* ( aggiunge bottoni sulla toolbar )
  - *Handle_user_command* ( gestione dei vari bottoni )
  - *Top_of_page* ( Evento TOP_OF_PAGE )
  - *Create_dyn_fc* ( crea il field catalog dinamico - Privato -> chiamato dal costruttore )
  - *Constructor* ( costruttore )
  - *Get_fcat* ( Ritorna il field catalog della tabella - PUBBLICO )<br><br>

ATTENZIONE<br>
Il metodo create_dyn_fc riceve in input il tipo tabella ZT_FC_CUSTOM. Se si vuole modificare un componente del field catalog si può inserire la modifica in questa tabella valorizzando i campi:
  - *FIELDNAME:* nome del campo della tabella di output ( es. matnr )
  - *FC_COMPONENT:* nome del componente del field catalog da modificare ( es. no_out )
  - *VALUE:* valore che si vuole dare al componente del field catalog ( es. ‘X’ )
  <br><br>

```abap
class ZCL_ALV_MANAGER definition
  public
  create public .

public section.

  types:
    BEGIN OF ty_fc_custom,
        fieldname    TYPE char255,
        fc_component TYPE char255,
        value        TYPE char255,
      END OF ty_fc_custom .
  types:
    BEGIN OF ty_button_toolbar,
        ls_btn    TYPE stb_button,
        has_param TYPE flag,
      END OF ty_button_toolbar .
  types:
    tty_fc_custom TYPE table OF ty_fc_custom .
  types:
    tty_button_toolbar TYPE TABLE OF ty_button_toolbar .

  data GO_ALV type ref to CL_GUI_ALV_GRID .
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
  methods CONSTRUCTOR
    importing
      value(IV_PROGRAM_NAME) type STRING
      value(IT_OUTTAB) type ANY
      value(IO_ALV) type ref to CL_GUI_ALV_GRID
      value(IT_TOOLBAR_BUTTON) type TTY_BUTTON_TOOLBAR optional
      value(IT_CUSTOM_FC) type TTY_FC_CUSTOM optional .
  methods GET_FCAT
    returning
      value(RT_FCAT) type LVC_T_FCAT .
protected section.

  data GT_FCAT type LVC_T_FCAT .
  data GT_TOOLBAR_BUTTON type TTY_BUTTON_TOOLBAR .
private section.

  methods CREATE_DYN_FC
    importing
      value(IS_OUTTAB) type DATA
      value(IT_CUSTOM_FC) type TTY_FC_CUSTOM optional
    returning
      value(CT_FIELDCAT) type LVC_T_FCAT .
ENDCLASS.



CLASS ZCL_ALV_MANAGER IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_PROGRAM_NAME                TYPE        STRING
* | [--->] IT_OUTTAB                      TYPE        ANY
* | [--->] IO_ALV                         TYPE REF TO CL_GUI_ALV_GRID
* | [--->] IT_TOOLBAR_BUTTON              TYPE        TTY_BUTTON_TOOLBAR(optional)
* | [--->] IT_CUSTOM_FC                   TYPE        TTY_FC_CUSTOM(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CONSTRUCTOR.

    DATA: lref_row_outtab  TYPE REF TO data,
          lref_outtab TYPE REF TO data.

    FIELD-SYMBOLS: <fs_outtab_row> TYPE any,
                   <fs_outtab>     TYPE INDEX TABLE.

    " Salvo internamente i dati in inpur
    go_alv = io_alv.
    gv_program_name = iv_program_name.
    gt_toolbar_button = it_toolbar_button.

    " Creo una tabella indicizzata
    CREATE DATA lref_outtab LIKE it_outtab.
    ASSIGN lref_outtab->* TO <fs_outtab>.

    " Creo una struttura basata sulla tabella
    CREATE DATA lref_row_outtab LIKE LINE OF <fs_outtab>.
    ASSIGN lref_row_outtab->* TO <fs_outtab_row>.

     " Passo i dati in input alla tabella
    MOVE-CORRESPONDING it_outtab TO <fs_outtab>.

    " Creo il fc della tabella ricevuta
    gt_fcat = create_dyn_fc( EXPORTING is_outtab = <fs_outtab_row> it_custom_fc = it_custom_fc ).

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCL_ALV_MANAGER->CREATE_DYN_FC
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_OUTTAB                      TYPE        DATA
* | [--->] IT_CUSTOM_FC                   TYPE        TTY_FC_CUSTOM(optional)
* | [<-()] CT_FIELDCAT                    TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method CREATE_DYN_FC.

     DATA : lo_ref_descr TYPE REF TO cl_abap_structdescr,
            lt_detail    TYPE abap_compdescr_tab,
            lt_field_det TYPE REF TO cl_abap_structdescr,
            ls_detail    LIKE LINE OF lt_detail,
            lr_typedescr TYPE REF TO cl_abap_typedescr,
            lv_counter   TYPE i VALUE 0.

  FIELD-SYMBOLS: <fs_dref>  TYPE any,
                 <fs_fname> TYPE any.

  lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( is_outtab ). "Chiamare metodo statico su una struttura
  lt_detail[] = lo_ref_descr->components.

  " Loop sui componenti della struttura - Creo fc
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

  " Estraggo descrizioni colonne std
   SELECT rollname, scrtext_m
    FROM dd04t
    INTO TABLE @DATA(lt_coldescr)
    FOR ALL ENTRIES IN @ct_fieldcat
    WHERE rollname EQ @ct_fieldcat-ref_field
    AND ddlanguage EQ @sy-langu.

   " Trasformo i campi inseriti dall'utente in upper case per evitare errori
  LOOP AT it_custom_fc REFERENCE INTO DATA(lr_cust_fc).
    TRANSLATE lr_cust_fc->fieldname TO UPPER CASE.
  ENDLOOP.

  " Applico le modifiche custom ai campi del fc
  LOOP AT ct_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
    <fs_fcat>-scrtext_m = VALUE #( lt_coldescr[ rollname = <fs_fcat>-ref_field ]-scrtext_m OPTIONAL ).

    LOOP AT it_custom_fc ASSIGNING FIELD-SYMBOL(<fs_custom_fc>) WHERE fieldname EQ <fs_fcat>-fieldname.
     
     " Evito che il valore venga convertito in minuscolo
      DATA(lv_fc_value) = <fs_custom_fc>-value.
      TRANSLATE <fs_custom_fc> TO LOWER CASE.
      ASSIGN COMPONENT <fs_custom_fc>-fc_component OF STRUCTURE <fs_fcat> TO FIELD-SYMBOL(<fs_comp>).
      IF sy-subrc EQ 0.
        <fs_comp> =  CONV #( lv_fc_value ).
      ENDIF.
      
    ENDLOOP.
  ENDLOOP.


  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->GET_FCAT
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RT_FCAT                        TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_FCAT.

    " Ritorno all'utente il fc creato nel costruttore
    rt_fcat = gt_fcat.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->HANDLE_TOOLBAR
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_OBJECT                       LIKE
* | [--->] E_INTERACTIVE                  LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD handle_toolbar.

    " Append dei bottoni custom alla toolbar standard
    LOOP AT gt_toolbar_button ASSIGNING FIELD-SYMBOL(<fs_toolbar>).
      APPEND <fs_toolbar>-ls_btn TO e_object->mt_toolbar.
    ENDLOOP.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->HANDLE_USER_COMMAND
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_UCOMM                        LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD HANDLE_USER_COMMAND.

    DATA: lt_rows     TYPE lvc_t_row.

    " Ottengo le linee selezionate dall'alv
    CALL METHOD go_alv->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    " Chiamo il perform in base alla funzione passata e al numero righe selezionate
    DATA(ls_button_triggered) = VALUE #( gt_toolbar_button[ ls_btn-function = e_ucomm ] OPTIONAL ).
    IF ls_button_triggered-has_param EQ 'X'.
      PERFORM (e_ucomm) IN PROGRAM (gv_program_name) IF FOUND USING lt_rows.
    ELSE.
      PERFORM (e_ucomm) IN PROGRAM (gv_program_name) IF FOUND.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_ALV_MANAGER->TOP_OF_PAGE
* +-------------------------------------------------------------------------------------------------+
* | [--->] E_DYNDOC_ID                    LIKE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD top_of_page.

    " Aggiungo il testo nella top-of-page
    CALL METHOD e_dyndoc_id->add_text
      EXPORTING
        text      = 'Header'
        sap_style = cl_dd_area=>heading.

  ENDMETHOD.
ENDCLASS.
```
