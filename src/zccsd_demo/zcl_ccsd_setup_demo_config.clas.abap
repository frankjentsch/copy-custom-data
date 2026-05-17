CLASS zcl_ccsd_setup_demo_config DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_ccsd_setup_demo_config IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    "fill table ZCCSD_TEMPLATE
    DATA lt_template TYPE STANDARD TABLE OF zccsd_template WITH EMPTY KEY.

    lt_template = VALUE #(
        ( template_name = 'DEMO_1' template_desc = 'Table set demo 1' )
    ) ##NO_TEXT.

    DELETE FROM zccsd_template WHERE template_name = 'DEMO_1'.
    INSERT zccsd_template FROM TABLE @lt_template.
    COMMIT WORK.

    out->write( |ZCCSD_TEMPLATE: { sy-dbcnt } entries updated| ) ##NO_TEXT.

    "fill table ZCCSD_TEMPLATE_T
    DATA lt_template_t TYPE STANDARD TABLE OF zccsd_template_t WITH EMPTY KEY.

    lt_template_t = VALUE #(
        ( template_name = 'DEMO_1' template_item_no = '0001' filter_attr_name = zif_ccsd_types=>c_filter_attr_name-table_name filter_option = 'EQ' filter_low = 'ZCCSD_DEMO_TAB_1' )
        ( template_name = 'DEMO_1' template_item_no = '0002' filter_attr_name = zif_ccsd_types=>c_filter_attr_name-table_name filter_option = 'EQ' filter_low = 'ZCCSD_DEMO_TAB_2' )
    ) ##NO_TEXT.

    DELETE FROM zccsd_template_t WHERE template_name = 'DEMO_1'.
    INSERT zccsd_template_t FROM TABLE @lt_template_t.
    COMMIT WORK.

    out->write( |ZCCSD_TEMPLATE_I: { sy-dbcnt } entries updated| ) ##NO_TEXT.

  ENDMETHOD.

ENDCLASS.
