CLASS ltc_ccsd_local_helper DEFINITION FINAL FOR TESTING
  DURATION SHORT RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES ty_template_stub TYPE STANDARD TABLE OF zccsd_template WITH EMPTY KEY.
    TYPES ty_template_t_stub TYPE STANDARD TABLE OF zccsd_template_t WITH EMPTY KEY.

    "! ABAP SQL test environment
    CLASS-DATA environment TYPE REF TO if_osql_test_environment.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.

    "! Class under test
    DATA cut TYPE REF TO zcl_ccsd_local_helper.

    METHODS setup.
    METHODS get_instance_test          FOR TESTING.
    METHODS get_table_names_01_test    FOR TESTING.
    METHODS get_table_names_02_test    FOR TESTING.
    METHODS get_table_names_03_test    FOR TESTING.
    METHODS get_local_table_statistics FOR TESTING.

    "! Test helper method
    METHODS configure_db_testdoubles
      IMPORTING
        template_stub_data   TYPE ty_template_stub OPTIONAL
        template_t_stub_data TYPE ty_template_t_stub OPTIONAL.

ENDCLASS.

CLASS ltc_ccsd_local_helper IMPLEMENTATION.

  METHOD class_setup.
    environment = cl_osql_test_environment=>create(
        i_dependency_list = VALUE #( ( 'ZCCSD_TEMPLATE' ) ( 'ZCCSD_TEMPLATE_T' ) )
    ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    cut = zcl_ccsd_local_helper=>get_instance( ).
    cl_abap_unit_assert=>assert_bound( act = cut ).

    environment->clear_doubles( ).
  ENDMETHOD.

  METHOD configure_db_testdoubles.
    environment->clear_doubles( ).

    IF template_stub_data IS SUPPLIED.
      environment->insert_test_data( template_stub_data ).
    ENDIF.
    IF template_t_stub_data IS SUPPLIED.
      environment->insert_test_data( template_t_stub_data ).
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_test.
    cl_abap_unit_assert=>assert_equals( act = zcl_ccsd_local_helper=>get_instance( ) exp = cut ).
  ENDMETHOD.

  METHOD get_table_names_01_test.
    "Read all custom tables
    TRY.
        FINAL(table_names) = cut->get_table_names( ).

        cl_abap_unit_assert=>assert_true(
            act = boolc( lines( table_names ) > 2 )
            msg = 'Unexpected number of custom tables'
        ).

        cl_abap_unit_assert=>assert_table_contains(
            line  = CONV zif_ccsd_types=>ty_table_name( 'ZCCSD_DEMO_TAB_1' )
            table = table_names
            msg   = 'ZCCSD_DEMO_TAB_1 not found'
        ).

        cl_abap_unit_assert=>assert_table_contains(
            line  = CONV zif_ccsd_types=>ty_table_name( 'ZCCSD_DEMO_TAB_2' )
            table = table_names
            msg   = 'ZCCSD_DEMO_TAB_2 not found'
        ).

      CATCH zcx_ccsd.
        cl_abap_unit_assert=>fail( 'Unexpected exception' ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_table_names_02_test.
    "Read unknown template
    TRY.
        FINAL(table_names) = cut->get_table_names( template_name = '@YYY-00' ).
        cl_abap_unit_assert=>fail( 'Expected exception not raised' ).

      CATCH zcx_ccsd INTO FINAL(exception).
        cl_abap_unit_assert=>assert_equals(
            act = exception->if_t100_message~t100key
            exp = zcx_ccsd=>template_not_found
            msg = 'Unexpected exception'
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_table_names_03_test.
    " Configure response of the ABAP SQL test double
    configure_db_testdoubles(
        template_stub_data = VALUE ty_template_stub(
          ( template_name = '@YYY-01' )
        )
        template_t_stub_data = VALUE ty_template_t_stub(
          ( template_name = '@YYY-01' template_item_no = '0001' filter_attr_name = 'TABLE_NAME' filter_option = 'EQ' filter_low = 'ZCCSD_TEMPLATE' )
          ( template_name = '@YYY-01' template_item_no = '0002' filter_attr_name = 'TABLE_NAME' filter_option = 'EQ' filter_low = 'ZCCSD_TEMPLATE_T' )
        )
    ).

    TRY.
        FINAL(table_names) = cut->get_table_names( template_name = '@YYY-01' ).
        cl_abap_unit_assert=>assert_equals(
            act = table_names
            exp = VALUE zif_ccsd_types=>ty_table_names( ( 'ZCCSD_TEMPLATE' ) ( 'ZCCSD_TEMPLATE_T' ) )
        ).

      CATCH zcx_ccsd INTO FINAL(exception).
        cl_abap_unit_assert=>fail(
            msg    = 'Unexpected exception'
            detail = exception->get_text( )
        ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_local_table_statistics.
    " Implementation for this method is not provided in the original code
  ENDMETHOD.

ENDCLASS.
