@EndUserText.label: 'Copy Copy Template'
define abstract entity ZCCSD_D_CopyTemplatePar
{
  @EndUserText.label: 'New Template Name'
  @UI.defaultValue: #( 'ELEMENT_OF_REFERENCED_ENTITY: TemplateName' )
  TemplateName : ZCCSD_TEMPLATE_NAME;
}
