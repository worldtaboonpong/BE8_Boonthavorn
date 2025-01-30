@isTest 
public class SObjectUtilsTest {
    @isTest 
    static void test_getSObjectPrefixId_case1(){
        String sObjectToFind = 'Account';
        String expected = '001';
        String actual   = SObjectUtils.getSObjectPrefixId(sObjectToFind);
        System.assertEquals(expected, actual);
    }
    @isTest 
    static void test_getSObjectPrefixId_case2(){
        String sObjectToFind = 'NotAnObject';
        String expected = MessageLabel.SOBJECTUTIL_NOTFOUNDOBJECT+sObjectToFind;
        try{
            SObjectUtils.getSObjectPrefixId(sObjectToFind);
        }catch(Exception ex){
            String actual = ex.getMessage();
            System.assertEquals(expected, actual);
        }
    }
    @isTest 
    static void test_getMockUpSObjectId_case1(){
        String sObjectToFind = 'Account';
        String expected = '001000000000000001';
        String actual   = SObjectUtils.getMockUpSObjectId(sObjectToFind,'001');
        System.assertEquals(expected, actual);
    }
    @isTest 
    static void test_getMockUpSObjectId_case2(){
        String sObjectToFind = 'NotAnObject';
        String expected = MessageLabel.SOBJECTUTIL_NOTFOUNDOBJECT+sObjectToFind;
        try{
            SObjectUtils.getMockUpSObjectId(sObjectToFind,'001');
        }catch(Exception ex){
            String actual = ex.getMessage();
            //System.assertEquals(expected, actual);
        }
    }
    @isTest
    static void test_getAllFieldInObject(){
        String sObjectToFind = 'Account';
        List<String> allFieldsInObject = SObjectUtils.getAllFieldInObject(sObjectToFind);
        System.assertNotEquals(new List<String>(), allFieldsInObject);
        System.assertNotEquals(0, allFieldsInObject.size());
    }
    @isTest 
    static void test_getPickValues(){
        List<SObjectUtils.SelectOption> options = SObjectUtils.getPickValues('Account','Type');
        System.assertNotEquals(0, options.size());  
    }
    @isTest 
    static void test_getValue(){
        String accountAsJSON = '{"attributes":{"type":"Account","url":"/services/data/v43.0/sobjects/Account/0016F00002NJbocQAD"},"Id":"0016F00002NJbocQAD","ParentId":"0016F00002NJboXQAT","Parent":{"attributes":{"type":"Account","url":"/services/data/v43.0/sobjects/Account/0016F00002NJboXQAT"},"Id":"0016F00002NJboXQAT","Name":"MOCKUP Parent"}}';
        Account acc = (Account)JSON.deserialize(accountAsJSON, Account.class );
        String actual_val = SObjectUtils.getValue(acc, 'Parent.Name');
        System.assertEquals('MOCKUP Parent',actual_val);
    }
    @isTest 
    static void test_getQueryString(){
        String queryString = SObjectUtils.getQueryAllField('Account');
        System.assertNotEquals(null,queryString);
        System.assert(queryString.contains('From Account'));
    }
    @istest 
    static void test_instantOf(){
        String sObjectType = 'Account';
        SObject account = SObjectUtils.instantOf(sObjectType);

        System.assertEquals( 'Account' , String.valueOf(account.getSObjectType()) );
    }
    @isTest 
    static void test_getSchemaFieldDescribe(){
        String sObjectType  = 'Account';
        String fieldName    = 'Name';
        Schema.DescribeFieldResult fieldResult = SObjectUtils.getSchemaFieldDescribe(sObjectType, fieldName);

        System.assertEquals('Name',fieldResult.getName());
    }
    @isTest 
    static void test_getSchemaFieldDescribe_false(){
        String sObjectType  = 'Account';
        String fieldName    = 'Name2';
        try{
            Schema.DescribeFieldResult fieldResult = SObjectUtils.getSchemaFieldDescribe(sObjectType, fieldName);
        }catch(Exception ex){
            System.assertEquals(MessageLabel.SOBJECTUTIL_NOTFOUNDFIELD+fieldName+' : on object : '+sObjectType,ex.getMessage());
        }
    }
    @isTest 
    static void test_getMapFieldSetsBySObjectAPI(){
        String sObjectType  = 'Account';
        try{
            Map<String, Schema.FieldSet> fieldResult = SObjectUtils.getMapFieldSetsBySObjectAPI(sObjectType);
        }catch(Exception ex){
            System.assertEquals(MessageLabel.SOBJECTUTIL_NOTFOUNDFIELD+' : on object : '+sObjectType,ex.getMessage());
        }
    }
    @isTest 
    static void test_getAllFieldInFieldSet(){
        String sObjectType  = 'Account';
        String fieldSetName  = 'BankInformation';
        try{
            Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fieldSets.getMap().get(fieldSetName);
            Set<String> fieldResult = SObjectUtils.getAllFieldInFieldSet(fieldSet);
        }catch(Exception ex){
            //System.assertEquals(MessageLabel.SOBJECTUTIL_NOTFOUNDFIELD+fieldSetName+' : on object : '+sObjectType,ex.getMessage());
        }
    }
    @isTest 
    static void test_getSobjectPrefix(){
        String expected = '001';
        String actual   = SObjectUtils.getSobjectPrefix(Schema.getGlobalDescribe().get('Account'));
        System.assertEquals(expected,actual);
    }
    @isTest 
    static void test_generate(){
        String actual   = SObjectUtils.generate(Schema.getGlobalDescribe().get('Account'));
    }
    @isTest 
    static void test_getPickValues2(){
        List<System.selectOption> options = SObjectUtils.getPickValues( Schema.getGlobalDescribe().get('Account'),'Type',new Map<String,String>());
    }
    @isTest 
    static void test_getPickValueWithFirstValue(){
        List<System.selectOption> options = SObjectUtils.getPickValues( Schema.getGlobalDescribe().get('Account'),'Type','');
    }
    
}