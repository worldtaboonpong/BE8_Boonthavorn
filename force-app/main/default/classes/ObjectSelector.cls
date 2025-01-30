public class ObjectSelector {

    public static List<Units__c> getRentalObjectByCondition(String condition, String orderByField){
        List<Units__c> rentalObjectList = new List<Units__c>();

        if (!String.isEmpty(condition)) {
        if (!String.isEmpty(orderByField)) {
            condition += ' ORDER BY '+orderByField + ' ASC';
        }

        try{
            String queryString = 'SELECT Id, Name, Floor__c,' +
            'Floor__r.Name, Floor__r.Floor_Short_Name__c, Available_for_Sales__c, Usage_Type__c, IsRetailZone__c, ' +
            'ValidFrom__c, ValidTo__c, Units_Code__c, TotalArea__c, Building__c, Building__r.Name, Type__c, ' +
            'CurrentContract__c, CurrentContract__r.Name, CurrentContractAccountName__c, CurrentContractEndDate__c, CurrentContractShopName__c, CurrentContractStartDate__c, '+
            'LastContract__c, LastContract__r.Name,  LastContractAccountName__c, LastContractEnddate__c, LastContractShopName__c, LastContractStartDate__c ' +
            'from Units__c ' + condition;

            System.debug(queryString);
            rentalObjectList = Database.query(queryString);

        }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
        }
        }

        return rentalObjectList;
    }

    public static List<Units__c> getUnitByIdSet(Set<Id> idSet){
        try{
        List<Units__c> rentalObjectList = new List<Units__c>();
        rentalObjectList = [SELECT Id, Name, Floor__c, Units_Code__c,
                    Floor__r.Name, Available_for_Sales__c, IsRetailZone__c,
                    Usage_Type__c, ValidFrom__c, ValidTo__c,
                    TotalArea__c, Building__c, Building__r.Name
                    FROM Units__c
                    WHERE Id IN: idSet ORDER BY CreatedDate DESC];
        return rentalObjectList;

        }catch(Exception e){
        System.debug('Error : ' + e.getMessage());
        throw e;
        }
    }

    public static List<Contract__c> getContractByPeriod(Date startDate, Date endDate){
        List<Contract__c> contractList = new List<Contract__c>();

        if (startDate != null && endDate != null) {
        try{
            contractList = [SELECT Id,
                    Contract_Start_Date__c,
                    Contract_End_Date__c,
                    Name,
                    Account_Name__c,
                    Account_Name__r.Name
                    FROM Contract__c
                    WHERE ((Contract_Start_Date__c <=: startDate OR Contract_End_Date__c >=:endDate) AND
                        (Contract_Start_Date__c >=: startDate OR Contract_End_Date__c <=:endDate)) AND IsActive__c =: true];

        }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
        }
        }

        return contractList;
    }

    public static Contract__c getContractById(String contractId){
        system.debug('query contract by id');
        Contract__c targetContract = new Contract__c();

        if (contractId != null) {
        try{
            targetContract = [SELECT Id,
                        // tms_CAMOrAirService__c,
                        // tms_Account__c,
                        // tms_Account__r.Name,
                        // tms_UsageType__c,
                        // tms_Building__c,
                        // tms_Building__r.tms_BuildingCode__c,
                        // tms_Building__r.tms_BusinessEntityCode__c,
                        // tms_Building__r.tms_Company__r.tms_CompanyCode__c,
                        // tms_ContractCode__c,
                        // tms_ContractActualEndDate__c,
                        // tms_ContractEndApprovalStatus__c,
                        // tms_ParentContract__r.tms_ContractCode__c,
                        // tms_TenantAccountBuilding__r.tms_BusinessPartnerCode__c,
                        // tms_BillingAccountBuilding__r.tms_BusinessPartnerCode__c,
                        // tms_SublesseeAccountBuilding__r.tms_BusinessPartnerCode__c,
                        // tms_ShopName__r.tms_SubCategory__r.tms_SubCategoryCode__c,
                        // tms_ShopName__r.Name,
                        // tms_ShopName__r.tms_BrandCode__c,
                        // tms_CalculationMethod__c,
                        // tms_ContractEndDate__c,
                        // tms_ContractStartDate__c,
                        // tms_CalculationAndReporting__c,
                        // tms_ContractType__c,
                        // tms_HandoverDate__c,
                        // tms_OwnCashier__c,
                        // tms_OwnCreditCard__c,
                        // tms_ContractSignedDate__c,
                        // tms_TenantStartDate__c,
                        // tms_BillingStartDate__c,
                        // tms_SubleaseStartDate__c,
                        // tms_TotalRent__c,
                        // tms_TotalService__c,
                        // tms_REKey__c,
                        // tms_Building__r.Name,
                        // tms_IsApplyRentedRentalObject__c,
                        // CarriedDepositAirService__c,
                        // CarriedDepositCAM__c,
                        // CarriedDepositRent__c,
                        // CarriedDepositService__c,
                        // RemarkRentService__c,
                        // tms_SubleaseEndDate__c,
                        // tms_TerminatedSublease__c
                        CreatedDate

                        FROM Contract__c WHERE Id =: contractId limit 1];

        }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
        }
        }

        return targetContract;
    }

    public static List<Contract__c> getContractBySetId(Set<Id> contractSetId){
        List<Contract__c> targetContractList = new List<Contract__c>();

        if (contractSetId != null) {
        try{
            targetContractList = [SELECT Id,
                        // tms_Account__c,
                        // tms_Account__r.Name,
                        // tms_ContractActualEndDate__c,
                        // tms_Building__c,
                        // tms_ContractEndApprovalStatus__c,
                        // tms_UsageType__c,
                        // tms_Building__r.tms_BuildingCode__c,
                        // tms_Building__r.tms_BusinessEntityCode__c,
                        // tms_Building__r.tms_Company__r.tms_CompanyCode__c,
                        // tms_ContractCode__c,
                        // tms_ParentContract__r.tms_ContractCode__c,
                        // tms_TenantAccountBuilding__r.tms_BusinessPartnerCode__c,
                        // tms_BillingAccountBuilding__r.tms_BusinessPartnerCode__c,
                        // tms_SublesseeAccountBuilding__r.tms_BusinessPartnerCode__c,
                        // tms_ShopName__r.tms_SubCategory__r.tms_SubCategoryCode__c,
                        // tms_ShopName__r.Name,
                        // tms_ShopName__r.tms_BrandCode__c,
                        // tms_CalculationMethod__c,
                        // tms_ContractEndDate__c,
                        // tms_ContractStartDate__c,
                        // tms_CalculationAndReporting__c,
                        // tms_ContractType__c,
                        // tms_HandoverDate__c,
                        // tms_OwnCashier__c,
                        // tms_OwnCreditCard__c,
                        // tms_ContractSignedDate__c,
                        // tms_TenantStartDate__c,
                        // tms_BillingStartDate__c,
                        // tms_SubleaseStartDate__c,
                        // tms_REKey__c,
                        // tms_Building__r.Name,
                        // tms_IsApplyRentedRentalObject__c,
                        // tms_CarriedDepositAirService__c,
                        // tms_TotalRent__c,
                        // tms_TotalService__c,
                        // tms_CarriedDepositCAM__c,
                        // tms_CarriedDepositRent__c,
                        // tms_CarriedDepositService__c,
                        // tms_HandoverToTenantName__c,
                        // tms_HandoverFromTenantName__c,
                        // tms_Stage__c,
                        // tms_RemarkRentService__c,
                        // tms_SubleaseEndDate__c,
                        // tms_TerminatedSublease__c
                        CreatedDate
                        FROM Contract__c WHERE Id IN: contractSetId];

        }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
        }
        }

        return targetContractList;
    }

    public static List<OpportunityLineItem__c> getOppLineItemFromOppId(String oppId){
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();

        if (String.isNotBlank(oppId)) {
        try{
            oppLineItemList = [SELECT Id, Unit__c, Unit__r.Usage_Type__c, Unit__r.Type__c, Opportunity__c, Unit__r.Name, Unit__r.Units_Code__c, Unit__r.Floor__r.Name,
                                Unit__r.Available_for_Sales__c, Unit__r.ValidFrom__c, Unit__r.ValidTo__c, Unit__r.IsRetailZone__c, Unit__r.Floor__r.Floor_Short_Name__c,
                                TotalArea__c, LeasableArea__c, Unit__r.CurrentContractAccountName__c, Unit__r.CurrentContract__c, Unit__r.CurrentContract__r.Name,
                                Unit__r.CurrentContractStartDate__c, Unit__r.CurrentContractEndDate__c, Unit__r.CurrentContractShopName__c
                               FROM OpportunityLineItem__c WHERE Opportunity__c =: oppId];

        }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
        }
        }

        return oppLineItemList;
    }

    public static List<OpportunityLineItem__c> getOppLineItemFromOpp(Id oppId){
        List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();

        if (oppId != null) {
          try{

            oppLineItemList = [SELECT Id,
                        Name,
                        LeasableArea__c,
                        Opportunity__c,
                        Unit__c,
                        Unit__r.Name,
                        Unit__r.Units_Code__c,
                        Unit__r.Floor__r.Name,
                        Unit__r.Floor__r.Floor_Short_Name__c,
                        Unit__r.Usage_Type__c,
                        Unit__r.Type__c,
                        Unit__r.Available_for_Sales__c,
                        Unit__r.ValidFrom__c,
                        Unit__r.ValidTo__c,
                        Unit__r.Floor__c,
                        Unit__r.IsRetailZone__c,
                        Unit__r.Building__c,
                        Unit__r.Building__r.Name,
                        Unit__r.CurrentContractAccountName__c,
                        Unit__r.CurrentContract__c,
                        Unit__r.CurrentContract__r.Name,
                        Unit__r.CurrentContractStartDate__c,
                        Unit__r.CurrentContractEndDate__c,
                        Unit__r.CurrentContractShopName__c,
                        TotalArea__c,
                        UsageType__c,
                        Unit__r.LastContract__c,
                        Unit__r.LastContract__r.Name,
                        Unit__r.LastContractAccountName__c,
                        Unit__r.LastContractEnddate__c,
                        Unit__r.LastContractShopName__c,
                        Unit__r.LastContractStartDate__c

                        FROM OpportunityLineItem__c

                        WHERE Opportunity__c =: oppId];
          }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
          }

        }
        return oppLineItemList;
      }

    public static List<Measurement__c> getROMeasurementFromRO(Set<Id> rentalObjectIdSet, Date periodStartDate, Date periodEndDate){
        List<Measurement__c> rentalObjectMeasurmentList = new List<Measurement__c>();

        System.debug('periodStartDate ' + periodStartDate);
        System.debug('periodEndDate ' + periodEndDate);

        if (!rentalObjectIdSet.isEmpty()) {
        try{
            rentalObjectMeasurmentList = [SELECT Id,
                Type__c,
                IsFOC__c,
                Measurement_Area_Sqm__c,
                Valid_From_Date__c,
                Valid_To_Date__c,
                Unit_No__c,
                Unit_No__r.Units_Code__c

                FROM Measurement__c

                WHERE Unit_No__c IN: rentalObjectIdSet AND ((Valid_From_Date__c <=: periodStartDate AND Valid_To_Date__c >=: periodEndDate))];
            System.debug('result Measurement ' + rentalObjectMeasurmentList);
        }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
        }
        }

        return rentalObjectMeasurmentList;
    }

    public static List<OpportunityPeriod__c> getOppPeriodCAMOrAirServiceFromOpp(Id oppId){
        List<OpportunityPeriod__c> oppPeriod = new List<OpportunityPeriod__c>();

        if (oppId != null) {
          try{
            oppPeriod = [SELECT Id,
                      Name,
                      Opportunity__c,
                      PeriodFrom__c,
                      PeriodTo__c,
                      Total__c,
                      CalculationMethod__c,
                      Sequence__c,
                      TotalArea__c,
                      IsOptionToRenew__c

                  FROM OpportunityPeriod__c
                  WHERE Opportunity__c =: oppId AND (CalculationMethod__c =: Constant.CAL_METHOD_CAM OR CalculationMethod__c =: Constant.CAL_METHOD_AIR)
                  ORDER BY Sequence__c];
          }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
          }
        }

        return oppPeriod;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: select more fields
	 */
    public static Map<Id,List<OpportunityPrice__c>> getOppPriceFromOpp(Id oppId, List<OpportunityPeriod__c> oppPeriodList){
        List<OpportunityPrice__c> oppPrice  = new List<OpportunityPrice__c>();

        Map<Id,List<OpportunityPrice__c>> res = new Map<Id,List<OpportunityPrice__c>>();
        for (OpportunityPeriod__c eachOppPeriod : oppPeriodList) {
            res.put(eachOppPeriod.Id, new List<OpportunityPrice__c>());
        }

        if (oppId != null) {
            try{
            oppPrice = [SELECT Id,
                    Name,
                    Opportunity__c,
                    OpportunityPeriod__c,
                    From__c,
                    To__c,
                    Price__c,
                    TotalPrice__c,
                    TotalPriceVAT__c,
                    Unit__c,
                    PriceItem__c,
                    PriceVAT__c,
                    VAT__c,
                    // tms_MinType__c,
                    MeasurementType__c,
                    Measurement__c,
                    Measurement__r.Measurement_Area_Sqm__c,
                    Measurement__r.Type__c,
                    Measurement__r.IsFOC__c,
                    MasterMeasurementAmount__c,
                    MeasurementAmount__c,
                    CalculationMethod__c,
                    SubType__c,
                    ProportionPercent__c,
                    ConditionPurpose__c,
                    CalculationFormula__c

                    FROM OpportunityPrice__c
                    WHERE Opportunity__c =: oppId AND OpportunityPeriod__c IN:oppPeriodList];

            System.debug('result oppPrice Query ' + oppPrice);

            for (OpportunityPrice__c eachOppPrice: oppPrice) {
                res.get(eachOppPrice.OpportunityPeriod__c).add(eachOppPrice);
            }

            }catch (QueryException e) {
            System.debug('Error : ' + e.getMessage());
            }
        }
        return res;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: select more fields
	 */
    public static List<OpportunityPeriod__c> getOppPeriodForRentAndServiceFromOpp(Id oppId){
    List<OpportunityPeriod__c> oppPeriod = new List<OpportunityPeriod__c>();

    if (oppId != null) {
        try{
        oppPeriod = [SELECT Id,
                    Name,
                    Opportunity__c,
                    PeriodFrom__c,
                    PeriodTo__c,
                    Total__c,
                    EstimateRevernue__c,
                    CalculationMethod__c,
                    Sequence__c,
                    IsOptionToRenew__c,
                    IsIncludeCAM__c,
                    MinType__c

                FROM OpportunityPeriod__c
                WHERE Opportunity__c =: oppId AND (CalculationMethod__c =: Constant.CAL_METHOD_RENT_SERVICE)
                ORDER BY Sequence__c];
        }catch(QueryException e){
        System.debug('Error : ' + e.getMessage());
        }
    }
    return oppPeriod;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: select more fields
	 */
    public static List<OpportunityPeriod__c> getOppPeriodFromOppId(String opptyId){
        List<OpportunityPeriod__c> targetOpportunityPeriod = new List<OpportunityPeriod__c>();
        if (!String.isBlank(opptyId)) {
            try{
            targetOpportunityPeriod = [SELECT Id,
                                            Opportunity__c,
                                            PeriodFrom__c,
                                            PeriodTo__c,
                                            CAMForDocument__c,
                                            SalesMin__c,
                                            IsOptionToRenew__c,
                                            IsIncludeCAM__c,
                                            EscalationRemark__c,
                                            RentMonth__c,
                                            ServiceMonth__c,
                                            CAMMonth__c,
                                            RentOpportunityGradingDetail__c,
                                            ServiceOpportunityGradingDetail__c,
                                            Sequence__c,
                                            TotalArea__c,
                                            LeasableArea__c,
                                            Total__c,
                                            EstimateRevernue__c,
                                            RentSqmMonth__c,
                                            ServiceSqmMonth__c,
                                            CAMSqmMonth__c,
                                            CalculationMethod__c,
                                            MinType__c FROM OpportunityPeriod__c WHERE Opportunity__c =: opptyId];
            }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
            }
        }
        return targetOpportunityPeriod;
    }

	/**
	 * CR Feb 2025
	 * Changed Detail: select more fields
	 */
    public static List<OpportunityPeriod__c> getOppPeriodFromOpp(Id oppId, List<String> calculationMethod){
        List<OpportunityPeriod__c> oppPeriod = new List<OpportunityPeriod__c>();

        if (oppId != null) {
          try{
            oppPeriod = [SELECT Id,
                      Name,
                      IsAddedPeriod__c,
                      Opportunity__c,
                      PeriodFrom__c,
                      PeriodTo__c,
                      Total__c,
                      EstimateRevernue__c,
                      CalculationMethod__c,
                      Sequence__c,
                      IsOptionToRenew__c,
                      IsIncludeCAM__c,
                      MinType__c,
                      SalesMin__c,
                      TotalArea__c,
                      IsAllSales__c,
                      EscalationRemark__c,
                      ServicePercent__c,
                      RentPercent__c

                  FROM OpportunityPeriod__c
                  WHERE Opportunity__c =: oppId AND CalculationMethod__c IN: calculationMethod
                  ORDER BY Sequence__c];
          }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
          }
        }

        return oppPeriod;
      }

    public static Map<Id,Map<String,List<OpportunityGradingModel.Data>>> getOppGradingFromOpp(Id oppId, List<OpportunityPeriod__c> oppPeriodList){
        List<OpportunityGradingModel.Data> oppGrading  = new List<OpportunityGradingModel.Data>();

        Map<Id,Map<String,List<OpportunityGradingModel.Data>>> res = new Map<Id,Map<String,List<OpportunityGradingModel.Data>>>();
        Set<String> oppPeriodIdSet = new Set<String>();
        for (OpportunityPeriod__c eachOppPeriod : oppPeriodList) {
            res.put(eachOppPeriod.Id, new Map<String,List<OpportunityGradingModel.Data>>());
            oppPeriodIdSet.add((eachOppPeriod.Id));
        }

        if (oppId != null) {
            try{
            /*oppGrading = [SELECT Id,
                    Name,
                    tms_Opportunity__c,
                    tms_OpportunityPeriod__c,
                    tms_GradingPeriodTo__c,
                    tms_GradingPeriodFrom__c,
                    tms_GPRangeNo__c,
                    tms_GroupNo__c,
                    tms_From__c,
                    tms_To__c,
                    tms_GP__c,
                    tms_IsIncludeCAM__c,
                    tms_SalesDescription__c,
                    tms_ReportingRule__c,
                    tms_GradingTierOption__c

                    FROM tms_OpportunityGrading__c
                    WHERE tms_Opportunity__c =: oppId AND tms_OpportunityPeriod__c IN:oppPeriodList ORDER BY tms_GroupNo__c, tms_GPRangeNo__c];*/
            String oppGradingJson = [SELECT OpportunityGrading__c FROM Opportunity WHERE Id =: oppId].OpportunityGrading__c;
            if(oppGradingJson != null) {
                oppGrading = OpportunityGradingModel.parse(oppGradingJson);

                String key;
                for (OpportunityGradingModel.Data eachOppGrading: oppGrading) {
                    if(oppPeriodIdSet.contains(eachOppGrading.OpportunityPeriodId)) {
                        key = eachOppGrading.ReportingRule+'_'+eachOppGrading.GroupNo;

                        if(!res.get(eachOppGrading.OpportunityPeriodId).containsKey(key)) {
                            res.get(eachOppGrading.OpportunityPeriodId).put(key, new List<OpportunityGradingModel.Data>());
                        }
                        res.get(eachOppGrading.OpportunityPeriodId).get(key).add(eachOppGrading);
                    }
                }
            }

            }catch (QueryException e) {
                System.debug('Error : ' + e.getMessage());
            }
        }
        System.debug('Return Opp Grdinng' + res);
        return res;
    }

    public static List<OpportunityDepositExpense__c> getOppDepositAndExpense(Id oppId, String typeGroup){
        List<OpportunityDepositExpense__c> oppDepositAndExpense = new List<OpportunityDepositExpense__c>();

        if (oppId != null) {
            try{
            oppDepositAndExpense = [SELECT Id,
                        Name,
                        Opportunity__c,
                        TypeGroup__c,
                        Type__c,
                        Price__c,
                        NumberOfInstallment__c,
                        Remark__c,
                        SubType__c,
                        CAMDeposit__c,
                        RentDeposit__c,
                        ServiceDeposit__c,
                        NumberOfMonth__c,
                        DepositInputMethod__c,
                        DepositOption__c,
                        ActualDepositCAM__c,
                        ActualDepositRent__c,
                        ActualDepositService__c,
                        OpportunityDepositExpense__c,
                        CarriedDepositAirService__c,
                        CarriedDepositCAM__c,
                        CarriedDepositRent__c,
                        CarriedDepositService__c

                        FROM OpportunityDepositExpense__c
                        WHERE Opportunity__c =: oppId AND TypeGroup__c =: typeGroup];
            }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
            }
        }
        return oppDepositAndExpense;
    }

    public static Map<Id,List<OpportunityPrice__c>> getOppPriceFromOppExpense(Id oppId, List<OpportunityDepositExpense__c> oppExpenseList, String typeGroup){
        List<OpportunityPrice__c> oppPrice  = new List<OpportunityPrice__c>();

        Map<Id,List<OpportunityPrice__c>> res = new Map<Id,List<OpportunityPrice__c>>();
        for (OpportunityDepositExpense__c eachOppExpense : oppExpenseList) {
            res.put(eachOppExpense.Id, new List<OpportunityPrice__c>());
        }

        if (oppId != null) {
            try{
            oppPrice = [SELECT Id,
                    Name,
                    Opportunity__c,
                    OpportunityDepositExpense__c,
                    From__c,
                    To__c,
                    VAT__c,
                    PaymentDueDate__c,
                    Price__c,
                    TotalPrice__c,
                    Installment__c,
                    InstallmentPriceWithVAT__c,
                    TypeGroup__c,
                    DepositExpenseType__c,
                    Area__c,
                    Rate__c,
                    PaymentType__c,
                    SubType__c,
                    Remark__c

                    FROM OpportunityPrice__c
                    WHERE Opportunity__c =: oppId AND OpportunityDepositExpense__c IN:oppExpenseList AND TypeGroup__c =: typeGroup ORDER BY OpportunityDepositExpense__c,Installment__c];

            for (OpportunityPrice__c eachOppPrice: oppPrice) {
                res.get(eachOppPrice.OpportunityDepositExpense__c).add(eachOppPrice);
            }

            }catch (QueryException e) {
            System.debug('Error : ' + e.getMessage());
            }
        }
        return res;
    }

    public static List<ContractDepositExpense__c> getContractDepositAndExpense(Id contractId, String typeGroup){
        List<ContractDepositExpense__c> contractDepositAndExpense = new List<ContractDepositExpense__c>();

        if (contractId != null) {
            try{
            contractDepositAndExpense = [SELECT Id,
                        Name,
                        ContractDepositExpense__c,
                        Contract__c,
                        TypeGroup__c,
                        //Type__c,
                        Price__c,
                        NumberOfInstallment__c,
                        Remark__c,
                        SubType__c,
                        CAMDeposit__c,
                        RentDeposit__c,
                        ServiceDeposit__c,
                        DepositNumberOfMonth__c,
                        DepositInputMethod__c,
                        PaidDepositCAM__c,
                        PaidDepositRent__c,
                        PaidDepositService__c,
                        PaidDepositCAM_BG__c,
                        PaidDepositRent_BG__c,
                        PaidDepositService_BG__c,
                        DepositOption__c


                        FROM ContractDepositExpense__c
                        WHERE Contract__c =: contractId AND TypeGroup__c =: typeGroup];
            }catch(QueryException e){
            System.debug('Error : ' + e.getMessage());
            }
        }

        return contractDepositAndExpense;
    }



}