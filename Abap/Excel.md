      
      Leggere excel lato frontend:
      
      CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
        EXPORTING
          filename                = CONV rlgrap-filename( |{ p_file }| )
          i_begin_col             = '1'
          i_begin_row             = '2'
          i_end_col               = '23'
          i_end_row               = '65536'
        TABLES
          intern                  = lt_exc_file
        EXCEPTIONS
          inconsistent_parameters = 1
          upload_ole              = 2
          OTHERS                  = 3.
          
          
          oppure 
          utilizzando INCLUDE ole2incl.
