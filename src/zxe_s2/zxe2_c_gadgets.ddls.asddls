@EndUserText.label: 'Consumption View for Gadgets Shop'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@UI: { headerInfo: { typeName: 'Gadgets Shop',
                     typeNamePlural: 'Gadgets Shop',
                     title: { type: #STANDARD, label: 'Order your Gadgets', value: 'order_id' } },

       presentationVariant: [{ sortOrder: [{ by: 'Creationdate',
                                             direction: #DESC }] }] }
define root view entity ZXE2_C_GADGETS
  provider contract transactional_query
  as projection on ZXE2_I_GADGETS
{
      @UI.facet: [          { id:                  'Orders',
                                     purpose:         #STANDARD,
                                     type:            #IDENTIFICATION_REFERENCE,
                                     label:           'Order',
                                     position:        10 }      ]
  key Order_Uuid,
      @UI: { lineItem:       [ { position: 10,label: 'Order ID', importance: #HIGH } ],
               identification: [ { position: 10, label: 'Order ID' } ] }
      @Search.defaultSearchElement: true

      Order_Id,
      @UI: { lineItem:       [ { position: 20,label: 'Ordered Item', importance: #HIGH } ],
              identification: [ { position: 20, label: 'Ordered Item' } ] }
      @Search.defaultSearchElement: true
      Ordereditem,

      @UI: { lineItem:       [ { position: 30,label: 'Creation Date', importance: #HIGH } ],
             identification: [ { position: 30, label: 'Creation Date' } ] }
      Creationdate as Creationdate,

      @UI: { lineItem:       [ { position: 40,label: 'Delivery Date' } ],
      identification: [ { position: 40, label: 'Delivery Date' } ] }
      Deliverydate as Deliverydate


}
