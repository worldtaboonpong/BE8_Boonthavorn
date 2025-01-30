public without sharing class ContractController {
    public static List<String> getAvaliableDate(Id contractId) {
     
        return null;
    }

    @AuraEnabled
    public static String checkAvaliable(Id contractId, String startDate, String endDate) {
        avaliableResponse response = new avaliableResponse();
        System.debug('startDate: ' + startDate);         
        System.debug('endDate: ' + endDate);        
        Date startDateVal = Date.valueOf(startDate);
        Date endDateVal = Date.valueOf(endDate);
        List<ContractLineItem__c> contractLineItemList = [SELECT Id, Unit__c
                                                            FROM ContractLineItem__c WHERE Contract__c =: contractId];
        Set<Id> unitIdSet = new Set<Id>();      
        for (ContractLineItem__c eachContractLineItem : contractLineItemList) {
            unitIdSet.add(eachContractLineItem.Unit__c);            
        }
        System.debug('unitIdSet: ' + JSON.serialize(unitIdSet));      
        
        contractLineItemList = [SELECT Id, Unit__c, Unit__r.Name, Contract__c,Contract__r.Contract_Start_Date__c,
                                        Contract__r.Contract_End_Date__c, Contract__r.Termination_Date__c 
                                FROM ContractLineItem__c WHERE Unit__c IN: unitIdSet AND Contract__c !=: contractId];
        Set<Id> contractIdSet = new Set<Id>();
        for (ContractLineItem__c eachContractLineItem : contractLineItemList) {
            contractIdSet.add(eachContractLineItem.Contract__c);     
        }
        System.debug('contractIdSet: ' + JSON.serialize(contractIdSet));

        Map<Id,Contract__c> contractToCheck = new Map<Id,Contract__c> ([SELECT Id, Contract_Number__c,
                                                                            Contract_Start_Date__c, 
                                                                            Contract_End_Date__c, 
                                                                            Termination_Date__c,
                                                                            Name, 
                                                                            Account_Name__c, 
                                                                            Account_Name__r.Name 
                                                                            FROM Contract__c WHERE Id IN: contractIdSet AND IsActive__c =: true ORDER BY Contract_Start_Date__c]);
        System.debug('contractToCheck: ' + JSON.serialize(contractToCheck));

        Map<String,List<Contract__c>> roMapWithContract = new Map<String,List<Contract__c>>();
        for (ContractLineItem__c eachContractLineItem : contractLineItemList){
            Date contractActualEndDate = eachContractLineItem.Contract__r.Termination_Date__c != null ? eachContractLineItem.Contract__r.Termination_Date__c : eachContractLineItem.Contract__r.Contract_End_Date__c;
            System.debug(startDateVal+' <= '+contractActualEndDate+' && '+eachContractLineItem.Contract__r.Contract_Start_Date__c+' <= '+endDateVal);   
            if (contractToCheck.get(eachContractLineItem.Contract__c) != null && 
                Utility.isPeriodOverlap(startDateVal, endDateVal, eachContractLineItem.Contract__r.Contract_Start_Date__c, contractActualEndDate)
            ){
                if (roMapWithContract.containsKey(eachContractLineItem.Unit__r.Name)) {
                    roMapWithContract.get(eachContractLineItem.Unit__r.Name).add(contractToCheck.get(eachContractLineItem.Contract__c));
                }else{
                    roMapWithContract.put(eachContractLineItem.Unit__r.Name,new List<Contract__c>{contractToCheck.get(eachContractLineItem.Contract__c)});
                }
            }
        }
        System.debug('roMapWithContract: ' + JSON.serialize(roMapWithContract));
        if(roMapWithContract.size() > 0) {
            response.avaliable = false;
            response.message = '';
            for(String room : roMapWithContract.keySet()) {
                response.message += 'Room: '+room+' is overlap with contract: (';
                List<Contract__c> temp = roMapWithContract.get(room);
                for(Contract__c con : temp) {
                    Date contractActualEndDate = con.Termination_Date__c != null ? con.Termination_Date__c : con.Contract_End_Date__c;
                    response.message += con.Contract_Number__c+' [Start: '+con.Contract_Start_Date__c.format()+', End: '+contractActualEndDate.format()+'], ';
                }
                response.message += '), ';
            }
        } else {
            response.avaliable = true;
        }

        return JSON.serialize(response);
    }

    @AuraEnabled
    public static Boolean changePeriodDetail(Id contractId, Integer days) {
        List<ContractPeriod__c> conPeriods = [SELECT Id, PeriodFrom__c, PeriodTo__c FROM ContractPeriod__c WHERE Contract__c =: contractId];
        for(ContractPeriod__c conPeriod : conPeriods) {
            conPeriod.PeriodFrom__c = conPeriod.PeriodFrom__c.addDays(days);
            conPeriod.PeriodTo__c = conPeriod.PeriodTo__c.addDays(days);
        }
        update(conPeriods);

        List<ContractPrice__c> conPrices = [SELECT Id, From__c, To__c, PaymentDueDate__c FROM ContractPrice__c WHERE Contract__c =: contractId];
        for(ContractPrice__c conPrice : conPrices) {
            conPrice.From__c = conPrice.From__c.addDays(days);
            conPrice.To__c = conPrice.To__c.addDays(days);
            if(conPrice.PaymentDueDate__c != null) conPrice.PaymentDueDate__c = conPrice.PaymentDueDate__c.addDays(days);
        }
        update(conPrices);

        Boolean toUpdate = false;
        Contract__c con = [SELECT Id, ContractGrading__c, ContractLeaseholdFloor__c, DepositMeasurement__c FROM Contract__c WHERE Id =: contractId LIMIT 1];
        if(con.ContractGrading__c != null) {
            List<ContractGradingModel.Data> conGrades = ContractGradingModel.parse(con.ContractGrading__c);
            if(!conGrades.isEmpty()) {
                for(ContractGradingModel.Data conGrade : conGrades) {
                    if(conGrade.GradingPeriodForm != null) conGrade.GradingPeriodForm = conGrade.GradingPeriodForm.addDays(days);
                    if(conGrade.GradingPeriodTo != null) conGrade.GradingPeriodTo = conGrade.GradingPeriodTo.addDays(days);
                }
                con.ContractGrading__c = ContractGradingModel.toString(conGrades);
                toUpdate = true;
            }
        }
        if(toUpdate) update(con);

        return true;
    }

    public class avaliableResponse {    
        public Boolean avaliable {get; set;}
        public String message {get; set;}
    }
}