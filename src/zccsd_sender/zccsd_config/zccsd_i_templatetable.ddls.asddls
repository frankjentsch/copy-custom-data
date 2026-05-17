@EndUserText.label: 'Copy Template Table'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZCCSD_I_TemplateTable
  as select from ZCCSD_TEMPLATE_T
  association [1..1] to ZCCSD_I_Template_S as _CopyTemplateAll on $projection.SingletonID = _CopyTemplateAll.SingletonID
  association to parent ZCCSD_I_Template as _CopyTemplate on $projection.TemplateName = _CopyTemplate.TemplateName
{
  key TEMPLATE_NAME as TemplateName,
  key TEMPLATE_ITEM_NO as TemplateItemNo,
  FILTER_ATTR_NAME as FilterAttrName,
  FILTER_OPTION as FilterOption,
  FILTER_LOW as FilterLow,
  FILTER_HIGH as FilterHigh,
  @Consumption.hidden: true
  1 as SingletonID,
  _CopyTemplateAll,
  _CopyTemplate
}
