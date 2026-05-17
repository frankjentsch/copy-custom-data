@EndUserText.label: 'Copy Template Table Field'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZCCSD_I_TemplateTableField
  as select from ZCCSD_TEMPLATE_F
  association [1..1] to ZCCSD_I_Template_S as _CopyTemplateAll on $projection.SingletonID = _CopyTemplateAll.SingletonID
  association to parent ZCCSD_I_Template as _CopyTemplate on $projection.TemplateName = _CopyTemplate.TemplateName
{
  key TEMPLATE_NAME as TemplateName,
  key TEMPLATE_ITEM_NO as TemplateItemNo,
  TABLE_NAME as TableName,
  FIELD_NAME as FieldName,
  FILTER_OPTION as FilterOption,
  FILTER_LOW as FilterLow,
  FILTER_HIGH as FilterHigh,
  @Consumption.hidden: true
  1 as SingletonID,
  _CopyTemplateAll,
  _CopyTemplate
}
