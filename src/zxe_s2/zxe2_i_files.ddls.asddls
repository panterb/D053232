@EndUserText.label: 'Root Entity for Files Storage'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.viewEnhancementCategory: [#NONE]
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define root view entity ZXE2_I_FILES
  as select from zxe2_files
{
  key uuid         as Uuid,
      description  as Description,
      file_content as FileContent,
      
      @Semantics.mimeType: true
      mime_type    as MimeType,
      file_name    as FileName,
      
      @Semantics.systemDateTime.lastChangedAt: true
      changed_on   as ChangedOn,
      
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      totaletag    as totaletag

}
