CLASS zcl_ccsd_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_apj_rt_run.

    "! <p class="shorttext synchronized" lang="en">Copy Template</p>
    DATA template_name TYPE zccsd_template_name.

    "! <p class="shorttext synchronized" lang="en">Comm. Arrangement for Target Tenant</p>
    DATA comm_arrangement_id TYPE c LENGTH 80.

    "! <p class="shorttext synchronized" lang="en">Simulate Only</p>
    DATA simulate_only TYPE abap_boolean VALUE abap_true.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS c_log_object    TYPE balobj_d  VALUE 'ZCCSD_JOB'.
    CONSTANTS c_log_subobject TYPE balsubobj VALUE 'EXECUTION'.
ENDCLASS.


CLASS zcl_ccsd_job IMPLEMENTATION.

  METHOD if_apj_rt_run~execute.

    TRY.
        FINAL(log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create(
            object    = c_log_object
            subobject = c_log_subobject
            external_id = |{ template_name }-{ comm_arrangement_id }|
        ) ).

        zcl_ccsd_push_helper=>get_instance( )->copy_custom_data(
            template_name       = template_name
            comm_arrangement_id = comm_arrangement_id
            simulate_only       = simulate_only
            log                 = log
        ).

        cl_bali_log_db=>get_instance( )->save_log_2nd_db_connection(
            log                        = log
            assign_to_current_appl_job = abap_true
        ).

      CATCH cx_bali_runtime INTO DATA(x_bali_runtime).
        RAISE EXCEPTION TYPE cx_apj_rt_content
          EXPORTING
            previous = x_bali_runtime.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
