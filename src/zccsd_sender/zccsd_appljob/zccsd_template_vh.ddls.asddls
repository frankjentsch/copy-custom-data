@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Copy Templates'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.semanticKey: ['TemplateName']
@Search.searchable: true
define view entity ZCCSD_TEMPLATE_VH
  as select from zccsd_template
{
      @Search.defaultSearchElement : true
      @EndUserText.label : 'Copy Template'
      @ObjectModel.text.element: [ 'TemplateDesc' ]
  key template_name as TemplateName,

      @Search.defaultSearchElement : true
      @EndUserText.label : 'Description'
      template_desc as TemplateDesc
}
