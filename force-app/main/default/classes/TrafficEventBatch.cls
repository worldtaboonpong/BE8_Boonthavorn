global class TrafficEventBatch implements Database.Batchable<SObject> {

    private Date dateFilter;

    global TrafficEventBatch(){
        System.debug(LoggingLevel.DEBUG, 'Default Date Filter Last 3 Months');
        this.dateFilter = Date.today().addDays(-90);
    }

    global TrafficEventBatch(Date startDate){
        this.dateFilter = startDate;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Date__c, Event__c, Branch__c, Roll_up_Traffic__c FROM Traffic__c WHERE Date__c >= :dateFilter OR LastModifiedDate >= :dateFilter ORDER BY Date__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Traffic__c> scope) {
        Map<String, Map<Date, Set<Id>>> eventDatesByBranch = getEventsDate(scope);
        Set<Date> specialDays = getSpecialDate(scope);

        updateTrafficRecords(scope, eventDatesByBranch, specialDays);
    }

    private void updateTrafficRecords(List<Traffic__c> scope, Map<String, Map<Date, Set<Id>>> eventDatesByBranch, Set<Date> specialDays) {
        Set<Id> trafficIds = new Set<Id>();
        Set<String> newJunctionKeys = new Set<String>();
        Map<Id, Roll_up_Traffic__c> rollTrafficToUpdate = new Map<Id, Roll_up_Traffic__c>();

        for(Traffic__c each : scope) {
            trafficIds.add(each.Id);
            if(eventDatesByBranch.containsKey(each.Branch__c) && eventDatesByBranch.get(each.Branch__c).containsKey(each.Date__c)) {
                each.Event__c = true;
                for(Id eventId : eventDatesByBranch.get(each.Branch__c).get(each.Date__c)) {
                    newJunctionKeys.add(each.Id + '_' + eventId);
                }
            } else {
                each.Event__c = false;
            }

            if(specialDays.contains(each.Date__c)) {
                each.Special_Holiday__c = true;
            } else {
                each.Special_Holiday__c = false;
            }

            if(!rollTrafficToUpdate.containsKey(each.Roll_up_Traffic__c)){
                Roll_up_Traffic__c rollTraffic = new Roll_up_Traffic__c(
                    Id = each.Roll_up_Traffic__c,
                    Event__c = each.Event__c,
                    Special_Holiday__c = each.Special_Holiday__c,
                    Is_Active__c = true
                );
                rollTrafficToUpdate.put(each.Roll_up_Traffic__c, rollTraffic);
            }
        }
        update scope;
        update rollTrafficToUpdate.values();

        List<Traffic_and_Event__c> oldJunctions = [SELECT Id, Traffic__c, Event__c FROM Traffic_and_Event__c WHERE Traffic__c IN :trafficIds];
        Map<String, Traffic_and_Event__c> oldJunctionsMap = new Map<String, Traffic_and_Event__c>();
        for(Traffic_and_Event__c junction : oldJunctions) {
            oldJunctionsMap.put(junction.Traffic__c + '_' + junction.Event__c, junction);
        }

        List<Traffic_and_Event__c> toDeleteJunctions = new List<Traffic_and_Event__c>();
        List<Traffic_and_Event__c> toInsertJunctions = new List<Traffic_and_Event__c>();

        for(String newJuncKey : newJunctionKeys) {
            if(!oldJunctionsMap.containsKey(newJuncKey)) {
                List<String> splitKey = newJuncKey.split('_');
                Traffic_and_Event__c junction = new Traffic_and_Event__c(
                    Traffic__c = splitKey[0],
                    Event__c = splitKey[1]
                );
                toInsertJunctions.add(junction);
            }
        }
        for(Traffic_and_Event__c junction : oldJunctions) {
            String key = junction.Traffic__c + '_' + junction.Event__c;
            if(!newJunctionKeys.contains(key)) {
                toDeleteJunctions.add(junction);
            }
        }

        if(!toDeleteJunctions.isEmpty()) {
            delete toDeleteJunctions;
        }
        if(!toInsertJunctions.isEmpty()) {
            insert toInsertJunctions;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'finish batch');
    }

    private static Map<String, Map<Date, Set<Id>>> getEventsDate(List<Traffic__c> scope) {
        Set<String> branchNameSet = new Set<String>();
        for(Traffic__c record : scope) {
            branchNameSet.add(record.Branch__c);
        }
        Date startDate = scope[0].Date__c;
        Date endDate = scope[scope.size() - 1].Date__c;
        Id recordTypeId = RecordTypeUtility.getRecordTypeId('Event_and_Special_Holiday__c', Constant.EVENT_RECORDTYPE_NAME);
        Map<String, Map<Date, Set<Id>>> eventDatesByBranch = new Map<String, Map<Date, Set<Id>>>();
        for(Event_and_Special_Holiday__c event : [SELECT Id, Event_Start_Date__c, Event_End_Date__c, Branch__c 
                              FROM Event_and_Special_Holiday__c 
                              WHERE Branch__c IN :branchNameSet AND Event_Start_Date__c <= :endDate AND Event_End_Date__c >= :startDate AND RecordTypeId = :recordTypeId]) {
            if(!eventDatesByBranch.containsKey(event.Branch__c)) {
                eventDatesByBranch.put(event.Branch__c, new Map<Date, Set<Id>>());
            }
            Date eventStart = event.Event_Start_Date__c;
            Date eventEnd = event.Event_End_Date__c;

            while(eventStart <= eventEnd) {
                if(!eventDatesByBranch.get(event.Branch__c).containsKey(eventStart)) {
                    eventDatesByBranch.get(event.Branch__c).put(eventStart, new Set<Id>());
                }
                eventDatesByBranch.get(event.Branch__c).get(eventStart).add(event.Id);
                eventStart = eventStart.addDays(1);
            }
        }
        return eventDatesByBranch;
    }

    private static Set<Date> getSpecialDate(List<Traffic__c> scope) {
        Date startDate = scope[0].Date__c;
        Date endDate = scope[scope.size() - 1].Date__c;
        Id recordTypeId = RecordTypeUtility.getRecordTypeId('Event_and_Special_Holiday__c', Constant.EVENT_SPECIAL_HOLIDAY_RECORDTYPE_NAME);
        Set<Date> specialDates = new Set<Date>();
        for(Event_and_Special_Holiday__c event : [SELECT Id, Special_Holiday_Date__c 
                              FROM Event_and_Special_Holiday__c 
                              WHERE Special_Holiday_Date__c <= :endDate AND Special_Holiday_Date__c >= :startDate AND RecordTypeId = :recordTypeId]) {
            specialDates.add(event.Special_Holiday_Date__c);
        }
        return specialDates;
    }
}