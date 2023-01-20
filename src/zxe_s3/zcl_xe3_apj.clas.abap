CLASS zcl_xe3_apj DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_xe3_apj IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
  ENDMETHOD.
  METHOD if_apj_rt_exec_object~execute.
    TRY.
        SELECT * FROM zxe3_defects INTO TABLE @DATA(lt_defects).

        SELECT * FROM I_ManufacturingOrder
        WHERE YY1_A_goodfor1_ORD = 'X'
        INTO TABLE @DATA(lt_mfgorder).

*Remove records for which defects are already created.
        LOOP AT lt_defects ASSIGNING FIELD-SYMBOL(<fs_defect>).
          READ TABLE lt_mfgorder WITH KEY ManufacturingOrder = <fs_defect>-order_id TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.
            DELETE lt_mfgorder WHERE ManufacturingOrder = <fs_defect>-order_id.
          ENDIF.
        ENDLOOP.

*Create defects for remaining records.
        LOOP AT lt_mfgorder ASSIGNING FIELD-SYMBOL(<fs>).

          zcl_xe3_defect=>create_defects_for_appl_job( iv_process_order = <fs>-ManufacturingOrder ).

        ENDLOOP.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


ENDCLASS.
