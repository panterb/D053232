@EndUserText.label: 'Consumption View for GoodFor API'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZXE3_A_GOODFOR
  provider contract transactional_query
  as projection on ZXE3_I_GOODFOR
{
  key Werks,
  key ProducedPro,
  key GoodforPro,
      Priority
}
