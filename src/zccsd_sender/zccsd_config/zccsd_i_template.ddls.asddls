@EndUserText.label: 'Copy Template'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZCCSD_I_Template
  as select from ZCCSD_TEMPLATE
  association to parent ZCCSD_I_Template_S as _CopyTemplateAll on $projection.SingletonID = _CopyTemplateAll.SingletonID
  composition [0..*] of ZCCSD_I_TemplateTableField as _CopyTemplateTField
  composition [0..*] of ZCCSD_I_TemplateTable as _CopyTemplateTable
{
  key TEMPLATE_NAME as TemplateName,
  TEMPLATE_DESC as TemplateDesc,
  @Consumption.hidden: true
  1 as SingletonID,
  _CopyTemplateAll,
  _CopyTemplateTField,
  _CopyTemplateTable
}
