CLASS zcx_ccsd DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .

    DATA template_name TYPE zif_ccsd_types=>ty_template_name.
    DATA filter_attr_name TYPE zif_ccsd_types=>ty_filter_attr_name.
    DATA filter_option TYPE zif_ccsd_types=>ty_filter_option.

    CONSTANTS:
      BEGIN OF template_not_found,
        msgid TYPE symsgid VALUE 'ZCCSD',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'TEMPLATE_NAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF template_not_found,

      BEGIN OF invalid_filter_attr_name,
        msgid TYPE symsgid VALUE 'ZCCSD',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'FILTER_ATTR_NAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_filter_attr_name,

      BEGIN OF invalid_filter_option,
        msgid TYPE symsgid VALUE 'ZCCSD',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'FILTER_OPTION',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_filter_option.


    METHODS constructor
      IMPORTING
        !textid           LIKE if_t100_message=>t100key OPTIONAL
        !previous         LIKE previous OPTIONAL
        !template_name    TYPE zif_ccsd_types=>ty_template_name OPTIONAL
        !filter_attr_name TYPE zif_ccsd_types=>ty_filter_attr_name OPTIONAL
        !filter_option    TYPE zif_ccsd_types=>ty_filter_option OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_CCSD IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    CLEAR me->textid.

    me->template_name = template_name.
    me->filter_attr_name = filter_attr_name.
    me->filter_option = filter_option.

    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
