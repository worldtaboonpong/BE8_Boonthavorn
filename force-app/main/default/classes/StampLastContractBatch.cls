global class StampLastContractBatch implements Database.Batchable<sObject> {

    global StampLastContractBatch() {
        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Decimal customLastDate = tms_OpportunitySetting__c.getInstance().tms_LastContractBackDate__c;
        Date lastDate = system.today().addDays(Integer.valueOf(30.00)*-1);
        system.debug(lastDate);
        // Date todayDate = system.today();
        List<String> stageNameList = new List<String>{'Activated','Renewal in Progress','Renewed'};
        String stageName = String.join( stageNameList, '\',\'');
        // String queryString = 'SELECT Id, name, Contract__c, Units__c, Contract__r.Contract_End_Date__c, Contract__r.Contract_Start_Date__c,  Contract__r.CreatedDate'+
        //                     ' FROM ContractLineItem__c'+
        //                     ' WHERE'+
        //                     ' ( Contract__r.Termination_Date__c != null AND'+
        //                     ' Contract__r.Status__c = \''+ 'Approved' +'\' AND'+
        //                     ' Contract__r.Termination_Date__c <= '+String.valueOf(todayDate.addDays(-1))+' AND'+
        //                     ' Contract__r.Termination_Date__c >= '+String.valueOf(lastDate)+' ) OR'+
        //                     ' (Contract__r.Termination_Date__c = null AND'+
        //                     ' Contract__r.Contract_End_Date__c <= '+String.valueOf(todayDate.addDays(-1))+' AND'+
        //                     ' Contract__r.Contract_End_Date__c >= '+String.valueOf(lastDate)+')'+
        //                     ' ORDER BY Contract__r.Contract_End_Date__c DESC, Contract__r.Termination_Date__c DESC, Units__c';

        String queryString = 'SELECT Id, name, Contract__c, Unit__c, Contract__r.Contract_End_Date__c, Contract__r.Contract_Start_Date__c,  Contract__r.CreatedDate'+
                            ' FROM ContractLineItem__c'+
                            ' WHERE'+
                            ' ( Contract__r.Termination_Date__c != null AND'+
                            ' Contract__r.Status__c = \''+ 'Terminated' +'\' AND'+
                            ' Contract__r.Termination_Date__c <= '+ 'TODAY'+
                            ' ) OR' +
                            ' (Contract__r.Termination_Date__c = null AND'+
                            ' Contract__r.Contract_End_Date__c <= '+ 'TODAY' +
                            ')'+
                            ' ORDER BY Contract__r.Contract_End_Date__c DESC, Contract__r.Termination_Date__c DESC, Unit__c';
        system.debug('queryString : '+queryString);
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        System.debug('Go in execute progress');
        updateLastContract((List<ContractLineItem__c>) scope);
    }

    global void finish(Database.BatchableContext BC) {

    }

    public static void updateLastContract(List<ContractLineItem__c> targetContractLineItemList){
        System.debug(targetContractLineItemList);
        Set<Id> rentalObjectSet = new Set<Id>();
        List<Units__c> targetRentalObjectToUpdateList = new List<Units__c>();
        for(ContractLineItem__c eachContractLineItem : targetContractLineItemList){
            if(rentalObjectSet.contains(eachContractLineItem.Unit__c)) continue;
            Units__c targetRentalObject = new Units__c(
                Id = eachContractLineItem.Unit__c,
                LastContract__c = eachContractLineItem.Contract__c
            );
            System.debug(eachContractLineItem);
            targetRentalObjectToUpdateList.add(targetRentalObject);
            rentalObjectSet.add(eachContractLineItem.Unit__c);
        }
        system.debug('targetRentalObjectToUpdateList : '+targetRentalObjectToUpdateList);
        for(Units__c eachtarget : targetRentalObjectToUpdateList) {
            System.debug(eachtarget.Name);
            System.debug(eachtarget.LastContract__r.Name);
        }
        update targetRentalObjectToUpdateList;
    }
}


// SELECT Id, name, Contract__c, Unit__c, Contract__r.Contract_End_Date__c, Contract__r.Contract_Start_Date__c,  Contract__r.CreatedDate 
// FROM ContractLineItem__c 
// WHERE ( Contract__r.Termination_Date__c != null 
//     AND Contract__r.Status__c = 'Terminated' 
//     AND Contract__r.Termination_Date__c <= TODAY ) 
//     OR 
//     (Contract__r.Termination_Date__c = null 
//     AND Contract__r.Contract_End_Date__c <= TODAY) 
//     ORDER BY Contract__r.Contract_End_Date__c DESC, Contract__r.Termination_Date__c DESC, Unit__c