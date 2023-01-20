CLASS zcl_xe3_defect DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS: create_defects_for_appl_job
      IMPORTING iv_process_order TYPE aufnr.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_xe3_defect IMPLEMENTATION.
  METHOD create_defects_for_appl_job.
    "Data type for header create operation
    DATA def_header TYPE TABLE FOR CREATE i_defecttp_2\\defect.
    "Data type for create by association (cba) of the long text
    DATA def_longtext_cba TYPE TABLE FOR CREATE i_defecttp_2\\defect\_defectlongtext.

    DATA: ls_defect TYPE zxe3_defects.

**********************************************************************
* Create text
**********************************************************************
    DATA lv_text TYPE string.
    DATA: lv_system_date TYPE c LENGTH 8,
          lv_system_time TYPE c LENGTH 6.

    lv_system_date = CONV string( cl_abap_context_info=>get_system_date( ) ).
    lv_system_time = CONV string( cl_abap_context_info=>get_system_time( ) ).
    CONCATENATE  lv_system_date lv_system_time 'APPL_JOB' iv_process_order INTO lv_text SEPARATED BY '_'.


    "Prepare content
    def_header = VALUE #(
        ( "content ID, must be unique across all records of one create operation
            %cid = 'CID_001'
           "defect header data
            DefectCategory = '06'
            DefectText = lv_text
            %control = VALUE #(
                DefectCategory = if_abap_behv=>mk-on
                DefectText = if_abap_behv=>mk-on
                                )
        )
    ).

    "Execute create operation. This will not write any data to the database, the data are stored in a transactional buffer.
    MODIFY ENTITIES OF I_DefectTP_2
    ENTITY Defect
    CREATE FROM def_header
    CREATE BY \_DefectLongText FROM def_longtext_cba
    MAPPED DATA(mapped)
    FAILED DATA(failed)
    REPORTED DATA(reported).

    IF failed IS INITIAL.

      " Execute DB commit for data in the transactional buffer
      COMMIT ENTITIES BEGIN
      RESPONSE OF I_DefectTP_2
      FAILED DATA(commit_failed)
      REPORTED DATA(commit_reported).
      COMMIT ENTITIES END.

      IF commit_failed IS INITIAL.
        " Create and commit operation executed without failure.
        " 'mapped-defect' contains the ID of the created defect instance

**********************************************************************
* Store defect in table
**********************************************************************
        READ TABLE mapped-defect INDEX 1 ASSIGNING FIELD-SYMBOL(<fs>).
        IF sy-subrc = 0.
          GET TIME STAMP FIELD ls_defect-created_at.
          ls_defect-defect_id = <fs>-DefectInternalID.
          ls_defect-order_id = iv_process_order.
          INSERT zxe3_defects FROM @ls_defect.
          COMMIT WORK.
        ENDIF.

      ENDIF.

    ELSE.
      " Add appropriate error handling. Field 'reported' shall contain messages if create operation failed

    ENDIF.

  ENDMETHOD.
ENDCLASS.
