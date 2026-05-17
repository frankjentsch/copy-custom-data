@EndUserText.label: 'Copy Template Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Semantics.valueRange.maximum: '1'
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'CopyTemplateAll'
  }
}
define root view entity ZCCSD_I_Template_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZCCSD_I_TEMPLATE'
  composition [0..*] of ZCCSD_I_Template as _CopyTemplate
{
  @UI.facet: [ {
    id: 'CopyTemplate', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Copy Templates', 
    position: 1 , 
    targetElement: '_CopyTemplate'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _CopyTemplate,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
}
where I_Language.Language = $session.system_language
