global with sharing class MonthlyRevenueReportBatch implements Database.Batchable<sobject> {

    private Date manualSetStartForcast;
    private Date manualSetEndForcast;
    private String manualStatus;
    private String contractIdString;

    public MonthlyRevenueReportBatch() {
        Date todayDate = Date.today();
        this.manualSetStartForcast = todayDate.addMonths(-36).toStartOfMonth();
        this.manualSetEndForcast = todayDate.addMonths(37).toStartOfMonth().addDays(-1);
        this.manualStatus = '\''+Constant.CONTRACT_STATUS_ACTIVATED+'\', \''+Constant.CONTRACT_STATUS_TERMINATED+'\'';
    }

    public MonthlyRevenueReportBatch(Date manualSetStartForcast, Date manualSetEndForcast, String filterStatus, List<Id> contractIds) {
        if (manualSetStartForcast >= manualSetEndForcast) {
            throw new CustomException('start date con not exceed end date');
        }
        Date todayDate = Date.today();
        this.manualSetStartForcast = (manualSetStartForcast == null) ? todayDate.addMonths(-36).toStartOfMonth() : manualSetStartForcast;
        this.manualSetEndForcast = (manualSetEndForcast == null) ? todayDate.addMonths(37).toStartOfMonth().addDays(-1) : manualSetEndForcast;
        if (String.isBlank(filterStatus)) {
            this.manualStatus = '\''+Constant.CONTRACT_STAGE_ACTIVATED+'\', \''+Constant.CONTRACT_STAGE_TERMINATED+'\'';
        } else {
            this.manualStatus = filterStatus;
        }
        if (contractIds != null && contractIds.size() > 0) {
            String queryIDs = '(';
            for (Integer order = 0; order < contractIds.size(); order++) {
                queryIDs += '\''+contractIds[order]+'\'';
                if (order < (contractIds.size() - 1)) {
                    queryIDs += ', ';
                }
            }
            queryIDs += ')';
            this.contractIdString = queryIDs;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('::: MonthlyRevenueReportBatch Start :::');
        String query = 'SELECT id, Name, Account_Name__c, Building__c, Building__r.Name, Building__r.Branch_Name__c, '+
                        'Grace_Month__c, Grace_Day__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, ContractGrading__c , '+
                        'Termination_Date__c, Calculation_Method__c, Contract_Type__c, Rental_Type__c, Category__c, TotalArea__c, Total_Leasable_Area__c, Record_Type_Name__c, '+
                            '(SELECT Id, IsDeleted, Name, CalculationMethod__c, CAMMonth__c, RentMonth__c, ServiceMonth__c, EstimateRevenue__c, '+
                                'RentSqmMonth__c, ServiceSqmMonth__c, CAMSqmMonth__c, IsIncludeCAM__c, LeasableArea__c, Contract__c, '+
                                'RentPercent__c, ServicePercent__c, PeriodFrom__c, PeriodTo__c, SalesMin__c, Sequence__c, Total__c, TotalArea__c FROM Contract_Periods__r) '+
                        'FROM Contract__c WHERE Contract_End_Date__c >= '+String.valueOf(this.manualSetStartForcast)+' AND Contract_Start_Date__c <= '+String.valueOf(this.manualSetEndForcast)+
                        ' AND (Status__c IN ('+this.manualStatus+') OR (Status__c IN (\''+Constant.CONTRACT_STATUS_CLOSED+'\', \''+Constant.CONTRACT_STATUS_RENEW+'\') AND Close_Date__c = LAST_N_DAYS:1))';
        if(this.contractIdString != null){
            query += ' AND Id IN '+this.contractIdString;
        }
        return Database.getquerylocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contract__c> scope) {
        System.debug('::: MonthlyRevenueReportBatch Execute :::');
        MonthlyRevenueRecordsBuilder mrrBuilder = new MonthlyRevenueRecordsBuilder(scope, this.manualSetStartForcast, this.manualSetEndForcast);
        List<Monthly_Revenue__c> monthlyRevenue = mrrBuilder.createMonthlyRevenueRecords();
        DiscountController discountCtrl = new DiscountController(scope);
        discountCtrl.stampMonthlyRevenueDiscount(monthlyRevenue);
        if(monthlyRevenue.size() > 0){
            List<Database.UpsertResult> upsertResult = Database.upsert(monthlyRevenue, Monthly_Revenue__c.External_ID__c, false);
            for (Database.UpsertResult ur : upsertResult) {
                if (ur.isSuccess()) {
                    System.debug('Upsert Success');
                } else {
                    for(Database.Error err : ur.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        System.debug('::: '+monthlyRevenue.size());
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('::: MonthlyRevenueReportBatch Finish :::');
    }
}