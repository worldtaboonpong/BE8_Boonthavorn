global class MasterRollUpReportByCategoryBatch implements Database.Batchable<SObject> {

    private final Integer BASE_START_FORCAST_DAYS = -13;
    private final Integer BASE_END_FORCAST_DAYS = 37;
    private Map<String, Integer> mapEndForecast;

    private Integer startForecast;
    private Integer endForecast;

    global MasterRollUpReportByCategoryBatch(){
       System.debug('Constructor for schedule');
    }

    global MasterRollUpReportByCategoryBatch(Integer startForecast, Integer endForecast){
        this.startForecast = startForecast;
        this.endForecast = endForecast;
    }

    global List<Roll_up_by_Category__mdt> start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Prefix_Branch_Category__c, Prefix_Category__c, Branch_Name__c, Category__c FROM Roll_up_by_Category__mdt WHERE Is_Active__c = true ORDER BY Category__c';
        if (Test.isRunningTest()) {
            query += ' LIMIT 100';
        }
        return Database.query(query);
    }

    global void execute(Database.BatchableContext bc, List<Roll_up_by_Category__mdt> scope) {
        Set<String> branchName = new Set<String>();
            for(Roll_up_by_Category__mdt meta :scope){
                branchName.add(meta.Branch_Name__c);
            }
            List<Branch__c> branches = [SELECT Id, Name FROM Branch__c WHERE Name IN :branchName];
            Map<String, Id> mapBranchIdByName = new Map<String, Id>();
            for(Branch__c each :branches){
                mapBranchIdByName.put(each.Name, each.Id);
            }

            Integer start = this.startForecast != null? this.startForecast : this.BASE_START_FORCAST_DAYS;
            Integer ended = this.endForecast != null? this.endForecast : this.BASE_END_FORCAST_DAYS;
            Map<String, Roll_up_Category__c> mapRollCategories = new Map<String, Roll_up_Category__c>();
            List<Roll_up_Category_and_Branch__c> rollCategoriesBranch = new List<Roll_up_Category_and_Branch__c>();
            for(Integer forecastMonth = start; forecastMonth < ended ; forecastMonth++){
                Datetime firstDayOfMonth = Date.today().toStartOfMonth();
                Datetime currentDate = firstDayOfMonth.addMonths(forecastMonth);
                String month = currentDate.format('MMM').toUpperCase();
                String year = currentDate.format('yyyy');
        
                for(Roll_up_by_Category__mdt meta :scope){
                    String branchCattegoryExt = concatRollUpExternalId(meta.Prefix_Branch_Category__c, month, year);
                    String categoryExt = concatRollUpExternalId(meta.Prefix_Category__c, month, year);
                    Roll_up_Category_and_Branch__c rollUp = new Roll_up_Category_and_Branch__c();
                    rollUp.Month__c = month;
                    rollUp.Year__c = year;
                    rollUp.Name = branchCattegoryExt;
                    rollUp.External_Id__c = branchCattegoryExt;
                    rollUp.Branch__c = mapBranchIdByName.get(meta.Branch_Name__c);
                    rollUp.Category__c = meta.Category__c;
                    rollCategoriesBranch.add(rollUp);

                    if(!mapRollCategories.containsKey(categoryExt)){
                        Roll_up_Category__c categoryRollUp = new Roll_up_Category__c();
                        categoryRollUp.Month__c = month;
                        categoryRollUp.Year__c = year;
                        categoryRollUp.Name = categoryExt;
                        categoryRollUp.External_Id__c = categoryExt;
                        categoryRollUp.Category__c = meta.Category__c;
                        mapRollCategories.put(categoryExt, categoryRollUp);
                    }
                }
            }
            
            if(mapRollCategories.size() > 0){
                upsert mapRollCategories.values() External_Id__c;
            }

            for(Roll_up_Category_and_Branch__c rollCatBranch :rollCategoriesBranch){
                List<String> splitExt = rollCatBranch.External_Id__c.split('_');
                String branchExt = concatRollUpExternalId(splitExt[1] + '_', rollCatBranch.Month__c, rollCatBranch.Year__c);
                Roll_up_Category__c rollUpBranch = mapRollCategories.get(branchExt);
                if(rollUpBranch != null){
                    rollCatBranch.Roll_up_Category__c = rollUpBranch.Id;
                }
            }
            System.debug(LoggingLevel.DEBUG, 'rollCategoriesBranch size : ' + rollCategoriesBranch.size());
            if(rollCategoriesBranch.size() > 0){
                upsert rollCategoriesBranch External_Id__c;
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