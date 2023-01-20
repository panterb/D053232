@EndUserText.label: 'Consumption View for GoodFor UI'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: { headerInfo: { typeName: 'FitFor Mapping',
                     typeNamePlural: 'FitFor Mappings',
                     title: { type: #STANDARD, label: 'FitFor Mapping'} } }

@Search.searchable: true
define root view entity ZXE3_C_GOODFOR
  provider contract transactional_query
  as projection on ZXE3_I_GOODFOR
{
      @UI: { lineItem:       [{ position: 10, label: 'Plant' }],
                         identification: [{ position: 10, label: 'Plant' }] }
      @Search.defaultSearchElement: true
      @UI.facet: [          { id:                  'Mapping',
                                     purpose:         #STANDARD,
                                     type:            #IDENTIFICATION_REFERENCE,
                                     label:           'Mapping',
                                     position:        10 }      ]
  key Werks,

      @UI: { lineItem:       [{ position: 20, label: 'Produced Product' }],
                       identification: [{ position: 20, label: 'Produced Product' }] }
      @Search.defaultSearchElement: true
  key ProducedPro,
      
      @UI: { lineItem:       [{ position: 30, label: 'FitFor Product' }],
                       identification: [{ position: 30, label: 'FitFor Product' }] }
      @Search.defaultSearchElement: true
  key GoodforPro,

      @UI: { lineItem:       [{ position: 40, label: 'Priority' }],
                       identification: [{ position: 40, label: 'Priority' }] }
      Priority

}
