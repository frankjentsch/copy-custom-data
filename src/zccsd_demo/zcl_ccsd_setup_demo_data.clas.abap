CLASS zcl_ccsd_setup_demo_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_ccsd_setup_demo_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    CONSTANTS c_block_size TYPE i VALUE 10001.
    CONSTANTS c_nr_of_blocks TYPE i VALUE 2.

    DELETE FROM zccsd_demo_tab_1.                       "#EC CI_NOWHERE
    COMMIT WORK.
    out->write( |ZCCSD_DEMO_TAB_1: { sy-dbcnt } entries deleted| ) ##NO_TEXT.

    DELETE FROM zccsd_demo_tab_2.                       "#EC CI_NOWHERE
    COMMIT WORK.
    out->write( |ZCCSD_DEMO_TAB_2: { sy-dbcnt } entries deleted| ) ##NO_TEXT.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    DATA lt_demo_tab_data_1 TYPE STANDARD TABLE OF zccsd_demo_tab_1 WITH EMPTY KEY.
    DATA lt_demo_tab_data_2 TYPE STANDARD TABLE OF zccsd_demo_tab_2 WITH EMPTY KEY.

    DO c_nr_of_blocks TIMES.

      DATA(current_block) = sy-index.

      CLEAR lt_demo_tab_data_1.
      CLEAR lt_demo_tab_data_2.

      DO c_block_size TIMES.
        DATA(total_index) = ( current_block - 1 ) * c_block_size + sy-index.

        TRY.
            APPEND VALUE #( event_uuid            = cl_system_uuid=>create_uuid_x16_static( )
                            event_id              = |E{ total_index }|
                            event_name            = |Event { total_index }|
                            location              = |Location { total_index }|
                            is_online             = abap_false
                            date_from             = '20260918'
                            date_to               = '20261013'
                            local_last_changed_at = lv_timestamp
                            last_changed_at       = lv_timestamp ) TO lt_demo_tab_data_1 ##NO_TEXT.
          CATCH cx_uuid_error.
            CONTINUE.
        ENDTRY.
      ENDDO.

      INSERT zccsd_demo_tab_1 FROM TABLE @lt_demo_tab_data_1.
      COMMIT WORK.

      MOVE-CORRESPONDING lt_demo_tab_data_1 TO lt_demo_tab_data_2.
      INSERT zccsd_demo_tab_2 FROM TABLE @lt_demo_tab_data_2.
      COMMIT WORK.

    ENDDO.

    out->write( |ZCCSD_DEMO_TAB_1: { c_nr_of_blocks * c_block_size } entries inserted| ) ##NO_TEXT.
    out->write( |ZCCSD_DEMO_TAB_2: { c_nr_of_blocks * c_block_size } entries inserted| ) ##NO_TEXT.

  ENDMETHOD.

ENDCLASS.
