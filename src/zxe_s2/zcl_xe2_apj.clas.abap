CLASS zcl_xe2_apj DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_xe2_apj IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
   " Parameter Description for Application Jobs Template
    et_parameter_def = VALUE #(
        ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     datatype = 'C' length = 80 param_text = 'Description'   lowercase_ind = abap_true changeable_ind = abap_true )
      ).

    " Parameter Table for Application Jobs Template
    et_parameter_val = VALUE #(
      ( selname = 'P_DESCR' kind = if_apj_dt_exec_object=>parameter     sign = 'I' option = 'EQ' low = 'Job Template for Gadgets Shop' )
    ).
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
TRY.
    DATA gadgets_shops TYPE TABLE FOR CREATE zxe2_i_gadgets.
    DATA gadgets_shop  TYPE STRUCTURE FOR CREATE zxe2_i_gadgets.

    TYPES:
       tt_gadgets_shop TYPE STANDARD TABLE OF zxe2_gadgets WITH DEFAULT KEY.
    DATA lt_gadgets_shop TYPE tt_gadgets_shop.

    TYPES:
      BEGIN OF ts_offline_ordering,
        ordereditem TYPE string,
      END OF ts_offline_ordering,
      tt_offline_ordering TYPE STANDARD TABLE OF ts_offline_ordering WITH DEFAULT KEY.

    DATA lt_offline_ordering TYPE tt_offline_ordering.

    DATA(lo_log) = cl_bali_log=>create( ).

    lo_log->set_header( header = cl_bali_header_setter=>create( object = 'ZXE2_GADGETS'
                                                                subobject = 'ZXE2_GADGETS_SUB'
                                                                external_id = 'OfflineOrdering' ) ).
    " Get file content from the stream table
    SELECT zxe2_i_files~FileContent  FROM zxe2_i_files
    WITH PRIVILEGED ACCESS
    WHERE description = 'OfflineOrdering'
    INTO @DATA(lv_file_content).
    ENDSELECT.

    DATA(lo_worksheet) = xco_cp_xlsx=>document->for_file_content( lv_file_content
       )->read_access(
       )->get_workbook(
       )->worksheet->at_position( 1 ).

    "Set cursor position
    DATA(lo_cursor) = lo_worksheet->cursor(
       io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
       io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
    ).

    "Extract the rows from the xlsx file
    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
      )->from_column( lo_cursor->position->column
      )->from_row( lo_cursor->position->row
      )->to_column( lo_cursor->position->column->shift( 2 )
      )->get_pattern( ).

    "Transform the pattern to the offline ordering table
    lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_offline_ordering )
      )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
      )->execute( ).

    DATA(today) = cl_abap_context_info=>get_system_date( ).


    " Fill in the offline orders in the internal table
    LOOP AT lt_offline_ordering INTO DATA(ls_offline_ordering).
      gadgets_shop-%cid = conv abp_behv_cid( sy-tabix ).
      gadgets_shop-ordereditem = ls_offline_ordering-ordereditem.
      gadgets_shop-Deliverydate  = today + 10.
      APPEND gadgets_shop TO gadgets_shops.
    ENDLOOP.

    "Modify entities of zxe2_i_gadgets
    MODIFY ENTITIES OF zxe2_i_gadgets
    ENTITY gadgets_shop CREATE SET FIELDS WITH  gadgets_shops
    MAPPED   DATA(ls_mapped_modify)
    FAILED   DATA(lt_failed_modify)
    REPORTED DATA(lt_reported_modify).

    COMMIT ENTITIES RESPONSE OF zxe2_i_gadgets FAILED DATA(lt_failed) REPORTED DATA(lt_data_reported).

    " Add application log
    MESSAGE ID 'ZXE2_GADGETS' TYPE 'S' NUMBER '000' WITH sy-dbcnt  INTO DATA(lv_message).
    lo_log->add_item( item = cl_bali_message_setter=>create_from_sy( ) ).

    cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).

  CATCH cx_bali_runtime INTO DATA(l_runtime_exception).
ENDTRY.


  ENDMETHOD.
ENDCLASS.
