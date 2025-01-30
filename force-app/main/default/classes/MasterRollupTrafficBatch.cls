global class MasterRollupTrafficBatch implements Database.Batchable<SObject> {
    private Date startDate;
    private Date endDate;
    private List<SelectOption> typePicklistValues;
    private Map<String, String> mapBranchCode;

    global MasterRollupTrafficBatch(){
        Date todayDate = Date.today();
        this.startDate = todayDate;
        this.endDate = todayDate;
        typePicklistValues = Utility.getPicklistValues('Roll_up_Traffic__c', 'Type__c');
        getMapBranchCode();
    } 

    global MasterRollupTrafficBatch(Date startDate, Date endDate){
        this.startDate = startDate;
        this.endDate = endDate;
        typePicklistValues = Utility.getPicklistValues('Roll_up_Traffic__c', 'Type__c');
        getMapBranchCode();
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name FROM Branch__c';
        return Database.getquerylocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Branch__c> scope) {
        List<Roll_up_Traffic__c> trafficRoll = new List<Roll_up_Traffic__c>();
        for(Branch__c branch :scope){
            Date curDate = startDate;
            while(curDate <= endDate){
                String dateString = formatDateToYYYYMMDD(curDate);
                for(SelectOption type :typePicklistValues){
                    String branchCode = this.mapBranchCode.get(branch.Name);
                    Roll_up_Traffic__c rollTraff = new Roll_up_Traffic__c();
                    rollTraff.External_ID__c = concatRollUpExternalId(branchCode, type.getValue().left(1), dateString);
                    rollTraff.Date__c = curDate;
                    rollTraff.Branch__c = branch.Id;
                    rollTraff.Type__c = type.getValue();
                    trafficRoll.add(rollTraff);
                    System.debug(LoggingLevel.DEBUG, 'rollTraff : ' + rollTraff);
                }

                curDate = curDate.addDays(1);
            }
        }
        System.debug(LoggingLevel.DEBUG, 'trafficRoll size : ' + trafficRoll.size());

        if(trafficRoll.size() > 0){
            upsert trafficRoll External_ID__c;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.DEBUG, 'finish batch');
    }

    public static String concatRollUpExternalId(String branchCode, String type, String dateString){
        String externalId = branchCode + type + '_' + dateString;
        return externalId;
    }

    public String formatDateToYYYYMMDD(Date inputDate) {
        String year = String.valueOf(inputDate.year());
        String month = String.valueOf(inputDate.month()).leftPad(2, '0');
        String day = String.valueOf(inputDate.day()).leftPad(2, '0');
        return year + month + day;
    }

    private void getMapBranchCode(){
        List<Roll_up_by_Branch__mdt> metaRollBranch = [SELECT Prefix_Branch__c, Branch_Name__c FROM Roll_up_by_Branch__mdt WHERE Is_Active__c = true];
        this.mapBranchCode = new Map<String, String>();
        for(Roll_up_by_Branch__mdt each :metaRollBranch){
            this.mapBranchCode.put(each.Branch_Name__c, each.Prefix_Branch__c);
        }
    }
}