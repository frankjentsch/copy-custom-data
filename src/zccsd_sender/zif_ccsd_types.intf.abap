INTERFACE zif_ccsd_types
  PUBLIC.

  TYPES ty_table_name  TYPE tabname.
  TYPES ty_table_names TYPE STANDARD TABLE OF ty_table_name WITH EMPTY KEY.

  TYPES BEGIN OF ty_table_statistic.
  TYPES   table_name TYPE ty_table_name.
  TYPES   row_count  TYPE i.
  TYPES END OF ty_table_statistic.
  TYPES ty_table_statistics TYPE STANDARD TABLE OF ty_table_statistic WITH EMPTY KEY.

  TYPES ty_template_name TYPE zccsd_template_name.
  TYPES ty_filter_option TYPE zccsd_filter_option.
  TYPES ty_filter_attr_name TYPE zccsd_filter_attr_name.

  TYPES ty_comm_arrangement_id TYPE if_com_arrangement=>ty_ca-name.
  TYPES ty_comm_system_id      TYPE if_com_system=>ty_cs-name.
  TYPES ty_destination_name    TYPE rfcdest.

  TYPES ty_operation TYPE c LENGTH 1.

  CONSTANTS BEGIN OF c_filter_attr_name.
  CONSTANTS   table_name TYPE zccsd_filter_attr_name VALUE 'TABLE_NAME'.
  CONSTANTS   swc_name   TYPE zccsd_filter_attr_name VALUE 'SWC_NAME'.
  CONSTANTS END OF c_filter_attr_name.

  CONSTANTS BEGIN OF c_operation.
  CONSTANTS   insert TYPE ty_operation VALUE 'I'.
  CONSTANTS   modify TYPE ty_operation VALUE 'M'.
  CONSTANTS   delete TYPE ty_operation VALUE 'D'.
  CONSTANTS END OF c_operation.

ENDINTERFACE.
