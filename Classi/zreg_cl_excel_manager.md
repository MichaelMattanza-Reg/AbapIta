```abap
CLASS zreg_cl_excel_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS: lc_value_separator VALUE ';'.
    TYPES:
      BEGIN OF ty_new_rows,
        index TYPE i,
        row   TYPE string,
      END OF ty_new_rows ,
      BEGIN OF ty_del_rows,
        index TYPE i,
      END OF ty_del_rows.
    TYPES:
      tty_new_rows TYPE TABLE OF ty_new_rows,
      tty_del_rows TYPE TABLE OF ty_del_rows.

    CLASS-METHODS create_excel_from_table
      EXPORTING
        VALUE(rv_bin_file) TYPE xstring
      CHANGING
        !ct_table          TYPE any .

    CLASS-METHODS add_rows_to_excel
      IMPORTING
        !it_new_rows TYPE tty_new_rows
      CHANGING
        !cv_data     TYPE xstring .

    CLASS-METHODS del_rows_from_excel
      IMPORTING
        !it_new_rows TYPE tty_del_rows
      CHANGING
        !cv_data     TYPE xstring .

    CLASS-METHODS create_table_from_excel
      EXPORTING
        !et_excel_tab TYPE tty_new_rows
      CHANGING
        !cv_excel     TYPE xstring.

    CLASS-METHODS upload_excel
      IMPORTING
        !iv_file_path TYPE string
      EXPORTING
        !ev_excel     TYPE xstring.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zreg_cl_excel_manager IMPLEMENTATION.


  METHOD add_rows_to_excel.
    DATA: lt_string_rows TYPE TABLE OF string,
          lt_rows        TYPE STANDARD TABLE OF string,
          lt_detail      TYPE abap_compdescr_tab,

          lref_data      TYPE REF TO data,

          lo_ref_descr   TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .

    TRY .
        DATA(lo_excel_ref) = NEW cl_fdt_xl_spreadsheet(
                                document_name = 'text.xlsx'
                                xdocument     = cv_data ) .
      CATCH cx_fdt_excel_core.
        "Implement suitable error handling here
    ENDTRY .

    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = DATA(lt_worksheets) ).

    IF NOT lt_worksheets IS INITIAL.
      READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lv_woksheetname ).
      "now you have excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data>.
    ENDIF.

    CHECK <gt_data> IS ASSIGNED.

    READ TABLE <gt_data> INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_row>).

    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( <fs_row> ). "Chiamare metodo statico su una struttura
    CREATE DATA lref_data TYPE HANDLE lo_ref_descr.
    lt_detail[] = lo_ref_descr->components.

    ASSIGN lref_data->* TO <fs_row>.
    CHECK <fs_row> IS ASSIGNED.

    LOOP AT it_new_rows ASSIGNING FIELD-SYMBOL(<fs_new_rows>).
      CLEAR <fs_row>.
      SPLIT <fs_new_rows>-row AT ';' INTO TABLE lt_string_rows.

      DATA(lv_counter) = 1.

      LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).
        ASSIGN COMPONENT <fs_detail>-name OF STRUCTURE <fs_row> TO FIELD-SYMBOL(<fs_component>).
        DATA(ls_string_rows) = VALUE #( lt_string_rows[ lv_counter ] OPTIONAL ).
        <fs_component> = ls_string_rows.
        lv_counter += 1.
      ENDLOOP.

      IF <fs_new_rows>-index IS NOT INITIAL.
        INSERT <fs_row> INTO <gt_data> INDEX <fs_new_rows>-index.
      ELSE.
        APPEND <fs_row> TO <gt_data>.
      ENDIF.
      CLEAR lt_string_rows.
    ENDLOOP.

    create_excel_from_table(
      IMPORTING
        rv_bin_file = cv_data
      CHANGING
        ct_table    = <gt_data>
    ).

  ENDMETHOD.


  METHOD create_excel_from_table.
    DATA(lref_excel_data) = REF #( ct_table ).

    ASSIGN lref_excel_data->* TO FIELD-SYMBOL(<fs_excel_data>).

    TRY.
        cl_salv_table=>factory(
        EXPORTING
          list_display = abap_false
        IMPORTING
          r_salv_table = DATA(lt_salv_table)
        CHANGING
          t_table      = <fs_excel_data> ).

        DATA(lt_fcat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
                                 r_columns      = lt_salv_table->get_columns( )
                                 r_aggregations = lt_salv_table->get_aggregations( )
                              ).
      CATCH cx_salv_msg.
        RETURN.
    ENDTRY.

    cl_salv_bs_lex=>export_from_result_data_table(
   EXPORTING
     is_format            = if_salv_bs_lex_format=>mc_format_xlsx
     ir_result_data_table =  cl_salv_ex_util=>factory_result_data_table(
                                             r_data                      = lref_excel_data
*                                                s_layout                    = is_layout
                                             t_fieldcatalog              = lt_fcat
*                                                t_sort                      = it_sort
*                                                t_filter                    = it_filt
*                                                t_hyperlinks                = it_hyperlinks
                                             )
   IMPORTING
     er_result_file       = rv_bin_file ).
  ENDMETHOD.

  METHOD del_rows_from_excel.
*    FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .
*
*    TRY .
*        DATA(lo_excel_ref) = NEW cl_fdt_xl_spreadsheet(
*                                document_name = 'test.xlsx'
*                                xdocument     = cv_data ) .
*      CATCH cx_fdt_excel_core.
*        "Implement suitable error handling here
*    ENDTRY .
*
*    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
*      IMPORTING
*        worksheet_names = DATA(lt_worksheets) ).
*
*    IF NOT lt_worksheets IS INITIAL.
*      READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.
*
*      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lv_woksheetname ).
*      "now you have excel work sheet data in dyanmic internal table
*      ASSIGN lo_data_ref->* TO <gt_data>.
*    ENDIF.
*
*    CHECK <gt_data> IS ASSIGNED.
  ENDMETHOD.

  METHOD create_table_from_excel.
    DATA: lt_string_rows TYPE TABLE OF string,
          lt_rows        TYPE STANDARD TABLE OF string,
          lt_detail      TYPE abap_compdescr_tab,

          lref_data      TYPE REF TO data,

          lo_ref_descr   TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS : <gt_data>       TYPE STANDARD TABLE .

    DATA(lv_doc_name) = 'test.xslx'.
    TRY .
        DATA(lo_excel_ref) = NEW cl_fdt_xl_spreadsheet(
                                document_name = CONV #( lv_doc_name )
                                xdocument     = cv_excel ) .
      CATCH cx_fdt_excel_core.
        "Implement suitable error handling here
    ENDTRY .

    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = DATA(lt_worksheets) ).

    IF NOT lt_worksheets IS INITIAL.
      READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lv_woksheetname ).
      "now you have excel work sheet data in dyanmic internal table
      ASSIGN lo_data_ref->* TO <gt_data>.
    ENDIF.

    CHECK <gt_data> IS ASSIGNED.
    READ TABLE <gt_data> INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_row>).

    lo_ref_descr ?= cl_abap_typedescr=>describe_by_data( <fs_row> ). "Chiamare metodo statico su una struttura
    CREATE DATA lref_data TYPE HANDLE lo_ref_descr.
    lt_detail[] = lo_ref_descr->components.


    LOOP AT <gt_data> ASSIGNING <fs_row>.
      APPEND VALUE #( ) TO et_excel_tab ASSIGNING FIELD-SYMBOL(<fs_rows_to_add>).
      LOOP AT lt_detail ASSIGNING FIELD-SYMBOL(<fs_detail>).
        ASSIGN COMPONENT <fs_detail>-name OF STRUCTURE <fs_row> TO FIELD-SYMBOL(<fs_component>).
        <fs_rows_to_add>-row = |{ <fs_rows_to_add>-row }{ <fs_component> };|.
      ENDLOOP.
    ENDLOOP.

*    add_rows_to_excel(
*      EXPORTING
*        it_new_rows = lt_rows_to_add
*      CHANGING
*        cv_data     = et
*    ).

  ENDMETHOD.

  METHOD upload_excel.

    DATA: lt_itab TYPE TABLE OF x,
          lv_lenght TYPE i,
          lv_excel_value TYPE STANDARD TABLE OF string.
*    DATA: lt_itab TYPE TABLE OF string,
*          lv_data_string TYPE string.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename                = CONV string( iv_file_path )
*       has_field_separator     = 'X'
        filetype                = 'BIN'
      TABLES
        data_tab                = lt_itab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        OTHERS                  = 17.

    DATA(lv_xstring_lenght) = REDUCE #( INIT wa_count TYPE int4 FOR wa_tab IN lt_itab NEXT wa_count += xstrlen( wa_tab ) ).

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_xstring_lenght
      IMPORTING
        buffer       = ev_excel
      TABLES
        binary_tab   = lt_itab
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
***
  ENDMETHOD.

ENDCLASS.
```
