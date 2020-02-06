<h1>Mail</h1>   
Per generare una mail in abap, visibile poi nella SOST, ci si deve affidare a delle classi standard.
In questo esempio viene generato un file .csv e poi spedito per mail ad una distribution list.   

```abap
FORM send_notification .

  DATA : obj_mail        TYPE REF TO cl_bcs,
         obj_send        TYPE REF TO if_recipient_bcs,
         l_output        TYPE boolean,
         mail_body       TYPE bcsy_text,
         lt_bin_excel    TYPE solix_tab,
         lv_size         TYPE so_obj_len,
         ls_tab_to_excel TYPE string.

  CHECK lines( gt_outtab ) GT 0.

" Trasformo la mia tabella interna in una tabella di stringhe
  LOOP AT gt_outtab ASSIGNING FIELD-SYMBOL(<fs_outtab>).
    LOOP AT gt_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
      ASSIGN COMPONENT <fs_fcat>-fieldname OF STRUCTURE <fs_outtab> TO FIELD-SYMBOL(<fs_field_outtab>).
      IF sy-subrc EQ 0.
        ls_tab_to_excel = |{ ls_tab_to_excel }{ <fs_field_outtab> }{ cl_abap_char_utilities=>horizontal_tab }|.
      ENDIF.
    ENDLOOP.

    ls_tab_to_excel = |{ ls_tab_to_excel }{ cl_abap_char_utilities=>newline }|.
  ENDLOOP.

  TRY.
      cl_bcs_convert=>string_to_solix(
      EXPORTING
      iv_string   = ls_tab_to_excel    " Input data
      iv_codepage = '4103'            " Target Code Page in SAP Form  (Default = SAPconnect Setting)
      iv_add_bom  =  'X'              " Add Byte-Order Mark
      IMPORTING
      et_solix    =  lt_bin_excel   " Output data
      ev_size     =  lv_size            " Size of Document Content
      ).

    CATCH cx_bcs.

  ENDTRY.

  TRY.
      obj_mail = cl_bcs=>create_persistent( ).
    CATCH cx_send_req_bcs.
  ENDTRY.

  TRY.
      obj_send ?=  cl_distributionlist_bcs=>getu_persistent( i_dliname = 'ROTTAME_ITA' i_private = ' ' ).
    CATCH cx_address_bcs.
  ENDTRY.

  TRY.
      obj_mail->add_recipient( i_recipient  = obj_send ).
    CATCH cx_send_req_bcs .
  ENDTRY.

  APPEND 'Quantità autorizzate rottame' TO mail_body.

  TRY.
      DATA(l_doc) =   cl_document_bcs=>create_document( i_type        = 'RAW'
                                                        i_subject     = 'Quantità autorizzate rottame'
                                                        i_sensitivity = 'P'
                                                        i_text        = mail_body ).
    CATCH cx_document_bcs .
  ENDTRY.

  TRY.
      l_doc->add_attachment(
        EXPORTING
          i_attachment_type     = 'xls'
          i_attachment_subject  = 'Allegato'
          i_attachment_size     = lv_size
          i_att_content_hex     = lt_bin_excel

      ).
    CATCH cx_document_bcs .
  ENDTRY.

  TRY.
      obj_mail->set_document( i_document = l_doc ).
    CATCH cx_send_req_bcs .
  ENDTRY.

  TRY.
      CALL METHOD obj_mail->send
        EXPORTING
          i_with_error_screen = space
        RECEIVING
          result              = l_output.
    CATCH cx_send_req_bcs .
  ENDTRY.

  COMMIT WORK.

ENDFORM. "send_notification
```
