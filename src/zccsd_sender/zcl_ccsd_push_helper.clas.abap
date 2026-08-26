CLASS zcl_ccsd_push_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-DATA singleton TYPE REF TO zcl_ccsd_push_helper.

    CLASS-METHODS get_instance
      RETURNING VALUE(result) TYPE REF TO zcl_ccsd_push_helper.

    METHODS copy_custom_data
      IMPORTING template_name       TYPE zif_ccsd_types=>ty_template_name
                comm_arrangement_id TYPE zif_ccsd_types=>ty_comm_arrangement_id
                simulate_only       TYPE abap_bool DEFAULT abap_true
                log                 TYPE REF TO if_bali_log.

  PRIVATE SECTION.
    CONSTANTS c_comm_scenario_id TYPE if_com_scenario=>ty_cscn-id VALUE 'ZCCSD_PUSH_TAB_DATA'.
    CONSTANTS c_rfc_name         TYPE c LENGTH 30 VALUE 'Z_CCSD_PUSH_TAB_DATA'.

    METHODS copy_table_to_target_system
      IMPORTING destination_name TYPE zif_ccsd_types=>ty_destination_name
                table_name       TYPE zif_ccsd_types=>ty_table_name
                log              TYPE REF TO if_bali_log
      RETURNING VALUE(failed)    TYPE abap_bool.

    METHODS call_rfc
      IMPORTING destination_name TYPE zif_ccsd_types=>ty_destination_name
                table_name       TYPE zif_ccsd_types=>ty_table_name
                payload          TYPE xstring OPTIONAL
                operation        TYPE zif_ccsd_types=>ty_operation
                log              TYPE REF TO if_bali_log
      RETURNING VALUE(failed)    TYPE abap_bool.

    METHODS has_ca_for_target_tenant
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS get_comm_system_id_by_ca
      IMPORTING comm_arrangement_id TYPE zif_ccsd_types=>ty_comm_arrangement_id
      RETURNING VALUE(result)       TYPE zif_ccsd_types=>ty_comm_system_id.

ENDCLASS.


CLASS zcl_ccsd_push_helper IMPLEMENTATION.

  METHOD get_instance.

    IF singleton IS NOT BOUND.
      CREATE OBJECT singleton.
    ENDIF.

    result = singleton.

  ENDMETHOD.

  METHOD copy_custom_data.

    TRY.
        "common checks for simulation and production run
        TRY.
            FINAL(table_names) = zcl_ccsd_local_helper=>get_instance( )->get_table_names( template_name ).

          CATCH zcx_ccsd INTO DATA(x_ccsd).
            log->add_item( cl_bali_exception_setter=>create(
                severity  = if_bali_constants=>c_severity_termination
                exception = x_ccsd ) ).
            RETURN.
        ENDTRY.

        IF table_names IS INITIAL.
          log->add_item( cl_bali_free_text_setter=>create(
              severity = if_bali_constants=>c_severity_termination
              text     = |Set of table names configured for template { template_name } is empty| ) ) ##no_text.
          RETURN.
        ENDIF.

        IF comm_arrangement_id IS INITIAL.
          log->add_item( cl_bali_free_text_setter=>create(
              severity = if_bali_constants=>c_severity_termination
              text     = |Communication Arrangement not specified| ) ) ##no_text.
          RETURN.
        ENDIF.

        IF has_ca_for_target_tenant( ) = abap_false.
          log->add_item( cl_bali_free_text_setter=>create(
              severity = if_bali_constants=>c_severity_termination
              text     = |No Communication Arrangement defined yet for scenario { c_comm_scenario_id }| ) ) ##no_text.
          RETURN.
        ENDIF.

        FINAL(comm_system_id) = get_comm_system_id_by_ca( comm_arrangement_id ).
        IF comm_system_id IS INITIAL.
          log->add_item( cl_bali_free_text_setter=>create(
              severity = if_bali_constants=>c_severity_termination
              text     = |Communication Arrangement { comm_arrangement_id } does not exist for scenario { c_comm_scenario_id }| ) ) ##no_text.
          RETURN.
        ENDIF.

        IF simulate_only = abap_true.
          "processing in simulation mode
          TRY.
              FINAL(table_statistics) = zcl_ccsd_local_helper=>get_instance( )->get_local_table_statistics( template_name ).

            CATCH zcx_ccsd INTO x_ccsd.
              log->add_item( cl_bali_exception_setter=>create(
                  severity  = if_bali_constants=>c_severity_error
                  exception = x_ccsd ) ).
              RETURN.
          ENDTRY.

          LOOP AT table_statistics INTO DATA(table_statistic).
            IF table_statistic-row_count >= 0.
              log->add_item( cl_bali_free_text_setter=>create(
                  severity = if_bali_constants=>c_severity_status
                  text     = |Table { table_statistic-table_name } will be copied with { table_statistic-row_count NUMBER = USER } rows| ) ) ##no_text.
            ELSE.
              log->add_item( cl_bali_free_text_setter=>create(
                  severity = if_bali_constants=>c_severity_error
                  text     = |Table { table_statistic-table_name } does not exist or is located in another software component and not released| ) ) ##no_text.
            ENDIF.
          ENDLOOP.
        ELSE.
          "processing in production mode
          TRY.
              FINAL(destination) = cl_rfc_destination_provider=>create_by_comm_arrangement(
                  comm_scenario  = c_comm_scenario_id
                  comm_system_id = CONV #( comm_system_id )
              ).

              FINAL(destination_name) = destination->get_destination_name( ).

              LOOP AT table_names INTO DATA(table_name).
                IF copy_table_to_target_system(
                       destination_name = destination_name
                       table_name       = table_name
                       log              = log
                   ) = abap_true.
                  EXIT.
                ENDIF.
              ENDLOOP.

            CATCH cx_rfc_dest_provider_error INTO FINAL(x_rfc_dest_provider_error).
              log->add_item( cl_bali_exception_setter=>create(
                 severity  = if_bali_constants=>c_severity_termination
                 exception = x_rfc_dest_provider_error ) ).
              RETURN.
          ENDTRY.
        ENDIF.

      CATCH cx_bali_runtime INTO FINAL(x_bali_runtime).
        RAISE SHORTDUMP x_bali_runtime.
    ENDTRY.

  ENDMETHOD.

  METHOD copy_table_to_target_system.

    CONSTANTS c_package_size TYPE i VALUE 10000.

    DATA r_dbtab_data      TYPE REF TO data.
    DATA payload           TYPE xstring.

    FIELD-SYMBOLS <lt_dbtab_data> TYPE STANDARD TABLE.

    "select data
    TRY.
        CREATE DATA r_dbtab_data TYPE STANDARD TABLE OF (table_name) WITH EMPTY KEY.
        ASSIGN r_dbtab_data->* TO <lt_dbtab_data>.

      CATCH cx_root INTO FINAL(x_root_create_data).
        TRY.
            log->add_item( cl_bali_free_text_setter=>create(
                  severity = if_bali_constants=>c_severity_error
                  text     = |Table { table_name }: { x_root_create_data->get_text( ) }| ) ) ##no_text.
            RETURN.
          CATCH cx_bali_runtime INTO DATA(x_bali_runtime).
            RAISE SHORTDUMP x_bali_runtime.
        ENDTRY.
    ENDTRY.

    TRY.
        "remove data in target tenant
        IF call_rfc(
               destination_name = destination_name
               table_name       = table_name
               operation        = zif_ccsd_types=>c_operation-delete
               log              = log
           ) = abap_true.
          RETURN.
        ENDIF.

        DATA(lv_table_name_checked) = cl_abap_dyn_prg=>check_table_name_str(
            val      = CONV string( table_name )
            packages = space
        ).

        DATA(package_index) = 0.
        DATA(total_rows) = 0.

        DO.
          SELECT FROM (lv_table_name_checked) FIELDS * ORDER BY PRIMARY KEY INTO TABLE @<lt_dbtab_data> OFFSET @total_rows UP TO @c_package_size ROWS.

          package_index += 1.
          total_rows += lines( <lt_dbtab_data> ).

          IF lines( <lt_dbtab_data> ) < c_package_size.
            DATA(last_package_reached) = abap_true.
          ENDIF.

          "serialize table data json
          DATA(xml_writer) = cl_sxml_string_writer=>create( type = if_sxml=>co_xt_json ).
          CALL TRANSFORMATION id
            SOURCE root = <lt_dbtab_data>
            RESULT XML xml_writer.

          payload = xml_writer->get_output( ).
          CLEAR <lt_dbtab_data>.
          FREE xml_writer.

          IF call_rfc(
                 destination_name = destination_name
                 table_name       = table_name
                 payload          = payload
                 operation        = zif_ccsd_types=>c_operation-insert
                 log              = log
             ) = abap_true.
            RETURN.
          ENDIF.

          IF last_package_reached = abap_true.
            EXIT.
          ENDIF.
        ENDDO.

        IF package_index > 1.
          log->add_item( cl_bali_free_text_setter=>create(
              severity = if_bali_constants=>c_severity_status
              text     = |Table { table_name } copied with { total_rows NUMBER = USER } rows (with { package_index NUMBER = USER } packages)| ) ) ##no_text.
        ELSE.
          log->add_item( cl_bali_free_text_setter=>create(
              severity = if_bali_constants=>c_severity_status
              text     = |Table { table_name } copied with { total_rows NUMBER = USER } rows| ) ) ##no_text.
        ENDIF.

      CATCH cx_root INTO FINAL(x_root).
        TRY.
            log->add_item( cl_bali_free_text_setter=>create(
                  severity = if_bali_constants=>c_severity_error
                  text     = |Table { table_name }: { x_root->get_text( ) }| ) ) ##no_text.
          CATCH cx_bali_runtime INTO x_bali_runtime.
            RAISE SHORTDUMP x_bali_runtime.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.

  METHOD call_rfc.

    DATA rfc_error_code    TYPE i.
    DATA rfc_error_message TYPE bapiret2.
    DATA msg               TYPE bapiret2-message.

    TRY.
        CALL FUNCTION c_rfc_name DESTINATION destination_name
          EXPORTING
            tabname               = table_name
            payload               = payload
            operation             = operation
          IMPORTING
            error_code            = rfc_error_code
            error_message         = rfc_error_message
          EXCEPTIONS
            system_failure        = 1 MESSAGE msg
            communication_failure = 2 MESSAGE msg
            OTHERS                = 3.
        CASE sy-subrc.
          WHEN 0.
            IF rfc_error_code IS NOT INITIAL.
              log->add_item( cl_bali_free_text_setter=>create(
                  severity = if_bali_constants=>c_severity_termination
                  text     = |Table { table_name }: RFC error: { rfc_error_message-message }| ) ) ##no_text.
            ENDIF.
          WHEN 1 OR 2.
            log->add_item( cl_bali_free_text_setter=>create(
                severity = if_bali_constants=>c_severity_termination
                text     = |Table { table_name }: RFC error: { msg }| ) ) ##no_text.
            failed = abap_true.
          WHEN OTHERS.
            log->add_item( cl_bali_free_text_setter=>create(
                severity = if_bali_constants=>c_severity_termination
                text     = |Table { table_name }: RFC error: Unknown error| ) ) ##no_text.
            failed = abap_true.
        ENDCASE.

      CATCH cx_root INTO FINAL(x_root).
        TRY.
            log->add_item( cl_bali_free_text_setter=>create(
                severity = if_bali_constants=>c_severity_termination
                text     = |Table { table_name }: RFC exception: { x_root->get_text( ) }| ) ) ##no_text.
            failed = abap_true.

          CATCH cx_bali_runtime INTO DATA(x_bali_runtime).
            RAISE SHORTDUMP x_bali_runtime.
        ENDTRY.
    ENDTRY.

  ENDMETHOD.

  METHOD has_ca_for_target_tenant.

    cl_com_arrangement_factory=>create_instance( )->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = VALUE #( ( sign = 'I' option = 'EQ' low = c_comm_scenario_id ) ) )
      IMPORTING
        et_com_arrangement = FINAL(comm_arrangements) ).

    result = boolc( comm_arrangements IS NOT INITIAL ).

  ENDMETHOD.

  METHOD get_comm_system_id_by_ca.

    cl_com_arrangement_factory=>create_instance( )->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = VALUE #( ( sign = 'I' option = 'EQ' low = c_comm_scenario_id ) ) )
      IMPORTING
        et_com_arrangement = FINAL(comm_arrangements) ).

    LOOP AT comm_arrangements INTO DATA(comm_arrangement).
      IF comm_arrangement->get_name( ) = comm_arrangement_id.
        result = comm_arrangement->get_comm_system_id( ).
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
