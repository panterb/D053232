CLASS lhc_ZXE2_I_GADGETS DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR gadgets_shop RESULT result.

    METHODS calculate_order_id FOR DETERMINE ON MODIFY
      IMPORTING keys FOR gadgets_shop~calculate_order_id.

    METHODS validate_delivery_date FOR VALIDATE ON SAVE
      IMPORTING keys FOR gadgets_shop~validate_delivery_date.

ENDCLASS.

CLASS lhc_ZXE2_I_GADGETS IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD calculate_order_id.
    DATA: gadgets_shops      TYPE TABLE FOR UPDATE zxe2_i_gadgets,
          gadgets_shop       TYPE STRUCTURE FOR UPDATE zxe2_i_gadgets,
          lv_number_unpacked TYPE n LENGTH 10.
    types: lty_c type c length 10.

    READ ENTITIES OF zxe2_i_gadgets IN LOCAL MODE
       ENTITY gadgets_shop
        ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_gadgets_shop_result)
      FAILED    DATA(lt_failed)
      REPORTED  DATA(lt_reported).
    DATA(today) = cl_abap_context_info=>get_system_date( ).

    LOOP AT lt_gadgets_shop_result INTO DATA(gadgets_shop_read).

      TRY.
        cl_numberrange_runtime=>number_get( EXPORTING
          nr_range_nr = '1'
          object      = 'ZXE2_GS_NR'
        IMPORTING
          number      = DATA(lv_number) ).
      CATCH cx_number_ranges.
        "handle exception
    ENDTRY.
    lv_number_unpacked = lv_number.

      gadgets_shop               = CORRESPONDING #( gadgets_shop_read ).
      gadgets_shop-order_id      = CONV lty_c( lv_number_unpacked ).
      gadgets_shop-Creationdate  = today.
      APPEND gadgets_shop TO gadgets_shops.
      CLEAR: lv_number, lv_number_unpacked.
    ENDLOOP.

    MODIFY ENTITIES OF zxe2_i_gadgets IN LOCAL MODE
   ENTITY gadgets_shop UPDATE SET FIELDS WITH gadgets_shops
   MAPPED   DATA(ls_mapped_modify)
   FAILED   DATA(lt_failed_modify)
   REPORTED DATA(lt_reported_modify).
  ENDMETHOD.

  METHOD validate_delivery_date.
    DATA: gadgets_shops     TYPE TABLE FOR UPDATE zxe2_i_gadgets,
          gadgets_shop      TYPE STRUCTURE FOR UPDATE zxe2_i_gadgets,
          val_delivery_date TYPE string VALUE 'VALIDATE_DELIVERY_DATE'.

    READ ENTITIES OF zxe2_i_gadgets IN LOCAL MODE
     ENTITY gadgets_shop
      ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_gadgets_shop_result)
    FAILED    DATA(lt_failed)
    REPORTED  DATA(lt_reported).

    TRY.
        cl_scal_api=>factory_calendar_get(
   IMPORTING
   et_factory_calendars = DATA(lt_factory_calendar)
    ).


        DATA(lo_mapper) = cl_fhc_calendar_id_mapper=>create_id_mapper(  ).
        DATA(lv_scal_id) = lo_mapper->mapping_fcal_legacyid_to_id( iv_legacy_id = '01' ).

        DATA(lo_hcal_run) = cl_fhc_calendar_runtime=>create_holidaycalendar_runtime(
         iv_holidaycalendar_id = lv_scal_id ).

        DATA(lo_fcal_run) = cl_fhc_calendar_runtime=>create_factorycalendar_runtime(
          iv_factorycalendar_id = lv_scal_id ).

        LOOP AT lt_gadgets_shop_result INTO DATA(gadgets_shop_read).
          gadgets_shop = CORRESPONDING #( gadgets_shop_read ).

          IF gadgets_shop_read-Deliverydate NE '00000000'.
            "Check if the delivery date is a holiday
            DATA(is_holiday) = lo_hcal_run->is_holiday(
             iv_date = gadgets_shop_read-Deliverydate
             ).

            "Check if the delivery date is a holiday
            IF is_holiday = abap_true.
              APPEND VALUE #( %tky        = gadgets_shop_read-%tky
                  %state_area = val_delivery_date
                  %msg        = NEW zcx_xe2_gadgets( textid      = zcx_xe2_gadgets=>date_holiday )
                  %element-Deliverydate = if_abap_behv=>mk-on
                  ) TO reported-gadgets_shop .
            ENDIF.
            else.
            "Check if the delivery date is not empty
                if gadgets_shop_read-Deliverydate = '00000000'.
                  APPEND VALUE #( %tky        = gadgets_shop_read-%tky
                      %state_area = val_delivery_date
                      %msg        = NEW zcx_xe2_gadgets( textid      = zcx_xe2_gadgets=>date_invalid )
                      %element-Deliverydate = if_abap_behv=>mk-on
                      ) TO reported-gadgets_shop .
                endif.
          ENDIF.
        ENDLOOP.

      CATCH cx_fhc_runtime INTO DATA(lx_err).
      CATCH cx_scal INTO DATA(lx_scal).
        "exception handling
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
