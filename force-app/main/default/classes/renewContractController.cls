public with sharing class renewContractController {
    @AuraEnabled
    public static Response renew(String contractId){
        String oppId;
        try{
            Contract__c contract = queryContract(contractId);
            Date newContractStartDate = contract.Contract_End_Date__c.addDays(1);
            Date newContractEndDate = contract.Contract_End_Date__c.addYears((Integer)contract.Rental_Year__c)
                                                                    .addMonths((Integer)contract.Rental_Period_Month__c)
                                                                    .addDays((Integer)contract.Rental_day__c);
            Opportunity opp = cloneOpp(contract);
            opp.Estimated_Contract_Start_Date__c = newContractStartDate;
            //opp.Estimated_Contract_End_Date__c = newContractEndDate;
            opp.Billing_Start_Date__c = newContractStartDate;
            insert(opp);
            oppId = opp.Id;

            List<OpportunityLineItem__c> listOppLine = new List<OpportunityLineItem__c>();
            List<OpportunityPeriod__c> listOppPeriod = new List<OpportunityPeriod__c>();
            List<OpportunityDepositExpense__c> listOppDepositExpense = new List<OpportunityDepositExpense__c>();
            List<OpportunityPrice__c> listOppPrice = new List<OpportunityPrice__c>();
            Map<String, String> mapOppPeriodIdByContractPeriodId = new Map<String, String>();
            Map<String, String> mapOppExpenseByConExpenseId = new Map<String, String>();

            List<ContractLineItem__c> listConLineItem = queryConLineItem(contractId);
            if(!listConLineItem.isEmpty()){
                for(ContractLineItem__c conLineItem : listConLineItem){
                    OpportunityLineItem__c oppLine = cloneOppLineItem(opp, conLineItem);
                    listOppLine.add(oppLine);
                }
                insert listOppLine;
            }

            List<ContractPeriod__c> listConPeriod = queryConPeriod(contractId);
            if(!listConPeriod.isEmpty()){
                for(ContractPeriod__c conPeriod : listConPeriod){
                    OpportunityPeriod__c oppPeriod = cloneOppPeriod(opp, conPeriod);
                    listOppPeriod.add(oppPeriod);
                }
                // insert listOppPeriod;
                Database.SaveResult[] srOppPeriodList = Database.insert(listOppPeriod, false);
                for(Integer i=0; i < srOppPeriodList.size() ;i++){
                    Database.SaveResult eachOppPeriod = srOppPeriodList.get(i);
                    if (eachOppPeriod.isSuccess()) {
                        String conPeriodId = listConPeriod[i].Id;
                        mapOppPeriodIdByContractPeriodId.put(conPeriodId, eachOppPeriod.getId());
                        System.debug('Successfully inserted Opportunity Period. Opportunity Period ID: ' + eachOppPeriod.getId());
                    }else {
                        for(Database.Error err : eachOppPeriod.getErrors()) {
                            String errorMessage = 'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
                            System.debug('errorMessage : ' + errorMessage);
                            System.debug('Opp Period fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }

            List<ContractDepositExpense__c> listConDepositExpense = queryConDepositExpense(contractId);
            if(!listConDepositExpense.isEmpty()){
                for(ContractDepositExpense__c conDepositExpense : listConDepositExpense){
                    OpportunityDepositExpense__c oppDepositExpense = cloneOppDepositExpense(opp, conDepositExpense);
                    listOppDepositExpense.add(oppDepositExpense);
                }
                Database.SaveResult[] srOppDepositExpenseList = Database.insert(listOppDepositExpense, false);
                for(Integer i=0; i < srOppDepositExpenseList.size() ;i++){
                    Database.SaveResult eachOppDepositExpense = srOppDepositExpenseList.get(i);
                    if (eachOppDepositExpense.isSuccess()) {
                        String conDepositExpenseId = listConDepositExpense[i].Id;
                        mapOppExpenseByConExpenseId.put(conDepositExpenseId, eachOppDepositExpense.getId());
                        System.debug('Successfully inserted Opportunity Deposit Expense. Opportunity Deposit Expense ID: ' + eachOppDepositExpense.getId());
                    }else {
                        for(Database.Error err : eachOppDepositExpense.getErrors()) {
                            String errorMessage = 'The following error has occurred.' + err.getStatusCode() + ': ' + err.getMessage();
                            System.debug('errorMessage : ' + errorMessage);
                            System.debug('Opportunity Deposit Expense fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }

            List<ContractPrice__c> listConPrice = queryConPrice(contractId);
            Map<String, List<OpportunityPrice__c>> mapOppPriceWithConPeriodId = new Map<String, List<OpportunityPrice__c>>();
            if(!listConPrice.isEmpty()){
                for(ContractPrice__c conPrice : listConPrice){
                    OpportunityPrice__c oppPrice = cloneOppPrice(opp, conPrice);
                    if(conPrice.ContractPeriod__c != null && mapOppPeriodIdByContractPeriodId.containsKey(conPrice.ContractPeriod__c)){
                        String oppPeriodId = mapOppPeriodIdByContractPeriodId.get(conPrice.ContractPeriod__c);
                        oppPrice.OpportunityPeriod__c = oppPeriodId;
                    }
                    if(conPrice.ContractDepositExpense__c != null && mapOppExpenseByConExpenseId.containsKey(conPrice.ContractDepositExpense__c)){
                        String oppDepositExpenseId = mapOppExpenseByConExpenseId.get(conPrice.ContractDepositExpense__c);
                        oppPrice.OpportunityDepositExpense__c = oppDepositExpenseId;
                    }
                    listOppPrice.add(oppPrice);
                }
                insert listOppPrice;
            }

            if(contract.ContractGrading__c != null){
                String oppGrading = cloneOppGrading(contract.ContractGrading__c, opp, mapOppPeriodIdByContractPeriodId);
                opp.OpportunityGrading__c = oppGrading;
            }
            if(contract.ContractLeaseholdFloor__c != null){
                String oppLeadholdFloor = cloneOppLeaseHoldFloor(contract.ContractLeaseholdFloor__c, opp.Id, mapOppExpenseByConExpenseId);
                opp.OpportunityLeaseholdFloor__c = oppLeadholdFloor;
            }
            if(contract.DepositMeasurement__c != null){
                String oppDepositMeasurement = cloneOppDepositMeasurement(contract.DepositMeasurement__c, opp.Id);
                opp.DepositMeasurement__c = oppDepositMeasurement;
            }
            update opp;

            contract.Status__c = 'Renew';
            update(contract);

        } catch(Exception ex){
            System.debug(ex);
            System.debug('Stack trace: ' + ex.getStackTraceString());
            return new Response('Error', ex.getMessage(), null);
        }
        return new Response('Success', null, oppId);
    }

    public static Opportunity cloneOpp(Contract__c con){
        Opportunity opp = new Opportunity();
        if(con.Opportunity_Name__c != null) {
            Opportunity oldOpp = queryOpp(con.Opportunity_Name__c);
            opp = oldOpp.clone(false, false, false, false);
        }
        opp.Parent_Contract__c = con.Id;
        opp.StageName = 'Quotation Preparation';
        opp.CloseDate = Date.today().addDays(Integer.valueOf(OpportunitySetting__c.getInstance().QuotationExpiryDate__c));
        return opp;
    }

    public static Contract__c queryContract(String contractId){
        Contract__c con = [
                            SELECT Id, Contract_End_Date__c, Rental_Year__c, Rental_Period_Month__c, Rental_day__c, Rental_Type__c, Opportunity_Name__c, ContractGrading__c, ContractLeaseholdFloor__c, DepositMeasurement__c
                            FROM Contract__c
                            WHERE Id = :contractId limit 1
                        ];
        return con;
    }

    public static Opportunity queryOpp(String oppId){
        Opportunity opp = [SELECT Id, Name, RecordTypeId, AccountId, Building__c, Usage_Type__c, Sales_Executive__c, ContractId, Revenue_Collected_By__c, RoomNumber__c, FloorNumber__c, Rental_Area__c,
                                  TotalDeposit__c, Leasable_Area__c, Rental_Period_Year__c, Rental_Period_Month__c, Rental_Period_Day__c, Rental_Type__c, Grace_Period_Month__c, Grace_Period_Day__c,
                                  RentAndServiceEscalationRate__c, Rent_and_Service_Escalation_Type__c, Water_meter__c, Water_Per_Unit__c, Monthly_Water__c, Electricity_Per_Unit__c,
                                  Monthly_Electricity__c, Gas_Per_Unit__c, Monthly_Gas__c, Total_Area_sq_m__c, Deposit_Month__c, Calculation_Method__c, Contract_Type__c, Shop_Name__c, Shop_Purpose__c, Category__c,
                                  TotalCAMPeriods__c, TotalPeriods__c, CAMEscalationRate__c, Additional_Expense__c, Deposit_Amount_THB__c, Rent_Percent_Last_Period__c, ServicePercentLastPeriod__c,
                                  Car_Parking__c, Number_of_Installment_Deposit__c, Internet_cable__c, Total_Other_Expense_Amount_THB__c, TotalEstimatGPRevernue__c, Grand_Total_Event__c, Grand_Total_Billboard__c,
                                  TotalMinRentServiceTHB__c, TotalMinRevenueTHB__c, Total_Event_Amount__c, Monthly_Rent_Billboard__c, Install_Billboard_Amount__c, Generate_Billboard_Amount__c, Total_Rent_billboard__c,
                                  Total_CAM_THB__c, Total_Rent_THB__c, Total_Service_THB__c, No_CAM__c, CAM_Type__c, TotalRentGP__c, TotalServiceGP__c, CAMEscalationType__c,
                                  Year_1_Monthly_CAM__c, Year_1_Monthly_CAM_Sq_m__c,
                                  Year_1_Monthly_Rental__c, Year_1_Monthly_Rent_Sq_m__c,
                                  Year_1_Monthly_Service__c, Year_1_Monthly_Service_Sq_m__c,
                                  Year_Last_Monthly_CAM__c, Year_Last_Monthly_CAM_Sq_m__c,
                                  Year_Last_Monthly_Rental__c, Year_Last_Monthly_Rent_Sq_m__c,
                                  Year_Last_Monthly_Service__c, Year_Last_Monthly_Service_Sq_m__c
                           FROM Opportunity WHERE Id =: oppId];
        return opp;
    }

    public static List<ContractLineItem__c> queryConLineItem(String conId){
        List<ContractLineItem__c> conLineItem = [   SELECT Id, LeasableArea__c, RoomNo__c, Unit__c, TotalArea__c
                                                    FROM ContractLineItem__c
                                                    WHERE Contract__c = :conId];
        return conLineItem;
    }

    public static OpportunityLineItem__c cloneOppLineItem(Opportunity opp, ContractLineItem__c conLine){
        OpportunityLineItem__c oppLine = new OpportunityLineItem__c();
        oppLine.Opportunity__c = opp.Id;
        oppLine.LeasableArea__c = conLine.LeasableArea__c;
        oppLine.RoomNo__c = conLine.RoomNo__c;
        oppLine.Unit__c = conLine.Unit__c;
        oppLine.TotalArea__c = conLine.TotalArea__c;
        return oppLine;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: query more fields
	 */
    public static List<ContractPeriod__c> queryConPeriod(String conId){
        List<ContractPeriod__c> conPeriod = [   SELECT Id, CalculationMethod__c, CAMMonth__c, CAMSqmMonthCalculation__c, EscalationRemark__c, EstimateGPRevenue__c,
                                                EstimateRevenue__c, IsIncludeCAM__c, IsAddedPeriod__c, IsAllSales__c, LeasableArea__c, MinType__c, IsOptionToRenew__c, PeriodFrom__c,
                                                PeriodTo__c, RentOpportunityGradingDetail__c, RentPercent__c, RentMonth__c, SalesMin__c, Sequence__c, ServiceOpportunityGradingDetail__c,
                                                ServicePercent__c, ServiceMonth__c, Total__c, TotalArea__c
                                                FROM ContractPeriod__c
                                                WHERE Contract__c = :conId
                                            ];
        return conPeriod;
    }

	/**
	 * CR Feb 2025
	 */
    public static OpportunityPeriod__c cloneOppPeriod(Opportunity opp, ContractPeriod__c conPeriod){
        Date newStartDate = conPeriod.PeriodFrom__c.addYears((Integer)opp.Rental_Period_Year__c)
                                                    .addMonths((Integer)opp.Rental_Period_Month__c)
                                                    .addDays((Integer)opp.Rental_Period_Day__c);
        Date newEndDate = conPeriod.PeriodTo__c.addYears((Integer)opp.Rental_Period_Year__c)
                                                .addMonths((Integer)opp.Rental_Period_Month__c)
                                                .addDays((Integer)opp.Rental_Period_Day__c);

        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c();
        oppPeriod.CalculationMethod__c = conPeriod.CalculationMethod__c;
        oppPeriod.CAMMonth__c = conPeriod.CAMMonth__c;
        oppPeriod.CAMSqmMonthCalculation__c = conPeriod.CAMSqmMonthCalculation__c;
        oppPeriod.Opportunity__c = opp.Id;
        oppPeriod.EscalationRemark__c = conPeriod.EscalationRemark__c;
        oppPeriod.EstimateGPRevernue__c = conPeriod.EstimateGPRevenue__c;
        oppPeriod.EstimateRevernue__c = conPeriod.EstimateRevenue__c;
        oppPeriod.IsIncludeCAM__c = conPeriod.IsIncludeCAM__c;
        oppPeriod.IsAddedPeriod__c = conPeriod.IsAddedPeriod__c;
        oppPeriod.IsAllSales__c = conPeriod.IsAllSales__c;
        oppPeriod.LeasableArea__c = conPeriod.LeasableArea__c;
        oppPeriod.MinType__c = conPeriod.MinType__c;
        oppPeriod.IsOptionToRenew__c = conPeriod.IsOptionToRenew__c;
        oppPeriod.PeriodFrom__c = newStartDate;
        oppPeriod.PeriodTo__c = newEndDate;
        oppPeriod.RentOpportunityGradingDetail__c = conPeriod.RentOpportunityGradingDetail__c;
        oppPeriod.RentPercent__c = conPeriod.RentPercent__c;
        oppPeriod.RentMonth__c = conPeriod.RentMonth__c;
        oppPeriod.SalesMin__c = conPeriod.SalesMin__c;
        oppPeriod.Sequence__c = conPeriod.Sequence__c;
        oppPeriod.ServiceOpportunityGradingDetail__c = conPeriod.ServiceOpportunityGradingDetail__c;
        oppPeriod.ServicePercent__c = conPeriod.ServicePercent__c;
        oppPeriod.ServiceMonth__c = conPeriod.ServiceMonth__c;
        oppPeriod.Total__c = conPeriod.Total__c;
        oppPeriod.TotalArea__c = conPeriod.TotalArea__c;
		/**
		 * CR Feb 2025
		 * Changed Detail: assign new fields
		 */
		//
		//
		//
		// Changed end

        return oppPeriod;
    }

    public static List<ContractDepositExpense__c>  queryConDepositExpense(String conId){
        List<ContractDepositExpense__c> conDepositExpense =  [  SELECT Id, ActualDepositCAM__c, ActualDepositRent__c, ActualDepositService__c, CAMDeposit__c, CAMDepositVat__c, DepositInputMethod__c,
                                                                DepositOption__c, HasRemark__c, NumberOfInstallment__c, Price__c, Remark__c, RentDeposit__c, RentDepositVat__c, ServiceDeposit__c,
                                                                ServiceDepositVat__c, Subtype__c, Type__c, TypeGroup__c
                                                                FROM ContractDepositExpense__c
                                                                WHERE Contract__c = :conId
                                                            ];
        return conDepositExpense;
    }

    public static OpportunityDepositExpense__c cloneOppDepositExpense(Opportunity opp, ContractDepositExpense__c conDepositExpense){
        OpportunityDepositExpense__c oppDepositExpense = new OpportunityDepositExpense__c();
        oppDepositExpense.ActualDepositCAM__c = conDepositExpense.ActualDepositCAM__c;
        oppDepositExpense.ActualDepositRent__c = conDepositExpense.ActualDepositRent__c;
        oppDepositExpense.ActualDepositService__c = conDepositExpense.ActualDepositService__c;
        oppDepositExpense.CAMDeposit__c = conDepositExpense.CAMDeposit__c;
        oppDepositExpense.CAMDepositVat__c = conDepositExpense.CAMDepositVat__c;
        oppDepositExpense.Opportunity__c = opp.Id;
        oppDepositExpense.DepositInputMethod__c = conDepositExpense.DepositInputMethod__c;
        oppDepositExpense.DepositOption__c = conDepositExpense.DepositOption__c;
        oppDepositExpense.HasRemark__c = conDepositExpense.HasRemark__c;
        oppDepositExpense.NumberOfInstallment__c = conDepositExpense.NumberOfInstallment__c;
        oppDepositExpense.Price__c = conDepositExpense.Price__c;
        oppDepositExpense.Remark__c = conDepositExpense.Remark__c;
        oppDepositExpense.RentDeposit__c = conDepositExpense.RentDeposit__c;
        oppDepositExpense.RentDepositVat__c = conDepositExpense.RentDepositVat__c;
        oppDepositExpense.ServiceDeposit__c = conDepositExpense.ServiceDeposit__c;
        oppDepositExpense.ServiceDepositVat__c = conDepositExpense.ServiceDepositVat__c;
        oppDepositExpense.Subtype__c = conDepositExpense.Subtype__c;
        oppDepositExpense.Type__c = conDepositExpense.Type__c;
        oppDepositExpense.TypeGroup__c = conDepositExpense.TypeGroup__c;

        return oppDepositExpense;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: query more fields
	 */
    public static List<ContractPrice__c> queryConPrice(String conId){
        List<ContractPrice__c> conPrice =    [  SELECT Id, Area__c, CalculationFormula__c, CalculationMethod__c, ConditionPurpose__c, To__c, From__c, Installment__c, InstallmentPriceWithVAT__c,
                                                Measurement__c, MeasurementAmount__c, MeasurementType__c, PaidDeposit__c, PaymentDueDate__c, PaymentType__c, Price__c, PriceItem__c, PriceVAT__c,
                                                ProportionPercent__c, Rate__c, Remark__c, SubType__c, TotalPrice__c, TotalPriceVAT__c, Unit__c, VAT__c, ContractPeriod__c, ContractDepositExpense__c
                                                FROM ContractPrice__c
                                                WHERE Contract__c = :conId
                                            ];
        return conPrice;
    }

	/**
	 * CR Feb 2025
	 */
    public static OpportunityPrice__c cloneOppPrice(Opportunity opp, ContractPrice__c conPrice){
        Date newStartDate = conPrice.From__c.addYears((Integer)opp.Rental_Period_Year__c)
                                            .addMonths((Integer)opp.Rental_Period_Month__c)
                                            .addDays((Integer)opp.Rental_Period_Day__c);
        Date newEndDate = conPrice.To__c.addYears((Integer)opp.Rental_Period_Year__c)
                                        .addMonths((Integer)opp.Rental_Period_Month__c)
                                        .addDays((Integer)opp.Rental_Period_Day__c);

        OpportunityPrice__c oppPrice = new OpportunityPrice__c();
        oppPrice.Area__c = conPrice.Area__c;
        oppPrice.CalculationFormula__c = conPrice.CalculationFormula__c;
        oppPrice.CalculationMethod__c = conPrice.CalculationMethod__c;
        oppPrice.ConditionPurpose__c = conPrice.ConditionPurpose__c;
        oppPrice.Opportunity__c = opp.Id;
        oppPrice.From__c = newStartDate;
        oppPrice.To__c = newEndDate;
        oppPrice.Installment__c = conPrice.Installment__c;
        oppPrice.InstallmentPriceWithVAT__c = conPrice.InstallmentPriceWithVAT__c;
        oppPrice.Measurement__c = conPrice.Measurement__c;
        oppPrice.MeasurementAmount__c = conPrice.MeasurementAmount__c;
        oppPrice.MeasurementType__c = conPrice.MeasurementType__c;
        oppPrice.PaidDeposit__c = conPrice.PaidDeposit__c;
        oppPrice.PaymentDueDate__c = conPrice.PaymentDueDate__c;
        oppPrice.PaymentType__c = conPrice.PaymentType__c;
        oppPrice.Price__c = conPrice.Price__c;
        oppPrice.PriceItem__c = conPrice.PriceItem__c;
        oppPrice.PriceVAT__c = conPrice.PriceVAT__c;
        oppPrice.ProportionPercent__c = conPrice.ProportionPercent__c;
        oppPrice.Rate__c = conPrice.Rate__c;
        oppPrice.Remark__c = conPrice.Remark__c;
        oppPrice.SubType__c = conPrice.SubType__c;
        oppPrice.TotalPrice__c = conPrice.TotalPrice__c;
        oppPrice.TotalPriceVAT__c = conPrice.TotalPriceVAT__c;
        oppPrice.Unit__c = conPrice.Unit__c;
        oppPrice.VAT__c = conPrice.VAT__c;
		/**
		 * CR Feb 2025
		 * Changed Detail: assign new fields
		 */
		//
		//
		//
		// Changed end

        return oppPrice;
    }

    public static String cloneOppGrading(String conGrading, Opportunity opp, Map<String, String> mapOppPeriodIdByConPeriodId){
        List<OpportunityGradingModel.Data> listOppGrading = new List<OpportunityGradingModel.Data>();
        List<ContractGradingModel.Data> listConGrading = ContractGradingModel.parse(conGrading);
        Date newStartDate;
        Date newEndDate;
        for(ContractGradingModel.Data eachConGrading : listConGrading){
            newStartDate = eachConGrading.GradingPeriodForm.addYears((Integer)opp.Rental_Period_Year__c)
                                                            .addMonths((Integer)opp.Rental_Period_Month__c)
                                                            .addDays((Integer)opp.Rental_Period_Day__c);
            newEndDate = eachConGrading.GradingPeriodTo.addYears((Integer)opp.Rental_Period_Year__c)
                                                        .addMonths((Integer)opp.Rental_Period_Month__c)
                                                        .addDays((Integer)opp.Rental_Period_Day__c);
            OpportunityGradingModel.Data oppGrading = new OpportunityGradingModel.Data();
            oppGrading.Id = eachConGrading.Id;
            oppGrading.Name = eachConGrading.Name;
            oppGrading.OpportunityId = opp.Id;
            if(mapOppPeriodIdByConPeriodId.containsKey(eachConGrading.ContractPeriodId)){
                oppGrading.OpportunityPeriodId = mapOppPeriodIdByConPeriodId.get(eachConGrading.ContractPeriodId);
            }else{
                oppGrading.OpportunityPeriodId = '';
            }
            oppGrading.GradingPeriodForm = newStartDate;
            oppGrading.GradingPeriodTo = newEndDate;
            oppGrading.GPRangeNo = eachConGrading.GPRangeNo;
            oppGrading.GroupNo = eachConGrading.GroupNo;
            oppGrading.FromR = eachConGrading.FromR;
            oppGrading.ToR = eachConGrading.ToR;
            oppGrading.GP = eachConGrading.GP;
            oppGrading.IsIncludeCAM = eachConGrading.IsIncludeCAM;
            oppGrading.IsGrading = eachConGrading.IsGrading;
            oppGrading.SalesDescription = eachConGrading.SalesDescription;
            oppGrading.ReportingRule = eachConGrading.ReportingRule;
            oppGrading.GradingTierOption = eachConGrading.GradingTierOption;
            listOppGrading.add(oppGrading);
        }
        String oppGradingJSON = OpportunityGradingModel.toString(listOppGrading);
        return oppGradingJSON;
    }

    public static String cloneOppLeaseHoldFloor(String conLeaseHoldFloor, String opId, Map<String, String> mapOppExpenseByConExpenseId){
        List<OpportunityLeaseholdFloorModel.Data> listOppLeaseHoldFloor = new List<OpportunityLeaseholdFloorModel.Data>();
        List<ContractLeaseholdFloorModel.Data> listConHoldFloor = ContractLeaseholdFloorModel.parse(conLeaseHoldFloor);
        for(ContractLeaseholdFloorModel.Data eachConHoldFloor : listConHoldFloor){
            OpportunityLeaseholdFloorModel.Data oppLeaseHoldFloor = new OpportunityLeaseholdFloorModel.Data();
            oppLeaseHoldFloor.Id = eachConHoldFloor.Id;
            oppLeaseHoldFloor.Name = eachConHoldFloor.Name;
            oppLeaseHoldFloor.Floor = eachConHoldFloor.Floor;
            oppLeaseHoldFloor.TotalPrice = eachConHoldFloor.TotalPrice;
            if(mapOppExpenseByConExpenseId.containsKey(eachConHoldFloor.ContractDepositExpense)){
                oppLeaseHoldFloor.OpportunityDepositExpense = mapOppExpenseByConExpenseId.get(eachConHoldFloor.ContractDepositExpense);
            }else{
                oppLeaseHoldFloor.OpportunityDepositExpense = '';
            }
            oppLeaseHoldFloor.PricePerSqm = eachConHoldFloor.PricePerSqm;
            oppLeaseHoldFloor.Area = eachConHoldFloor.Area;
            oppLeaseHoldFloor.Measurement = eachConHoldFloor.Measurement;
            oppLeaseHoldFloor.BuildingFloor = eachConHoldFloor.BuildingFloor;
            oppLeaseHoldFloor.Opportunity = opId;
            listOppLeaseHoldFloor.add(oppLeaseHoldFloor);
        }
        String oppLeaseHoldFloorJSON = OpportunityLeaseholdFloorModel.toString(listOppLeaseHoldFloor);
        return oppLeaseHoldFloorJSON;
    }

    public static String cloneOppDepositMeasurement(String conDepositMeasurement, String oppId){
        List<DepositMeasurementModel.Data> listOppDepositMeasurement = new List<DepositMeasurementModel.Data>();
        List<ContractDepositMeasurementModel.Data> listConDepositMeasurement = ContractDepositMeasurementModel.parse(conDepositMeasurement);
        for(ContractDepositMeasurementModel.Data eachConDepositMeasurement : listConDepositMeasurement){
            DepositMeasurementModel.Data oppDepositMeasurement = new DepositMeasurementModel.Data();
            oppDepositMeasurement.Id = eachConDepositMeasurement.Id;
            oppDepositMeasurement.Name = eachConDepositMeasurement.Name;
            oppDepositMeasurement.OpportunityId = oppId;
            oppDepositMeasurement.Measurement = eachConDepositMeasurement.Measurement;
            oppDepositMeasurement.SubType = eachConDepositMeasurement.SubType;
            oppDepositMeasurement.Price = eachConDepositMeasurement.Price;
            listOppDepositMeasurement.add(oppDepositMeasurement);
        }
        String oppDepositMeasurementJSON = DepositMeasurementModel.toString(listOppDepositMeasurement);
        return oppDepositMeasurementJSON;
    }

    public class Response{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public String oppId;

        public Response(String inputStatus, String inputMsg, String inputId){
            status = inputStatus;
            message = inputMsg;
            oppId = inputId;
        }
    }
}