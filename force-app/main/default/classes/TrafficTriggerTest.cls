@isTest
private with sharing class TrafficTriggerTest {
    
    @isTest
    static void lookupRollUpTrafficTest(){
        TriggerActivation__c customSetting = new TriggerActivation__c(TrafficTrigger__c = true);
        insert(customSetting);

        Branch__c branchBNA = new Branch__c(
        	Name = 'Design Village บางนา',
            Branch_Code__c = 'BNA'
        );
        insert branchBNA;

        Date mockDate = Date.today();
        MockUpDataFor_Test.createRollUpTraffic(mockDate, mockDate, branchBNA.Id);
        List<Traffic__c> trafficsBNA = MockUpDataFor_Test.createTraffics(mockDate, mockDate, branchBNA.Id);
        insert trafficsBNA;
    }
}