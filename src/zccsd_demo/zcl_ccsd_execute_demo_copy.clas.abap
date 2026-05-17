CLASS zcl_ccsd_execute_demo_copy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_ccsd_execute_demo_copy IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    TRY.
        FINAL(log) = cl_bali_log=>create( ).

        zcl_ccsd_push_helper=>get_instance( )->copy_custom_data(
            template_name       = 'DEMO_1'
            comm_arrangement_id = 'TENANT_COPY_TST'
            simulate_only       = abap_false
            log                 = log
        ).

        out->write( |Log entries:| ) ##no_text.
        out->write( |------------| ).
        LOOP AT log->get_all_items( ) INTO FINAL(log_entry).
          out->write( |{ log_entry-item->severity }: { log_entry-item->get_message_text( ) }| ).
        ENDLOOP.

      CATCH cx_bali_runtime INTO FINAL(x_bali_runtime).
        out->write( x_bali_runtime->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
