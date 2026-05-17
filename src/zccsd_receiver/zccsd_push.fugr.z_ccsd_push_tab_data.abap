FUNCTION z_ccsd_push_tab_data.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(TABNAME) TYPE  TABNAME
*"     VALUE(PAYLOAD) TYPE  XSTRING OPTIONAL
*"     VALUE(OPERATION) TYPE  ZCCSD_PUSH_OPERATON DEFAULT 'I'
*"  EXPORTING
*"     VALUE(ERROR_CODE) TYPE  I
*"     VALUE(ERROR_MESSAGE) TYPE  BAPIRET2
*"----------------------------------------------------------------------
  DATA r_dbtab_data TYPE REF TO data.

  TRY.
      CREATE DATA r_dbtab_data TYPE STANDARD TABLE OF (tabname) WITH EMPTY KEY.

      IF payload IS NOT INITIAL.
        CALL TRANSFORMATION id
          SOURCE XML payload
          RESULT root = r_dbtab_data->*.
      ENDIF.

      FREE payload.

      DATA(lv_table_name_checked) = cl_abap_dyn_prg=>check_table_name_str(
          val      = tabname
          packages = space
      ).

      CASE operation.
        WHEN zif_ccsd_types=>c_operation-insert.
          INSERT (lv_table_name_checked) FROM TABLE @r_dbtab_data->*.
        WHEN zif_ccsd_types=>c_operation-modify.
          MODIFY (lv_table_name_checked) FROM TABLE @r_dbtab_data->*.
        WHEN zif_ccsd_types=>c_operation-delete.
          DELETE FROM (lv_table_name_checked).
        WHEN OTHERS.
          error_code = 1.
          error_message = VALUE #( type = 'E' message = |Unknown operation { operation }| ) ##no_text.
          RETURN.
      ENDCASE.

      FREE r_dbtab_data.

      COMMIT WORK.

    CATCH cx_root INTO DATA(x_root) ##catch_all.
      ROLLBACK WORK.
      error_code = 1.
      error_message = VALUE #( type = 'E' message = x_root->get_text( ) ).
  ENDTRY.

ENDFUNCTION.
