global class MasterRollUpReportByBranchBatch implements Database.Batchable<SObject> {

    private final Integer BASE_START_FORCAST_DAYS = -13;
    private final Integer BASE_END_FORCAST_DAYS = 37;
    private Map<String, Integer> mapEndForecast;
    
    private Integer startForecast;
    private Integer endForecast;

    global MasterRollUpReportByBranchBatch(){
        System.debug(LoggingLevel.DEBUG, 'Constructor for schedule');
    }

    global MasterRollUpReportByBranchBatch(Integer startForecast, Integer endForecast){
        this.startForecast = startForecast;
        this.endForecast = endForecast;
    }

    global List<Roll_up_by_Branch__mdt> start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Prefix_Branch__c, Prefix_Branch_Building__c, Branch_Name__c, Building_Name__c FROM Roll_up_by_Branch__mdt WHERE Is_Active__c = true ORDER BY Branch_Name__c';
        if (Test.isRunningTest()) {
            query += ' LIMIT 100';
        }
        return Database.query(query);
    }

    global void execute(Database.BatchableContext bc, List<Roll_up_by_Branch__mdt> scope) {
        Set<String> buildingName = new Set<String>();
        for(Roll_up_by_Branch__mdt meta :scope){
            buildingName.add(meta.Building_Name__c);
        }
        List<Building__c> buildings = [SELECT Id, Name, Branch__c, Branch__r.Name FROM Building__c WHERE Name IN :buildingName];
        Map<String, Id> mapBranchIdByName = new Map<String, Id>();
        Map<String, Id> mapBuildingIdByName = new Map<String, Id>();
        for(Building__c each :buildings){
            mapBranchIdByName.put(each.Branch__r.Name, each.Branch__c);
            mapBuildingIdByName.put(each.Name, each.Id);
        }

        Integer start = this.startForecast != null? this.startForecast : this.BASE_START_FORCAST_DAYS;
        Integer ended = this.endForecast != null? this.endForecast : this.BASE_END_FORCAST_DAYS;
        Map<String, Roll_up_Area_Branch__c> mapRollBranchs = new Map<String, Roll_up_Area_Branch__c>();
        List<Roll_Up_Area_Building__c> rollBuildings = new List<Roll_Up_Area_Building__c>();
        for(Integer forecastMonth = start; forecastMonth < ended ; forecastMonth++){
            Datetime firstDayOfMonth = Date.today().toStartOfMonth();
            Datetime currentDate = firstDayOfMonth.addMonths(forecastMonth);
            String month = currentDate.format('MMM').toUpperCase();
            String year = currentDate.format('yyyy');
    
            for(Roll_up_by_Branch__mdt meta :scope){
                String buildingExt = concatRollUpExternalId(meta.Prefix_Branch_Building__c, month, year);
                String branchExt = concatRollUpExternalId(meta.Prefix_Branch__c, month, year);
                Roll_Up_Area_Building__c rollUp = new Roll_Up_Area_Building__c();
                rollUp.Month__c = month;
                rollUp.Year__c = year;
                rollUp.Name = buildingExt;
                rollUp.External_Id__c = buildingExt;
                rollUp.Branch__c = mapBranchIdByName.get(meta.Branch_Name__c);
                rollUp.Building__c = mapBuildingIdByName.get(meta.Building_Name__c);
                rollBuildings.add(rollUp);

                if(!mapRollBranchs.containsKey(branchExt)){
                    Roll_up_Area_Branch__c branchRollUp = new Roll_up_Area_Branch__c();
                    branchRollUp.Month__c = month;
                    branchRollUp.Year__c = year;
                    branchRollUp.Name = branchExt;
                    branchRollUp.External_Id__c = branchExt;
                    branchRollUp.Branch__c = mapBranchIdByName.get(meta.Branch_Name__c);
                    mapRollBranchs.put(branchExt, branchRollUp);
                }
            }
        }

        if(mapRollBranchs.size() > 0){
            upsert mapRollBranchs.values() External_Id__c;
        }

        for(Roll_Up_Area_Building__c rollBuilding :rollBuildings){
            List<String> splitExt = rollBuilding.External_Id__c.split('_');
            String branchExt = concatRollUpExternalId(splitExt[0] + '_', rollBuilding.Month__c, rollBuilding.Year__c);
            Roll_up_Area_Branch__c rollUpBranch = mapRollBranchs.get(branchExt);
            if(rollUpBranch != null){
                rollBuilding.Roll_up_Area_Branch__c = rollUpBranch.Id;
            }
        }

        if(rollBuildings.size() > 0){
            upsert rollBuildings External_Id__c;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'finish batch');
    }

    public static String concatRollUpExternalId(String prefix, String month, String year){
        String externalId = prefix + month + '_' + year;
        return externalId;
    }
}