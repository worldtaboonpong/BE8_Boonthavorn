trigger TrafficTrigger on Traffic__c (before insert) {
    TriggerActivation setting = TriggerActivation.getInstance('Traffic__c');
    if (!setting.isActiveTrigger() || !CacheTrigger.isRunningTrafficTrigger) { return; }
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            Set<String> branchSet = new Set<String>();
            Set<Date> dateSet = new Set<Date>();
            for(Traffic__c traffic : Trigger.new) {
                branchSet.add(traffic.Branch__c);
                dateSet.add(traffic.Date__c);
            }

            List<Roll_up_Traffic__c> relatedRollTraffic = [SELECT Id, Branch__c, Type__c, Date__c FROM Roll_up_Traffic__c WHERE Date__c IN :dateSet AND Branch__c IN :branchSet];
            Map<String, Id> mapRollByKey = new Map<String, Id>();
            for(Roll_up_Traffic__c rollTraffic :relatedRollTraffic){
                String key = rollTraffic.Branch__c + '_' + rollTraffic.Type__c + '_' + rollTraffic.Date__c;
                mapRollByKey.put(key, rollTraffic.Id);
            }
            for(Traffic__c traffic : Trigger.new) {
                String key = traffic.Branch__c + '_' + traffic.Type__c + '_' + traffic.Date__c;
                traffic.Roll_up_Traffic__c = mapRollByKey.get(key);
            }
        }
    }
}