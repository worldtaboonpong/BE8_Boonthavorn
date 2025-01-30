trigger ContractTrigger on Contract__c (before insert, before update) {

    TriggerActivation setting = TriggerActivation.getInstance('Contract__c');
    if(!setting.isActiveTrigger() || !CacheTrigger.isRunningContractTrigger) return;

    if(Trigger.isInsert) {
        List<Id> buildingIds = new List<Id>();
        for(Contract__c con : Trigger.new) {
            if(con.Contract_Number__c == null && con.Building__c != null) {
                buildingIds.add(con.Building__c);
            }

            //Transform Amount to Word
            if(con.Year_1_Monthly_Rental__c != null) {
                con.Text_of_Year_1_Monthly_Rent__c = numberToWord.numberToWordTH(con.Year_1_Monthly_Rental__c, false, true);
            }
            if(con.Year_1_Monthly_Rent_Sq_m__c != null) {
                con.Text_of_Year_1_Monthly_Rent_Sq_m__c = numberToWord.numberToWordTH(con.Year_1_Monthly_Rent_Sq_m__c, false, true);
            }
            if(con.Year_1_Monthly_Service__c != null) {
                con.Text_of_Year_1_Monthly_Service__c = numberToWord.numberToWordTH(con.Year_1_Monthly_Service__c, false, true);
            }
            if(con.Year_1_Monthly_Service_Sq_m__c != null) {
                con.Text_of_1_Year_Monthly_Service_Sq_m__c = numberToWord.numberToWordTH(con.Year_1_Monthly_Service_Sq_m__c, false, true);
            }
            if(con.Year_1_Monthly_CAM__c != null) {
                con.Text_of_Year_1_Monthly_CAM__c = numberToWord.numberToWordTH(con.Year_1_Monthly_CAM__c, false, true);
            }
            if(con.Year_1_Monthly_CAM_Sq_m__c != null) {
                con.Text_of_Year_1_Monthly_CAM_Sq_m__c = numberToWord.numberToWordTH(con.Year_1_Monthly_CAM_Sq_m__c, false, true);
            }

            if(con.Year_Last_Monthly_Rental__c != null) {
                con.Text_of_Year_Last_Monthly_Rental__c = numberToWord.numberToWordTH(con.Year_Last_Monthly_Rental__c, false, true);
            }
            if(con.Year_Last_Monthly_Rent_Sq_m__c != null) {
                con.Text_of_Year_Last_Monthly_Rent_Sq_m__c = numberToWord.numberToWordTH(con.Year_Last_Monthly_Rent_Sq_m__c, false, true);
            }
            if(con.Year_Last_Monthly_Service__c != null) {
                con.Text_of_Year_Last_Monthly_Service__c = numberToWord.numberToWordTH(con.Year_Last_Monthly_Service__c, false, true);
            }
            if(con.Year_Last_Monthly_Service_Sq_m__c != null) {
                con.Text_of_Year_Last_Monthly_Service_Sq_m__c = numberToWord.numberToWordTH(con.Year_Last_Monthly_Service_Sq_m__c, false, true);
            }
            if(con.Year_Last_Monthly_CAM__c != null) {
                con.Text_of_Year_Last_Monthly_CAM__c = numberToWord.numberToWordTH(con.Year_Last_Monthly_CAM__c, false, true);
            }
            if(con.Year_Last_Monthly_CAM_Sq_m__c != null) {
                con.Text_of_Year_Last_Monthly_CAM_Sq_m__c = numberToWord.numberToWordTH(con.Year_Last_Monthly_CAM_Sq_m__c, false, true);
            }
            if(con.Other_Fines_and_Fees__c != null) {
                con.Text_Other_Fines_and_Fees__c = numberToWord.numberToWordTH(con.Other_Fines_and_Fees__c, false, true);
            }
            if(con.Total_Contract_Value_TCV__c != null) {
                con.Text_Total_Contract_Value_TCV__c = numberToWord.numberToWordTH(con.Total_Contract_Value_TCV__c, false, true);
            }
            if(con.Total_Contract_Value_for_Billboard__c != null) {
                con.Text_Total_Contract_Value_for_Billboard__c = numberToWord.numberToWordTH(con.Total_Contract_Value_for_Billboard__c, false, true);
            }
            if(con.Agreement_Total_Other_Expense__c != null) {
                con.Text_of_Agreement_Total_OtherExpens__c = numberToWord.numberToWordTH(con.Agreement_Total_Other_Expense__c, false, true);
            }
            if(con.Decoration_Insurance_Amount__c != null) {
                con.Text_of_Decoration_Insurance_Amount__c = numberToWord.numberToWordTH(con.Decoration_Insurance_Amount__c, false, true);
            }
            if(con.Decoration_Insurance_Total__c != null) {
                con.Text_Decoration_Insurance_Total__c = numberToWord.numberToWordTH(con.Decoration_Insurance_Total__c, false, true);
            }
            if(con.Deposit_Amount_for_Event__c != null) {
                con.Text_Deposit_Amount_for_Event__c = numberToWord.numberToWordTH(con.Deposit_Amount_for_Event__c, false, true);
            }
            if(con.Total_Service_Deposit_Include_Vat__c != null) {
                con.Text_of_Total_Service_Deposit_Vat__c = numberToWord.numberToWordTH(con.Total_Service_Deposit_Include_Vat__c, false, true);
            }
        }

        //Generate Running Number
        Map<Id, Building__c> mapBuilding = new Map<Id, Building__c>([SELECT Branch__c, Branch__r.Branch_Code__c, Branch__r.Contract_Space__c,
                                                                            Branch__r.Contract_Service__c, Branch__r.Contract_OP__c,
                                                                            Branch__r.Contract_Event__c, Branch__r.Contract_Billboard__c
                                                                    FROM Building__c WHERE Id IN: buildingIds]);
        Map<Id, Branch__c> mapBranch = new Map<Id, Branch__c>();
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
        String runningText;
        String typeText;
        String branchText;
        String yearText = String.valueOf(Date.Today().Year()).right(2);
        Integer runningNumber;
        String runningNumberText;
        Building__c myBuilding;
        Branch__c myBranch;

        for(Contract__c con : Trigger.new) {
            if(con.Contract_Number__c == null && con.Building__c != null && mapBuilding.containsKey(con.Building__c) && con.Rental_Type__c != null) {
                myBuilding = mapBuilding.get(con.Building__c);
                if(myBuilding.Branch__c == null || myBuilding.Branch__r.Branch_Code__c == null) continue;
                branchText = myBuilding.Branch__r.Branch_Code__c;

                if(mapBranch.containsKey(myBuilding.Branch__c)) {
                    myBranch = mapBranch.get(myBuilding.Branch__c);
                } else {
                    myBranch = new Branch__c(Id = myBuilding.Branch__c);
                    myBranch.Contract_Space__c = myBuilding.Branch__r.Contract_Space__c == null? 1 : myBuilding.Branch__r.Contract_Space__c;
                    myBranch.Contract_Service__c = myBuilding.Branch__r.Contract_Service__c == null? 1 : myBuilding.Branch__r.Contract_Service__c;
                    myBranch.Contract_OP__c = myBuilding.Branch__r.Contract_OP__c == null? 1 : myBuilding.Branch__r.Contract_OP__c;
                    myBranch.Contract_Event__c = myBuilding.Branch__r.Contract_Event__c == null? 1 : myBuilding.Branch__r.Contract_Event__c;
                    myBranch.Contract_Billboard__c = myBuilding.Branch__r.Contract_Billboard__c == null? 1 : myBuilding.Branch__r.Contract_Billboard__c;
                    mapBranch.put(myBuilding.Branch__c, myBranch);
                }
                
                switch on con.Rental_Type__c {
                    when 'Space_Rental' {
                        typeText = 'LA';
                        runningNumber = Integer.valueOf(myBranch.Contract_Space__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = typeText + branchText + yearText + runningNumberText;
                        con.Contract_Number__c = runningText;
                        myBranch.Contract_Space__c += 1;

                        typeText = 'SA';
                        runningNumber = Integer.valueOf(myBranch.Contract_Space__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = typeText + branchText + yearText + runningNumberText;
                        con.Contract_Service_No__c = runningText;
                        myBranch.Contract_Service__c += 1;
                    }
                    when 'OP_Rental' {
                        typeText = 'SAOP';
                        runningNumber = Integer.valueOf(myBranch.Contract_OP__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = typeText + branchText + yearText + runningNumberText;
                        con.Contract_Number__c = runningText;
                        myBranch.Contract_OP__c += 1;
                        /*
                        typeText = 'SA';
                        runningNumber = Integer.valueOf(myBranch.Contract_Space__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = typeText + branchText + yearText + runningNumberText;
                        con.Contract_Service_No__c = runningText;
                        myBranch.Contract_Service__c += 1;
                        */
                    }
                    when 'Billboard_Rental' {
                        typeText = 'SAMD';
                        runningNumber = Integer.valueOf(myBranch.Contract_Billboard__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = typeText + branchText + yearText + runningNumberText;
                        con.Contract_Number__c = runningText;
                        myBranch.Contract_Billboard__c += 1;
                    }
                    when 'Event_Rental' {
                        typeText = 'SAEV';
                        runningNumber = Integer.valueOf(myBranch.Contract_Event__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = typeText + branchText + yearText + runningNumberText;
                        con.Contract_Number__c = runningText;
                        myBranch.Contract_Event__c += 1;
                    }
                }
                
                mapOpp.put(con.Opportunity_Name__c, new Opportunity(Id = con.Opportunity_Name__c, Contract_No__c = con.Contract_Number__c));
            }
        }
        if(mapBranch.size() > 0) update(mapBranch.values());
        if(mapOpp.size() > 0) {
            CacheTrigger.isRunningOpportunityTrigger = false;
            update(mapOpp.values());
            CacheTrigger.isRunningOpportunityTrigger = true;
        }
    } else {
        for(Contract__c con : Trigger.new) {
            if(con.Other_Fines_and_Fees__c != Trigger.oldMap.get(con.Id).Other_Fines_and_Fees__c) {
                con.Text_Other_Fines_and_Fees__c = numberToWord.numberToWordTH(con.Other_Fines_and_Fees__c, false, true);
            }
            if(con.Total_Contract_Value_TCV__c != Trigger.oldMap.get(con.Id).Total_Contract_Value_TCV__c || 
              (con.Text_Total_Contract_Value_TCV__c == null && con.Total_Contract_Value_TCV__c != null)) {
                con.Text_Total_Contract_Value_TCV__c = numberToWord.numberToWordTH(con.Total_Contract_Value_TCV__c, false, true);
            }
            if(con.Total_Contract_Value_for_Billboard__c != Trigger.oldMap.get(con.Id).Total_Contract_Value_for_Billboard__c ||
              (con.Text_Total_Contract_Value_for_Billboard__c == null && con.Total_Contract_Value_for_Billboard__c != null)) {
                con.Text_Total_Contract_Value_for_Billboard__c = numberToWord.numberToWordTH(con.Total_Contract_Value_for_Billboard__c, false, true);
            }
            if(con.Agreement_Total_Other_Expense__c != Trigger.oldMap.get(con.Id).Agreement_Total_Other_Expense__c ||
              (con.Text_of_Agreement_Total_OtherExpens__c == null && con.Agreement_Total_Other_Expense__c != null)) {
                con.Text_of_Agreement_Total_OtherExpens__c = numberToWord.numberToWordTH(con.Agreement_Total_Other_Expense__c, false, true);
            }
            if(con.Decoration_Insurance_Amount__c != Trigger.oldMap.get(con.Id).Decoration_Insurance_Amount__c ||
              (con.Text_of_Decoration_Insurance_Amount__c == null && con.Decoration_Insurance_Amount__c != null)) {
                con.Text_of_Decoration_Insurance_Amount__c = numberToWord.numberToWordTH(con.Decoration_Insurance_Amount__c, false, true);
            }
            if(con.Decoration_Insurance_Total__c != Trigger.oldMap.get(con.Id).Decoration_Insurance_Total__c ||
              (con.Text_Decoration_Insurance_Total__c == null && con.Decoration_Insurance_Total__c != null)) {
                con.Text_Decoration_Insurance_Total__c = numberToWord.numberToWordTH(con.Decoration_Insurance_Total__c, false, true);
            }
            if(con.Deposit_Amount_for_Event__c != Trigger.oldMap.get(con.Id).Deposit_Amount_for_Event__c ||
              (con.Text_Deposit_Amount_for_Event__c == null && con.Deposit_Amount_for_Event__c != null)) {
                con.Text_Deposit_Amount_for_Event__c = numberToWord.numberToWordTH(con.Deposit_Amount_for_Event__c, false, true);
            }
            if(con.Total_Service_Deposit_Include_Vat__c != Trigger.oldMap.get(con.Id).Total_Service_Deposit_Include_Vat__c ||
              (con.Text_of_Total_Service_Deposit_Vat__c == null && con.Total_Service_Deposit_Include_Vat__c != null)) {
                con.Text_of_Total_Service_Deposit_Vat__c = numberToWord.numberToWordTH(con.Total_Service_Deposit_Include_Vat__c, false, true);
            }
            if(con.Status__c != Trigger.oldMap.get(con.Id).Status__c && 
              (con.Status__c == Constant.CONTRACT_STATUS_RENEW || con.Status__c == Constant.CONTRACT_STATUS_CLOSED)){
                con.Close_Date__c = Datetime.now();
            }
        }
    }
}