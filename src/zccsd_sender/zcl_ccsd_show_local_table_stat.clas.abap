CLASS zcl_ccsd_show_local_table_stat DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CCSD_SHOW_LOCAL_TABLE_STAT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.
        FINAL(table_statistics) = zcl_ccsd_local_helper=>get_instance( )->get_local_table_statistics( 'DEMO_1' ).
        out->write( table_statistics ).
        out->write( |{ lines( table_statistics ) NUMBER = USER } tables identified| ) ##NO_TEXT.

      CATCH zcx_ccsd INTO FINAL(exception).
        out->write( exception->get_text( ) ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
