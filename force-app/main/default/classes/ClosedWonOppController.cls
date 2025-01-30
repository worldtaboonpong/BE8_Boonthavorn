public with sharing class ClosedWonOppController {
    //validate input for integration
    //Callout insert account
    @AuraEnabled
    public static SyncResponse syncAccount(String oppId){
        try{
            List<Opportunity> listOpp = queryOpp(oppId);
            Opportunity opp = listOpp[0];
            List<Account> listAccount = queryAccount(opp.AccountId);
            if(!listAccount.isEmpty()){
                Account acc = listAccount[0];
                if(acc.Customer_ID__c == null) {
                    List<String> missingFields = validateData(acc);
                    if(!missingFields.isEmpty()){
                        return new SyncResponse('Error', null, 'Missing required fields in account : ' + String.join(missingFields, ', '));
                    }

                    WSCalloutCreateAccountToSAP.response resInsertAcc = WSCalloutCreateAccountToSAP.callout(acc);
                    if(resInsertAcc.isSuccess && resInsertAcc.customerId != null){
                        acc.Customer_ID__c = resInsertAcc.customerId;
                        update(acc);
                    } else{
                        String message = '';
                        String errorMessage = '';
                        if(!resInsertAcc.isSuccess){
                            message = 'API Callout Error: ';
                            errorMessage = resInsertAcc.message != null ? resInsertAcc.message : String.valueOf(resInsertAcc);
                        }else{
                            message = 'Not found customer code';
                        }
                        return new SyncResponse('Error',null, message + errorMessage);
                    }
                }
                return new SyncResponse('Success',new List<Opportunity>{opp}, acc.Id);
            }else{
                return new SyncResponse('Error', null, 'Account not found');
            }
        }catch(Exception ex){
            System.debug(ex);
            System.debug('Stack trace: ' + ex.getStackTraceString());
            return new SyncResponse('Error',null,'Error: ' + ex);
        }
    }
    //Callout create contact
    @AuraEnabled
    public static SyncResponse syncContact(String accId){
        try{
            List<Contact> listContact = queryContact(accId);
            ID jobID = System.enqueueJob(new syncContactJob(listContact));
            System.debug('jobID: ' + jobID);
            return new SyncResponse('Success', null, '');
        }catch(Exception ex){
            System.debug(ex);
            System.debug('Stack trace: ' + ex.getStackTraceString());
            return new SyncResponse('Error',null,'Error: ' + ex);
        }
    }
    //Update opp to closed won
    //Clone opp detail to contract
    @AuraEnabled
    public static SyncResponse updateClosedWonOpp(String oppId){
        try{
            if(!haveContract(oppId)) {
                List<Opportunity> listOpp = queryOpp(oppId);
                Opportunity opp = listOpp[0];
                opp.StageName = 'Closed Won';
                update opp;
                Boolean isSuccess = cloneData(opp);
                return new SyncResponse('Success',new List<Opportunity>{opp},'');
            } else {
                return new SyncResponse('Warning',null,'Already have Contract.');
            }
        }catch(Exception ex){
            System.debug(ex);
            System.debug('Stack trace: ' + ex.getStackTraceString());
            return new SyncResponse('Error',null,'Error: ' + ex);
        }
    }

    public static List<String> validateData(Account acc){
        List<String> missingField = new List<String>();
        if(acc.Name == null) missingField.add('Name');
        if(acc.Address__c == null) missingField.add('Address');
        if(acc.Subdistrict__c == null) missingField.add('Subdistrict');
        if(acc.District__c == null) missingField.add('District');
        if(acc.Province__c == null) missingField.add('Province');
        if(acc.ZipCode__c == null) missingField.add('Zipcode');
        if(acc.Mobile_Phone__c == null) missingField.add('Mobile phone');

        return missingField;
    }

    public static Boolean cloneData(Opportunity opp){
        List<ContractLineItem__c> listContractLine = new List<ContractLineItem__c>();
        List<ContractPeriod__c> listContractPeriod = new List<ContractPeriod__c>();
        List<ContractDepositExpense__c> listContractDepositExpense = new List<ContractDepositExpense__c>();
        List<ContractPrice__c> listContractPrice = new List<ContractPrice__c>();
        Map<String, String> mapContractPeriodIdByOppPeriodId = new Map<String, String>();
        Map<String, String> mapContractExpenseByOppExpenseId = new Map<String, String>();
        Boolean isSuccess = false;
        Boolean isNeedToUpdateContract = false;

        Contract__c contract = cloneContract(opp);
        System.debug('contract : ' + contract);
        insert contract;

        List<OpportunityLineItem__c> listOppLineItem = queryOppLineItem(opp.Id);
        if(!listOppLineItem.isEmpty()){
            for(OpportunityLineItem__c oppLineItem : listOppLineItem){
                ContractLineItem__c contractLine = cloneContractLineItem(contract, oppLineItem);
                listContractLine.add(contractLine);
            }
            insert listContractLine;
        }

        List<OpportunityPeriod__c> listOppPeriod = queryOppPeriod(opp.Id);
        if(!listOppPeriod.isEmpty()){
            for(OpportunityPeriod__c oppPeriod : listOppPeriod){
                ContractPeriod__c contractPeriod = cloneContractPeriod(contract, oppPeriod);
                listContractPeriod.add(contractPeriod);
            }
            // insert listContractPeriod;
            Database.SaveResult[] srContractPeriodList = Database.insert(listContractPeriod, false);
            for(Integer i=0; i < srContractPeriodList.size() ;i++){
                Database.SaveResult eachContractPeriod = srContractPeriodList.get(i);
				if (eachContractPeriod.isSuccess()) {
                    String oppPeriodId = listOppPeriod[i].Id;
                    mapContractPeriodIdByOppPeriodId.put(oppPeriodId, eachContractPeriod.getId());
					System.debug('Successfully inserted Contract Period. Contract Period ID: ' + eachContractPeriod.getId());
				}else {
					for(Database.Error err : eachContractPeriod.getErrors()) {
						String errorMessage = 'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
						System.debug('errorMessage : ' + errorMessage);
						System.debug('Campaign fields that affected this error: ' + err.getFields());
					}
				}
			}
        }

        List<OpportunityDepositExpense__c> listOppDepositExpense = queryOppDepositExpense(opp.Id);
        if(!listOppDepositExpense.isEmpty()){
            for(OpportunityDepositExpense__c oppDepositExpense : listOppDepositExpense){
                ContractDepositExpense__c contractDepositExpense = cloneContractDepositExpense(contract, oppDepositExpense);
                listContractDepositExpense.add(contractDepositExpense);
            }
            Database.SaveResult[] srContractDepositExpenseList = Database.insert(listContractDepositExpense, false);
            for(Integer i=0; i < srContractDepositExpenseList.size() ;i++){
                Database.SaveResult eachContractDepositExpense = srContractDepositExpenseList.get(i);
				if (eachContractDepositExpense.isSuccess()) {
                    String oppDepositExpenseId = listOppDepositExpense[i].Id;
                    mapContractExpenseByOppExpenseId.put(oppDepositExpenseId, eachContractDepositExpense.getId());
					System.debug('Successfully inserted Contract Deposit Expense. Contract Deposit Expense ID: ' + eachContractDepositExpense.getId());
				}else {
					for(Database.Error err : eachContractDepositExpense.getErrors()) {
						String errorMessage = 'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
						System.debug('errorMessage : ' + errorMessage);
						System.debug('Campaign fields that affected this error: ' + err.getFields());
					}
				}
			}
        }

        List<OpportunityPrice__c> listOppPrice = queryOppPrice(opp.Id);
        Map<String, List<ContractPrice__c>> mapContractPriceWithOppPeriodId = new Map<String, List<ContractPrice__c>>();
        if(!listOppPrice.isEmpty()){
            for(OpportunityPrice__c oppPrice : listOppPrice){
                ContractPrice__c contractPrice = cloneContractPrice(contract, oppPrice);
                if(oppPrice.OpportunityPeriod__c != null){
                    if(mapContractPeriodIdByOppPeriodId.containsKey(oppPrice.OpportunityPeriod__c)){
                        String contractPeriodId = mapContractPeriodIdByOppPeriodId.get(oppPrice.OpportunityPeriod__c);
                        contractPrice.ContractPeriod__c = contractPeriodId;
                    }
                }
                if(oppPrice.OpportunityDepositExpense__c != null){
                    if(mapContractExpenseByOppExpenseId.containsKey(oppPrice.OpportunityDepositExpense__c)){
                        String contractDepositExpenseId = mapContractExpenseByOppExpenseId.get(oppPrice.OpportunityDepositExpense__c);
                        contractPrice.ContractDepositExpense__c = contractDepositExpenseId;
                    }
                }
                listContractPrice.add(contractPrice);
            }
            insert listContractPrice;
        }

        if(opp.OpportunityGrading__c != null){
            String contractGrading = cloneContractGrading(opp.OpportunityGrading__c, contract.Id, mapContractPeriodIdByOppPeriodId);
            contract.ContractGrading__c = contractGrading;
            isNeedToUpdateContract = true;
        }
        if(opp.OpportunityLeaseholdFloor__c != null){
            String contractLeadholdFloor = cloneContractLeaseHoldFloor(opp.OpportunityLeaseholdFloor__c, contract.Id, mapContractExpenseByOppExpenseId);
            contract.ContractLeaseholdFloor__c = contractLeadholdFloor;
            isNeedToUpdateContract = true;
        }
        if(opp.DepositMeasurement__c != null){
            String contractDepositMeasurement = cloneContractDepositMeasurement(opp.DepositMeasurement__c, contract.Id);
            contract.DepositMeasurement__c = contractDepositMeasurement;
            isNeedToUpdateContract = true;
        }

        update contract;

        isSuccess = true;

        return isSuccess;
    }

    public static List<Account> queryAccount(String accId){
        List<Account> account = [
                                    SELECT Id, Customer_ID__c, Tax_Branch__c, Tax_Number__c, Currency__c, Title__c, Name, Address__c, Street__c, Subdistrict__c,
                                    District__c, Province__c, Zipcode__c, Country_Code__c, Phone, Phone_Ext__c, Mobile_Phone__c, Fax, Salutation_TH__c,
                                    Fax_Ext__c, Email__c, Passport__c, BillingLatitude, BillingLongitude, Customer_Group__c, Remark__c, TR_Zone__c
                                    FROM Account
                                    WHERE Id = :accId
                                ];
        return account;
    }

    public static List<Contact> queryContact(String accId){
        List<Contact> contact = [
                                    SELECT Id, Account.Customer_ID__c, Title__c, Salutation_TH__c, Firstname, Lastname, Department, Function__c, Email, MobilePhone//, Street__c, Province__c
                                    FROM Contact
                                    WHERE AccountId = :accId AND Contact_ID__c = null
                                ];
        return contact;
    }

    public static List<Opportunity> queryOpp(String oppId){
        List<Opportunity> opp = [
                                    SELECT Id, Name, AccountId, Actual_of_Billing_Insurance__c, Actual_of_Billing_Rent_Service__c, Actual_of_Decorate_the_Space__c, Actual_of_Delivery_the_Area__c,
                                    Actual_of_Design_Guideline__c, Actual_of_Shop_Open__c, Actual_of_Signed_Contract__c, Billing_Start_Date__c, Building__c, Estimated_Contract_End_Date__c,
                                    Estimated_Contract_Start_Date__c, Grace_Period_Month__c, Grace_Period_Day__c, Plan_of_Billing_Insurance__c, Plan_of_Billing_Rent_Service__c,
                                    Plan_of_Decorate_the_Space__c, Plan_of_Delivery_the_Area__c, Plan_of_Design_Guideline__c, Plan_of_Shop_Open__c, Plan_of_Signed_Contract__c,
                                    Rental_Period_Day__c, Rental_Period_Month__c, Rental_Period_Year__c, Shop_Opening_Date__c, Year_Last_Monthly_CAM__c, Year_Last_Monthly_CAM_Sq_m__c,
                                    Year_Last_Monthly_Rent_Sq_m__c, Year_Last_Monthly_Rental__c, Year_Last_Monthly_Service__c, Year_Last_Monthly_Service_Sq_m__c, StageName,
                                    DepositMeasurement__c, OpportunityGrading__c, OpportunityLeaseholdFloor__c, Rental_Type__c, Year_1_Monthly_CAM__c, Year_1_Monthly_CAM_Sq_m__c,
                                    Year_1_Monthly_Rent_Sq_m__c, Year_1_Monthly_Rental__c, Year_1_Monthly_Service__c, Year_1_Monthly_Service_Sq_m__c
                                    FROM Opportunity
                                    WHERE Id = :oppId
                                ];
        return opp;
    }

    public static boolean haveContract(String oppId){
        List<Contract__c> listCon = [SELECT Id FROM Contract__c WHERE Opportunity_Name__c =: oppId];
        if(listCon.isEmpty()) return false;
        return true;
    }

    public static List<OpportunityLineItem__c> queryOppLineItem(String oppId){
        List<OpportunityLineItem__c> oppLineItem = [
                                                        SELECT Id, LeasableArea__c, RoomNo__c, Unit__c, TotalArea__c
                                                        FROM OpportunityLineItem__c
                                                        WHERE Opportunity__c = :oppId];
        return oppLineItem;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: query more fields
	 */
    public static List<OpportunityPeriod__c> queryOppPeriod(String oppId){
        List<OpportunityPeriod__c> oppPeriod = [
                                                    SELECT Id, CalculationMethod__c, CAMMonth__c, CAMSqmMonthCalculation__c, EscalationRemark__c, EstimateGPRevernue__c,
                                                    EstimateRevernue__c, IsIncludeCAM__c, IsAddedPeriod__c, IsAllSales__c, LeasableArea__c, MinType__c, IsOptionToRenew__c, PeriodFrom__c,
                                                    PeriodTo__c, RentOpportunityGradingDetail__c, RentPercent__c, RentMonth__c, SalesMin__c, Sequence__c, ServiceOpportunityGradingDetail__c,
                                                    ServicePercent__c, ServiceMonth__c, Total__c, TotalArea__c
                                                    FROM OpportunityPeriod__c
                                                    WHERE Opportunity__c = :oppId
                                                ];
        return oppPeriod;
    }

    public static List<OpportunityDepositExpense__c>  queryOppDepositExpense(String oppId){
        List<OpportunityDepositExpense__c> oppDepositExpense =  [
                                                                    SELECT Id, ActualDepositCAM__c, ActualDepositRent__c, ActualDepositService__c, CAMDeposit__c, CAMDepositVat__c, DepositInputMethod__c,
                                                                    DepositOption__c, HasRemark__c, NumberOfInstallment__c, Price__c, Remark__c, RentDeposit__c, RentDepositVat__c, ServiceDeposit__c,
                                                                    ServiceDepositVat__c, Subtype__c, Type__c, TypeGroup__c
                                                                    FROM OpportunityDepositExpense__c
                                                                    WHERE Opportunity__c = :oppId
                                                                ];
        return oppDepositExpense;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: query more fields
	 */
    public static List<OpportunityPrice__c> queryOppPrice(String oppId){
        List<OpportunityPrice__c> oppPrice =    [
                                                    SELECT Id, Area__c, CalculationFormula__c, CalculationMethod__c, ConditionPurpose__c, To__c, From__c, Installment__c, InstallmentPriceWithVAT__c,
                                                    Measurement__c, MeasurementAmount__c, MeasurementType__c, PaidDeposit__c, PaymentDueDate__c, PaymentType__c, Price__c, PriceItem__c, PriceVAT__c,
                                                    ProportionPercent__c, Rate__c, Remark__c, SubType__c, TotalPrice__c, TotalPriceVAT__c, Unit__c, VAT__c, OpportunityPeriod__c, OpportunityDepositExpense__c
                                                    FROM OpportunityPrice__c
                                                    WHERE Opportunity__c = :oppId
                                                ];
        return oppPrice;
    }

    public static Contract__c cloneContract(Opportunity opp){
        Contract__c contract = new Contract__c();
        contract.Name = opp.Name;
        contract.Account_Name__c = opp.AccountId;
        contract.Actual_of_Billing_Insurance__c = opp.Actual_of_Billing_Insurance__c;
        contract.Actual_of_Billing_Rent_Service__c = opp.Actual_of_Billing_Rent_Service__c;
        contract.Actual_of_Decorate_the_Space__c = opp.Actual_of_Decorate_the_Space__c;
        contract.Actual_of_Delivery_the_Area__c = opp.Actual_of_Delivery_the_Area__c;
        contract.Actual_of_Design_Guideline__c = opp.Actual_of_Design_Guideline__c;
        contract.Actual_of_Shop_Open__c = opp.Actual_of_Shop_Open__c;
        contract.Actual_of_Signed_Contract__c = opp.Actual_of_Signed_Contract__c;
        contract.Billing_Start_Date__c = opp.Billing_Start_Date__c;
        contract.Building__c = opp.Building__c;
        contract.Contract_End_Date__c = opp.Estimated_Contract_End_Date__c;
        contract.Contract_Start_Date__c	= opp.Estimated_Contract_Start_Date__c;
        contract.Grace_Month__c = opp.Grace_Period_Month__c;
        contract.Grace_Day__c = opp.Grace_Period_Day__c;
        contract.Opportunity_Name__c = opp.Id;
        contract.Plan_of_Billing_Insurance__c = opp.Plan_of_Billing_Insurance__c;
        contract.Plan_of_Billing_Rent_Service__c = opp.Plan_of_Billing_Rent_Service__c;
        contract.Plan_of_Decorate_the_Space__c = opp.Plan_of_Decorate_the_Space__c;
        contract.Plan_of_Delivery_the_Area__c = opp.Plan_of_Delivery_the_Area__c;
        contract.Plan_of_Design_Guideline__c = opp.Plan_of_Design_Guideline__c;
        contract.Plan_of_Shop_Open__c = opp.Plan_of_Shop_Open__c;
        contract.Plan_of_Signed_Contract__c = opp.Plan_of_Signed_Contract__c;
        contract.Rental_day__c = opp.Rental_Period_Day__c;
        contract.Rental_Period_Month__c = opp.Rental_Period_Month__c;
        contract.Rental_Year__c = opp.Rental_Period_Year__c;
        contract.Shop_Opening_Date__c = opp.Shop_Opening_Date__c;
        contract.Year_1_Monthly_CAM__c = opp.Year_1_Monthly_CAM__c;
        contract.Year_1_Monthly_CAM_Sq_m__c = opp.Year_1_Monthly_CAM_Sq_m__c;
        contract.Year_1_Monthly_Rent_Sq_m__c = opp.Year_1_Monthly_Rent_Sq_m__c;
        contract.Year_1_Monthly_Rental__c = opp.Year_1_Monthly_Rental__c;
        contract.Year_1_Monthly_Service__c = opp.Year_1_Monthly_Service__c;
        contract.Year_1_Monthly_Service_Sq_m__c	 = opp.Year_1_Monthly_Service_Sq_m__c;
        contract.Year_Last_Monthly_CAM__c = opp.Year_Last_Monthly_CAM__c;
        contract.Year_Last_Monthly_CAM_Sq_m__c = opp.Year_Last_Monthly_CAM_Sq_m__c;
        contract.Year_Last_Monthly_Rent_Sq_m__c = opp.Year_Last_Monthly_Rent_Sq_m__c;
        contract.Year_Last_Monthly_Rental__c = opp.Year_Last_Monthly_Rental__c;
        contract.Year_Last_Monthly_Service__c = opp.Year_Last_Monthly_Service__c;
        contract.Year_Last_Monthly_Service_Sq_m__c = opp.Year_Last_Monthly_Service_Sq_m__c;
        contract.Status__c = 'New';
        String rentType = opp.Rental_Type__c.split('_').get(0);
        RecordType rec = [SELECT Id FROM RecordType WHERE SobjectType = 'Contract__c' AND Name LIKE: rentType+'%' limit 1];
        contract.RecordTypeId = rec.Id;
        return contract;
    }

    public static ContractLineItem__c cloneContractLineItem(Contract__c contract, OpportunityLineItem__c oppLine){
        ContractLineItem__c contractLine = new ContractLineItem__c();
        contractLine.Contract__c = contract.Id;
        contractLine.LeasableArea__c = oppLine.LeasableArea__c;
        contractLine.RoomNo__c = oppLine.RoomNo__c;
        contractLine.Unit__c = oppLine.Unit__c;
        contractLine.TotalArea__c = oppLine.TotalArea__c;

        return contractLine;
    }

	/**
	 * CR Feb 2025
	 */
    public static ContractPeriod__c cloneContractPeriod(Contract__c contract, OpportunityPeriod__c oppPeriod){
        ContractPeriod__c contractPeriod = new ContractPeriod__c();
        contractPeriod.CalculationMethod__c = oppPeriod.CalculationMethod__c;
        contractPeriod.CAMMonth__c = oppPeriod.CAMMonth__c;
        contractPeriod.CAMSqmMonthCalculation__c = oppPeriod.CAMSqmMonthCalculation__c;
        contractPeriod.Contract__c = contract.Id;
        contractPeriod.EscalationRemark__c = oppPeriod.EscalationRemark__c;
        contractPeriod.EstimateGPRevenue__c = oppPeriod.EstimateGPRevernue__c;
        contractPeriod.EstimateRevenue__c = oppPeriod.EstimateRevernue__c;
        contractPeriod.IsIncludeCAM__c = oppPeriod.IsIncludeCAM__c;
        contractPeriod.IsAddedPeriod__c = oppPeriod.IsAddedPeriod__c;
        contractPeriod.IsAllSales__c = oppPeriod.IsAllSales__c;
        contractPeriod.LeasableArea__c = oppPeriod.LeasableArea__c;
        contractPeriod.MinType__c = oppPeriod.MinType__c;
        contractPeriod.IsOptionToRenew__c = oppPeriod.IsOptionToRenew__c;
        contractPeriod.PeriodFrom__c = oppPeriod.PeriodFrom__c;
        contractPeriod.PeriodTo__c = oppPeriod.PeriodTo__c;
        contractPeriod.RentOpportunityGradingDetail__c = oppPeriod.RentOpportunityGradingDetail__c;
        contractPeriod.RentPercent__c = oppPeriod.RentPercent__c;
        contractPeriod.RentMonth__c = oppPeriod.RentMonth__c;
        contractPeriod.SalesMin__c = oppPeriod.SalesMin__c;
        contractPeriod.Sequence__c = oppPeriod.Sequence__c;
        contractPeriod.ServiceOpportunityGradingDetail__c = oppPeriod.ServiceOpportunityGradingDetail__c;
        contractPeriod.ServicePercent__c = oppPeriod.ServicePercent__c;
        contractPeriod.ServiceMonth__c = oppPeriod.ServiceMonth__c;
        contractPeriod.Total__c = oppPeriod.Total__c;
        contractPeriod.TotalArea__c = oppPeriod.TotalArea__c;
		/**
		 * CR Feb 2025
		 * Changed Detail: assign new fields
		 */
		//
		//
		//
		// Changed end

        return contractPeriod;
    }

	/**
	 * CR Feb 2025
	 */
    public static ContractPrice__c cloneContractPrice(Contract__c contract, OpportunityPrice__c oppPrice){
        ContractPrice__c contractPrice = new ContractPrice__c();
        contractPrice.Area__c = oppPrice.Area__c;
        contractPrice.CalculationFormula__c = oppPrice.CalculationFormula__c;
        contractPrice.CalculationMethod__c = oppPrice.CalculationMethod__c;
        contractPrice.ConditionPurpose__c = oppPrice.ConditionPurpose__c;
        contractPrice.Contract__c = contract.Id;
        contractPrice.To__c = oppPrice.To__c;
        contractPrice.From__c = oppPrice.From__c;
        contractPrice.Installment__c = oppPrice.Installment__c;
        contractPrice.InstallmentPriceWithVAT__c = oppPrice.InstallmentPriceWithVAT__c;
        contractPrice.Measurement__c = oppPrice.Measurement__c;
        contractPrice.MeasurementAmount__c = oppPrice.MeasurementAmount__c;
        contractPrice.MeasurementType__c = oppPrice.MeasurementType__c;
        contractPrice.PaidDeposit__c = oppPrice.PaidDeposit__c;
        contractPrice.PaymentDueDate__c = oppPrice.PaymentDueDate__c;
        contractPrice.PaymentType__c = oppPrice.PaymentType__c;
        contractPrice.Price__c = oppPrice.Price__c;
        contractPrice.PriceItem__c = oppPrice.PriceItem__c;
        contractPrice.PriceVAT__c = oppPrice.PriceVAT__c;
        contractPrice.ProportionPercent__c = oppPrice.ProportionPercent__c;
        contractPrice.Rate__c = oppPrice.Rate__c;
        contractPrice.Remark__c = oppPrice.Remark__c;
        contractPrice.SubType__c = oppPrice.SubType__c;
        contractPrice.TotalPrice__c = oppPrice.TotalPrice__c;
        contractPrice.TotalPriceVAT__c = oppPrice.TotalPriceVAT__c;
        contractPrice.Unit__c = oppPrice.Unit__c;
        contractPrice.VAT__c = oppPrice.VAT__c;
		/**
		 * CR Feb 2025
		 * Changed Detail: assign new fields
		 */
		//
		//
		//
		// Changed end
        return contractPrice;
    }

    public static ContractDepositExpense__c cloneContractDepositExpense(Contract__c contract, OpportunityDepositExpense__c oppDepositExpense){
        ContractDepositExpense__c contractDepositExpense = new ContractDepositExpense__c();
        contractDepositExpense.ActualDepositCAM__c = oppDepositExpense.ActualDepositCAM__c;
        contractDepositExpense.ActualDepositRent__c = oppDepositExpense.ActualDepositRent__c;
        contractDepositExpense.ActualDepositService__c = oppDepositExpense.ActualDepositService__c;
        contractDepositExpense.CAMDeposit__c = oppDepositExpense.CAMDeposit__c;
        contractDepositExpense.CAMDepositVat__c = oppDepositExpense.CAMDepositVat__c;
        contractDepositExpense.Contract__c = contract.Id;
        contractDepositExpense.DepositInputMethod__c = oppDepositExpense.DepositInputMethod__c;
        contractDepositExpense.DepositOption__c = oppDepositExpense.DepositOption__c;
        contractDepositExpense.HasRemark__c = oppDepositExpense.HasRemark__c;
        contractDepositExpense.NumberOfInstallment__c = oppDepositExpense.NumberOfInstallment__c;
        contractDepositExpense.Price__c = oppDepositExpense.Price__c;
        contractDepositExpense.Remark__c = oppDepositExpense.Remark__c;
        contractDepositExpense.RentDeposit__c = oppDepositExpense.RentDeposit__c;
        contractDepositExpense.RentDepositVat__c = oppDepositExpense.RentDepositVat__c;
        contractDepositExpense.ServiceDeposit__c = oppDepositExpense.ServiceDeposit__c;
        contractDepositExpense.ServiceDepositVat__c = oppDepositExpense.ServiceDepositVat__c;
        contractDepositExpense.Subtype__c = oppDepositExpense.Subtype__c;
        contractDepositExpense.Type__c = oppDepositExpense.Type__c;
        contractDepositExpense.TypeGroup__c = oppDepositExpense.TypeGroup__c;

        return contractDepositExpense;
    }

    public static String cloneContractGrading(String oppGrading, String contractId, Map<String, String> mapContractPeriodIdByOppPeriodId){
        List<ContractGradingModel.Data> listContractGrading = new List<ContractGradingModel.Data>();
        List<OpportunityGradingModel.Data> listOppGrading = OpportunityGradingModel.parse(oppGrading);
        for(OpportunityGradingModel.Data eachOppGrading : listOppGrading){
            ContractGradingModel.Data contractGrading = new ContractGradingModel.Data();
            contractGrading.Id = eachOppGrading.Id;
            contractGrading.Name = eachOppGrading.Name;
            contractGrading.ContractId = contractId;
            if(mapContractPeriodIdByOppPeriodId.containsKey(eachOppGrading.OpportunityPeriodId)){
                contractGrading.ContractPeriodId = mapContractPeriodIdByOppPeriodId.get(eachOppGrading.OpportunityPeriodId);
            }else{
                contractGrading.ContractPeriodId = '';
            }
            contractGrading.GradingPeriodTo = eachOppGrading.GradingPeriodTo;
            contractGrading.GradingPeriodForm = eachOppGrading.GradingPeriodForm;
            contractGrading.GPRangeNo = eachOppGrading.GPRangeNo;
            contractGrading.GroupNo = eachOppGrading.GroupNo;
            contractGrading.FromR = eachOppGrading.FromR;
            contractGrading.ToR = eachOppGrading.ToR;
            contractGrading.GP = eachOppGrading.GP;
            contractGrading.IsIncludeCAM = eachOppGrading.IsIncludeCAM;
            contractGrading.IsGrading = eachOppGrading.IsGrading;
            contractGrading.SalesDescription = eachOppGrading.SalesDescription;
            contractGrading.ReportingRule = eachOppGrading.ReportingRule;
            contractGrading.GradingTierOption = eachOppGrading.GradingTierOption;
            listContractGrading.add(contractGrading);
        }
        String contractGradingJSON = ContractGradingModel.toString(listContractGrading);
        return contractGradingJSON;
    }

    public static String cloneContractLeaseHoldFloor(String oppLeaseHoldFloor, String contractId, Map<String, String> mapContractExpenseByOppExpenseId){
        List<ContractLeaseholdFloorModel.Data> listContractLeaseHoldFloor = new List<ContractLeaseholdFloorModel.Data>();
        List<OpportunityLeaseholdFloorModel.Data> listOppHoldFloor = OpportunityLeaseholdFloorModel.parse(oppLeaseHoldFloor);
        for(OpportunityLeaseholdFloorModel.Data eachOppHoldFloor : listOppHoldFloor){
            ContractLeaseholdFloorModel.Data contractLeaseHoldFloor = new ContractLeaseholdFloorModel.Data();
            contractLeaseHoldFloor.Id = eachOppHoldFloor.Id;
            contractLeaseHoldFloor.Name = eachOppHoldFloor.Name;
            contractLeaseHoldFloor.Floor = eachOppHoldFloor.Floor;
            contractLeaseHoldFloor.TotalPrice = eachOppHoldFloor.TotalPrice;
            if(mapContractExpenseByOppExpenseId.containsKey(eachOppHoldFloor.OpportunityDepositExpense)){
                contractLeaseHoldFloor.ContractDepositExpense = mapContractExpenseByOppExpenseId.get(eachOppHoldFloor.OpportunityDepositExpense);
            }else{
                contractLeaseHoldFloor.ContractDepositExpense = '';
            }
            contractLeaseHoldFloor.PricePerSqm = eachOppHoldFloor.PricePerSqm;
            contractLeaseHoldFloor.Area = eachOppHoldFloor.Area;
            contractLeaseHoldFloor.Measurement = eachOppHoldFloor.Measurement;
            contractLeaseHoldFloor.BuildingFloor = eachOppHoldFloor.BuildingFloor;
            contractLeaseHoldFloor.Contract = contractId;
            listContractLeaseHoldFloor.add(contractLeaseHoldFloor);
        }
        String contractLeaseHoldFloorJSON = ContractLeaseholdFloorModel.toString(listContractLeaseHoldFloor);
        return contractLeaseHoldFloorJSON;
    }

    public static String cloneContractDepositMeasurement(String oppDepositMeasurement, String contractId){
        List<ContractDepositMeasurementModel.Data> listContractDepositMeasurement = new List<ContractDepositMeasurementModel.Data>();
        List<DepositMeasurementModel.Data> listOppDepositMeasurement = DepositMeasurementModel.parse(oppDepositMeasurement);
        for(DepositMeasurementModel.Data eachOppDepositMeasurement : listOppDepositMeasurement){
            ContractDepositMeasurementModel.Data contractDepositMeasurement = new ContractDepositMeasurementModel.Data();
            contractDepositMeasurement.Id = eachOppDepositMeasurement.Id;
            contractDepositMeasurement.Name = eachOppDepositMeasurement.Name;
            contractDepositMeasurement.ContractId = contractId;
            contractDepositMeasurement.Measurement = eachOppDepositMeasurement.Measurement;
            contractDepositMeasurement.SubType = eachOppDepositMeasurement.SubType;
            contractDepositMeasurement.Price = eachOppDepositMeasurement.Price;
            listContractDepositMeasurement.add(contractDepositMeasurement);
        }
        String contractDepositMeasurementJSON = ContractDepositMeasurementModel.toString(listContractDepositMeasurement);
        return contractDepositMeasurementJSON;
    }

    public class SyncResponse{

        @AuraEnabled public String status;
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String remark;

        public SyncResponse (){}

        public SyncResponse(String inputStatus, List<Object> inputData, String inputRemark){
            status = inputStatus;
            data = inputData;
            remark = inputRemark;
        }
    }


}