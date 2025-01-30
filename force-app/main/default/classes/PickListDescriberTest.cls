@isTest 
public class PickListDescriberTest {
  @isTest 
    static void test_getPicklistEntry(){
        Schema.sObjectType sobject_type = Schema.getGlobalDescribe().get('Application_Log__c');
        String field_name = 'Status__c';
        Test.startTest();
        Map<String, Schema.SObjectField> mapPicklist = PickListDescriber.getPicklistEntry(sobject_type);
        List<Schema.PicklistEntry> pick_list_values = PickListDescriber.getPicklistEntry(sobject_type, field_name);
        Test.stopTest();
    }
}