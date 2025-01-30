@isTest
public class SOQLBuilderTest {
  @isTest 
  static void test_queryBuilder(){
    SOQLBuilder builder = new SOQLBuilder('Account');
    builder.addCondition('Where Id = null');
    String actualSOQL = builder.getQueryString();
    System.assert(actualSOQL.contains('From Account'));
  }
  @isTest 
  static void test_queryByAddAdditionalField(){
    SOQLBuilder builder = new SOQLBuilder('Account');
    builder.addField('Parent.Name');
        builder.excludeField(new List<String>{'Name'});
    String actualSOQL = builder.getQueryString();
    System.assert(actualSOQL.contains('From Account'));
    System.assert(actualSOQL.contains('Parent.Name'));
  }
  @isTest 
  static void test_queryByAddParentField(){
    SOQLBuilder builder = new SOQLBuilder('Account');
    builder.addAllFieldFromRelation('Parent','Account');
    String actualSOQL = builder.getQueryString();
    System.assert(actualSOQL.contains('From Account'));
    System.assert(actualSOQL.toUpperCase().contains('PARENT.NAME'));
    System.assert(actualSOQL.toUpperCase().contains('PARENT.ID'));
    System.assert(actualSOQL.toUpperCase().contains('PARENT.CREATEDDATE'));
  }
  @isTest 
  static void test_queryByAddChildField(){
    SOQLBuilder builder = new SOQLBuilder('Account');
    builder.addAllChildField('ChildAccounts','Account','');
    String actualSOQL = builder.getQueryString();
    System.assert(actualSOQL.toUpperCase().contains('FROM ACCOUNT'));
    System.assert(actualSOQL.toUpperCase().contains('FROM CHILDACCOUNTS'));
  }
  @isTest 
  static void test_lightmode(){
    SOQLBuilder builder_normal   = new SOQLBuilder('Account',false);
    SOQLBuilder builder_light   = new SOQLBuilder('Account',true);

    System.assertEquals(0,builder_light.allFieldsInObject.size() );
  }
  @isTest 
  static void test_childField(){
    SOQLBuilder parentBuilder   = new SOQLBuilder('Account');
    SOQLBuilder childBuilder   = new SOQLBuilder('Account');
  
    childBuilder.overrideMainSObject('Parents');
    parentBuilder.addAllChildField('Parents',childBuilder);


  }  

}