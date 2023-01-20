@EndUserText.label: 'Interface View for Gadgets Shop'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZXE2_I_GADGETS
  as select from zxe2_gadgets
{
  key order_uuid   as Order_Uuid,
      order_id     as Order_Id,
      ordereditem  as Ordereditem,
      deliverydate as Deliverydate,
      creationdate as Creationdate
}
