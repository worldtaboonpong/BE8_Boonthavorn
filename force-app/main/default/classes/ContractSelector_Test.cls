@isTest
public class ContractSelector_Test {
    @isTest
    public static void test_getContractInfoByOppId() {
        Test.startTest();
        List<Contract__c> res = ContractSelector.getContractInfoByOppId(new Set<Id>{TestUtility.getFakeId(Contract__c.SObjectType)});
        Test.stopTest();
    }
}