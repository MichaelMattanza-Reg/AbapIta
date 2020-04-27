<h1>Unit Test sistemi vecchi</h1>

```abap 
class ZCL_UT_PRINT definition
  public
  final
  create public .

public section.

  interfaces /REG/IF_UT_PRINT_DOCUMENT_OLD .

  data GV_REPID type REPID .

  methods CONSTRUCTOR
    importing
      !IV_REPID type REPID .
protected section.
private section.
ENDCLASS.



CLASS ZCL_UT_PRINT IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_UT_PRINT->/REG/IF_UT_PRINT_DOCUMENT_OLD~CREATE_PDF
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_NAST                         TYPE        NAST
* | [--->] IS_UNIT_TEST_ENABLED           TYPE        FLAG(optional)
* | [<---] E_PDF                          TYPE        XSTRING
* | [<---] E_DATA                         TYPE REF TO DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /REG/IF_UT_PRINT_DOCUMENT_OLD~CREATE_PDF.

  DATA: lv_xdata          TYPE xstring,
        lv_xdata_typename TYPE typename,
        lv_destination    TYPE string.

  FIELD-SYMBOLS: <fs_data> TYPE any.

  CALL FUNCTION '/REG/GET_PDF_DOCUMENT' DESTINATION lv_destination
    EXPORTING
      iw_nast              = i_nast
      is_unit_test_enabled = is_unit_test_enabled
    IMPORTING
      e_data_typename      = lv_xdata_typename
      e_data               = lv_xdata
      e_pdf                = e_pdf.

  CHECK lv_xdata IS NOT INITIAL AND lv_xdata_typename IS NOT INITIAL.

  CREATE DATA e_data TYPE (lv_xdata_typename).

  ASSIGN e_data->* TO <fs_data>.
  CHECK sy-subrc EQ 0.

  CALL TRANSFORMATION id
    SOURCE XML lv_xdata
    RESULT param_data = <fs_data>.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_UT_PRINT->/REG/IF_UT_PRINT_DOCUMENT_OLD~GET_PRINT_DATA
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_NAST                         TYPE        NAST
* | [--->] I_RETCODE                      TYPE        SYSUBRC(optional)
* | [--->] I_SCREEN                       TYPE        CHAR1(optional)
* | [<---] E_RETCODE                      TYPE        SYSUBRC
* | [<---] E_SCREEN                       TYPE        CHAR1
* | [<---] E_DATA                         TYPE REF TO DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
METHOD /REG/IF_UT_PRINT_DOCUMENT_OLD~GET_PRINT_DATA.

  DATA: lref_data   TYPE REF TO data,
        lv_nast_pnt TYPE string,
        lv_data_pnt TYPE string.

  FIELD-SYMBOLS: <fs_data>    TYPE any,
                 <fs_nast>    TYPE nast,
                 <fs_retcode> TYPE sy-subrc.

  lv_nast_pnt = gv_repid &&  'NAST'.
  lv_data_pnt = gv_repid &&  'GS_INTERFACE'.

  ASSIGN (lv_nast_pnt) TO <fs_nast>.
  ASSIGN (lv_data_pnt) TO <fs_data>.

  PERFORM select_data IN PROGRAM (gv_repid) IF FOUND.
  CHECK <fs_retcode> IS INITIAL.

  GET REFERENCE OF <fs_data> INTO e_data.
  e_retcode = <fs_retcode>.
  e_screen = i_screen.

ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_UT_PRINT->/REG/IF_UT_PRINT_DOCUMENT_OLD~GET_PRINT_DATA_FOR_TESTING
* +-------------------------------------------------------------------------------------------------+
* | [--->] I_NAST                         TYPE        NAST
* | [--->] I_RETCODE                      TYPE        SYSUBRC(optional)
* | [--->] I_SCREEN                       TYPE        CHAR1(optional)
* | [<---] E_RETCODE                      TYPE        SYSUBRC
* | [<---] E_SCREEN                       TYPE        CHAR1
* | [<---] E_DATA                         TYPE REF TO DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
method /REG/IF_UT_PRINT_DOCUMENT_OLD~GET_PRINT_DATA_FOR_TESTING.

  DATA: lref_data   TYPE REF TO data,
        lv_nast_pnt TYPE string,
        lv_data_pnt TYPE string.

  FIELD-SYMBOLS: <fs_data>    TYPE any,
                 <fs_nast>    TYPE nast,
                 <fs_retcode> TYPE sy-subrc.

  lv_nast_pnt = gv_repid &&  'NAST'.
  lv_data_pnt = gv_repid &&  'GS_INTERFACE'.

  ASSIGN (lv_nast_pnt) TO <fs_nast>.
  ASSIGN (lv_data_pnt) TO <fs_data>.

  PERFORM select_data IN PROGRAM (gv_repid) CHANGING <fs_retcode> IF FOUND.
  CHECK <fs_retcode> IS INITIAL.

  GET REFERENCE OF <fs_data> INTO e_data.
  e_retcode = <fs_retcode>.
  e_screen = i_screen.

endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_UT_PRINT->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] IV_REPID                       TYPE        REPID
* +--------------------------------------------------------------------------------------</SIGNATURE>
method CONSTRUCTOR.
  gv_repid = iv_repid.
endmethod.
ENDCLASS.
```