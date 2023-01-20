@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity for GoodFor Product Mapping'
define root view entity ZXE3_I_GOODFOR
  as select from zxe3_goodfor
{
  key werks           as Werks,
  key produced_pro    as ProducedPro,
  key goodfor_pro     as GoodforPro,
      priority        as Priority
}
