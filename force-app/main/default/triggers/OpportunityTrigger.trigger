trigger OpportunityTrigger on Opportunity (before insert, before update, after update) {
    
    TriggerActivation setting = TriggerActivation.getInstance('Opportunity');
    if(!setting.isActiveTrigger() || !CacheTrigger.isRunningOpportunityTrigger) return;

    OpportunityController oppController = new OpportunityController();
    if(Trigger.isBefore) {
        //Stamp Opportunity Name
        oppController.stampOppName(Trigger.oldMap, Trigger.new);
        oppController.processClearCAMDataWhenOppIsNoCAM(Trigger.oldMap, Trigger.new);
        //oppController.processResetSecurityDeposit(Trigger.oldMap, Trigger.new);

        Set<Id> toCheckQuoteSign = new Set<Id>();
        List<Id> buildingIds = new List<Id>();
        for(Opportunity opp : Trigger.new) {
            if(opp.Quotation_No__c == null && opp.Building__c != null && opp.Rental_Type__c != null) {
                buildingIds.add(opp.Building__c);
            }

            Set<Id> ownerIDs = new Set<Id>();
                if( opp.OwnerId != null )
                {
                    ownerIDs.add( opp.OwnerId );
                }
                
                Map<Id, User> ownerMap = new Map<Id, User>([ Select Id, ProfileId, Profile.Name From User where Profile.Name LIKE '%Manager%']);
            
                if(ownerMap.containsKey( opp.OwnerId )){
                    opp.Approve_Status__c = 'Approved';
                }

            //Transform Amount to Word
            if(Trigger.isInsert) {
                if(opp.Total_Area_sq_m__c != null) {
                    opp.Text_of_Total_Area_sq_m__c = numberToWord.numberToWordTH(opp.Total_Area_sq_m__c, false, false);
                }
                if(opp.Total_Other_Expense_Amount_THB__c != null) {
                    opp.Text_of_Total_Other_Expense_Amount_THB__c = numberToWord.numberToWordTH(opp.Total_Other_Expense_Amount_THB__c, false, true);
                }
                if(opp.Total_Electricity__c != null) {
                    opp.Text_of_Total_Electricity__c = numberToWord.numberToWordTH(opp.Total_Electricity__c, false, true);
                }
                if(opp.TotalDeposit__c != null) {
                    opp.Text_Deposit_Amount_THB__c = numberToWord.numberToWordTH(opp.TotalDeposit__c, false, true);
                }
                if(opp.Total_Rent_billboard__c != null) {
                    opp.Text_Total_Rent_billboard__c = numberToWord.numberToWordTH(opp.Total_Rent_billboard__c, false, true);
                } 
                if(opp.Generate_Billboard_Amount__c != null) {
                    opp.Text_Generate_Billboard_Amount__c = numberToWord.numberToWordTH(opp.Generate_Billboard_Amount__c, false, true);
                } 
                if(opp.Install_Billboard_Amount__c != null) {
                    opp.Text_Install_Billboard_Amount__c = numberToWord.numberToWordTH(opp.Install_Billboard_Amount__c, false, true);
                } 
                if(opp.Monthly_Rent_Billboard__c != null) {
                    opp.Text_Monthly_Rent_Billboard__c = numberToWord.numberToWordTH(opp.Monthly_Rent_Billboard__c, false, true);
                }
                if(opp.TotalRentGP__c != null) {
                    opp.Text_Total_Estimated_Rent_GP__c = numberToWord.numberToWordTH(opp.TotalRentGP__c, false, true);
                }
                if(opp.Total_Rent_Deposit__c != null) {
                    opp.Text_of_Total_Rent_Deposit__c = numberToWord.numberToWordTH(opp.Total_Rent_Deposit__c, false, true);
                }
                if(opp.Total_Service_Deposit__c != null) {
                    opp.Text_of_Total_Service_Deposit__c = numberToWord.numberToWordTH(opp.Total_Service_Deposit__c, false, true);
                }
                if(opp.Owner.Profile.Name == 'Manager'){
                    opp.Approve_Status__c = 'Approved';
                }
            } else {
                if(opp.Total_Area_sq_m__c != Trigger.oldMap.get(opp.Id).Total_Area_sq_m__c) {
                    opp.Text_of_Total_Area_sq_m__c = numberToWord.numberToWordTH(opp.Total_Area_sq_m__c, false, false);
                }
                if(opp.Total_Other_Expense_Amount_THB__c != Trigger.oldMap.get(opp.Id).Total_Other_Expense_Amount_THB__c) {
                    opp.Text_of_Total_Other_Expense_Amount_THB__c = numberToWord.numberToWordTH(opp.Total_Other_Expense_Amount_THB__c, false, true);
                }
                if(opp.Total_Electricity__c != Trigger.oldMap.get(opp.Id).Total_Electricity__c) {
                    opp.Text_of_Total_Electricity__c = numberToWord.numberToWordTH(opp.Total_Electricity__c, false, true);
                }
                if(opp.TotalDeposit__c != Trigger.oldMap.get(opp.Id).TotalDeposit__c) {
                    opp.Text_Deposit_Amount_THB__c = numberToWord.numberToWordTH(opp.TotalDeposit__c, false, true);
                }
                if(opp.Total_Rent_billboard__c != Trigger.oldMap.get(opp.Id).Total_Rent_billboard__c) {
                    opp.Text_Total_Rent_billboard__c = numberToWord.numberToWordTH(opp.Total_Rent_billboard__c, false, true);
                }
                if(opp.Generate_Billboard_Amount__c != Trigger.oldMap.get(opp.Id).Generate_Billboard_Amount__c) {
                    opp.Text_Generate_Billboard_Amount__c = numberToWord.numberToWordTH(opp.Generate_Billboard_Amount__c, false, true);
                } 
                if(opp.Install_Billboard_Amount__c != Trigger.oldMap.get(opp.Id).Install_Billboard_Amount__c) {
                    opp.Text_Install_Billboard_Amount__c = numberToWord.numberToWordTH(opp.Install_Billboard_Amount__c, false, true);
                } 
                if(opp.Monthly_Rent_Billboard__c != Trigger.oldMap.get(opp.Id).Monthly_Rent_Billboard__c) {
                    opp.Text_Monthly_Rent_Billboard__c = numberToWord.numberToWordTH(opp.Monthly_Rent_Billboard__c, false, true);
                }
                if(opp.TotalRentGP__c != Trigger.oldMap.get(opp.Id).TotalRentGP__c) {
                    opp.Text_Total_Estimated_Rent_GP__c = numberToWord.numberToWordTH(opp.TotalRentGP__c, false, true);
                }
                if(opp.Total_Rent_Deposit__c != Trigger.oldMap.get(opp.Id).Total_Rent_Deposit__c) {
                    opp.Text_of_Total_Rent_Deposit__c = numberToWord.numberToWordTH(opp.Total_Rent_Deposit__c, false, true);
                }
                if(opp.Total_Service_Deposit__c != Trigger.oldMap.get(opp.Id).Total_Service_Deposit__c) {
                    opp.Text_of_Total_Service_Deposit__c = numberToWord.numberToWordTH(opp.Total_Service_Deposit__c, false, true);
                }
            }
            if(opp.Rental_Type__c == 'Event_Rental') {
                opp.Total_Event_Amount__c = 0;
                if(opp.Total_Rent_THB__c != null) opp.Total_Event_Amount__c += opp.Total_Rent_THB__c;
                if(opp.Total_Service_THB__c != null) opp.Total_Event_Amount__c += opp.Total_Service_THB__c;
                if(opp.Total_Other_Expense_Amount_THB__c != null) opp.Total_Event_Amount__c  += opp.Total_Other_Expense_Amount_THB__c;
                if(opp.Decoration_Insurance_Amount__c != null) opp.Total_Event_Amount__c += opp.Decoration_Insurance_Amount__c;
                if(opp.Total_Electricity__c != null) opp.Total_Event_Amount__c += opp.Total_Electricity__c;
                opp.Text_Total_Event_Amount__c = numberToWord.numberToWordTH(opp.Total_Event_Amount__c, false, true);
                opp.VAT_Event__c = opp.Total_Event_Amount__c * (OpportunitySetting__c.getInstance().Tax__c) / 100;

                opp.Grand_Total_Event__c = opp.Total_Event_Amount__c * (100 + OpportunitySetting__c.getInstance().Tax__c) / 100;
                opp.Text_of_Grand_Total_Event__c = numberToWord.numberToWordTH(opp.Grand_Total_Event__c, false, true);
            } else if(opp.Rental_Type__c == 'Billboard_Rental') {
                opp.Grand_Total_Billboard__c = 0;
                if(opp.Total_Rent_THB__c != null) opp.Grand_Total_Billboard__c += opp.Total_Rent_THB__c;
                if(opp.Total_Service_THB__c != null) opp.Grand_Total_Billboard__c += opp.Total_Service_THB__c;
                if(opp.Install_Billboard_Amount__c != null) opp.Grand_Total_Billboard__c += opp.Install_Billboard_Amount__c;
                if(opp.Generate_Billboard_Amount__c != null) opp.Grand_Total_Billboard__c += opp.Generate_Billboard_Amount__c;
                if(opp.Total_Electricity__c != null) opp.Grand_Total_Billboard__c += opp.Total_Electricity__c;
                opp.VAT_Billboard__c	 = opp.Grand_Total_Billboard__c * (OpportunitySetting__c.getInstance().Tax__c) / 100;
                
                opp.Grand_Total_Billboard__c = opp.Grand_Total_Billboard__c * (100 + OpportunitySetting__c.getInstance().Tax__c) / 100;
                opp.Text_of_Grand_Total_Billboard__c =  numberToWord.numberToWordTH(opp.Grand_Total_Billboard__c, false, true);
            }

            //Get Opp to Check Quotation Signed
            if(Trigger.isUpdate) {
                if(opp.StageName != Trigger.oldMap.get(opp.Id).StageName && opp.StageName == 'Signed Quotation Uploaded') {
                    toCheckQuoteSign.add(opp.Id);
                }

                // Set<Id> ownerIDs = new Set<Id>();
                // if( opp.OwnerId != null )
                // {
                //     ownerIDs.add( opp.OwnerId );
                // }
                
                // Map<Id, User> ownerMap = new Map<Id, User>([ Select Id, ProfileId, Profile.Name From User where Profile.Name LIKE '%Manager%']);
            
                // if(ownerMap.containsKey( opp.OwnerId )){
                //     opp.Approve_Status__c = 'Approved';
                // }
                
            }
        }
        Map<Id, ContentVersion> quoteFile = new Map<Id, ContentVersion>();
        if(toCheckQuoteSign.size() > 0) {
            for(ContentVersion file : [SELECT Id, FirstPublishLocationId, ContentDocument.FileType FROM ContentVersion WHERE FirstPublishLocationId IN: toCheckQuoteSign]) {
                //System.debug('=========='+file.ContentDocument.FileType+'===========');
                if(file.ContentDocument.FileType == 'PDF') {
                    quoteFile.put(file.FirstPublishLocationId, file);
                }
            }
        }

        //Generate Running Number
        Map<Id, Building__c> mapBuilding = new Map<Id, Building__c>([SELECT Branch__c, Branch__r.Branch_Code__c, Branch__r.Quote_Billboard__c,
                                                                            Branch__r.Quote_Event__c, Branch__r.Quote_Space__c
                                                                    FROM Building__c WHERE Id IN: buildingIds]);
        Map<Id, Branch__c> mapBranch = new Map<Id, Branch__c>();
        String runningText;
        String typeText;
        String branchText;
        String yearText = String.valueOf(Date.Today().Year()).right(2);
        Integer runningNumber;
        String runningNumberText;
        Building__c myBuilding;
        Branch__c myBranch;

        for(Opportunity opp : Trigger.new) {
            if(opp.Quotation_No__c == null && opp.Building__c != null && mapBuilding.containsKey(opp.Building__c) && opp.Rental_Type__c != null) {
                myBuilding = mapBuilding.get(opp.Building__c);
                if(myBuilding.Branch__c == null || myBuilding.Branch__r.Branch_Code__c == null) continue;
                branchText = myBuilding.Branch__r.Branch_Code__c;

                if(mapBranch.containsKey(myBuilding.Branch__c)) {
                    myBranch = mapBranch.get(myBuilding.Branch__c);
                } else {
                    myBranch = new Branch__c(Id = myBuilding.Branch__c);
                    myBranch.Quote_Billboard__c = myBuilding.Branch__r.Quote_Billboard__c == null? 1 : myBuilding.Branch__r.Quote_Billboard__c;
                    myBranch.Quote_Event__c = myBuilding.Branch__r.Quote_Event__c == null? 1 : myBuilding.Branch__r.Quote_Event__c;
                    myBranch.Quote_Space__c = myBuilding.Branch__r.Quote_Space__c == null? 1 : myBuilding.Branch__r.Quote_Space__c;
                    mapBranch.put(myBuilding.Branch__c, myBranch);
                }
                
                switch on opp.Rental_Type__c {
                    when 'Space_Rental' {
                        typeText = 'LS';
                        runningNumber = Integer.valueOf(myBranch.Quote_Space__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = 'QT' + typeText + branchText + yearText + runningNumberText;
                        opp.Quotation_No__c = runningText;
                        myBranch.Quote_Space__c += 1;
                    }
                    when 'OP_Rental' {
                        typeText = 'LS';
                        runningNumber = Integer.valueOf(myBranch.Quote_Space__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = 'QT' + typeText + branchText + yearText + runningNumberText;
                        opp.Quotation_No__c = runningText;
                        myBranch.Quote_Space__c += 1;
                    }
                    when 'Billboard_Rental' {
                        typeText = 'MD';
                        runningNumber = Integer.valueOf(myBranch.Quote_Billboard__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = 'QT' + typeText + branchText + yearText + runningNumberText;
                        opp.Quotation_No__c = runningText;
                        myBranch.Quote_Billboard__c += 1;
                    }
                    when 'Event_Rental' {
                        typeText = 'EV';
                        runningNumber = Integer.valueOf(myBranch.Quote_Event__c);
                        runningNumberText = String.valueOf(runningNumber).leftPad(3, '0');
                        runningText = 'QT' + typeText + branchText + yearText + runningNumberText;
                        opp.Quotation_No__c = runningText;
                        myBranch.Quote_Event__c += 1;
                    }
                }
            }

            //Check Quotation Signed
            if(toCheckQuoteSign.contains(opp.Id) && !quoteFile.containsKey(opp.Id)) {
                opp.addError('Please attach sign quotation to this opportunity "'+opp.Name+'"');
            }
        }
        if(mapBranch.size() > 0) update(mapBranch.values());
    } else {
        
        //Clear Pricing when some data channge
        oppController.processClearPricingRecord(Trigger.oldMap, Trigger.newMap);
    }
}