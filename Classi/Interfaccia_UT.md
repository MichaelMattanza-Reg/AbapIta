
<h1>Interfaccia UT</h1>

```abap
interface /REG/IF_UT_PRINT_DOCUMENT_OLD
  public .


  constants C_GET_PRINT_DATA type STRING value 'get_print_data'. "#EC NOTEXT
  constants C_GET_PRINT_DATA_FOR_TESTING type STRING value 'get_print_data_for_testing'. "#EC NOTEXT
  constants C_CREATE_PDF type STRING value 'create_pdf'. "#EC NOTEXT

  methods GET_PRINT_DATA
    importing
      !I_NAST type NAST
      value(I_RETCODE) type SYSUBRC optional
      value(I_SCREEN) type CHAR1 optional
    exporting
      !E_RETCODE type SYSUBRC
      !E_SCREEN type CHAR1
      value(E_DATA) type ref to DATA .
  methods GET_PRINT_DATA_FOR_TESTING
    importing
      !I_NAST type NAST
      value(I_RETCODE) type SYSUBRC optional
      value(I_SCREEN) type CHAR1 optional
    exporting
      !E_RETCODE type SYSUBRC
      !E_SCREEN type CHAR1
      value(E_DATA) type ref to DATA .
  methods CREATE_PDF
    importing
      !I_NAST type NAST
      !IS_UNIT_TEST_ENABLED type FLAG optional
    exporting
      !E_PDF type XSTRING
      value(E_DATA) type ref to DATA .
endinterface.
