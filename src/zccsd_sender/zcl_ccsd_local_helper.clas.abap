CLASS zcl_ccsd_local_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-DATA singleton TYPE REF TO zcl_ccsd_local_helper.

    CLASS-METHODS get_instance
      RETURNING VALUE(result) TYPE REF TO zcl_ccsd_local_helper.

    METHODS get_table_names
      IMPORTING template_name      TYPE zif_ccsd_types=>ty_template_name OPTIONAL
      RETURNING VALUE(table_names) TYPE zif_ccsd_types=>ty_table_names
      RAISING   zcx_ccsd.

    METHODS get_local_table_statistics
      IMPORTING template_name           TYPE zif_ccsd_types=>ty_template_name OPTIONAL
      RETURNING VALUE(table_statictics) TYPE zif_ccsd_types=>ty_table_statistics
      RAISING   zcx_ccsd.

ENDCLASS.


CLASS zcl_ccsd_local_helper IMPLEMENTATION.

  METHOD get_instance.

    IF singleton IS NOT BOUND.
      CREATE OBJECT singleton.
    ENDIF.
    result = singleton.

  ENDMETHOD.

  METHOD get_table_names.

    IF template_name IS INITIAL.
      "no copy template - simulate all tables in the system
      DATA(database_tables_ref) = xco_cp_abap_repository=>objects->tabl->database_tables->all->in( xco_cp_abap=>repository )->get( ).
    ELSE.
      "copy template specified
      SELECT SINGLE @abap_true FROM zccsd_template WHERE template_name = @template_name INTO @DATA(template_name_exists).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_ccsd
          EXPORTING
            textid        = zcx_ccsd=>template_not_found
            template_name = template_name.
      ENDIF.

      "apply filter from copy template
      SELECT * FROM zccsd_template_t WHERE template_name = @template_name ORDER BY PRIMARY KEY INTO TABLE @DATA(table_filter_items).

      IF table_filter_items IS INITIAL.
        "no filter defined for the template - determine all tables in the system
        database_tables_ref = xco_cp_abap_repository=>objects->tabl->database_tables->all->in( xco_cp_abap=>repository )->get( ).
      ELSE.
        "evaluate filter settings
        DATA table_name_filters TYPE sxco_t_ar_filters.
        DATA swc_name_filters TYPE sxco_t_ar_filters.
        DATA constraint TYPE REF TO cl_xco_asql_constraint.
        LOOP AT table_filter_items INTO DATA(table_filter_item).
          CASE table_filter_item-filter_option.
            WHEN 'BT'.
              constraint = xco_cp_abap_sql=>constraint->between( iv_low = table_filter_item-filter_low iv_high = table_filter_item-filter_high ).
            WHEN 'CP'.
              constraint = xco_cp_abap_sql=>constraint->contains_pattern( table_filter_item-filter_low ).
            WHEN 'NP'.
              constraint = xco_cp_abap_sql=>constraint->does_not_contain_pattern( table_filter_item-filter_low ).
            WHEN 'EQ'.
              constraint = xco_cp_abap_sql=>constraint->equal( table_filter_item-filter_low ).
            WHEN 'GE'.
              constraint = xco_cp_abap_sql=>constraint->greater_equal( table_filter_item-filter_low ).
            WHEN 'GT'.
              constraint = xco_cp_abap_sql=>constraint->greater_than( table_filter_item-filter_low ).
            WHEN 'LE'.
              constraint = xco_cp_abap_sql=>constraint->less_equal( table_filter_item-filter_low ).
            WHEN 'LT'.
              constraint = xco_cp_abap_sql=>constraint->less_than( table_filter_item-filter_low ).
            WHEN 'NB'.
              constraint = xco_cp_abap_sql=>constraint->not_between( iv_low = table_filter_item-filter_low iv_high = table_filter_item-filter_high ).
            WHEN 'NE'.
              constraint = xco_cp_abap_sql=>constraint->not_equal( table_filter_item-filter_low ).
            WHEN OTHERS.
              "invalid filter option - should never happen as filter option is defined by a domain with fixed values
              RAISE EXCEPTION TYPE zcx_ccsd
                EXPORTING
                  textid        = zcx_ccsd=>invalid_filter_option
                  filter_option = table_filter_item-filter_option.
          ENDCASE.

          CASE table_filter_item-filter_attr_name.
            WHEN zif_ccsd_types=>c_filter_attr_name-table_name.
              APPEND xco_cp_abap_repository=>object_name->get_filter( constraint ) TO table_name_filters.
            WHEN zif_ccsd_types=>c_filter_attr_name-swc_name.
              APPEND xco_cp_system=>software_component->get_filter( constraint ) TO swc_name_filters.
            WHEN OTHERS.
              "invalid filter attribute name - should never happen as filter attribute name is defined by a domain with fixed values
              RAISE EXCEPTION TYPE zcx_ccsd
                EXPORTING
                  textid           = zcx_ccsd=>invalid_filter_attr_name
                  filter_attr_name = table_filter_item-filter_attr_name.
          ENDCASE.

        ENDLOOP.

        DATA filters TYPE sxco_t_ar_filters.

        IF table_name_filters IS NOT INITIAL.
          DATA(table_name_union_filter) = xco_cp_abap_repository=>filter->union( table_name_filters ).
          APPEND table_name_union_filter TO filters.
        ENDIF.

        IF swc_name_filters IS NOT INITIAL.
          DATA(swc_name_union_filter) = xco_cp_abap_repository=>filter->union( swc_name_filters ).
          APPEND swc_name_union_filter TO filters.
        ENDIF.

        database_tables_ref = xco_cp_abap_repository=>objects->tabl->database_tables->where( filters )->in( xco_cp_abap=>repository )->get( ).
      ENDIF.
    ENDIF.

    LOOP AT database_tables_ref INTO DATA(database_table_ref).
      APPEND database_table_ref->name TO table_names.
    ENDLOOP.

    SORT table_names BY table_line.

  ENDMETHOD.

  METHOD get_local_table_statistics.

    FINAL(table_names) = get_table_names( template_name ).

    LOOP AT table_names INTO DATA(table_name).
      APPEND INITIAL LINE TO table_statictics ASSIGNING FIELD-SYMBOL(<table_statictic>).
      <table_statictic>-table_name = table_name.
      <table_statictic>-row_count  = -1.

      TRY.
          DATA(table_name_checked) = cl_abap_dyn_prg=>check_table_name_str(
              val      = table_name
              packages = space
          ).

        CATCH cx_abap_not_a_table
              cx_abap_not_in_package.
          CONTINUE.
      ENDTRY.

      TRY.
          SELECT     COUNT(*)
            FROM     (table_name_checked)
            INTO     @<table_statictic>-row_count.

        CATCH cx_root.
          CONTINUE.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
