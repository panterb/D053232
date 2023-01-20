CLASS zcx_xe2_gadgets DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_message .
    CONSTANTS: message_class TYPE symsgid VALUE 'ZXE2_GADGETS',
               BEGIN OF date_holiday,
                 msgid TYPE symsgid VALUE message_class,
                 msgno TYPE symsgno VALUE '001',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF date_holiday,
               BEGIN OF date_invalid,
                 msgid TYPE symsgid VALUE message_class,
                 msgno TYPE symsgno VALUE '002',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF date_invalid.

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        severity  TYPE if_abap_behv_message=>t_severity DEFAULT  if_abap_behv_message=>severity-error
          PREFERRED PARAMETER textid .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_xe2_gadgets IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    me->if_abap_behv_message~m_severity = severity.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
