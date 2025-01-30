public without sharing class QuotationPrepController {
    public QuotationPrepController() {

    }

    @TestVisible
    private class MessageDialog
    {
            @AuraEnabled public MessageDialogAuraWrapper messageAura;
            public MessageDialog()
            {
                    this.messageAura = new MessageDialogAuraWrapper ('', false, false);
            }
            public MessageDialog(MessageDialogAuraWrapper messageAura)
            {
                    this.messageAura = messageAura;
            }
    }

    @AuraEnabled
    public static String getRecordTypeName(Id recordId){
        System.debug('getRecordTypeName recordId: ' + recordId);
        try {
            return [SELECT Id, RecordType.Name FROM Opportunity WHERE Id =: recordId]?.RecordType.Name ;
        } catch (Exception e) {
            System.debug('getOpportunityRecordType exception has occurred: ' + e.getMessage());
            throw e;
        }
    }

    @AuraEnabled
    public static String getOppDetail(Id recordId){

        Opportunity opp = [SELECT Id,
                                Name,
                                Building__r.Name,
                                Building__c,
                                Estimated_Contract_Start_Date__c,
                                Estimated_Contract_End_Date__c,
                                Total_Area_sq_m__c,
                                Leasable_Area__c,
                                Calculation_Method__c,
                                Contract_Type__c,
                                Rental_Type__c,
                                // tms_CAMOrAirService__c,
                                CAMEscalationType__c,
                                CAMEscalationRate__c,
                                Usage_Type__c,
                                OptionToRenewYear__c,
                                OptiontoRenewMonth__c,
                                Deposit_Month__c,
                                Parent_Contract__c,
                                RentAndServiceEscalationType__c,
                                RentAndServiceEscalationRate__c,
                                StageName,
                                OptionToRenewwithPricing__c,
                                // tms_IsApplyRentedRentalObject__c,
                                FloorNumber__c,
                                RoomNumber__c,
                                // tms_OwnCashier__c,
                                No_CAM__c,
                                Total_Rent_THB__c,
                                Total_Service_THB__c,
                                Is_Renew__c,
                                // tms_SalesforCalculation__c,
                                TotalPeriods__c,
                                // tms_ParentContract__r.tms_CAMOrAirService__c,
                                Quotation_Language__c,
                                // tms_ParentContract__r.tms_NoCAMAirService__c,
                                // tms_ShopName__r.tms_SubCategory__r.tms_SubCategoryCode__c,
                                // tms_LongLeasePriceOption__c,
                                // tms_IsMigrate__c,
                                // tms_GPTierYearly__c,
                                Is_Period_Date_Changed__c,
                                Rental_Period_Year__c,
                                Rental_Period_Month__c,
                                ElectricityFormula__c,
                                WaterFormula__c,
                                GasFormula__c

                        FROM Opportunity WHERE Id =: recordId];

        Map<String,String> contractTypeMap = getPicklistOption('Opportunity', 'Contract_Type__c');
        List<String> contractTypeKey = new List<String>(contractTypeMap.keySet());

        QuotationComponentDataWrapper.OppUIWrapper uiWrapper = new QuotationComponentDataWrapper.OppUIWrapper(
                                                                        opp.StageName,
                                                                        opp.Name,
                                                                        opp.Building__r.Name,
                                                                        opp.Estimated_Contract_Start_Date__c,
                                                                        opp.Estimated_Contract_End_Date__c,
                                                                        opp.Total_Area_sq_m__c,
                                                                        opp.Leasable_Area__c,
                                                                        opp.Calculation_Method__c,
                                                                        (opp.Contract_Type__c!=null)?contractTypeMap.get(opp.Contract_Type__c):contractTypeMap.get(contractTypeKey.get(0)),
                                                                        'CAM',
                                                                        opp.CAMEscalationType__c,
                                                                        opp.CAMEscalationRate__c,
                                                                        opp.RentAndServiceEscalationType__c,
                                                                        opp.RentAndServiceEscalationRate__c,
                                                                        opp.Usage_Type__c,
                                                                        opp.OptionToRenewYear__c,
                                                                        opp.OptiontoRenewMonth__c,
                                                                        opp.Deposit_Month__c,
                                                                        opp.Parent_Contract__c,
                                                                        false
                                                                        );
        uiWrapper.oppId = opp.Id;
        uiWrapper.rentType = opp.Rental_Type__c;
        uiWrapper.contractTypeValue = opp.Contract_Type__c;
        uiWrapper.buildingId = opp.Building__c;
        uiWrapper.optionToRenewWithPrince = opp.OptionToRenewwithPricing__c;
        //uiWrapper.isRentedRO = (opp.tms_IsApplyRentedRentalObject__c!=null)?opp.tms_IsApplyRentedRentalObject__c:false;
        uiWrapper.isRentedRO = false;
        uiWrapper.floorNumber = opp.FloorNumber__c;
        uiWrapper.roomNumber = opp.RoomNumber__c;
        uiWrapper.recordtypeName = [SELECT Id, RecordType.Name FROM Opportunity WHERE Id =: recordId]?.RecordType.Name ;
        uiWrapper.isNoCAM = opp.No_CAM__c;
        uiWrapper.totalRent = (opp.Total_Rent_THB__c != null)?opp.Total_Rent_THB__c:0;
        uiWrapper.totalService = (opp.Total_Service_THB__c != null)?opp.Total_Service_THB__c:0;
        //uiWrapper.isRetailzone = (uiWrapper.recordtypeName == 'Retail Zone Process')?true:false;
        uiWrapper.isRetailzone = false;
        uiWrapper.isAllowChangeOptionToRenew = (opp.Is_Renew__c && opp.Parent_Contract__c != null)?true:false;
        uiWrapper.isRenew = opp.Is_Renew__c;
        //uiWrapper.isAllowLongLeaseChangePeriod = (uiWrapper.leaseType == 'Long-Term' && opp.tms_LongLeasePriceOption__c == 'ระบุราคาปีปฏิทินแรก' && uiWrapper.parentContractId != null && uiWrapper.isRenew == true)? true : false;
        uiWrapper.isAllowLongLeaseChangePeriod = false;
        //uiWrapper.oppSalesForCalculation = opp.tms_SalesforCalculation__c;
        uiWrapper.totalQuotationPeriod = (opp.TotalPeriods__c != null)?opp.TotalPeriods__c:0;
        //uiWrapper.parentContractCAMOrAirService = opp.tms_ParentContract__r.tms_CAMOrAirService__c;
        uiWrapper.parentContractCAMOrAirService = 'CAM';
        uiWrapper.quotationLanguage = opp.Quotation_Language__c;
        //uiWrapper.parentContractIsNoCAM = opp.tms_ParentContract__r.tms_NoCAMAirService__c;
        uiWrapper.parentContractIsNoCAM = false;
        //uiWrapper.oppSupcategoryCode = opp.tms_ShopName__r.tms_SubCategory__r.tms_SubCategoryCode__c;
        //uiWrapper.longleaseType = opp.tms_LongLeasePriceOption__c;
        uiWrapper.longleaseType = 'ระบุราคาทุกปีตามปีสัญญา';
        //uiWrapper.isMigration = Utility.isValidateMigrationProfile(opp);
        uiWrapper.isMigration = false;
        //uiWrapper.isGPYearlyTier = (opp.tms_GPTierYearly__c && uiWrapper.pricingType == 'GP');
        uiWrapper.isGPYearlyTier = false;
        uiWrapper.isRenewChangeOppPeriod = opp.Is_Period_Date_Changed__c;
        uiWrapper.yearRange = opp.Rental_Period_Year__c;
        uiWrapper.monthRange = opp.Rental_Period_Month__c;
        uiWrapper.defaultElectricity = opp.ElectricityFormula__c;
        uiWrapper.defaultWater = opp.WaterFormula__c;
        uiWrapper.defaultGas = opp.GasFormula__c;

        Date endDatePeriod = opp.Estimated_Contract_End_Date__c;
        Date startDatePeriod = opp.Estimated_Contract_Start_Date__c;
        Date theThirdYear;

        if(uiWrapper.yearRange < 3){
            theThirdYear = endDatePeriod;
        }else{
            startDatePeriod = startDatePeriod.addYears(3);
            startDatePeriod = startDatePeriod.addDays(-1);
            theThirdYear = startDatePeriod;
        }
        uiWrapper.thirdYearOfPeriod = theThirdYear;

        List<QuotationPreparationScreenMaster__c> screenSetting  = [SELECT
                                                                            Type__c,
                                                                            Subtype__c,
                                                                            SpecificMeasurement__c,
                                                                            Format__c
                                                                        FROM QuotationPreparationScreenMaster__c
                                                                        WHERE
                                                                            Format__c =: Constant.DEP_EXP_TYPE_LEASEHOLD AND
                                                                            ScreentoDisplay__c =: Constant.TYPE_OTHER AND
                                                                            RentalType__c =: opp.Rental_Type__c AND
                                                                            SpecificMeasurement__c !=: null];

        List<String> specialValue = new List<String>();
        for (QuotationPreparationScreenMaster__c eachScreenMaster : screenSetting) {
             specialValue.add(eachScreenMaster.Type__c);
        }
        uiWrapper.spetialOtherTypePicklist = specialValue;

        if (opp.OptionToRenewYear__c != null || opp.OptiontoRenewMonth__c != null) {
            uiWrapper.renewStartDate = (opp.Estimated_Contract_End_Date__c != null)?(opp.Estimated_Contract_End_Date__c).addDays(1):null;
            uiWrapper.renewEndDate = (uiWrapper.renewStartDate!=null)?Date.newInstance((opp.OptionToRenewYear__c != null)?(uiWrapper.renewStartDate.year()+(Integer)opp.OptionToRenewYear__c):(uiWrapper.renewStartDate.year()),(opp.OptiontoRenewMonth__c != null)?(uiWrapper.renewStartDate.month()+(Integer)opp.OptiontoRenewMonth__c):(uiWrapper.renewStartDate.month()), (Integer)uiWrapper.renewStartDate.day()-1):null;
        }


        String jsonResult = JSON.serialize(uiWrapper);
        return jsonResult;
    }

    @AuraEnabled
    public static Map<String,String> getPicklistOption(String objectName, String picklistField){

        List<SelectOption> lstPickvals = new List<SelectOption>();
        lstPickvals = Utility.getPicklistValues(objectName, picklistField);
        Map<String,String> options = new Map<String,String>();
        for(SelectOption eachOption : lstPickvals)
        {
            System.debug(eachOption.getLabel() +' '+ eachOption.getValue());
            options.put(eachOption.getValue(), eachOption.getLabel());
        }

        return options;
    }

	// #region Get Saved RO
    @AuraEnabled
    public static String getSavedSelectedRO(Id recordId, Date opp_ContractStartDate, Date opp_ContractEndDate){
        List<OpportunityLineItem__c> oppLineItemList = ObjectSelector.getOppLineItemFromOpp(recordId);
        List<QuotationComponentDataWrapper.RentalObjectClass> rentalObjectWrapper = new List<QuotationComponentDataWrapper.RentalObjectClass>();
        String jsonResult;

        if (!oppLineItemList.isEmpty()) {

            Set<Id> roIdSet = getROIdSetFromOppLineItem(oppLineItemList);
            Set<Id> rentedRoomIdSet = new Set<Id>();
            List<ContractLineItem__c> contractLineItemList = [SELECT Id,
                                                                Name,
                                                                LeasableArea__c,
                                                                Contract__c,
                                                                Contract__r.Contract_Start_Date__c,
                                                                Contract__r.Contract_End_Date__c,
                                                                Unit__c,
                                                                Unit__r.Name,
                                                                Unit__r.Units_Code__c,
                                                                Unit__r.Floor__r.Name,
                                                                Unit__r.Usage_Type__c,
                                                                Unit__r.Available_for_Sales__c,
                                                                Unit__r.ValidFrom__c,
                                                                Unit__r.ValidTo__c,
                                                                Unit__r.Floor__c,
                                                                Unit__r.IsRetailZone__c,
                                                                Unit__r.Building__c,
                                                                Unit__r.Building__r.Name

                                                                FROM ContractLineItem__c WHERE Unit__c IN: roIdSet];


            Set<Id> contractIdSet = new Set<Id>();

            for (ContractLineItem__c eachContractLineItem : contractLineItemList) {
                if (eachContractLineItem!=null) {
                    contractIdSet.add(eachContractLineItem.Contract__c);
                }
            }

            System.debug('contractIdSet '+ contractIdSet);

            Map<Id,Contract__c> contractToCheck = new Map<Id,Contract__c> ([SELECT Id,
                                                                            Contract_Start_Date__c,
                                                                            Contract_End_Date__c,
                                                                            Name,
                                                                            Account_Name__c,
                                                                            Account_Name__r.Name
                                                                            FROM Contract__c WHERE Id IN: contractIdSet AND IsActive__c =: true ORDER BY Contract_Start_Date__c]);

            System.debug('contractToCheck '+ contractToCheck);
            if (!contractLineItemList.isEmpty()) {

                for (ContractLineItem__c eachContractLineItem : contractLineItemList) {
                    if (
                            (
                                (
                                    opp_ContractStartDate >= eachContractLineItem.Contract__r.Contract_Start_Date__c
                                        &&
                                    opp_ContractEndDate <= eachContractLineItem.Contract__r.Contract_End_Date__c
                                )   ||
                                (
                                    opp_ContractStartDate >= eachContractLineItem.Contract__r.Contract_Start_Date__c
                                        &&
                                    opp_ContractStartDate <= eachContractLineItem.Contract__r.Contract_End_Date__c
                                )   ||
                                (
                                    opp_ContractEndDate >= eachContractLineItem.Contract__r.Contract_Start_Date__c
                                        &&
                                    opp_ContractEndDate <= eachContractLineItem.Contract__r.Contract_End_Date__c
                                )
                            )
                    ) {
                        rentedRoomIdSet.add(eachContractLineItem.Unit__c);
                    }
                }
            }

            Map<Id, Contract__c> contractedRO = getContractedROMap(contractToCheck, contractLineItemList, opp_ContractStartDate, opp_ContractEndDate);
            Map<Id,Map<String,QuotationComponentDataWrapper.ROMeasurementClass>> rentalObjectMesurmentMap =  getMeasurementTypeAreaMap(roIdSet, opp_ContractStartDate, opp_ContractEndDate);

            List<QuotationComponentDataWrapper.ROMeasurementClass> measurementClass ;


            Decimal leasableArea;
            Decimal measurement;
            String meterList;
            Map<String,String> usageTypeMap = getPicklistOption('Units__c', 'Usage_Type__c');
            Map<String,String> roTypeMap = getPicklistOption('Units__c', 'Type__c');


            for (OpportunityLineItem__c eachOppLineItem : oppLineItemList) {
                measurementClass = new List<QuotationComponentDataWrapper.ROMeasurementClass>();
                leasableArea = 0;
                measurement = 0;

                if (!rentalObjectMesurmentMap.isEmpty() && !rentalObjectMesurmentMap.get(eachOppLineItem.Unit__c).isEmpty()) {

                    for ( String measurementKey : rentalObjectMesurmentMap.get(eachOppLineItem.Unit__c).keySet()) {
                        measurement += rentalObjectMesurmentMap.get(eachOppLineItem.Unit__c).get(measurementKey).measurementArea;
                        measurementClass.add(rentalObjectMesurmentMap.get(eachOppLineItem.Unit__c).get(measurementKey));

                        if (!rentalObjectMesurmentMap.get(eachOppLineItem.Unit__c).get(measurementKey).isFOC) {
                            leasableArea += rentalObjectMesurmentMap.get(eachOppLineItem.Unit__c).get(measurementKey).measurementArea;
                        }
                    }
                }

                System.debug('rentedRoomIdSet '+ rentedRoomIdSet);

                QuotationComponentDataWrapper.RentalObjectClass eachWrpperClass  = new QuotationComponentDataWrapper.RentalObjectClass(
                                                                                        eachOppLineItem.Unit__c,
                                                                                        eachOppLineItem.Unit__r.Name,
                                                                                        eachOppLineItem.Unit__r.Floor__r.Name,
                                                                                        measurement,
                                                                                        usageTypeMap.get(eachOppLineItem.Unit__r.Usage_Type__c),
                                                                                        eachOppLineItem.Unit__r.Available_for_Sales__c,
                                                                                        eachOppLineItem.Unit__r.ValidFrom__c,
                                                                                        meterList,
                                                                                        leasableArea,
                                                                                        measurement,
                                                                                        eachOppLineItem.Unit__r.ValidTo__c,
                                                                                        (rentedRoomIdSet.contains(eachOppLineItem.Unit__c))?true:false,
                                                                                        measurementClass,
                                                                                        null,
                                                                                        (rentedRoomIdSet.contains(eachOppLineItem.Unit__c))?true:false,
                                                                                        eachOppLineItem.Unit__r.CurrentContractAccountName__c,
                                                                                        eachOppLineItem.Unit__r.CurrentContract__r.Name,
                                                                                        (eachOppLineItem.Unit__r.CurrentContractEndDate__c != null)?Date.valueof(eachOppLineItem.Unit__r.CurrentContractEndDate__c):null,
                                                                                        '',//eachOppLineItem.Unit__r.tms_RequestHeader__c,
                                                                                        eachOppLineItem.Unit__r.Floor__c,
                                                                                        '',//eachOppLineItem.Unit__r.tms_LocationOnFloor__c,
                                                                                        '',//eachOppLineItem.Unit__r.tms_LocationOnFloor__r.Name,
                                                                                        eachOppLineItem.Unit__r.IsRetailZone__c,
                                                                                        eachOppLineItem.Unit__r.Usage_Type__c,
                                                                                        false, //eachOppLineItem.Unit__r.tms_IsSPWGSublease__c,
                                                                                        eachOppLineItem.Unit__r.Building__c,
                                                                                        eachOppLineItem.Unit__r.Building__r.Name
                                                                                        );

                eachWrpperClass.roCode = eachOppLineItem.Unit__r.Units_Code__c;
                eachWrpperClass.oppLineId = eachOppLineItem.Id;
                eachWrpperClass.currentShopname = eachOppLineItem.Unit__r.CurrentContractShopName__c;
                eachWrpperClass.isToDeleteRecord = false;
                eachWrpperClass.floorShortName = eachOppLineItem.Unit__r.Floor__r.Floor_Short_Name__c;
                eachWrpperClass.currentContractIdLink = (eachOppLineItem.Unit__r.CurrentContract__c != null)?'/'+eachOppLineItem.Unit__r.CurrentContract__c: '';
                eachWrpperClass.oppLineTotalArea = eachOppLineItem.TotalArea__c;
                eachWrpperClass.oppLineLeasableArea = eachOppLineItem.LeasableArea__c;
                eachWrpperClass.lastContractId = eachOppLineItem.Unit__r.LastContract__c;
                eachWrpperClass.lastContractName = (eachOppLineItem.Unit__r.LastContract__c !=null)? eachOppLineItem.Unit__r.LastContract__r.Name : '';
                eachWrpperClass.lastContractURL = (eachOppLineItem.Unit__r.LastContract__c !=null)? URL.getSalesforceBaseUrl().toExternalForm() + '/'+ eachWrpperClass.lastContractId : '';
                eachWrpperClass.lastContractAccountName  = eachOppLineItem.Unit__r.LastContractAccountName__c;
                eachWrpperClass.lastContractShopName = eachOppLineItem.Unit__r.LastContractShopName__c;
                eachWrpperClass.lastContractEndDate = eachOppLineItem.Unit__r.LastContractEnddate__c;
                eachWrpperClass.lastContractStartDate = eachOppLineItem.Unit__r.LastContractStartDate__c;
                eachWrpperClass.roType = roTypeMap.get(eachOppLineItem.Unit__r.Type__c);
                // eachWrpperClass.requestName = (eachOppLineItem.Unit__r.tms_RequestHeader__c != null)? eachOppLineItem.Unit__r.tms_Request__r.Name : '';
                System.debug('eachWrpperClass'+eachWrpperClass);
                rentalObjectWrapper.add(eachWrpperClass);
            }

            jsonResult = JSON.serialize(rentalObjectWrapper);
        }

        return jsonResult;
    }

    public static Set<Id> getROIdSetFromOppLineItem(List<OpportunityLineItem__c> oppLineItemList){

        Set<Id> roIdSet = new Set<Id>();
        for (OpportunityLineItem__c eachOppLineItem : oppLineItemList) {
            roIdSet.add(eachOppLineItem.Unit__c);
        }

        return roIdSet;
    }

    public static Map<Id, Contract__c> getContractedROMap(Map<Id,Contract__c> contractMap, List<ContractLineItem__c> contractLineItemList, Date oppContractStartDate, Date oppContractEndDate){
        Map<Id, Contract__c> res = new Map<Id, Contract__c>();

        if (contractMap!=null && contractLineItemList!=null) {
            for (ContractLineItem__c eachContractLineItem : contractLineItemList){

                if (contractMap.get(eachContractLineItem.Contract__c) != null) {
                    if (
                            (
                                (
                                    oppContractStartDate >= contractMap.get(eachContractLineItem.Contract__c).Contract_Start_Date__c
                                        &&
                                    oppContractEndDate <= contractMap.get(eachContractLineItem.Contract__c).Contract_End_Date__c
                                )   ||
                                (
                                    oppContractStartDate >= contractMap.get(eachContractLineItem.Contract__c).Contract_Start_Date__c
                                        &&
                                    oppContractStartDate <= contractMap.get(eachContractLineItem.Contract__c).Contract_End_Date__c
                                )   ||
                                (
                                    oppContractEndDate >= contractMap.get(eachContractLineItem.Contract__c).Contract_Start_Date__c
                                        &&
                                    oppContractEndDate <= contractMap.get(eachContractLineItem.Contract__c).Contract_End_Date__c
                                )
                            )
                        ) {
                    }
                    res.put(eachContractLineItem.Unit__c, contractMap.get(eachContractLineItem.Contract__c));
                }
            }
        }
        return res;
    }

    public static Map<Id,Map<String,QuotationComponentDataWrapper.ROMeasurementClass>> getMeasurementTypeAreaMap(List<Units__c> rentalObjectList, Date opp_ContractStartDate, Date opp_ContractEndDate){
        Set<Id> rentalObjectIdSet = new Set<Id>();
        for(Units__c ro : rentalObjectList) {
            rentalObjectIdSet.add(ro.Id);
        }
        return getMeasurementTypeAreaMap(rentalObjectIdSet, opp_ContractStartDate, opp_ContractEndDate);
    }

    public static Map<Id,Map<String,QuotationComponentDataWrapper.ROMeasurementClass>> getMeasurementTypeAreaMap(Set<Id> rentalObjectIdSet, Date opp_ContractStartDate, Date opp_ContractEndDate){

        Map<String,QuotationComponentDataWrapper.ROMeasurementClass> measurementMap = new Map<String,QuotationComponentDataWrapper.ROMeasurementClass>();
        Map<Id,Map<String,QuotationComponentDataWrapper.ROMeasurementClass>> result = new Map<Id,Map<String,QuotationComponentDataWrapper.ROMeasurementClass>>();
        Decimal measurementArea = 0;

        if (!rentalObjectIdSet.isEmpty()) {

            List<Measurement__c> rentalObjectMeasurementList = ObjectSelector.getROMeasurementFromRO(rentalObjectIdSet, opp_ContractStartDate,opp_ContractEndDate);
            QuotationComponentDataWrapper.ROMeasurementClass roMeasurementWrapper;

            for (Id eachROId : rentalObjectIdSet) {
                result.put(eachROId, new Map<String,QuotationComponentDataWrapper.ROMeasurementClass>());
            }
            // String oldROId = rentalObjectMeasurementList.get(0).tms_RentalObject__c;

            for (Measurement__c eachROMeasurment : rentalObjectMeasurementList) {
                measurementMap = new Map<String,QuotationComponentDataWrapper.ROMeasurementClass>();
                String measurementMapKey = eachROMeasurment.Unit_No__c + eachROMeasurment.Type__c;
                measurementArea = 0;
                measurementArea += eachROMeasurment.Measurement_Area_Sqm__c;
                roMeasurementWrapper = new QuotationComponentDataWrapper.ROMeasurementClass(eachROMeasurment.Type__c, eachROMeasurment.Type__c,measurementArea,eachROMeasurment.IsFOC__c, eachROMeasurment.Valid_From_Date__c, eachROMeasurment.Valid_To_Date__c, eachROMeasurment.Id);
                roMeasurementWrapper.measurementCode = eachROMeasurment.Type__c;
                roMeasurementWrapper.roMeasurementId = eachROMeasurment.Id;
                roMeasurementWrapper.roCode = eachROMeasurment.Unit_No__r.Units_Code__c ;
                roMeasurementWrapper.roId = eachROMeasurment.Unit_No__c;
                measurementMap.put(measurementMapKey, roMeasurementWrapper);

                if(!result.containsKey(eachROMeasurment.Unit_No__c)) {
                    result.put(eachROMeasurment.Unit_No__c,
                                new Map<String,QuotationComponentDataWrapper.ROMeasurementClass>(measurementMap));
                } else {
                    Map<String,QuotationComponentDataWrapper.ROMeasurementClass> existingMeasurementMap = result.get(eachROMeasurment.Unit_No__c);
                    if(!existingMeasurementMap.containsKey(measurementMapKey)) {
                        existingMeasurementMap.put(measurementMapKey, roMeasurementWrapper);
                    } else {
                        QuotationComponentDataWrapper.ROMeasurementClass existingWrapper = existingMeasurementMap.get(measurementMapKey);
                        // existingWrapper = existingWrapper + roMeasurementWrapper
                        existingWrapper.measurementArea += roMeasurementWrapper.measurementArea;
                    }
                }

            }
        }

        return result;
    }

	// #region Get Search RO
    @AuraEnabled
    public static String SearchRentalObject(String queryCondition, Boolean isRentedRoom, String contractStartDate, String contractEndDate) {
      // Filter By Romm Number or Floor Number
      // Filter By only AvailableForSales
      // Remark In case of only AvailableForSales, Code should check RO in Contract Line Item which target RO are contracted or not.

        System.debug('contractStartDate ' + contractStartDate );
        System.debug('contractEndDate ' + contractEndDate );
        String jsonResult;
        Date todayDate = Date.today();

        queryCondition += ' AND (ValidFrom__c <= '+contractStartDate+ ' AND ValidTo__c >= '+ contractEndDate+')';

        System.debug(queryCondition);



        List<Units__c> rentalObjectList = ObjectSelector.getRentalObjectByCondition(queryCondition, 'Name');
        Set<Id> availableRoIdSet = validateROMeasurementForSales(rentalObjectList, Date.valueOf(contractStartDate), Date.valueOf(contractEndDate));
        List<ContractLineItem__c> contractLineItemList = [SELECT Id,
                                                            Name,
                                                            LeasableArea__c,
                                                            Contract__c,
                                                            Contract__r.Contract_Start_Date__c,
                                                            Contract__r.Contract_End_Date__c,
                                                            Contract__r.Termination_Date__c,
                                                            Unit__c,
                                                            Unit__r.Name,
                                                            Unit__r.Units_Code__c,
                                                            Unit__r.Floor__r.Name,
                                                            Unit__r.Usage_Type__c,
                                                            Unit__r.Available_for_Sales__c,
                                                            Unit__r.ValidFrom__c,
                                                            Unit__r.ValidTo__c,
                                                            Unit__r.Floor__c,
                                                            Unit__r.IsRetailZone__c,
                                                            Unit__r.Building__c,
                                                            Unit__r.Building__r.Name,
                                                            TotalArea__c

                                                            FROM ContractLineItem__c WHERE Unit__c IN: rentalObjectList];

        Set<Id> contractIdSet = new Set<Id>();

        for (ContractLineItem__c eachContractLineItem : contractLineItemList) {
            if (eachContractLineItem!=null) {
                contractIdSet.add(eachContractLineItem.Contract__c);
            }
        }
        System.debug('contractIdSet: ' + JSON.serialize(contractIdSet));

        Map<Id,Contract__c> contractToCheck = new Map<Id,Contract__c> ([SELECT Id,
                                                                            Contract_Start_Date__c,
                                                                            Contract_End_Date__c,
                                                                            Termination_Date__c,
                                                                            Name,
                                                                            Account_Name__c,
                                                                            Account_Name__r.Name
                                                                            FROM Contract__c WHERE Id IN: contractIdSet AND IsActive__c =: true ORDER BY Contract_Start_Date__c]);

        System.debug('contractToCheck: ' + JSON.serialize(contractToCheck));

        Map<Id,List<Contract__c>> roMapWithContract = new Map<Id,List<Contract__c>>();
        for (ContractLineItem__c eachContractLineItem : contractLineItemList){
            // เช็คว่า tms_ContractActualEndDate__c มีมั้ย ถ้ามีให้ใช้ tms_ContractActualEndDate__c มาแทน tms_ContractEndDate__c
            Date contractActualEndDate = eachContractLineItem.Contract__r.Termination_Date__c != null ? eachContractLineItem.Contract__r.Termination_Date__c : eachContractLineItem.Contract__r.Contract_End_Date__c;

            if(contractToCheck.get(eachContractLineItem.Contract__c) != null
                 &&
                (
                    // เช็คว่า Opp Contract Date ไหนที่มีวันที่ผูกอยู่ในสัญญารึป่าว ถ้ามี ให้ add เข้าไป
                    Utility.isPeriodOverlap(Date.valueOf(contractStartDate), Date.valueOf(contractEndDate), eachContractLineItem.Contract__r.Contract_Start_Date__c, contractActualEndDate)
                )
            ){
                if (roMapWithContract.containsKey(eachContractLineItem.Unit__c)) {
                    roMapWithContract.get(eachContractLineItem.Unit__c).add(contractToCheck.get(eachContractLineItem.Contract__c));
                }else{
                    roMapWithContract.put(eachContractLineItem.Unit__c,new List<Contract__c>{contractToCheck.get(eachContractLineItem.Contract__c)});
                }
            }
        }
        System.debug('roMapWithContract: ' + JSON.serialize(roMapWithContract));

        Map<Id, Contract__c> contractedRO = getContractedROMap(contractToCheck, contractLineItemList, Date.valueOf(contractStartDate), Date.valueOf(contractEndDate));
        Set<Units__c> resultRentalObjectSet = new Set<Units__c>();

        for(Units__c eachQueryRO : rentalObjectList){
            Boolean isDateContractOverlapsRO = false;
            System.debug('isRentedRoom: ' + isRentedRoom);
            if (!isRentedRoom) {
                System.debug('roMapWithContract: ' + JSON.serialize(roMapWithContract));
                System.debug('eachQueryRO.Id: ' + JSON.serialize(eachQueryRO.Id));
                if (roMapWithContract.containsKey(eachQueryRO.Id)) {
                    System.debug(roMapWithContract.get(eachQueryRO.Id));
                    for (Contract__c eachContract : roMapWithContract.get(eachQueryRO.Id)) {
                        // เช็คว่า Termination_Date__c มีมั้ย ถ้ามีให้ใช้ Termination_Date__c มาแทน Contract_End_Date__c
                        Date contractActualEndDate = eachContract.Termination_Date__c != null ? eachContract.Termination_Date__c : eachContract.Contract_End_Date__c;

                        if(Utility.isPeriodOverlap(eachContract.Contract_Start_Date__c, contractActualEndDate, Date.valueOf(contractStartDate), Date.valueOf(contractEndDate))){
                            isDateContractOverlapsRO = true;
                            break;
                        }
                    }
                    if(!isDateContractOverlapsRO){
                        resultRentalObjectSet.add(eachQueryRO);
                    }
                    else{
                        isDateContractOverlapsRO = false;
                    }
                }else{
                    System.debug('elseeeeee');
                    resultRentalObjectSet.add(eachQueryRO);
                }

            }else{
                resultRentalObjectSet.add(eachQueryRO);
            }
        }

        List<Units__c> resultRentalObject = new List<Units__c>(resultRentalObjectSet);
        Map<Id,Map<String,QuotationComponentDataWrapper.ROMeasurementClass>> rentalObjectMesurmentMap =  getMeasurementTypeAreaMap(resultRentalObject, Date.valueOf(contractStartDate), Date.valueOf(contractEndDate));
        List<QuotationComponentDataWrapper.ROMeasurementClass> measurementClass ;

        Decimal leasableArea;
        Decimal measurement;
        String meterList;
        Map<String,String> usageTypeMap = getPicklistOption('Units__c', 'Usage_Type__c');
        Map<String,String> roTypeMap = getPicklistOption('Units__c', 'Type__c');

        List<QuotationComponentDataWrapper.RentalObjectClass> rentalObjectWrapper = new List<QuotationComponentDataWrapper.RentalObjectClass>();
        for (Units__c eachRentalObject : resultRentalObject) {

            if (availableRoIdSet.contains(eachRentalObject.Id)) {

                measurementClass = new List<QuotationComponentDataWrapper.ROMeasurementClass>();
                leasableArea = 0;
                measurement = 0;

                if (!rentalObjectMesurmentMap.isEmpty() && !rentalObjectMesurmentMap.get(eachRentalObject.Id).isEmpty()) {

                    for ( String measurementKey : rentalObjectMesurmentMap.get(eachRentalObject.Id).keySet()) {
                        measurement += rentalObjectMesurmentMap.get(eachRentalObject.Id).get(measurementKey).measurementArea;
                        measurementClass.add(rentalObjectMesurmentMap.get(eachRentalObject.Id).get(measurementKey));

                        if (!rentalObjectMesurmentMap.get(eachRentalObject.Id).get(measurementKey).isFOC) {
                            leasableArea += rentalObjectMesurmentMap.get(eachRentalObject.Id).get(measurementKey).measurementArea;
                        }
                    }
                }

                QuotationComponentDataWrapper.RentalObjectClass eachWrpperClass  = new QuotationComponentDataWrapper.RentalObjectClass(
                                                                                                                        eachRentalObject.Id,
                                                                                                                        eachRentalObject.Name,
                                                                                                                        eachRentalObject.Floor__r.Name ,
                                                                                                                        measurement,
                                                                                                                        usageTypeMap.get(eachRentalObject.Usage_Type__c),
                                                                                                                        eachRentalObject.Available_for_Sales__c,
                                                                                                                        eachRentalObject.ValidFrom__c,
                                                                                                                        meterList,
                                                                                                                        leasableArea,
                                                                                                                        measurement,
                                                                                                                        eachRentalObject.ValidTo__c,
                                                                                                                        (roMapWithContract.containsKey(eachRentalObject.Id))?true:false,
                                                                                                                        measurementClass,
                                                                                                                        null,
                                                                                                                        (roMapWithContract.containsKey(eachRentalObject.Id))?true:false,
                                                                                                                        eachRentalObject.CurrentContractAccountName__c,
                                                                                                                        (roMapWithContract.containsKey(eachRentalObject.Id))?contractedRO.get(eachRentalObject.Id).Name:'',
                                                                                                                        (eachRentalObject.CurrentContractEndDate__c!=null)?Date.valueOf(eachRentalObject.CurrentContractEndDate__c):null,
                                                                                                                        null, //eachRentalObject.tms_RequestHeader__c,
                                                                                                                        eachRentalObject.Floor__c,
                                                                                                                        null, //eachRentalObject.tms_LocationOnFloor__c,
                                                                                                                        null, //eachRentalObject.tms_LocationOnFloor__r.Name,
                                                                                                                        eachRentalObject.IsRetailZone__c,
                                                                                                                        eachRentalObject.Usage_Type__c,
                                                                                                                        false, //eachRentalObject.tms_IsSPWGSublease__c,
                                                                                                                        eachRentalObject.Building__c,
                                                                                                                        eachRentalObject.Building__r.Name
                                                                                                                        );
                eachWrpperClass.roCode = eachRentalObject.Units_Code__c;
                eachWrpperClass.isToDeleteRecord = false;
                eachWrpperClass.currentShopname = eachRentalObject.CurrentContractShopName__c;
                eachWrpperClass.floorShortName = eachRentalObject.Floor__r.Floor_Short_Name__c;
                eachWrpperClass.currentContractIdLink = (roMapWithContract.containsKey(eachRentalObject.Id))?'/'+String.valueof(contractedRO.get(eachRentalObject.Id).Id):'';
                eachWrpperClass.roTypeLabel = eachWrpperClass.roType = roTypeMap.get(eachRentalObject.Type__c);
                //eachWrpperClass.roTypeLabel = (eachWrpperClass.roType == Constant.TMS_TYPE_DRAFT && eachRentalObject.tms_RequestHeader__c != null)? 'Split' : eachWrpperClass.roType;
                //eachWrpperClass.requestName = (eachRentalObject.tms_RequestHeader__c != null)? eachRentalObject.tms_Request__r.Name : '';
                eachWrpperClass.lastContractId = eachRentalObject.LastContract__c;
                eachWrpperClass.lastContractName = (eachRentalObject.LastContract__c !=null)? eachRentalObject.LastContract__r.Name : '';
                eachWrpperClass.lastContractURL = (eachRentalObject.LastContract__c !=null)? URL.getSalesforceBaseUrl().toExternalForm() + '/'+ eachWrpperClass.lastContractId : '';
                eachWrpperClass.lastContractAccountName  = eachRentalObject.LastContractAccountName__c;
                eachWrpperClass.lastContractShopName = eachRentalObject.LastContractShopName__c;
                eachWrpperClass.lastContractEndDate = eachRentalObject.LastContractEnddate__c;
                eachWrpperClass.lastContractStartDate = eachRentalObject.LastContractStartDate__c;

                System.debug('eachWrpperClass'+eachWrpperClass);
                rentalObjectWrapper.add(eachWrpperClass);
            }

        }

        jsonResult = JSON.serialize(rentalObjectWrapper);

        System.debug('Return Data ' +jsonResult);
        return jsonResult;
    }

    public static Set<Id> validateROMeasurementForSales(List<Units__c> rentalObjectList, Date opp_ContractStartDate, Date opp_ContractEndDate){

        Map<Id,List<Measurement__c>> roMeasurementMap  = new Map<Id,List<Measurement__c>>();
        Map<Id,List<Measurement__c>> res  = new Map<Id,List<Measurement__c>>();


        for (Units__c eachRO : rentalObjectList) {
            roMeasurementMap.put(eachRO.Id, new List<Measurement__c>());
        }

        List<Measurement__c> rentalObjectMeasurmentList =  [SELECT Id,
                                                                Type__c,
                                                                Measurement_Area_Sqm__c,
                                                                Valid_From_Date__c,
                                                                Valid_To_Date__c,
                                                                Unit_No__c,
                                                                Unit_No__r.Units_Code__c

                                                                FROM Measurement__c

                                                                WHERE Unit_No__c IN: rentalObjectList ORDER BY Valid_To_Date__c];

        for (Measurement__c eachROMeasurment : rentalObjectMeasurmentList) {
            if (roMeasurementMap.containskey(eachROMeasurment.Unit_No__c)) {
                roMeasurementMap.get(eachROMeasurment.Unit_No__c).add(eachROMeasurment);
            }
        }

        res = roMeasurementMap;

        for (Id eachROId : roMeasurementMap.keySet()) {
            Date dateGap;
            for (Measurement__c eachROMeasurment : rentalObjectMeasurmentList){

                if (eachROMeasurment.Valid_To_Date__c > opp_ContractEndDate) {
                    dateGap = eachROMeasurment.Valid_To_Date__c;
                }

                if (dateGap != null) {
                    if (dateGap.addDays(1) == eachROMeasurment.Valid_From_Date__c) {
                        if (res.containskey(eachROMeasurment.Unit_No__c)) {
                            res.remove(eachROMeasurment.Unit_No__c);
                        }
                    }
                }
            }
        }
        return res.keySet();
    }

	// #region Validate Save RO
    @AuraEnabled
    public static string validateBeforeSaveSelectedRO(List<Id> roIdList, String selectedRoomJson , String oppUiWrapper){
        try {
            QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
            List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList;
            if (selectedRoomJson != null) {
                selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
            }

            String result = '';
            String errorMsg = 'ไม่อนุญาตให้เลือก Rental Object ที่มี Main Rental object เดียวกันในการเสนอขาย';
            String errorMsg2 = 'Cannot select Room which Measurement = 0';
            String errorMsg3 = 'Selected Rental Object Usage Type not Match with Opportuinity Usage Type';
            System.debug('roIdList: ' + roIdList);
            Map<Id, Set<Id>> rentalObjRelationshipMap = new Map<Id, Set<Id>>();
            Set<Id> mainRoSet = new set<Id>();
            Set<Id> mainRoRelationshipSet = new set<Id>();
            Set<Id> resultRoSet = new set<Id>();
            /*if(roIdList.size() > 0){
                List<tms_RentalObjRelationship__c> rentalObjRelationship = tms_ObjectSelector.getRentalObjRelationshipResultByROList(roIdList);
                if(rentalObjRelationship.size() > 0){
                    for (tms_RentalObjRelationship__c roResult : rentalObjRelationship) {
                        resultRoSet.add(roResult.tms_ResultRentalObject__c);
                        if(!rentalObjRelationshipMap.containsKey(roResult.tms_MainRentalObject__c)){
                            Set<Id> requestIdSet = new Set<Id>{roResult.tms_Request__c};
                            rentalObjRelationshipMap.put(roResult.tms_MainRentalObject__c, requestIdSet);
                        }
                        else{
                            rentalObjRelationshipMap.get(roResult.tms_MainRentalObject__c).add(roResult.tms_Request__c);
                        }
                    }
                    System.debug('rentalObjRelationshipMap: ' + JSON.serialize(rentalObjRelationshipMap));
                }
                for (Id roId : roIdList) {
                    if(!resultRoSet.contains(roId)){
                        mainRoSet.add(roId);
                    }
                }
                for (Id mainRoId : rentalObjRelationshipMap.keySet()) {
                    if(rentalObjRelationshipMap.get(mainRoId).size() > 1){
                        result = errorMsg;
                        break;
                    }
                    else {
                        mainRoRelationshipSet.add(mainRoId);
                    }

                }
                System.debug('mainRoSet: ' + JSON.serialize(mainRoSet));
                System.debug('mainRoRelationshipSet: ' + JSON.serialize(mainRoRelationshipSet));
                if(mainRoRelationshipSet != null){
                    for (Id mainRelationshipRoId : mainRoRelationshipSet) {
                        if(mainRoSet.contains(mainRelationshipRoId)){
                            result = errorMsg;
                            break;
                        }
                    }
                }
            }*/

            if (selectedRoomList.size() > 0) {
                for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRoom : selectedRoomList) {
                    if (!eachSelectedRoom.isToDeleteRecord &&(eachSelectedRoom.measurement == 0 || eachSelectedRoom.measurement == null)) {

                        if (result == '') {
                            result = errorMsg2;
                        }else{
                            result =+ ' & ' + errorMsg2;
                        }
                    }

                    if (!eachSelectedRoom.isToDeleteRecord && eachSelectedRoom.usageTypeId != oppDetail.usageType) {
                        if (result == '') {
                            result = errorMsg3;
                        }else{
                            result =+ ' & ' + errorMsg3;
                        }
                    }
                }
            }

            return result;
        } catch (Exception e) {
            System.debug('validateBeforeSaveSelectedRO exception is occured: ' + e.getMessage());
            throw e;
        }
    }

	// #region Save RO
    @AuraEnabled
    public static String saveSelectedRentalObject(String selectedRoomJson, Id oppId, String oppUiWrapper){
        System.debug('Selected Room To save '+ selectedRoomJson);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList =
		(List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        System.debug('desrialize '+ selectedRoomList);

        Opportunity oppInfo = new Opportunity(  Id=oppId,
                                                Leasable_Area__c = oppDetail.totalLeasableArea,
                                                Total_Area_sq_m__c = oppDetail.totalMeasurmentArea);

        OpportunityController oppController = new OpportunityController();
        List<QuotationComponentDataWrapper.RentalObjectClass> newSelectedRoomList = oppController.processSelectedRentalObject(oppInfo,selectedRoomList);

        return JSON.serialize(newSelectedRoomList);
    }

	// #region Update Area in Opp
    @AuraEnabled
    public static Boolean updateOppArea (String selectedRoomJson, Id oppId, String oppUiWrapper){
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);

        Boolean result = false;

        try {
            List<String> roomNumberList = new List<String>();
            Set<String> floorSet = new Set<String>();
            for(QuotationComponentDataWrapper.RentalObjectClass rentalObject : selectedRoomList) {
                if(!rentalObject.isToDeleteRecord) {
                    roomNumberList.add(rentalObject.roomNumber);
                    floorSet.add(rentalObject.floorShortName);
                }
            }
            String floorNumber = String.join(new List<String>(floorSet), ',');
            String roomNumber = roomNumberList.isEmpty() != true ? String.join(roomNumberList, ',') : null;

            Opportunity oppInfo = new Opportunity(  Id=oppId,
                                                    Leasable_Area__c = oppDetail.totalLeasableArea,
                                                    Total_Area_sq_m__c = oppDetail.totalMeasurmentArea,
                                                    RoomNumber__c = roomNumber,
                                                    FloorNumber__c = floorNumber);
            update oppInfo;

            result = true;

        }
        catch (Exception e) {
            result =  false;
            throw e;
        }

        return result;
    }

	// #region Other Expense JSON
    @AuraEnabled
    public static String getOtherExpenseJson(String rentType){
        QuotationComponentDataWrapper.OtherWrapper  otherWrapperObject = new QuotationComponentDataWrapper.OtherWrapper();

        List<QuotationPreparationScreenMaster__c> pageMasterListQuery = [SELECT
                                                                            Format__c,
                                                                            IsActive__c,
                                                                            ScreentoDisplay__c,
                                                                            Type__c,
                                                                            RentalType__c,
                                                                            Sequence__c
                                                                            FROM QuotationPreparationScreenMaster__c
                                                                            WHERE ScreentoDisplay__c =: Constant.TYPE_EXPENSEANDFEE AND IsActive__c =: TRUE AND RentalType__c =: rentType ORDER BY Sequence__c ];

        System.debug('get new Other Expense' + pageMasterListQuery);

        Map<String,QuotationPreparationScreenMaster__c> pageMasterMap = new Map<String,QuotationPreparationScreenMaster__c>();
        for(QuotationPreparationScreenMaster__c eachMaster : pageMasterListQuery){
            pageMasterMap.put(eachMaster.Type__c,eachMaster);
        }

        List<QuotationPreparationScreenMaster__c> pageMasterList  = pageMasterMap.values();


        QuotationComponentDataWrapper.FixedOtherExpenseFormat fixedFormat;
        QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat rateAndAreaFormat;
        for (QuotationPreparationScreenMaster__c eachPageMaster : pageMasterList) {

            if(eachPageMaster.Format__c == Constant.PAGE_MASTER_FORMAT_FIXED){
                fixedFormat = new QuotationComponentDataWrapper.FixedOtherExpenseFormat(eachPageMaster.Type__c);
                fixedFormat.ExpenseOtherType = eachPageMaster.Format__c;
                fixedFormat.Sequence = eachPageMaster.Sequence__c;
                otherWrapperObject.fixedFormatList.add(fixedFormat);

            }else if(eachPageMaster.Format__c == Constant.PAGE_MASTER_FORMAT_RATE_AND_AREA){
                rateAndAreaFormat = new QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat(eachPageMaster.Type__c);
                rateAndAreaFormat.ExpenseOtherType = eachPageMaster.Format__c;
                rateAndAreaFormat.Sequence = eachPageMaster.Sequence__c;
                otherWrapperObject.rateAndAreaFormatList.add(rateAndAreaFormat);

            }
        }

        return JSON.serialize(otherWrapperObject);
    }

	// #region CAM JSON
    @AuraEnabled
    public static String getCAMPricingDetail(Id oppId ,String selectedRoomJson, Date contractStartDate, Date contractEndDate, String leaseType, Decimal escalationRate, Boolean isUpdateOpp, Integer optionToRenewYear, Integer optionToRenewMonth, String oppUiWrapper){

        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        System.debug('desrialize '+ selectedRoomList);

        Map<Integer,QuotationComponentDataWrapper.DatePeriod> yearPeriod;

        System.debug('optionToRenewYear' +optionToRenewYear);
        System.debug('optionToRenewMonth' +optionToRenewMonth);

        // if (optionToRenewYear > 0 || optionToRenewMonth > 0) {
        //     System.debug('iffff');
        //     yearPeriod = OpportunityUtility.getYearCalendarPeriod(contractStartDate, contractEndDate, leaseType,optionToRenewYear, optionToRenewMonth, oppDetail.longleaseType);
        // }else if(optionToRenewYear == 0 && optionToRenewMonth == 0){
        //     System.debug('else');
        //     yearPeriod = OpportunityUtility.getYearCalendarPeriod(contractStartDate,contractEndDate,leaseType, oppDetail.longleaseType);
        // }
        if (optionToRenewYear > 0 || optionToRenewMonth > 0) {
            System.debug('iffff');
            yearPeriod = OpportunityUtility.getPricingDatePeriod(contractStartDate, contractEndDate,optionToRenewYear, optionToRenewMonth);
        }else if(optionToRenewYear == 0 && optionToRenewMonth == 0){
            System.debug('else');
            yearPeriod = OpportunityUtility.getPricingDatePeriod(contractStartDate, contractEndDate);
        }

        System.debug('yearPeriod' + JSON.serialize(yearPeriod));

        String jsonResult;

        Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);

        QuotationComponentDataWrapper.CAMPricingWrapper camPricingDetail = new QuotationComponentDataWrapper.CAMPricingWrapper();

        QuotationComponentDataWrapper.UINumberInputClass camEscalateRateInput = new QuotationComponentDataWrapper.UINumberInputClass((escalationRate!=null)?escalationRate:OpportunitySetting__c.getInstance().CAMEscalation__c, false);

        List<QuotationComponentDataWrapper.CAMYearPeriodWrapper> camYerPeriodList = new List<QuotationComponentDataWrapper.CAMYearPeriodWrapper>();

        List<QuotationComponentDataWrapper.MeasurmentWrapper> camMeasurementList;
        QuotationComponentDataWrapper.MeasurmentWrapper camMeasurement;
        QuotationComponentDataWrapper.CAMYearPeriodWrapper camYearPeriod;
        QuotationComponentDataWrapper.UINumberInputClass measurmentTypeInput;

        Decimal totalArea = 0;

        if (leaseType == 'Short-Term' || (leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาทุกปีตามปีสัญญา')){

            for (Integer eachPeriod : yearPeriod.keySet()) {

                totalArea = 0;

                camYearPeriod = new QuotationComponentDataWrapper.CAMYearPeriodWrapper();
                camYearPeriod.isToDeleteRecord = false;
                camYearPeriod.isRenewCAMPeriod = false;
                camYearPeriod.Year = eachPeriod;
                camYearPeriod.DateTo = yearPeriod.get(eachPeriod).endDate;
                camYearPeriod.DateFrom = yearPeriod.get(eachPeriod).startDate;
                camYearPeriod.IsDisableInput = true;
                camYearPeriod.TotalPrice = 0;
                camYearPeriod.isOptionToRenew = yearPeriod.get(eachPeriod).isOptionToRenew;

                camMeasurementList = new List<QuotationComponentDataWrapper.MeasurmentWrapper>();
                for(String eachROMeasurmentType : roMeasurementTypeMap.keySet()){

                    camMeasurement = new QuotationComponentDataWrapper.MeasurmentWrapper();
                    measurmentTypeInput = new QuotationComponentDataWrapper.UINumberInputClass(null,null);

                    measurmentTypeInput.value = 0;

                    if(!roMeasurementTypeMap.get(eachROMeasurmentType).isFOC){

                        camMeasurement.isFOC = false;

                        if (eachPeriod == 1) {
                            measurmentTypeInput.IsDisabled = false;
                        }else{
                            measurmentTypeInput.IsDisabled = true;
                        }

                        camMeasurement.measurementId = roMeasurementTypeMap.get(eachROMeasurmentType).measurementId;
                        camMeasurement.MeasurementArea = roMeasurementTypeMap.get(eachROMeasurmentType).measurementArea;
                        camMeasurement.Price = measurmentTypeInput;
                        camMeasurement.MeasurementType = eachROMeasurmentType;
                        camMeasurement.roMeasurementId = roMeasurementTypeMap.get(eachROMeasurmentType).roMeasurementId;
                        camMeasurement.isToDeleteRecord = false;

                        totalArea += camMeasurement.MeasurementArea;

                        camMeasurementList.add(camMeasurement);
                    }
                }

                camYearPeriod.CAMMeasurmentList = camMeasurementList;
                camYearPeriod.TotalArea = totalArea;

                camYerPeriodList.add(camYearPeriod);


            }
        }if (leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก'){

            // totalArea = 0;

            // camYearPeriod = new QuotationComponentDataWrapper.CAMYearPeriodWrapper();
            // camYearPeriod.isToDeleteRecord = false;
            // camYearPeriod.isRenewCAMPeriod = false;
            // camYearPeriod.Year = 1;
            // camYearPeriod.DateTo = Date.newInstance(contractStartDate.year(), 12, 31);
            // camYearPeriod.DateFrom = contractStartDate;
            // camYearPeriod.IsDisableInput = true;
            // camYearPeriod.TotalPrice = 0;
            // camYearPeriod.isOptionToRenew = yearPeriod.get(1).isOptionToRenew;

            // camMeasurementList = new List<QuotationComponentDataWrapper.MeasurmentWrapper>();
            // for(String eachROMeasurmentType : roMeasurementTypeMap.keySet()){

            //     camMeasurement = new QuotationComponentDataWrapper.MeasurmentWrapper();
            //     measurmentTypeInput = new QuotationComponentDataWrapper.UINumberInputClass(null,null);

            //     measurmentTypeInput.value = 0;

            //     if(!roMeasurementTypeMap.get(eachROMeasurmentType).isFOC){

            //         camMeasurement.isFOC = false;
            //         measurmentTypeInput.IsDisabled = false;

            //         camMeasurement.measurementId = roMeasurementTypeMap.get(eachROMeasurmentType).measurementId;
            //         camMeasurement.MeasurementArea = roMeasurementTypeMap.get(eachROMeasurmentType).measurementArea;
            //         camMeasurement.Price = measurmentTypeInput;
            //         camMeasurement.MeasurementType = eachROMeasurmentType;
            //         camMeasurement.roMeasurementId = roMeasurementTypeMap.get(eachROMeasurmentType).roMeasurementId;
            //         camMeasurement.isToDeleteRecord = false;

            //         totalArea += camMeasurement.MeasurementArea;

            //         camMeasurementList.add(camMeasurement);
            //     }
            // }

            // camYearPeriod.CAMMeasurmentList = camMeasurementList;
            // camYearPeriod.TotalArea = totalArea;

            // camYerPeriodList.add(camYearPeriod);

        }
        camPricingDetail.oppId = oppId;
        camPricingDetail.CAMYearPeriod = camYerPeriodList;
        camPricingDetail.CAMEscationRate = camEscalateRateInput;
        camPricingDetail.CAMCondition = '% Escalation';
        camPricingDetail.CAMOrAirService = 'CAM';



        jsonResult = JSON.serialize(camPricingDetail);
        if (isUpdateOpp) {
            Opportunity opp = new Opportunity(Id = oppId,
                                              CAMEscalationType__c = '% Escalation');
            update opp;
        }
        return jsonResult;
    }

    public static Map<String, QuotationComponentDataWrapper.ROMeasurementClass> getROMeasurmentTypeSet(String selectedRoomJson){
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        Map<String, QuotationComponentDataWrapper.ROMeasurementClass> measurementTypeMap = new Map<String, QuotationComponentDataWrapper.ROMeasurementClass>();
        for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRoom : selectedRoomList) {
            if (!eachSelectedRoom.isToDeleteRecord) {
                if (eachSelectedRoom.roMeasurmentList!=null) {
                    if (!eachSelectedRoom.roMeasurmentList.isEmpty()) {

                        for (QuotationComponentDataWrapper.ROMeasurementClass eachMeasurment : eachSelectedRoom.roMeasurmentList) {
                            if (!eachMeasurment.isFOC) {
                                if (measurementTypeMap.containsKey(eachMeasurment.measurementName)) {
                                    measurementTypeMap.get(eachMeasurment.measurementName).measurementArea += eachMeasurment.measurementArea;
                                }else{
                                    measurementTypeMap.put(eachMeasurment.measurementName , eachMeasurment);
                                }
                            }
                        }
                    }
                }
            }
        }

        return measurementTypeMap;
    }

	// #region Rent Service JSON
    @AuraEnabled
    public static String getRentServicePricingDetail(String selectedRoomJson, Decimal rentServiceEscalationRate, Id oppId, Boolean isUpdateOpp){
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        System.debug('desrialize '+ selectedRoomList);

        String jsonResult;

        if (selectedRoomList!=null) {
            Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);
            QuotationComponentDataWrapper.RentServicePricingWrapper rentServiceDetail = new QuotationComponentDataWrapper.RentServicePricingWrapper();
            rentServiceDetail.isToDeleteRecord = false;
            rentServiceDetail.RentCondition ='% Escalation';
            rentServiceDetail.RentServiceEscalationRate = new QuotationComponentDataWrapper.UINumberInputClass((rentServiceEscalationRate!=null)?rentServiceEscalationRate:OpportunitySetting__c.getInstance().RentAndServiceEscalation__c,false);

            QuotationComponentDataWrapper.MeasurmentWrapper measurmentWrapper;
            List<QuotationComponentDataWrapper.MeasurmentWrapper> measurementWrapperList  = new List<QuotationComponentDataWrapper.MeasurmentWrapper>();

            for(String eachROMeasurmentType : roMeasurementTypeMap.keySet()){
                if (!roMeasurementTypeMap.get(eachROMeasurmentType).isFOC) {
                    measurmentWrapper = new QuotationComponentDataWrapper.MeasurmentWrapper();
                    measurmentWrapper.measurementId = roMeasurementTypeMap.get(eachROMeasurmentType).measurementId;
                    measurmentWrapper.Price = new QuotationComponentDataWrapper.UINumberInputClass(0,false);
                    measurmentWrapper.isToDeleteRecord = false;
                    measurmentWrapper.MeasurementType = eachROMeasurmentType;
                    measurmentWrapper.isFOC = roMeasurementTypeMap.get(eachROMeasurmentType).isFOC;
                    measurmentWrapper.MeasurementArea = roMeasurementTypeMap.get(eachROMeasurmentType).MeasurementArea;

                    measurementWrapperList.add(measurmentWrapper);
                }

            }

            rentServiceDetail.RentServiceMeasurment = measurementWrapperList;
            rentServiceDetail.RentalObjectList = selectedRoomList;

            jsonResult = JSON.serialize(rentServiceDetail);


            if (isUpdateOpp) {
                Opportunity opp = new Opportunity(Id = oppId,
                                                  RentAndServiceEscalationType__c = '% Escalation');
                update opp;
            }
        }


        return jsonResult;
    }

	// #region Period Pricing JSON
	/**
	 * CR Feb 2025
	 */
    @AuraEnabled
    public static String getPeriodPricingDetail(String selectedRoomJson, Date contractStartDate, Date contractEndDate, String calCulationMethod, String leaseType, Integer optionToRenewYear, Integer optionToRenewMonth, String oppUiWrapper){

        String jsonResult;
        Map<String,String> repotingRuleValue = new Map<String,String>{'Sales before VAT' => 'Sales before VAT'};
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);

        Map<String,String> calculationMethodLabel = getPicklistOption('Opportunity', 'Calculation_Method__c');
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);

        System.debug('desrialize '+ selectedRoomList);

        List<QuotationComponentDataWrapper.PeriodPricing> periodList = new List<QuotationComponentDataWrapper.PeriodPricing>();
        QuotationComponentDataWrapper.PeriodPricing period;
        Map<Integer,QuotationComponentDataWrapper.DatePeriod> periodPricingMap;

        Decimal proportionRent = 0;
        Decimal proportionService = 0;

        Boolean doneOnSubcat = false;
        Boolean doneOnUsageType = false;

        if(oppDetail.rentType == 'Event_Rental') {
            proportionRent = OpportunitySetting__c.getInstance().RentEventProportion__c;
            proportionService = OpportunitySetting__c.getInstance().ServiceEventProportion__c;
        } else if(oppDetail.rentType == 'OP_Rental') {
            proportionRent = OpportunitySetting__c.getInstance().RentOPProportion__c;
            proportionService = OpportunitySetting__c.getInstance().ServiceOPProportion__c;
        } else {
            proportionRent = OpportunitySetting__c.getInstance().RentProportion__c;
            proportionService = OpportunitySetting__c.getInstance().ServiceProportion__c;
        }

        // List<QuotationComponentDataWrapper.ProportionWrapper> proportionList  = new List<QuotationComponentDataWrapper.ProportionWrapper>();
        QuotationComponentDataWrapper.ProportionWrapper proportion = new QuotationComponentDataWrapper.ProportionWrapper();
        proportion.Proportion = calCulationMethod;
        proportion.Rent = proportionRent;
        proportion.Service = proportionService;
        // proportionList.add(proportion);

        Decimal periodTotalArea = 0;

        if (leaseType == 'Short-Term' || (leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาทุกปีตามปีสัญญา')) {
            if (optionToRenewYear > 0 || optionToRenewMonth > 0) {
                System.debug('iffff');
                periodPricingMap = OpportunityUtility.getPricingDatePeriod(contractStartDate, contractEndDate,optionToRenewYear, optionToRenewMonth);
            }else if(optionToRenewYear == 0 && optionToRenewMonth == 0){
                System.debug('else');
                periodPricingMap = OpportunityUtility.getPricingDatePeriod(contractStartDate, contractEndDate);
            }

            for (Integer eachPeriod : periodPricingMap.keySet()) {
                period = new QuotationComponentDataWrapper.PeriodPricing();
                period.isCustomPeriod = false;
                period.isToDeleteRecord = false;
                period.PeriodNumber = eachPeriod;
                period.PricingFrom = periodPricingMap.get(eachPeriod).startDate;
                period.PricingTo = periodPricingMap.get(eachPeriod).endDate;
                period.CalculationMethod = calCulationMethod;
                period.CalculationMethodLabel = calculationMethodLabel.get(calCulationMethod);
                period.IsIncludeCAM = false;
                period.OptionToRenew = periodPricingMap.get(eachPeriod).isOptionToRenew;
                period.Proportion = proportion;
                period.EstimateRevernue = 0;
                period.IsAllSales = false;
                System.debug('period: ' + JSON.serialize(period));

                for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList) {
                        if (!eachSelectedRO.isToDeleteRecord) {
                            periodTotalArea += eachSelectedRO.totalArea;
                        }
                }

                period.TotalArea = periodTotalArea;

                if (calCulationMethod == Constant.CAL_METHOD_FIXED_PRICE) {

                    Decimal totalRentalObjectLeasable = 0;

                    for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList){
                        if (!eachSelectedRO.isToDeleteRecord) {
                            totalRentalObjectLeasable += eachSelectedRO.LeasableArea;
                        }
                    }

                    period.FixedPriceSection = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
                    period.FixedPriceSection.isToDeleteRecord =false;
                    period.FixedPriceSection.Price = 0;
                    period.FixedPriceSection.PriceSQM = 0;
                    period.FixedPriceSection.TotalArea = totalRentalObjectLeasable;
                    period.FixedPriceSection.IsDisabled = true;
                    period.FixedPriceSection.MinType = 'Measurement';

                }else if(calCulationMethod == Constant.CAL_METHOD_FIXED_RO){
                    period.FixedRentalObjectSection = new QuotationComponentDataWrapper.FixedRentalObjectSectionWrapper();

                    Decimal totalRentalObjectArea = 0;
                    Decimal totalRentalObjectLeasable = 0;
                    Decimal totalRentalObjectPrice = 0;
                    Decimal totalRentalObjectPriceSQM = 0;

                    List<QuotationComponentDataWrapper.RentalObjectPricingWrapper> roPricingList = new List<QuotationComponentDataWrapper.RentalObjectPricingWrapper>();
                    QuotationComponentDataWrapper.RentalObjectPricingWrapper roPricing;

                    for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList) {
                        if (!eachSelectedRO.isToDeleteRecord) {
                            roPricing = new QuotationComponentDataWrapper.RentalObjectPricingWrapper();
                            roPricing.isToDeleteRecord = false;
                            roPricing.roId = eachSelectedRO.Id;
                            roPricing.roCode = eachSelectedRO.roCode;
                            roPricing.RentalObject = eachSelectedRO.roomNumber;
                            roPricing.TotalArea = eachSelectedRO.totalArea;
                            roPricing.LeasableArea = eachSelectedRO.leasableArea;
                            roPricing.Price = new QuotationComponentDataWrapper.UINumberInputClass(0, false);
                            roPricing.PriceSQM = new QuotationComponentDataWrapper.UINumberInputClass(0, false);
                            roPricing.roMeasurementList = new List<QuotationComponentDataWrapper.ROMeasurementClass>(eachSelectedRO.roMeasurmentList);
							/**
							 * CR Feb 2025
							 * Changed Detail: add more attribute in wrapper to init in Aura
							 */
							//
							//
							//
							// Changed end

                            totalRentalObjectArea += roPricing.TotalArea;
                            totalRentalObjectLeasable += roPricing.LeasableArea;
                            totalRentalObjectPrice += roPricing.Price.value;
                            totalRentalObjectPriceSQM += roPricing.PriceSQM.value;
							/**
							 * CR Feb 2025
							 * Changed Detail: add more cumulative value
							 */
							//
							//
							//
							// Changed end

                            roPricingList.add(roPricing);
                        }
                    }
                    period.FixedRentalObjectSection.MinType = 'Measurement';
                    if(oppDetail.rentType == 'Billboard_Rental') period.FixedRentalObjectSection.MinType = 'Fixed';
                    period.FixedRentalObjectSection.rentalObjectList = roPricingList;
                    period.FixedRentalObjectSection.TotalArea = totalRentalObjectArea;
                    period.FixedRentalObjectSection.TotalLeasableArea = totalRentalObjectLeasable;
                    period.FixedRentalObjectSection.TotalPrice = totalRentalObjectPrice;
                    period.FixedRentalObjectSection.TotalPriceSQm = totalRentalObjectPriceSQM;
					/**
					 * CR Feb 2025
					 * Changed Detail: assign more cumulative value in wrapper
					 */
					//
					//
					//
					// Changed end

                }else if(calCulationMethod == Constant.CAL_METHOD_FIXED_MEAS){
                    period.FixedMeasurementSection = new QuotationComponentDataWrapper.FixedMeasurementSectionWrapper();

                    List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,true);

                    Decimal totalArea = 0;
                    Decimal totalLeasableArea = 0;
                    Decimal totalPrice = 0;
                    Decimal totalSummary = 0;
                    for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                        totalArea += measurementPricing.Area;
                        totalPrice += measurementPricing.Price.value;
                        totalSummary += measurementPricing.Summary;
                        if (!measurementPricing.isFOC) {
                            totalLeasableArea += measurementPricing.Area;
                        }
                    }

                    period.FixedMeasurementSection.pricingList = measurementPricingList;
                    period.FixedMeasurementSection.TotalArea = totalArea;
                    period.FixedMeasurementSection.TotalLeasableArea = totalLeasableArea;
                    period.FixedMeasurementSection.TotalPrice = totalPrice;
                    period.FixedMeasurementSection.TotalSummary = totalSummary;
                }
                else if(calCulationMethod == Constant.CAL_METHOD_GP_NOMIN){
                    List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
                    QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
                    reportingRule.isToDeleteRecord = false;
                    reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
                    reportingRuleList.add(reportingRule);
                    // reportingRule.ReportingRule = '';
                    // reportingRule.ReportingRuleDescription = '';
                    // reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();

                    // reportingRuleList.add(reportingRule);

                    period.GPNoMinSection = new QuotationComponentDataWrapper.GPNoMinSectionWrapper();
                    period.GPNoMinSection.ReportingRuleList = reportingRuleList;
                }
                else if(calCulationMethod == Constant.CAL_METHOD_GP_WITHMIN){
                    List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
                    QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
                    reportingRule.isToDeleteRecord = false;
                    reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
                    reportingRuleList.add(reportingRule);
                    // reportingRule.ReportingRule = '';
                    // reportingRule.ReportingRuleDescription = '';
                    // reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();

                    // reportingRuleList.add(reportingRule);


                   List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,true);

                    Decimal totalArea = 0;
                    Decimal totalPrice = 0;
                    Decimal totalSummary = 0;
                    Decimal totalLeasableArea = 0;
                    for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                        totalArea += measurementPricing.Area;
                        totalPrice += measurementPricing.Price.value;
                        totalSummary += measurementPricing.Summary;
                        if (!measurementPricing.isFOC) {
                            totalLeasableArea += measurementPricing.Area;
                        }
                    }


                    QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
                    pricingSection.MinType = 'Measurement';
                    pricingSection.MeasumentPricingList = measurementPricingList;
                    pricingSection.TotalPrice = totalPrice;
                    pricingSection.TotalArea = totalArea;
                    pricingSection.TotalLeasableArea = totalLeasableArea;
                    pricingSection.TotalSummary = totalSummary;
                    pricingSection.FixedPricing = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
                    pricingSection.FixedPricing.isToDeleteRecord = false;
                    pricingSection.FixedPricing.Price = 0;
                    pricingSection.FixedPricing.IsDisabled = false;


                    period.GPWithMinSection = new QuotationComponentDataWrapper.GPWithMinSectionWrapper();
                    period.GPWithMinSection.ReportingRuleList = reportingRuleList;
                    period.GPWithMinSection.SalesMin = 0;
                    period.GPWithMinSection.PricingSection = pricingSection;
                }
                else if(calCulationMethod == Constant.CAL_METHOD_GP_ONTOP){
                    List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
                    QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
                    reportingRule.isToDeleteRecord = false;
                    reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
                    reportingRuleList.add(reportingRule);
                    // reportingRule.ReportingRule = '';
                    // reportingRule.ReportingRuleDescription = '';
                    // reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();

                    // reportingRuleList.add(reportingRule);


                   List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,true);

                    Decimal totalArea = 0;
                    Decimal totalPrice = 0;
                    Decimal totalSummary = 0;
                    Decimal totalLeasableArea = 0;
                    for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                        totalArea += measurementPricing.Area;
                        totalPrice += measurementPricing.Price.value;
                        totalSummary += measurementPricing.Summary;
                        if (!measurementPricing.isFOC) {
                            totalLeasableArea += measurementPricing.Area;
                        }
                    }


                    QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
                    pricingSection.MinType = 'Measurement';
                    pricingSection.MeasumentPricingList = measurementPricingList;
                    pricingSection.TotalPrice = totalPrice;
                    pricingSection.TotalArea = totalArea;
                    pricingSection.TotalLeasableArea = totalLeasableArea;
                    pricingSection.TotalSummary = totalSummary;
                    pricingSection.FixedPricing = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
                    pricingSection.FixedPricing.isToDeleteRecord = false;
                    pricingSection.FixedPricing.Price = 0;
                    pricingSection.FixedPricing.IsDisabled = false;

                    period.GPOnTopSection = new QuotationComponentDataWrapper.GPOnTopSectionWrapper();
                    period.GPOnTopSection.ReportingRuleList = reportingRuleList;
                    period.GPOnTopSection.PricingSection = pricingSection;
                }

                periodList.add(period);
            }
        }

        if (leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก') {

            // period = new QuotationComponentDataWrapper.PeriodPricing();
            // period.isCustomPeriod = false;
            // period.isToDeleteRecord = false;
            // period.PeriodNumber = 1;
            // period.PricingFrom = contractStartDate;
            // period.PricingTo = Date.newInstance(contractStartDate.year(), 12, 31);
            // period.CalculationMethod = calCulationMethod;
            // period.CalculationMethodLabel = calculationMethodLabel.get(calCulationMethod);
            // period.IsIncludeCAM = false;
            // period.OptionToRenew = false;
            // period.Proportion = proportion;
            // period.EstimateRevernue = 0;
            // period.IsAllSales = false;

            // if (calCulationMethod == Constant.CAL_METHOD_FIXED_PRICE) {
            //         Decimal totalRentalObjectLeasable = 0;

            //         for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList){
            //             if (!eachSelectedRO.isToDeleteRecord) {
            //                 totalRentalObjectLeasable += eachSelectedRO.leasableArea;
            //             }
            //         }
            //         period.FixedPriceSection = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
            //         period.FixedPriceSection.isToDeleteRecord = false;
            //         period.FixedPriceSection.Price = 0;
            //         period.FixedPriceSection.PriceSQM = 0;
            //         period.FixedPriceSection.TotalArea = totalRentalObjectLeasable;
            //         period.FixedPriceSection.IsDisabled = true;
            //         // period.FixedPriceSection.MinType = 'Fixed';
            //         // defect log UATIT-STH-019-48
            //         period.FixedPriceSection.MinType = 'Measurement';

            //     }else if(calCulationMethod == Constant.CAL_METHOD_FIXED_RO){
            //         period.FixedRentalObjectSection = new QuotationComponentDataWrapper.FixedRentalObjectSectionWrapper();

            //         Decimal totalRentalObjectArea = 0;
            //         Decimal totalRentalObjectLeasable = 0;
            //         Decimal totalRentalObjectPrice = 0;
            //         Decimal totalRentalObjectPriceSQM = 0;

            //         List<QuotationComponentDataWrapper.RentalObjectPricingWrapper> roPricingList = new List<QuotationComponentDataWrapper.RentalObjectPricingWrapper>();
            //         QuotationComponentDataWrapper.RentalObjectPricingWrapper roPricing;

            //         for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList) {
            //             if (!eachSelectedRO.isToDeleteRecord) {
            //                 roPricing = new QuotationComponentDataWrapper.RentalObjectPricingWrapper();
            //                 roPricing.isToDeleteRecord = false;
            //                 roPricing.roId = eachSelectedRO.Id;
            //                 roPricing.roCode = eachSelectedRO.roCode;
            //                 roPricing.RentalObject = eachSelectedRO.roomNumber;
            //                 roPricing.TotalArea = eachSelectedRO.totalArea;
            //                 roPricing.LeasableArea = eachSelectedRO.leasableArea;
            //                 roPricing.Price = new QuotationComponentDataWrapper.UINumberInputClass(0, false);
            //                 roPricing.PriceSQM = new QuotationComponentDataWrapper.UINumberInputClass(0, false);
            //                 roPricing.roMeasurementList = new List<QuotationComponentDataWrapper.ROMeasurementClass>(eachSelectedRO.roMeasurmentList);

            //                 totalRentalObjectArea += roPricing.TotalArea;
            //                 totalRentalObjectLeasable += roPricing.LeasableArea;
            //                 totalRentalObjectPrice += roPricing.Price.value;
            //                 totalRentalObjectPriceSQM += roPricing.PriceSQM.value;

            //                 roPricingList.add(roPricing);
            //             }
            //         }
            //         // period.FixedRentalObjectSection.MinType = 'Fixed';
            //         period.FixedRentalObjectSection.rentalObjectList = roPricingList;
            //         period.FixedRentalObjectSection.TotalArea = totalRentalObjectArea;
            //         period.FixedRentalObjectSection.TotalLeasableArea = totalRentalObjectLeasable;
            //         period.FixedRentalObjectSection.TotalPrice = totalRentalObjectPrice;
            //         period.FixedRentalObjectSection.TotalPriceSQm = totalRentalObjectPriceSQM;
            //         // defect log UATIT-STH-019-48
            //         period.FixedRentalObjectSection.MinType = 'Measurement';
            //         if(oppDetail.rentType == 'Billboard_Rental') period.FixedRentalObjectSection.MinType = 'Fixed';

            //     }else if(calCulationMethod == Constant.CAL_METHOD_FIXED_MEAS){
            //         period.FixedMeasurementSection = new QuotationComponentDataWrapper.FixedMeasurementSectionWrapper();

            //         List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,true);

            //         Decimal totalArea = 0;
            //         Decimal totalPrice = 0;
            //         Decimal totalSummary = 0;
            //         for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

            //             totalArea += measurementPricing.Area;
            //             totalPrice += measurementPricing.Price.value;
            //             totalSummary += measurementPricing.Summary;
            //         }


            //         period.FixedMeasurementSection.pricingList = measurementPricingList;
            //         period.FixedMeasurementSection.TotalArea = totalArea;
            //         period.FixedMeasurementSection.TotalPrice = totalPrice;
            //         period.FixedMeasurementSection.TotalSummary = totalSummary;
            //     }
            //     else if(calCulationMethod == Constant.CAL_METHOD_GP_NOMIN){
            //         List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
            //         QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
            //         reportingRule.isToDeleteRecord = false;
            //         reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
            //         reportingRuleList.add(reportingRule);
            //         // reportingRule.ReportingRule = '';
            //         // reportingRule.ReportingRuleDescription = '';
            //         // reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();

            //         // reportingRuleList.add(reportingRule);

            //         period.GPNoMinSection = new QuotationComponentDataWrapper.GPNoMinSectionWrapper();
            //         period.GPNoMinSection.ReportingRuleList = reportingRuleList;
            //     }
            //     else if(calCulationMethod == Constant.CAL_METHOD_GP_WITHMIN){
            //         List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
            //         QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
            //         reportingRule.isToDeleteRecord = false;
            //         reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
            //         reportingRuleList.add(reportingRule);
            //         // reportingRule.ReportingRule = '';
            //         // reportingRule.ReportingRuleDescription = '';
            //         // reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();

            //         // reportingRuleList.add(reportingRule);


            //        List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,true);

            //         Decimal totalArea = 0;
            //         Decimal totalPrice = 0;
            //         Decimal totalSummary = 0;
            //         Decimal totalLeasableArea = 0;
            //         for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

            //             totalArea += measurementPricing.Area;
            //             totalPrice += measurementPricing.Price.value;
            //             totalSummary += measurementPricing.Summary;
            //             if (!measurementPricing.isFOC) {
            //                 totalLeasableArea += measurementPricing.Area;
            //             }
            //         }


            //         QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
            //         pricingSection.MinType = 'Measurement';
            //         pricingSection.MeasumentPricingList = measurementPricingList;
            //         pricingSection.TotalPrice = totalPrice;
            //         pricingSection.TotalLeasableArea = totalLeasableArea;
            //         pricingSection.TotalArea = totalArea;
            //         pricingSection.TotalSummary = totalSummary;
            //         pricingSection.FixedPricing = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
            //         pricingSection.FixedPricing.isToDeleteRecord = false;
            //         pricingSection.FixedPricing.Price = 0;
            //         pricingSection.FixedPricing.IsDisabled = false;


            //         period.GPWithMinSection = new QuotationComponentDataWrapper.GPWithMinSectionWrapper();
            //         period.GPWithMinSection.ReportingRuleList = reportingRuleList;
            //         period.GPWithMinSection.SalesMin = 0;
            //         period.GPWithMinSection.PricingSection = pricingSection;
            //     }
            //     else if(calCulationMethod == Constant.CAL_METHOD_GP_ONTOP){
            //         List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
            //         QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
            //         reportingRule.isToDeleteRecord = false;
            //         reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
            //         reportingRuleList.add(reportingRule);
            //         // reportingRule.ReportingRule = '';
            //         // reportingRule.ReportingRuleDescription = '';
            //         // reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();

            //         // reportingRuleList.add(reportingRule);


            //        List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,true);

            //         Decimal totalArea = 0;
            //         Decimal totalPrice = 0;
            //         Decimal totalSummary = 0;
            //         Decimal totalLeasableArea = 0;
            //         for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

            //             totalArea += measurementPricing.Area;
            //             totalPrice += measurementPricing.Price.value;
            //             totalSummary += measurementPricing.Summary;
            //             if (!measurementPricing.isFOC) {
            //                 totalLeasableArea += measurementPricing.Area;
            //             }
            //         }


            //         QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
            //         pricingSection.MinType = 'Measurement';
            //         pricingSection.MeasumentPricingList = measurementPricingList;
            //         pricingSection.TotalPrice = totalPrice;
            //         pricingSection.TotalArea = totalArea;
            //         pricingSection.TotalLeasableArea = totalLeasableArea;
            //         pricingSection.TotalSummary = totalSummary;
            //         pricingSection.FixedPricing = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
            //         pricingSection.FixedPricing.isToDeleteRecord = false;
            //         pricingSection.FixedPricing.Price = 0;
            //         pricingSection.FixedPricing.IsDisabled = false;

            //         period.GPOnTopSection = new QuotationComponentDataWrapper.GPOnTopSectionWrapper();
            //         period.GPOnTopSection.ReportingRuleList = reportingRuleList;
            //         period.GPOnTopSection.PricingSection = pricingSection;
            //     }

            //     periodList.add(period);

        }

        jsonResult = JSON.serialize(periodList);
        return jsonResult;
    }

    public static List<QuotationComponentDataWrapper.MeasurementPricingList> getMeasurementPricingList(Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap, Boolean isDisablePrice){
        List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = new List<QuotationComponentDataWrapper.MeasurementPricingList>();
        QuotationComponentDataWrapper.MeasurementPricingList measurementPricing;
        for(String eachROMeasurmentType : roMeasurementTypeMap.keySet()){

            measurementPricing = new QuotationComponentDataWrapper.MeasurementPricingList();
            measurementPricing.isToDeleteRecord = false;
            measurementPricing.MeasurementType = eachROMeasurmentType;
            measurementPricing.measurementId =  roMeasurementTypeMap.get(eachROMeasurmentType).measurementId;
            measurementPricing.isFOC = roMeasurementTypeMap.get(eachROMeasurmentType).isFOC;
            measurementPricing.roMeasurementId = roMeasurementTypeMap.get(eachROMeasurmentType).roMeasurementId;
            measurementPricing.roId = roMeasurementTypeMap.get(eachROMeasurmentType).roId;
            measurementPricing.roCode = roMeasurementTypeMap.get(eachROMeasurmentType).roCode;
            measurementPricing.Price = new QuotationComponentDataWrapper.UINumberInputClass(0, isDisablePrice);
            measurementPricing.Area = roMeasurementTypeMap.get(eachROMeasurmentType).measurementArea;
            measurementPricing.Summary = measurementPricing.Area * measurementPricing.Price.value;

            measurementPricingList.add(measurementPricing);
        }

        return measurementPricingList;
    }

	// #region Get Saved CAM
    @AuraEnabled
    public static String getSavedCAMPricingDetail(Id recordId, String escalationType, Decimal escalationRate, String selectedRoomJson, String oppUiWrapper){
        List<OpportunityPeriod__c> oppPeriodList = ObjectSelector.getOppPeriodCAMOrAirServiceFromOpp(recordId);
        Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        System.debug('oppPeriodList From Query'+oppPeriodList);
        String res;

        if (oppPeriodList!=null && !oppPeriodList.isEmpty()) {
            QuotationComponentDataWrapper.CAMPricingWrapper camPricingDetail;
            camPricingDetail = new QuotationComponentDataWrapper.CAMPricingWrapper();
            Map<Id,List<OpportunityPrice__c>> oppPrice = ObjectSelector.getOppPriceFromOpp(recordId,oppPeriodList);
            System.debug('oppPrice Map From Period '+ oppPrice);

            List<QuotationComponentDataWrapper.CAMYearPeriodWrapper> camYerPeriodList = new List<QuotationComponentDataWrapper.CAMYearPeriodWrapper>();

            List<QuotationComponentDataWrapper.MeasurmentWrapper> camMeasurementList;
            QuotationComponentDataWrapper.MeasurmentWrapper camMeasurement;
            QuotationComponentDataWrapper.CAMYearPeriodWrapper camYearPeriod;
            QuotationComponentDataWrapper.UINumberInputClass measurmentTypeInput;
            QuotationComponentDataWrapper.UINumberInputClass camEscalateRateInput = new QuotationComponentDataWrapper.UINumberInputClass((escalationRate!=null)?escalationRate:OpportunitySetting__c.getInstance().CAMEscalation__c, (escalationType=='Advance')?true:false);

            Decimal totalPrice = 0;
            Decimal totalArea = 0;

            System.debug('oppPeriodList' + oppPeriodList);
            for (OpportunityPeriod__c eachPeriod : oppPeriodList) {
                camYearPeriod = new QuotationComponentDataWrapper.CAMYearPeriodWrapper();
                camYearPeriod.Id = eachPeriod.Id;
                camYearPeriod.Year = Integer.valueof(eachPeriod.Sequence__c);
                camYearPeriod.DateTo = eachPeriod.PeriodTo__c;
                camYearPeriod.DateFrom = eachPeriod.PeriodFrom__c;
                camYearPeriod.IsDisableInput = (escalationType == Constant.RENT_SERVICE_ESCALATION)?true:false;
                camYearPeriod.isToDeleteRecord = false;
                camYearPeriod.isRenewCAMPeriod = false;
                camYearPeriod.isOptionToRenew = eachPeriod.IsOptionToRenew__c;

                camMeasurementList = new List<QuotationComponentDataWrapper.MeasurmentWrapper>();
                System.debug(oppPrice.get(eachPeriod.Id));

                totalPrice = 0;
                totalArea = 0;

                for(OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)){

                    camMeasurement = new QuotationComponentDataWrapper.MeasurmentWrapper();
                    measurmentTypeInput = new QuotationComponentDataWrapper.UINumberInputClass(null,null);

                    measurmentTypeInput.value = (eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0;

                    if(eachOppPrice.Measurement__r.IsFOC__c == true){
                        measurmentTypeInput.IsDisabled = true;
                        camMeasurement.isFOC = true;
                    }else{
                        camMeasurement.isFOC = false;

                        if (escalationType == Constant.RENT_SERVICE_ESCALATION) {
                            if (eachPeriod.Sequence__c == 1) {
                                measurmentTypeInput.IsDisabled = false;
                            }else{
                                measurmentTypeInput.IsDisabled = true;
                            }
                        }else{
                            measurmentTypeInput.IsDisabled = false;
                        }
                    }

                    camMeasurement.Price = measurmentTypeInput;
                    camMeasurement.measurementId = eachOppPrice.Measurement__c;
                    //camMeasurement.MeasurementType = eachOppPrice.Measurement__r.Type__c;
                    camMeasurement.MeasurementType = eachOppPrice.MeasurementType__c;
                    camMeasurement.oppPriceId = eachOppPrice.Id;
                    camMeasurement.isToDeleteRecord = false;

                    if(roMeasurementTypeMap.containsKey(eachOppPrice.MeasurementType__c)){
                        camMeasurement.MeasurementArea = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? roMeasurementTypeMap.get(eachOppPrice.MeasurementType__c).measurementArea :eachOppPrice.MeasurementAmount__c;
                        totalArea += roMeasurementTypeMap.get(eachOppPrice.MeasurementType__c).measurementArea;
                        totalPrice += roMeasurementTypeMap.get(eachOppPrice.MeasurementType__c).measurementArea * measurmentTypeInput.value;
                    }

                    camMeasurementList.add(camMeasurement);
                }
                camYearPeriod.CAMMeasurmentList = camMeasurementList;
                camYearPeriod.TotalPrice = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? totalPrice :eachPeriod.Total__c;
                camYearPeriod.TotalArea = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? totalArea :eachPeriod.TotalArea__c;

                camYerPeriodList.add(camYearPeriod);

            }

            camPricingDetail.oppId = recordId;
            camPricingDetail.CAMYearPeriod = camYerPeriodList;
            camPricingDetail.CAMEscationRate = camEscalateRateInput;
            camPricingDetail.CAMCondition = escalationType;
            camPricingDetail.CAMOrAirService = oppPeriodList.get(0).CalculationMethod__c;

            res = JSON.serialize(camPricingDetail);
            System.debug('camPricingDetail' + JSON.serialize(camPricingDetail));
        }
        return res;
    }

	// #region Get Saved RS
    @AuraEnabled
    public static String getSavedRentServicePricingDetail(Id oppId,String selectedRoomJson, String rentServiceEscalationType, Decimal rentServiceEscalationRate, String oppUiWrapper){
        String jsonResult;
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        List<OpportunityPeriod__c> oppPeriodList = ObjectSelector.getOppPeriodForRentAndServiceFromOpp(oppId);
        if (oppPeriodList!=null && !oppPeriodList.isEmpty()) {

            Map<Id,List<OpportunityPrice__c>> oppPrice = ObjectSelector.getOppPriceFromOpp(oppId,oppPeriodList);
            System.debug('RentService OppPrice '+ oppPrice);

            List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
            System.debug('desrialize '+ selectedRoomList);


            if (selectedRoomList!=null) {
                Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);
                QuotationComponentDataWrapper.RentServicePricingWrapper rentServiceDetail = new QuotationComponentDataWrapper.RentServicePricingWrapper();
                rentServiceDetail.isToDeleteRecord = false;
                rentServiceDetail.RentCondition = (rentServiceEscalationType!=null||!String.isBlank(rentServiceEscalationType))?rentServiceEscalationType:'% Escalation';
                rentServiceDetail.RentServiceEscalationRate = new QuotationComponentDataWrapper.UINumberInputClass((rentServiceEscalationRate!=null)?rentServiceEscalationRate:OpportunitySetting__c.getInstance().RentandServiceEscalation__c,(rentServiceEscalationType=='Advance')?true:false);
                List<QuotationComponentDataWrapper.MeasurmentWrapper> measurementWrapperList  = new List<QuotationComponentDataWrapper.MeasurmentWrapper>();

                for (OpportunityPeriod__c eachOppPeriod : oppPeriodList) {

                    if (eachOppPeriod.Sequence__c == 0) {

                        rentServiceDetail.rentServicePeriodId = eachOppPeriod.Id;

                        QuotationComponentDataWrapper.MeasurmentWrapper measurmentWrapper;

                        for(String eachROMeasurmentType : roMeasurementTypeMap.keySet()){
                            measurmentWrapper = new QuotationComponentDataWrapper.MeasurmentWrapper();
                            measurmentWrapper.MeasurementType = eachROMeasurmentType;
                            measurmentWrapper.isToDeleteRecord = false;
                            measurmentWrapper.isFOC = roMeasurementTypeMap.get(eachROMeasurmentType).isFOC;
                            measurmentWrapper.measurementId = roMeasurementTypeMap.get(eachROMeasurmentType).measurementId;

                            System.debug('oppPrice.get(eachOppPeriod.Id) '+oppPrice.get(eachOppPeriod.Id));
                            if (!oppPrice.isEmpty()) {
                                for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachOppPeriod.Id)) {
                                    if (eachOppPrice.SubType__c == Constant.CAL_METHOD_RENT_SERVICE && eachOppPrice.PriceItem__c == eachROMeasurmentType) {
                                        measurmentWrapper.MeasurementArea = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? roMeasurementTypeMap.get(eachROMeasurmentType).MeasurementArea : eachOppPrice.MeasurementAmount__c;
                                        measurmentWrapper.Price = new QuotationComponentDataWrapper.UINumberInputClass((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0,(rentServiceEscalationType=='Advance')?true:false);
                                        measurmentWrapper.oppPriceId = eachOppPrice.Id;
                                    }
                                }
                            }
                            measurementWrapperList.add(measurmentWrapper);

                        }
                    }
                }
                rentServiceDetail.RentServiceMeasurment = measurementWrapperList;
                rentServiceDetail.RentalObjectList = selectedRoomList;

                jsonResult = JSON.serialize(rentServiceDetail);
            }
        }
        return jsonResult;
    }

	// #region Get Saved Pricing
	/**
	 * CR Feb 2025
	 */
    @AuraEnabled
    public static String getSavedPeriodPricingDetail(Id oppId, String oppUiWrapper, String selectedRoomJson, String rentServiceEscalationType, String calculationMethod){
        Map<String,String> calculationMethodLabel = getPicklistOption('Opportunity', 'Calculation_Method__c');
        List<String> calculationMethodList = new List<String>{
            Constant.CAL_METHOD_FIXED_PRICE,
            Constant.CAL_METHOD_FIXED_RO,
            Constant.CAL_METHOD_FIXED_MEAS,
            Constant.CAL_METHOD_GP_NOMIN,
            Constant.CAL_METHOD_GP_WITHMIN,
            Constant.CAL_METHOD_GP_ONTOP
        };
        String res;
        System.debug('Incomming selectedRoom JSON' + selectedRoomJson);
        List<OpportunityPeriod__c> oppPeriodList = ObjectSelector.getOppPeriodFromOpp(oppId,calculationMethodList);
        System.debug('Prcing Period ' + oppPeriodList);

         if (oppPeriodList!=null && !oppPeriodList.isEmpty()) {

            Map<String,String> repotingRuleValue = new Map<String,String>{'Sales before VAT' => 'Sales before VAT'};

            List<QuotationComponentDataWrapper.PeriodPricing> periodList = new List<QuotationComponentDataWrapper.PeriodPricing>();
            List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
            QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);


            System.debug('selectedRoomList Apex ' +selectedRoomList);
            Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);

            Decimal roMeasurmentTotalLeasableArea = 0;
            Decimal roMeasurmentTotalArea = 0;

            for(String eachROMeasurmentType : roMeasurementTypeMap.keySet()){
                if(!roMeasurementTypeMap.get(eachROMeasurmentType).isFOC){
                    roMeasurmentTotalLeasableArea += roMeasurementTypeMap.get(eachROMeasurmentType).MeasurementArea;
                }

                roMeasurmentTotalArea += roMeasurementTypeMap.get(eachROMeasurmentType).MeasurementArea;
            }

            Map<Id,List<OpportunityPrice__c>> oppPrice = ObjectSelector.getOppPriceFromOpp(oppId,oppPeriodList);
            System.debug('period OppPrice '+ oppPrice);
            Map<Id,Map<String,List<OpportunityGradingModel.Data>>> oppGradning = ObjectSelector.getOppGradingFromOpp(oppId,oppPeriodList);

            QuotationComponentDataWrapper.PeriodPricing period;
            for (OpportunityPeriod__c eachPeriod : oppPeriodList){
                QuotationComponentDataWrapper.ProportionWrapper proportion = new QuotationComponentDataWrapper.ProportionWrapper();

                proportion.Proportion = eachPeriod.CalculationMethod__c;
                proportion.Rent = eachPeriod.RentPercent__c;
                proportion.Service = eachPeriod.ServicePercent__c;

                period = new QuotationComponentDataWrapper.PeriodPricing();
                period.isCustomPeriod = eachPeriod.IsAddedPeriod__c;
                period.isToDeleteRecord = false;
                period.Id = eachPeriod.Id;
                period.PeriodNumber = Integer.valueof(eachPeriod.Sequence__c);
                period.PricingFrom = eachPeriod.PeriodFrom__c;
                period.PricingTo = eachPeriod.PeriodTo__c;
                period.CalculationMethod = eachPeriod.CalculationMethod__c;
                period.CalculationMethodLabel = calculationMethodLabel.get(eachPeriod.CalculationMethod__c);
                period.IsIncludeCAM = eachPeriod.IsIncludeCAM__c;
                period.OptionToRenew = eachPeriod.IsOptionToRenew__c;
                period.Proportion = proportion;
                period.TotalArea = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? roMeasurmentTotalArea :eachPeriod.TotalArea__c;
                period.IsAllSales = eachPeriod.IsAllSales__c;
                period.EstimateRevernue = eachPeriod.EstimateRevernue__c;
                period.escalationRemark = eachPeriod.EscalationRemark__c;

                if (eachPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_PRICE) {
                    // String minType = eachPeriod.MinType__c;
                    // Decimal totalRentalObjectLeasable = 0;

                    // period.FixedPriceSection = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
                    // period.FixedPriceSection.isToDeleteRecord = false;
                    // period.FixedPriceSection.MinType = minType;

                    // for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList){
                    //     if (!eachSelectedRO.isToDeleteRecord){
                    //         totalRentalObjectLeasable += (eachSelectedRO.leasableArea!=null)?eachSelectedRO.leasableArea:0;
                    //     }
                    // }

                    // for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)) {
                    //     if(eachOppPrice.CalculationMethod__c == Constant.CAL_METHOD_FIXED_PRICE && eachOppPrice.ProportionPercent__c == null){
                    //         period.FixedPriceSection.IsDisabled = false;
                    //         period.FixedPriceSection.oppPriceId = eachOppPrice.Id;
                    //         period.FixedPriceSection.TotalArea = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? totalRentalObjectLeasable : eachOppPrice.MeasurementAmount__c;

                    //         if (minType == 'Measurement'){
                    //             period.FixedPriceSection.Price =  (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? ((oppDetail.isWindowDisplay)?(eachOppPrice.PriceVAT__c * period.FixedPriceSection.TotalArea) : (eachOppPrice.Price__c * period.FixedPriceSection.TotalArea)) :((oppDetail.isWindowDisplay)?eachOppPrice.TotalPriceVAT__c : eachOppPrice.TotalPrice__c);
                    //             period.FixedPriceSection.Price_withoutVat =  (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)?((oppDetail.isWindowDisplay)? (eachOppPrice.Price__c * period.FixedPriceSection.TotalArea): 0):((oppDetail.isWindowDisplay)? eachOppPrice.TotalPrice__c: 0);
                    //             period.FixedPriceSection.PriceSQM_withoutVat = (oppDetail.isWindowDisplay)?eachOppPrice.Price__c:0;
                    //             period.FixedPriceSection.PriceSQM = (oppDetail.isWindowDisplay)?eachOppPrice.PriceVAT__c:eachOppPrice.Price__c;

                    //         }else if (minType == 'Fixed'){
                    //             period.FixedPriceSection.Price = (oppDetail.isWindowDisplay)?eachOppPrice.PriceVAT__c:eachOppPrice.Price__c;
                    //             period.FixedPriceSection.PriceSQM = 0;
                    //             period.FixedPriceSection.Price_withoutVat = (oppDetail.isWindowDisplay)?eachOppPrice.Price__c:0;
                    //             period.FixedPriceSection.PriceSQM_withoutVat = 0;

                    //         }

                    //     }
                    // }

                }else if(eachPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_RO){
                    period.FixedRentalObjectSection = new QuotationComponentDataWrapper.FixedRentalObjectSectionWrapper();

                    String minType = eachPeriod.MinType__c;

                    Decimal totalRentalObjectArea = 0;
                    Decimal totalRentalObjectLeasable = 0;
                    Decimal totalRentalObjectPrice = 0;
                    Decimal totalRentalObjectPriceSQM = 0;
                    Decimal totalRentalObjectPrice_withOutVat = 0;
                    Decimal totalRentalObjectPriceSQM_withOutVat = 0;

                    List<QuotationComponentDataWrapper.RentalObjectPricingWrapper> roPricingList = new List<QuotationComponentDataWrapper.RentalObjectPricingWrapper>();
                    QuotationComponentDataWrapper.RentalObjectPricingWrapper roPricing;

                    for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList) {
                        if (!eachSelectedRO.isToDeleteRecord) {
                            System.debug('eachSelectedRO'+eachSelectedRO);
                            roPricing = new QuotationComponentDataWrapper.RentalObjectPricingWrapper();
                            roPricing.isToDeleteRecord = false;
                            roPricing.roId = eachSelectedRO.Id;
                            roPricing.roCode = eachSelectedRO.roCode;
                            roPricing.RentalObject = eachSelectedRO.roomNumber;
                            roPricing.TotalArea = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? ((eachSelectedRO.totalArea!=null)?eachSelectedRO.totalArea:0) : ((eachSelectedRO.oppLineTotalArea!=null)?eachSelectedRO.oppLineTotalArea:0);
                            roPricing.LeasableArea = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? ((eachSelectedRO.leasableArea!=null)?eachSelectedRO.leasableArea:0) : ((eachSelectedRO.oppLineLeasableArea!=null)?eachSelectedRO.oppLineLeasableArea:0);

                            System.debug('get Saved '+ eachSelectedRO.roMeasurmentList);
                            roPricing.roMeasurementList = new List<QuotationComponentDataWrapper.ROMeasurementClass>(eachSelectedRO.roMeasurmentList);

                            for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)) {
                                System.debug('eachOppPrice'+eachOppPrice);
                                if(eachOppPrice.CalculationMethod__c == Constant.CAL_METHOD_FIXED_RO && eachOppPrice.ProportionPercent__c == null && eachOppPrice.Unit__c == roPricing.roId){
                                    System.debug('Pass My Condition');

                                    if (minType == 'Measurement'){
                                        roPricing.PriceSQM =(oppDetail.isWindowDisplay)? (new QuotationComponentDataWrapper.UINumberInputClass((eachOppPrice.PriceVAT__c!=null)?eachOppPrice.PriceVAT__c:0, false)) : (new QuotationComponentDataWrapper.UINumberInputClass((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0, false));
                                        roPricing.PriceSQM_withoutVat =(oppDetail.isWindowDisplay)? ((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0) : 0;
                                        roPricing.Price = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? (new QuotationComponentDataWrapper.UINumberInputClass((oppDetail.isWindowDisplay)?(roPricing.PriceSQM_withoutVat * roPricing.LeasableArea):(roPricing.PriceSQM.value * roPricing.LeasableArea), false)) :(new QuotationComponentDataWrapper.UINumberInputClass((oppDetail.isWindowDisplay)?((eachOppPrice.TotalPriceVAT__c!=null)?eachOppPrice.TotalPriceVAT__c:0):((eachOppPrice.TotalPrice__c!=null)?eachOppPrice.TotalPrice__c:0), false));
                                        roPricing.Price_withoutVat = (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION)? ((oppDetail.isWindowDisplay)?(roPricing.PriceSQM_withoutVat * roPricing.LeasableArea):0) : ((oppDetail.isWindowDisplay)?((eachOppPrice.TotalPrice__c!=null)?eachOppPrice.TotalPrice__c:0):0);
										/**
										 * CR Feb 2025
										 * Changed Detail: add more attribute in wrapper to get saved value
										 */
										//
										//
										//
										// Changed end

                                    }else if (minType == 'Fixed'){
                                        roPricing.PriceSQM_withoutVat = 0;
                                        roPricing.Price_withoutVat = (oppDetail.isWindowDisplay)? ((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0) :0;
                                        roPricing.Price = (oppDetail.isWindowDisplay)? (new QuotationComponentDataWrapper.UINumberInputClass((eachOppPrice.PriceVAT__c!=null)?eachOppPrice.PriceVAT__c:0, false)) : (new QuotationComponentDataWrapper.UINumberInputClass((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0, false));
                                        roPricing.PriceSQM = new QuotationComponentDataWrapper.UINumberInputClass(0, false);
										/**
										 * CR Feb 2025
										 * Changed Detail: add more attribute in wrapper to get saved value
										 */
										//
										//
										//
										// Changed end

                                    }

                                    roPricing.oppPriceId = eachOppPrice.Id;
                                }
                            }

                            totalRentalObjectArea += (roPricing.TotalArea!=null)?roPricing.TotalArea:0;
                            totalRentalObjectLeasable += (roPricing.LeasableArea!=null)?roPricing.LeasableArea:0;
                            totalRentalObjectPrice += (roPricing.Price?.value!=null)?roPricing.Price.value:0;
                            totalRentalObjectPrice_withOutVat += (roPricing.Price_withoutVat!=null)?roPricing.Price_withoutVat:0;
							/**
							 * CR Feb 2025
							 * Changed Detail: add more calculate accoumulative value
							 */
							//
							//
							//
							// Changed end

                            roPricingList.add(roPricing);
                        }
                    }

                    totalRentalObjectPriceSQM = totalRentalObjectLeasable != 0 ? totalRentalObjectPrice/totalRentalObjectLeasable : 0;
                    totalRentalObjectPriceSQM_withOutVat = totalRentalObjectLeasable != 0 ? totalRentalObjectPrice_withOutVat/totalRentalObjectLeasable : 0;

                    period.FixedRentalObjectSection.MinType = minType;
                    period.FixedRentalObjectSection.rentalObjectList = roPricingList;
                    period.FixedRentalObjectSection.TotalArea = (totalRentalObjectArea!=null)?totalRentalObjectArea:0;
                    period.FixedRentalObjectSection.TotalLeasableArea = (totalRentalObjectLeasable!=null)?totalRentalObjectLeasable:0;
                    period.FixedRentalObjectSection.TotalPrice = (totalRentalObjectPrice!=null)?totalRentalObjectPrice:0;
                    period.FixedRentalObjectSection.TotalPriceSQm = (totalRentalObjectPriceSQM!=null)?totalRentalObjectPriceSQM:0;
                    period.FixedRentalObjectSection.TotalPrice_withOutVat = (totalRentalObjectPrice_withOutVat != null)?totalRentalObjectPrice_withOutVat:0;
                    period.FixedRentalObjectSection.TotalPriceSQm_withOutVat = (totalRentalObjectPriceSQM_withOutVat != null)?totalRentalObjectPriceSQM_withOutVat:0;
					/**
					 * CR Feb 2025
					 * Changed Detail: assign more cumulative value in wrapper
					 */
					//
					//
					//
					// Changed end


                }else if(eachPeriod.CalculationMethod__c == Constant.CAL_METHOD_FIXED_MEAS){
                    // period.FixedMeasurementSection = new QuotationComponentDataWrapper.FixedMeasurementSectionWrapper();

                    // List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,(rentServiceEscalationType==Constant.RENT_SERVICE_ESCALATION)?(period.isCustomPeriod)?false:true:false);

                    // Decimal totalArea = 0;
                    // Decimal totalPrice = 0;
                    // Decimal totalSummary = 0;
                    // Decimal totalPrice_withoutVat = 0;
                    // Decimal totalSummary_withoutVat = 0;

                    // for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                    //     for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)) {
                    //         if(eachOppPrice.CalculationMethod__c == Constant.CAL_METHOD_FIXED_MEAS && eachOppPrice.MeasurementType__c == measurementPricing.MeasurementType && eachOppPrice.ProportionPercent__c == null){

                    //             if (oppDetail.oppStageName != Constant.OPP_STAGE_QUOTATIONPREPARATION) {
                    //                 measurementPricing.Area = eachOppPrice.MeasurementAmount__c;
                    //             }

                    //             measurementPricing.Price.value = (oppDetail.isWindowDisplay)?((eachOppPrice.PriceVAT__c!=null)?eachOppPrice.PriceVAT__c:0):((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0);
                    //             measurementPricing.Price_withOutVat = (oppDetail.isWindowDisplay)?((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0) : 0;
                    //             measurementPricing.Summary_withOutVat = measurementPricing.Area * measurementPricing.Price_withOutVat;
                    //             measurementPricing.Summary = measurementPricing.Area * measurementPricing.Price.value;
                    //             measurementPricing.oppPriceId = eachOppPrice.Id;
                    //         }
                    //     }
                    //     System.debug('Test Debug'+ measurementPricing);
                    //     totalArea += measurementPricing.Area;
                    //     totalPrice += measurementPricing.Price.value;
                    //     totalSummary += measurementPricing.Summary;
                    //     totalPrice_withoutVat += (measurementPricing.Price_withOutVat!=null)?measurementPricing.Price_withOutVat:0;
                    //     totalSummary_withoutVat += (measurementPricing.Summary_withOutVat!=null)?measurementPricing.Summary_withOutVat:0;
                    // }

                    // period.FixedMeasurementSection.pricingList = measurementPricingList;
                    // period.FixedMeasurementSection.TotalArea = totalArea;
                    // period.FixedMeasurementSection.TotalPrice = totalPrice;
                    // period.FixedMeasurementSection.TotalSummary = totalSummary;
                    // period.FixedMeasurementSection.TotalPrice_withoutVat = totalPrice_withoutVat;
                    // period.FixedMeasurementSection.TotalSummary_withoutVat = totalSummary_withoutVat;

                }else if(eachPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_NOMIN){
                    System.debug('===============Check Load GP=============');
                    System.debug('oppGradning : '+oppGradning.size());
                    List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
                    QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule ;

                    for (String eachOppGradingReportingRule : oppGradning.get(eachPeriod.Id).keySet()) {
                        reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper();
                        reportingRule.isToDeleteRecord =false;
                        reportingRule.ReportingRule = eachOppGradingReportingRule.split('_').get(0);
                        reportingRule.reportingRulId = oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).Id;
                        reportingRule.ReportingRuleLabel = repotingRuleValue.get(reportingRule.ReportingRule);
                        reportingRule.ReportingRuleDescription = oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).SalesDescription;
                        reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();
                        reportingRule.GroupNumber = Integer.valueOf(oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).GroupNo);

                        QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReporting;
                        for (OpportunityGradingModel.Data eachOppGrading : oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule)) {
                            eachReporting = new QuotationComponentDataWrapper.ReportingRuleDetailWrapper();
                            eachReporting.isToDeleteRecord = false;
                            eachReporting.reportingRuleDetailId = eachOppGrading.Id;
                            eachReporting.rangFrom = (eachOppGrading.FromR!=null)?eachOppGrading.FromR:0;
                            eachReporting.rangTo = (eachOppGrading.ToR!=null)?eachOppGrading.ToR:0;
                            eachReporting.GPPercent = (eachOppGrading.GP!=null)?eachOppGrading.GP:0;
                            eachReporting.IsIncludeCam = eachOppGrading.IsIncludeCAM;
                            eachReporting.gpYearlyTier = eachOppGrading.GradingTierOption;

                            reportingRule.ReportingRuleDetailList.add(eachReporting);
                        }

                        reportingRuleList.add(reportingRule);
                    }

                    period.GPNoMinSection = new QuotationComponentDataWrapper.GPNoMinSectionWrapper();
                    period.GPNoMinSection.ReportingRuleList = reportingRuleList;
                }else if(eachPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_WITHMIN){
                    List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
                    QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule;


                    for (String eachOppGradingReportingRule : oppGradning.get(eachPeriod.Id).keySet()) {
                        reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper();
                        reportingRule.isToDeleteRecord = false;
                        reportingRule.ReportingRule = eachOppGradingReportingRule.split('_').get(0);
                        reportingRule.reportingRulId = oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).Id;
                        reportingRule.ReportingRuleLabel = repotingRuleValue.get(reportingRule.ReportingRule);
                        reportingRule.ReportingRuleDescription = oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).SalesDescription;
                        reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();
                        reportingRule.GroupNumber = Integer.valueOf(oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).GroupNo);

                        QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReporting;
                        for (OpportunityGradingModel.Data eachOppGrading : oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule)) {
                            eachReporting = new QuotationComponentDataWrapper.ReportingRuleDetailWrapper();
                            eachReporting.reportingRuleDetailId = eachOppGrading.Id;
                            eachReporting.isToDeleteRecord = false;
                            eachReporting.GradingIndex = Integer.valueof(eachOppGrading.GPRangeNo);
                            eachReporting.rangFrom = (eachOppGrading.FromR!=null)?eachOppGrading.FromR:0;
                            eachReporting.rangTo = (eachOppGrading.ToR!=null)?eachOppGrading.ToR:0;
                            eachReporting.GPPercent = (eachOppGrading.GP!=null)?eachOppGrading.GP:0;
                            eachReporting.IsIncludeCam = eachOppGrading.IsIncludeCAM;
                            eachReporting.gpYearlyTier = eachOppGrading.GradingTierOption;

                            reportingRule.ReportingRuleDetailList.add(eachReporting);
                        }

                        reportingRuleList.add(reportingRule);
                    }


                   List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,(rentServiceEscalationType==Constant.RENT_SERVICE_ESCALATION)?(period.isCustomPeriod)?false:true:false);
                   QuotationComponentDataWrapper.FixedPriceSectionWrapper fixedPricingSection = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
                   fixedPricingSection.isToDeleteRecord = false;

                    Decimal totalArea = 0;
                    Decimal totalPrice = 0;
                    Decimal totalSummary = 0;
                    Decimal totalLeasableArea = 0;
                    Decimal totalPrice_withoutVat = 0;
                    Decimal totalSummary_withoutVat = 0;

                    String minType = eachPeriod.MinType__c;
                    System.debug('MinType' + minType);
                    if (minType == 'Measurement'){
                        for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                            for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)) {
                                if(eachOppPrice.ProportionPercent__c == null){
                                    if(eachOppPrice.CalculationMethod__c == Constant.CAL_METHOD_GP_WITHMIN && eachOppPrice.MeasurementType__c == measurementPricing.MeasurementType){

                                        if (oppDetail.oppStageName != Constant.OPP_STAGE_QUOTATIONPREPARATION) {
                                            measurementPricing.Area = eachOppPrice.MeasurementAmount__c;
                                        }

                                        measurementPricing.Price.value = (oppDetail.isWindowDisplay)?eachOppPrice.PriceVAT__c:eachOppPrice.Price__c;
                                        measurementPricing.Summary = measurementPricing.Area * measurementPricing.Price.value;
                                        measurementPricing.Price_withOutVat = (oppDetail.isWindowDisplay)?((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0) : 0;
                                        measurementPricing.Summary_withOutVat = measurementPricing.Area * measurementPricing.Price_withOutVat;
                                    }
                                }
                            }

                            if (!measurementPricing.isFOC) {
                                totalLeasableArea += measurementPricing.Area;
                            }

                            totalArea += measurementPricing.Area;
                            totalPrice += measurementPricing.Price.value;
                            totalSummary += measurementPricing.Summary;
                            totalPrice_withoutVat += (measurementPricing.Price_withOutVat!=null)?measurementPricing.Price_withOutVat:0;
                            totalSummary_withoutVat += (measurementPricing.Summary_withOutVat!=null)?measurementPricing.Summary_withOutVat:0;


                        }
                        fixedPricingSection.isToDeleteRecord = false;
                        fixedPricingSection.Price = 0;
                        fixedPricingSection.IsDisabled = false;
                    }else if (minType == 'Fixed'){
                        System.debug('ComeToFixed');
                        for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)){
                            System.debug('eachOppPrice Fixed PRice GP' + eachOppPrice);
                            if(eachOppPrice.ProportionPercent__c == null){
                                if (eachOppPrice.CalculationMethod__c == Constant.CAL_METHOD_GP_WITHMIN) {
                                    System.debug('Assign Fixed PRice GP');
                                    fixedPricingSection.Price = (oppDetail.isWindowDisplay)?((eachOppPrice.PriceVAT__c!=null)?eachOppPrice.PriceVAT__c:0):((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0);
                                    fixedPricingSection.Price_withoutVat = (oppDetail.isWindowDisplay)?((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0) : 0;
                                    fixedPricingSection.IsDisabled = false;
                                }
                            }
                        }

                        for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                            totalArea += measurementPricing.Area;
                            totalPrice += measurementPricing.Price.value;
                            totalSummary += measurementPricing.Summary;
                            if (!measurementPricing.isFOC) {
                                totalLeasableArea += measurementPricing.Area;
                            }
                        }
                    }


                    QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
                    pricingSection.MinType = minType;
                    pricingSection.MeasumentPricingList = measurementPricingList;
                    pricingSection.TotalPrice = totalPrice;
                    pricingSection.TotalArea = totalArea;
                    pricingSection.TotalSummary = totalSummary;
                    pricingSection.TotalLeasableArea = totalLeasableArea;
                    pricingSection.FixedPricing = fixedPricingSection;
                    pricingSection.TotalPrice_withoutVat = totalPrice_withoutVat;
                    pricingSection.TotalSummary_withoutVat = totalSummary_withoutVat;


                    period.GPWithMinSection = new QuotationComponentDataWrapper.GPWithMinSectionWrapper();
                    period.GPWithMinSection.ReportingRuleList = reportingRuleList;
                    period.GPWithMinSection.SalesMin = (eachPeriod.SalesMin__c!=null)?eachPeriod.SalesMin__c:0;
                    period.GPWithMinSection.PricingSection = pricingSection;
                }
                else if(eachPeriod.CalculationMethod__c == Constant.CAL_METHOD_GP_ONTOP){
                    List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
                    QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule;

                    for (String eachOppGradingReportingRule : oppGradning.get(eachPeriod.Id).keySet()) {
                        reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper();
                        reportingRule.isToDeleteRecord = false;
                        reportingRule.ReportingRule = eachOppGradingReportingRule.split('_').get(0);
                        reportingRule.ReportingRuleLabel = repotingRuleValue.get(reportingRule.ReportingRule);
                        reportingRule.reportingRulId = oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).Id;
                        reportingRule.ReportingRuleDescription = oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).SalesDescription;
                        reportingRule.ReportingRuleDetailList = new List<QuotationComponentDataWrapper.ReportingRuleDetailWrapper>();
                        reportingRule.GroupNumber = Integer.valueOf(oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule).get(0).GroupNo);

                        QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReporting ;
                        for (OpportunityGradingModel.Data eachOppGrading : oppGradning.get(eachPeriod.Id).get(eachOppGradingReportingRule)) {
                            System.debug('eachOppGrading' + eachOppGrading);
                            eachReporting = new QuotationComponentDataWrapper.ReportingRuleDetailWrapper();
                            eachReporting.reportingRuleDetailId = eachOppGrading.Id;
                            eachReporting.GradingIndex =  Integer.valueof(eachOppGrading.GPRangeNo);
                            eachReporting.rangFrom = (eachOppGrading.FromR!=null)?eachOppGrading.FromR:0;
                            eachReporting.rangTo = (eachOppGrading.ToR!=null)?eachOppGrading.ToR:0;
                            eachReporting.GPPercent = (eachOppGrading.GP!=null)?eachOppGrading.GP:0;
                            eachReporting.IsIncludeCam = eachOppGrading.IsIncludeCAM;
                            eachReporting.gpYearlyTier = eachOppGrading.GradingTierOption;

                            reportingRule.ReportingRuleDetailList.add(eachReporting);
                        }

                        reportingRuleList.add(reportingRule);
                    }


                   List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,(rentServiceEscalationType==Constant.RENT_SERVICE_ESCALATION)?(period.isCustomPeriod)?false:true:false);
                   QuotationComponentDataWrapper.FixedPriceSectionWrapper fixedPricingSection = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
                   fixedPricingSection.isToDeleteRecord = false;

                    Decimal totalArea = 0;
                    Decimal totalPrice = 0;
                    Decimal totalSummary = 0;
                    Decimal totalLeasableArea = 0;
                    Decimal totalPrice_withoutVat = 0;
                    Decimal totalSummary_withoutVat = 0;

                    String minType = eachPeriod.MinType__c;

                    if (minType == 'Measurement'){
                        for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                            for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)) {

                                if(eachOppPrice.ProportionPercent__c == null){
                                    if(eachOppPrice.CalculationMethod__c == Constant.CAL_METHOD_GP_ONTOP && eachOppPrice.MeasurementType__c == measurementPricing.MeasurementType){

                                        if (oppDetail.oppStageName != Constant.OPP_STAGE_QUOTATIONPREPARATION) {
                                            measurementPricing.Area = eachOppPrice.MeasurementAmount__c;
                                        }

                                        measurementPricing.Price.value = (oppDetail.isWindowDisplay)?((eachOppPrice.PriceVAT__c!=null)?eachOppPrice.PriceVAT__c:0):((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0);
                                        measurementPricing.Summary = measurementPricing.Area * measurementPricing.Price.value;
                                        measurementPricing.Price_withOutVat = (oppDetail.isWindowDisplay)?((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0) : 0;
                                        measurementPricing.Summary_withOutVat = measurementPricing.Area * measurementPricing.Price_withOutVat;
                                    }
                                }
                            }

                            if (!measurementPricing.isFOC) {
                                totalLeasableArea += measurementPricing.Area;
                            }

                            totalArea += measurementPricing.Area;
                            totalPrice += measurementPricing.Price.value;
                            totalSummary += measurementPricing.Summary;
                            totalPrice_withoutVat += (measurementPricing.Price_withOutVat!=null)?measurementPricing.Price_withOutVat:0;
                            totalSummary_withoutVat += (measurementPricing.Summary_withOutVat!=null)?measurementPricing.Summary_withOutVat:0;

                        }
                        fixedPricingSection.isToDeleteRecord = false;
                        fixedPricingSection.Price = 0;
                        fixedPricingSection.IsDisabled = false;
                    }else if (minType == 'Fixed'){
                        for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachPeriod.Id)){
                            if(eachOppPrice.ProportionPercent__c == null){
                                if (eachOppPrice.CalculationMethod__c == Constant.CAL_METHOD_GP_ONTOP) {
                                    fixedPricingSection.Price = (oppDetail.isWindowDisplay)?((eachOppPrice.PriceVAT__c!=null)?eachOppPrice.PriceVAT__c:0):((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0);
                                    fixedPricingSection.Price_withoutVat = (oppDetail.isWindowDisplay)?((eachOppPrice.Price__c!=null)?eachOppPrice.Price__c:0) : 0;
                                    fixedPricingSection.IsDisabled = false;
                                }
                            }
                        }

                        for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                            totalArea += measurementPricing.Area;
                            totalPrice += measurementPricing.Price.value;
                            totalSummary += measurementPricing.Summary;
                            if (!measurementPricing.isFOC) {
                                totalLeasableArea += measurementPricing.Area;
                            }
                        }
                    }

                    QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
                    pricingSection.MinType = minType;
                    pricingSection.MeasumentPricingList = measurementPricingList;
                    pricingSection.TotalPrice = totalPrice;
                    pricingSection.TotalArea = totalArea;
                    pricingSection.TotalSummary = totalSummary;
                    pricingSection.TotalLeasableArea = totalLeasableArea;
                    pricingSection.FixedPricing = fixedPricingSection;
                    pricingSection.TotalPrice_withoutVat = totalPrice_withoutVat;
                    pricingSection.TotalSummary_withoutVat = totalSummary_withoutVat;


                    period.GPOnTopSection = new QuotationComponentDataWrapper.GPOnTopSectionWrapper();
                    period.GPOnTopSection.ReportingRuleList = reportingRuleList;
                    period.GPOnTopSection.PricingSection = pricingSection;
                }

                periodList.add(period);


            }

            res = JSON.serialize(periodList);
            System.debug('periodList'+JSON.serialize(periodList));
        }
        return res;
    }

	// #region Get Saved Inst
    @AuraEnabled
    public static String getSavedExpenseINstallmentJson(Id oppId){
        String res;
        List<OpportunityDepositExpense__c> oppDepositExpenseList = ObjectSelector.getOppDepositAndExpense(oppId, 'Expense');
        if (oppDepositExpenseList!=null && !oppDepositExpenseList.isEmpty()) {
            Set<String> oppExpenseIds = new Set<String>();
            for(OpportunityDepositExpense__c eachOppExpense : oppDepositExpenseList) {
                oppExpenseIds.add(eachOppExpense.Id);
            }
            List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expensList = new List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>();
            List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> leaseHoldExpensList = new List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>();

            Map<Id,List<OpportunityPrice__c>> oppPrice = ObjectSelector.getOppPriceFromOppExpense(oppId,oppDepositExpenseList,'Expense');
            Decimal totalInstallment = 0;
            Decimal leaseholdTotalArea = 0;
            Decimal leaseholdTotalPrice = 0;

            //List<tms_OpportunityLeaseholdFloor__c> leaseHoldFloor = [SELECT Id, tms_Floor__c, tms_TotalPrice__c, tms_OpportunityDepositExpense__c, tms_PricePerSqm__c, tms_Area__c, tms_Measurement__c, tms_BuildingFloor__c FROM tms_OpportunityLeaseholdFloor__c WHERE tms_OpportunityDepositExpense__c IN: oppDepositExpenseList];
            List<OpportunityLeaseholdFloorModel.Data> leaseHoldFloor = OpportunityLeaseholdFloorModel.getData(oppId);
            Map<Id,List<OpportunityLeaseholdFloorModel.Data>> leaseHoldFloorMap = new Map<Id,List<OpportunityLeaseholdFloorModel.Data>>();

            for (OpportunityLeaseholdFloorModel.Data eachLeaseHoldFloor : leaseHoldFloor) {
                if(oppExpenseIds.contains(eachLeaseHoldFloor.OpportunityDepositExpense)) {
                    if(leaseHoldFloorMap.containsKey(eachLeaseHoldFloor.OpportunityDepositExpense)){
                        leaseHoldFloorMap.get(eachLeaseHoldFloor.OpportunityDepositExpense).add(eachLeaseHoldFloor);
                    }else{
                        leaseHoldFloorMap.put(eachLeaseHoldFloor.OpportunityDepositExpense, new List<OpportunityLeaseholdFloorModel.Data>{eachLeaseHoldFloor});
                    }
                }
            }

            QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper  expenseInstallment;
            QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper  expenseInstallmentLeaseHoldSummary;

            for(OpportunityDepositExpense__c eachOppExpense : oppDepositExpenseList){

                expenseInstallment = new QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper();
                expenseInstallmentLeaseHoldSummary = new QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper();

                totalInstallment = 0;

                if(eachOppExpense.OpportunityDepositExpense__c != null){

                    leaseholdTotalArea = 0;
                    leaseholdTotalPrice = 0;

                    expenseInstallment.Id = eachOppExpense.Id;
                    expenseInstallment.Type = eachOppExpense.Type__c;
                    expenseInstallment.TypeGroup = eachOppExpense.TypeGroup__c;
                    expenseInstallment.TotalAmount = eachOppExpense.Price__c;
                    expenseInstallment.NumberOfInstallment = Integer.valueof(eachOppExpense.NumberOfInstallment__c);
                    expenseInstallment.Remark = eachOppExpense.Remark__c;
                    expenseInstallment.isLEASEHOLD = true;
                    expenseInstallment.isLEASEHOLDSUMMARY = false;
                    expenseInstallment.isLeaseHoldDisableINstallment = (leaseHoldExpensList.isEmpty())?false:true;

                    expenseInstallment.leaseHoldInfo = new List<QuotationComponentDataWrapper.LeaseHoldFloorInfoTable>();
                    QuotationComponentDataWrapper.LeaseHoldFloorInfoTable leaseHoldObject;
                    for (OpportunityLeaseholdFloorModel.Data eachLeaseHoldFloorExpt : leaseHoldFloorMap.get(eachOppExpense.Id)) {
                        leaseHoldObject = new QuotationComponentDataWrapper.LeaseHoldFloorInfoTable();
                        leaseHoldObject.Id = eachLeaseHoldFloorExpt.Id;
                        leaseHoldObject.floorName = eachLeaseHoldFloorExpt.Floor;
                        leaseHoldObject.area = eachLeaseHoldFloorExpt.Area;
                        leaseHoldObject.price = eachLeaseHoldFloorExpt.PricePerSqm;
                        leaseHoldObject.totalAmount = eachLeaseHoldFloorExpt.TotalPrice;
                        leaseHoldObject.floorId = eachLeaseHoldFloorExpt.BuildingFloor;
                        leaseHoldObject.measurementId = eachLeaseHoldFloorExpt.Measurement;

                        leaseholdTotalArea += (leaseHoldObject.area != null)?leaseHoldObject.area : 0;
                        leaseholdTotalPrice += (leaseHoldObject.price != null)?leaseHoldObject.price : 0;

                        expenseInstallment.leaseHoldInfo.add(leaseHoldObject);
                    }

                    expenseInstallment.leaseHoldTotalArea = leaseholdTotalArea;
                    expenseInstallment.leaseHoldTotalPrice = leaseholdTotalPrice;

                    expenseInstallment.InstallmentList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

                    QuotationComponentDataWrapper.InstallmentWrapper eachInstallment;
                    for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachOppExpense.Id)) {

                        if(eachOppPrice.SubType__c == Constant.DEP_EXP_SUBTYPE_INSTALLMENT){

                            eachInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();

                            eachInstallment.Id = eachOppPrice.Id;
                            eachInstallment.InstallmentNumber = String.valueof(eachOppPrice.Installment__c);
                            eachInstallment.InstallmentAmount = eachOppPrice.Price__c;
                            eachInstallment.PaymentDueDate = (eachOppPrice.PaymentDueDate__c!=null)?eachOppPrice.PaymentDueDate__c:eachOppPrice.To__c;
                            eachInstallment.PaymentMethod = '';
                            eachInstallment.remark = eachOppPrice.Remark__c;

                            totalInstallment += eachInstallment.InstallmentAmount;


                            expenseInstallment.InstallmentList.add(eachInstallment);
                        }

                    }
                    expenseInstallment.TotalInstallment = totalInstallment;

                    leaseHoldExpensList.add(expenseInstallment);

                }else{
                    if(eachOppExpense.Type__c != 'Summary สิทธิการเช่า'){
                        expenseInstallment.Id = eachOppExpense.Id;
                        expenseInstallment.Type = eachOppExpense.Type__c;
                        expenseInstallment.TypeGroup = eachOppExpense.TypeGroup__c;
                        expenseInstallment.TotalAmount = eachOppExpense.Price__c;
                        expenseInstallment.NumberOfInstallment = Integer.valueof(eachOppExpense.NumberOfInstallment__c);
                        expenseInstallment.Remark = eachOppExpense.Remark__c;
                        expenseInstallment.InstallmentList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

                        QuotationComponentDataWrapper.InstallmentWrapper eachInstallment;
                        for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachOppExpense.Id)) {

                            if(eachOppPrice.SubType__c == Constant.DEP_EXP_SUBTYPE_INSTALLMENT){

                                eachInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();

                                eachInstallment.Id = eachOppPrice.Id;
                                eachInstallment.InstallmentNumber = String.valueof(eachOppPrice.Installment__c);
                                eachInstallment.InstallmentAmount = eachOppPrice.Price__c;
                                eachInstallment.PaymentDueDate = (eachOppPrice.PaymentDueDate__c!=null)?eachOppPrice.PaymentDueDate__c:eachOppPrice.To__c;
                                eachInstallment.PaymentMethod = '';
                                eachInstallment.remark = eachOppPrice.Remark__c;

                                totalInstallment += eachInstallment.InstallmentAmount;


                                expenseInstallment.InstallmentList.add(eachInstallment);
                            }

                        }
                        expenseInstallment.TotalInstallment = totalInstallment;

                        expensList.add(expenseInstallment);
                    }else if(eachOppExpense.Type__c == 'Summary สิทธิการเช่า'){
                        expenseInstallmentLeaseHoldSummary.Id = eachOppExpense.Id;
                        expenseInstallmentLeaseHoldSummary.Type = eachOppExpense.Type__c;
                        expenseInstallmentLeaseHoldSummary.TypeGroup = eachOppExpense.TypeGroup__c;
                        expenseInstallmentLeaseHoldSummary.TotalAmount = eachOppExpense.Price__c;
                        expenseInstallmentLeaseHoldSummary.NumberOfInstallment = Integer.valueof(eachOppExpense.NumberOfInstallment__c);
                        expenseInstallmentLeaseHoldSummary.Remark = eachOppExpense.Remark__c;
                        expenseInstallmentLeaseHoldSummary.isLEASEHOLD = false;
                        expenseInstallmentLeaseHoldSummary.isLEASEHOLDSUMMARY = true;
                        expenseInstallmentLeaseHoldSummary.isLeaseHoldDisableINstallment = true;
                        expenseInstallmentLeaseHoldSummary.InstallmentList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

                        QuotationComponentDataWrapper.InstallmentWrapper eachInstallment;
                        for (OpportunityPrice__c eachOppPrice : oppPrice.get(eachOppExpense.Id)) {

                            if(eachOppPrice.SubType__c == Constant.DEP_EXP_SUBTYPE_INSTALLMENT){

                                eachInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();

                                eachInstallment.Id = eachOppPrice.Id;
                                eachInstallment.InstallmentNumber = String.valueof(eachOppPrice.Installment__c);
                                eachInstallment.InstallmentAmount = eachOppPrice.Price__c;
                                eachInstallment.PaymentDueDate = (eachOppPrice.PaymentDueDate__c!=null)?eachOppPrice.PaymentDueDate__c:eachOppPrice.To__c;
                                eachInstallment.PaymentMethod = '';
                                eachInstallment.remark = eachOppPrice.Remark__c;

                                totalInstallment += eachInstallment.InstallmentAmount;


                                expenseInstallmentLeaseHoldSummary.InstallmentList.add(eachInstallment);
                            }

                        }
                        expenseInstallmentLeaseHoldSummary.TotalInstallment = totalInstallment;
                        leaseHoldExpensList.add(expenseInstallmentLeaseHoldSummary);
                    }
                }
            }
            expensList.addAll(leaseHoldExpensList);
            res = JSON.serialize(expensList);
        }
        return res;
    }

	// #region Get Saved Other
    @AuraEnabled
    public static String getSavedOtherExpenseJson(Id oppId, String rentType){
        String res;
        List<OpportunityDepositExpense__c> oppDepositExpenseList = ObjectSelector.getOppDepositAndExpense(oppId, Constant.DEP_EXP_TYPE_GROUP_OTHER);

        if (oppDepositExpenseList != null && !oppDepositExpenseList.isEmpty()) {
            QuotationComponentDataWrapper.OtherWrapper  otherWrapperObject = new QuotationComponentDataWrapper.OtherWrapper();

            List<QuotationPreparationScreenMaster__c> pageMasterListQuery = [SELECT
                                                                                Format__c,
                                                                                IsActive__c,
                                                                                ScreentoDisplay__c,
                                                                                Type__c,
                                                                                Sequence__c
                                                                                FROM QuotationPreparationScreenMaster__c
                                                                                WHERE ScreentoDisplay__c =: Constant.TYPE_EXPENSEANDFEE AND IsActive__c =: TRUE AND RentalType__c =: rentType ORDER BY Sequence__c];

            System.debug('get Save Other Expense' + pageMasterListQuery);

            Map<String,QuotationPreparationScreenMaster__c> pageMasterMap = new Map<String,QuotationPreparationScreenMaster__c>();
            for(QuotationPreparationScreenMaster__c eachMaster : pageMasterListQuery){
                pageMasterMap.put(eachMaster.Type__c,eachMaster);
            }

            List<QuotationPreparationScreenMaster__c> pageMasterList  = pageMasterMap.values();

            QuotationComponentDataWrapper.FixedOtherExpenseFormat fixedFormat;
            QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat rateAndAreaFormat;

            Map<Id,List<OpportunityPrice__c>> oppPrice = ObjectSelector.getOppPriceFromOppExpense(oppId,oppDepositExpenseList,Constant.DEP_EXP_TYPE_GROUP_OTHER);
            System.debug('Other Page OppPrice'+oppPrice);
            for (QuotationPreparationScreenMaster__c eachPageMaster : pageMasterList){
                for(OpportunityDepositExpense__c eachOppExpense : oppDepositExpenseList){

                    if(eachPageMaster.Format__c == Constant.PAGE_MASTER_FORMAT_FIXED && eachPageMaster.Type__c == eachOppExpense.Type__c) {
                        fixedFormat = new QuotationComponentDataWrapper.FixedOtherExpenseFormat();
                        fixedFormat.Remark = eachOppExpense.Remark__c;
                        fixedFormat.depositExpenseId = eachOppExpense.Id;
                        fixedFormat.Type = eachOppExpense.Type__c;
                        fixedFormat.TypeGroup = eachOppExpense.TypeGroup__c;
                        fixedFormat.isToDeleteRecord = false;
                        fixedFormat.ExpenseOtherType = eachPageMaster.Format__c;
                        fixedFormat.Sequence = eachPageMaster.Sequence__c;

                        for (OpportunityPrice__c eachOppPrice :oppPrice.get(eachOppExpense.Id) ){
                            fixedFormat.oppPriceId = eachOppPrice.Id;
                            fixedFormat.Monthly = eachOppPrice.Price__c;
                        }
                        otherWrapperObject.fixedFormatList.add(fixedFormat);
                    }else if(eachPageMaster.Format__c == Constant.PAGE_MASTER_FORMAT_RATE_AND_AREA && eachPageMaster.Type__c == eachOppExpense.Type__c){
                        System.debug('eachOppExpense.Type__c' + eachOppExpense.Type__c);
                        System.debug('eachOppExpense.Id' + eachOppExpense.Id);
                        rateAndAreaFormat = new QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat();
                        rateAndAreaFormat.depositExpenseId = eachOppExpense.Id;
                        rateAndAreaFormat.Remark = eachOppExpense.Remark__c;
                        rateAndAreaFormat.Type = eachOppExpense.Type__c;
                        rateAndAreaFormat.TypeGroup = eachOppExpense.TypeGroup__c;
                        rateAndAreaFormat.isToDeleteRecord = false;
                        rateAndAreaFormat.ExpenseOtherType = eachPageMaster.Format__c;
                        rateAndAreaFormat.Sequence = eachPageMaster.Sequence__c;

                        for (OpportunityPrice__c eachOppPrice :oppPrice.get(eachOppExpense.Id) ) {
                            System.debug('eachOppPrice' + eachOppPrice);
                            if (eachOppPrice.DepositExpenseType__c == eachPageMaster.Type__c) {

                                rateAndAreaFormat.SubType = eachOppPrice.SubType__c;
                                rateAndAreaFormat.oppPriceId = eachOppPrice.Id;
                                rateAndAreaFormat.Area = eachOppPrice.Area__c;
                                rateAndAreaFormat.Total = eachOppPrice.Price__c;
                                rateAndAreaFormat.Rate = eachOppPrice.Rate__c;
                            }
                        }
                        otherWrapperObject.rateAndAreaFormatList.add(rateAndAreaFormat);
                    }
                }
            }
            res = JSON.serialize(otherWrapperObject);
        }
        else{
            QuotationComponentDataWrapper.OtherWrapper  otherWrapperObject = new QuotationComponentDataWrapper.OtherWrapper();
            List<QuotationPreparationScreenMaster__c> pageMasterListQuery = [SELECT Format__c, IsActive__c, ScreentoDisplay__c, Type__c, Sequence__c FROM QuotationPreparationScreenMaster__c WHERE ScreentoDisplay__c =: Constant.TYPE_EXPENSEANDFEE AND IsActive__c =: TRUE AND RentalType__c =: rentType ORDER BY Sequence__c];

            Map<String,QuotationPreparationScreenMaster__c> pageMasterMap = new Map<String,QuotationPreparationScreenMaster__c>();
            for(QuotationPreparationScreenMaster__c eachMaster : pageMasterListQuery){
                pageMasterMap.put(eachMaster.Type__c,eachMaster);
            }

            List<QuotationPreparationScreenMaster__c> pageMasterList  = pageMasterMap.values();

            QuotationComponentDataWrapper.FixedOtherExpenseFormat fixedFormat;
            QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat rateAndAreaFormat;
            for (QuotationPreparationScreenMaster__c eachPageMaster : pageMasterList){

                if(eachPageMaster.Format__c == Constant.PAGE_MASTER_FORMAT_FIXED){
                    fixedFormat = new QuotationComponentDataWrapper.FixedOtherExpenseFormat(eachPageMaster.Type__c);
                    fixedFormat.ExpenseOtherType = eachPageMaster.Format__c;
                    fixedFormat.Sequence = eachPageMaster.Sequence__c;
                    otherWrapperObject.fixedFormatList.add(fixedFormat);

                }else if(eachPageMaster.Format__c == Constant.PAGE_MASTER_FORMAT_RATE_AND_AREA){
                    rateAndAreaFormat = new QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat(eachPageMaster.Type__c);
                    rateAndAreaFormat.ExpenseOtherType = eachPageMaster.Format__c;
                    rateAndAreaFormat.Sequence = eachPageMaster.Sequence__c;
                    otherWrapperObject.rateAndAreaFormatList.add(rateAndAreaFormat);

                }
            }
            res = JSON.serialize(otherWrapperObject);
        }
        return res;
    }

	// #region Get Saved Deposit
    @AuraEnabled
    public static String getSavedDepositObjectJson(Id oppId, String camCondition, String oppUiWrapper){
        String res;
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
        Map<String,String> depositOptionMap = getPicklistOption('OpportunityDepositExpense__c', 'DepositOption__c');
        List<String> depositOptionKey = new List<String>(depositOptionMap.keySet());

        List<OpportunityDepositExpense__c> oppDepositExpenseList = ObjectSelector.getOppDepositAndExpense(oppId, 'Deposit');

        if (oppDepositExpenseList!=null && !oppDepositExpenseList.isEmpty()) {
            QuotationComponentDataWrapper.DepositWrapper depositObject = new QuotationComponentDataWrapper.DepositWrapper();

            Map<Id,List<OpportunityPrice__c>> oppPrice = ObjectSelector.getOppPriceFromOppExpense(oppId,oppDepositExpenseList,'Deposit');

            QuotationComponentDataWrapper.DepositSummaryWrapper depositSumary = new QuotationComponentDataWrapper.DepositSummaryWrapper();
            QuotationComponentDataWrapper.InstallmentWrapper eachInstallment;

            depositObject.OtherDepositList = new List<QuotationComponentDataWrapper.DepositOtherWrapper>();
            QuotationComponentDataWrapper.DepositOtherWrapper eachOtherDeposit;
            Decimal totalInstallment = 0;
            Decimal totalInstallment_Vat = 0;
            Decimal totalInstallment_WithVat = 0;


            QuotationComponentDataWrapper.ParentContractPaidDeposit paidDeposit;
            if (oppDetail.isAllowChangeOptionToRenew){

                if (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION) {
                    List<ContractDepositExpense__c> contractDepositExpenseList = ObjectSelector.getContractDepositAndExpense(oppDetail.parentContractId, 'Deposit');
                    if (!contractDepositExpenseList.isEmpty()) {
                        ContractDepositExpense__c contractDepositExpense = contractDepositExpenseList.get(0);
                        paidDeposit = new QuotationComponentDataWrapper.ParentContractPaidDeposit(oppDetail.parentContractCAMOrAirService);
                        paidDeposit.camOrAirService_BankGuaruntee = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((contractDepositExpense.PaidDepositCAM_BG__c != null)?contractDepositExpense.PaidDepositCAM_BG__c : 0);
                        paidDeposit.rent_BankGuaruntee = (contractDepositExpense.PaidDepositRent_BG__c != null)?contractDepositExpense.PaidDepositRent_BG__c : 0;
                        paidDeposit.service_BankGuaruntee = (contractDepositExpense.PaidDepositService_BG__c != null)?contractDepositExpense.PaidDepositService_BG__c : 0;
                        // paidDeposit.camOrAirService_Cash = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((oppDetail.parentContractCAMOrAirService == Constant.TYPE_CAM)?((contractDepositExpense.PaidDepositCAM__c != null)?contractDepositExpense.PaidDepositCAM__c : 0):0);
                        // paidDeposit.rent_Cash = (contractDepositExpense.PaidDepositRent__c != null)?contractDepositExpense.PaidDepositRent__c : 0;
                        // paidDeposit.service_Cash = (contractDepositExpense.PaidDepositService__c != null)?contractDepositExpense.PaidDepositService__c : 0;
                        paidDeposit.camOrAirService_Cash = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((oppDetail.parentContractCAMOrAirService == Constant.TYPE_CAM)?((contractDepositExpense.CAMDeposit__c != null)?contractDepositExpense.CAMDeposit__c : 0):0);
                        paidDeposit.rent_Cash = (contractDepositExpense.RentDeposit__c != null)?contractDepositExpense.RentDeposit__c : 0;
                        paidDeposit.service_Cash = (contractDepositExpense.ServiceDeposit__c != null)?contractDepositExpense.ServiceDeposit__c : 0;
                        paidDeposit.camOrAirService_Summary = paidDeposit.camOrAirService_BankGuaruntee + paidDeposit.camOrAirService_Cash;
                        paidDeposit.rent_Summary = paidDeposit.rent_BankGuaruntee + paidDeposit.rent_Cash;
                        paidDeposit.service_Summary = paidDeposit.service_BankGuaruntee + paidDeposit.service_Cash;

                    }
                }else{
                    paidDeposit = new QuotationComponentDataWrapper.ParentContractPaidDeposit(oppDetail.camOrAirService);
                    //paidDeposit.camOrAirService_BankGuaruntee = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((oppDetail.cam_CarrierDeposit_BG!=null)?oppDetail.cam_CarrierDeposit_BG:0);
                    paidDeposit.camOrAirService_BankGuaruntee = 0;
                    //paidDeposit.rent_BankGuaruntee = (oppDetail.rent_CarrierDeposit_BG != null) ? oppDetail.rent_CarrierDeposit_BG: 0;
                    paidDeposit.rent_BankGuaruntee = 0;
                    //paidDeposit.service_BankGuaruntee = (oppDetail.service_CarrierDeposit_BG != null) ? oppDetail.service_CarrierDeposit_BG: 0;
                    paidDeposit.service_BankGuaruntee = 0;
                    //paidDeposit.camOrAirService_Cash = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((oppDetail.camOrAirService == Constant.TYPE_CAM)?((oppDetail.cam_CarrierDeposit != null)? oppDetail.cam_CarrierDeposit : 0 ):((oppDetail.airService_CarrierDeposit != null)? oppDetail.airService_CarrierDeposit : 0 ));
                    paidDeposit.camOrAirService_Cash = 0;
                    //paidDeposit.rent_Cash = (oppDetail.rent_CarrierDeposit != null)? oppDetail.rent_CarrierDeposit : 0;
                    paidDeposit.rent_Cash =0;
                    //paidDeposit.service_Cash = (oppDetail.service_CarrierDeposit != null)? oppDetail.service_CarrierDeposit : 0;
                    paidDeposit.service_Cash = 0;
                    paidDeposit.camOrAirService_Summary = paidDeposit.camOrAirService_BankGuaruntee + paidDeposit.camOrAirService_Cash;
                    paidDeposit.rent_Summary = paidDeposit.rent_BankGuaruntee + paidDeposit.rent_Cash;
                    paidDeposit.service_Summary = paidDeposit.service_BankGuaruntee + paidDeposit.service_Cash;
                }
                depositSumary.ParentContractPaidDeposit = paidDeposit;
            }

            for (OpportunityDepositExpense__c eachOppDeposit : oppDepositExpenseList) {
                if (eachOppDeposit.Type__c == 'Security Deposit') {
                    totalInstallment = 0;
                    totalInstallment_WithVat = 0;
                    totalInstallment_Vat = 0;

                    depositObject.DepositMonth = eachOppDeposit.NumberOfMonth__c;
                    depositObject.NumberOfInstallment = Integer.valueof(eachOppDeposit.NumberOfInstallment__c);
                    depositObject.DepositCalculationType = eachOppDeposit.DepositInputMethod__c;
                    depositObject.DepositRemark = eachOppDeposit.Remark__c;
                    depositObject.DepositOption = (eachOppDeposit.DepositOption__c != null)?eachOppDeposit.DepositOption__c : depositOptionKey.get(0);

                    depositSumary.depositSummaryId = eachOppDeposit.Id;
                    depositSumary.DepositSummaryPricing = new QuotationComponentDataWrapper.DepositSummaryPricing(
                                                                            oppDetail.isNoCAM,
                                                                            eachOppDeposit.DepositInputMethod__c,
                                                                            camCondition,
                                                                            eachOppDeposit.NumberOfMonth__c,
                                                                            eachOppDeposit.CAMDeposit__c,
                                                                            0,//eachOppDeposit.tms_AirServiceDeposit__c,
                                                                            eachOppDeposit.RentDeposit__c,
                                                                            eachOppDeposit.ServiceDeposit__c,
                                                                            eachOppDeposit.CarriedDepositCAM__c == null? paidDeposit.camOrAirService_Cash : eachOppDeposit.CarriedDepositCAM__c,
                                                                            eachOppDeposit.CarriedDepositAirService__c,
                                                                            eachOppDeposit.CarriedDepositRent__c == null? paidDeposit.rent_Cash : eachOppDeposit.CarriedDepositRent__c,
                                                                            eachOppDeposit.CarriedDepositService__c == null? paidDeposit.service_Cash : eachOppDeposit.CarriedDepositService__c);

                    depositSumary.DepositSummaryPricing.camOrAirService_ActualDeposit = (eachOppDeposit.ActualDepositCAM__c != null)?eachOppDeposit.ActualDepositCAM__c:0;
                    depositSumary.DepositSummaryPricing.rent_ActualDeposit = (eachOppDeposit.ActualDepositRent__c != null)?eachOppDeposit.ActualDepositRent__c:0;
                    depositSumary.DepositSummaryPricing.service_ActualDeposit = (eachOppDeposit.ActualDepositService__c != null)?eachOppDeposit.ActualDepositService__c:0;

                    if (oppDetail.isAllowChangeOptionToRenew) {

                        if (oppDetail.isNoCAM) {
                            depositSumary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = 0;
                            depositSumary.DepositSummaryPricing.camOrAirService_Vat = 0;
                            depositSumary.DepositSummaryPricing.camOrAirService_TotalDeposit = 0;
                            depositSumary.DepositSummaryPricing.camOrAirService_Summary_WithVat = 0;

                            depositSumary.DepositSummaryPricing.service_CarriedDeposit = depositSumary.DepositSummaryPricing.camOrAirService_CarriedDeposit + depositSumary.DepositSummaryPricing.service_CarriedDeposit;
                            depositSumary.DepositSummaryPricing.camOrAirService_CarriedDeposit = 0;
                        }

                        Decimal rentCarriedDeposit = (depositSumary.DepositSummaryPricing.rent_CarriedDeposit != null)?(depositSumary.DepositSummaryPricing.rent_CarriedDeposit):0;
                        Decimal serviceCarriedDeposit = (depositSumary.DepositSummaryPricing.service_CarriedDeposit != null)?(depositSumary.DepositSummaryPricing.service_CarriedDeposit):0;
                        Decimal camOrAirServiceCarriedDeposit = (depositSumary.DepositSummaryPricing.camOrAirService_CarriedDeposit != null)?(depositSumary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;

                        Decimal rentActualDDeposit = depositSumary.DepositSummaryPricing.rent_ActualDeposit;
                        Decimal serviceActualDDeposit = depositSumary.DepositSummaryPricing.service_ActualDeposit;
                        Decimal camOrAirServiceActualDDeposit = depositSumary.DepositSummaryPricing.camOrAirService_ActualDeposit;

                        Decimal rentSummaryDeposit =  rentActualDDeposit - rentCarriedDeposit ;
                        Decimal serviceSummaryDeposit =  serviceActualDDeposit - serviceCarriedDeposit ;
                        Decimal camOrAirServiceSummaryDeposit =  camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit ;

                        depositSumary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
                        depositSumary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
                        depositSumary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
                        depositSumary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;

                        Decimal camOrAirService_Summary_vat = (depositSumary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100)).setscale(2, RoundingMode.HALF_UP);
                        Decimal service_Summary_vat = (depositSumary.DepositSummaryPricing.service_Summary*(vatPercent/100)).setscale(2, RoundingMode.HALF_UP);

                        depositSumary.DepositSummaryPricing.camOrAirService_Summary_WithVat = depositSumary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
                        depositSumary.DepositSummaryPricing.rent_Summary_WithVat = depositSumary.DepositSummaryPricing.rent_Summary;
                        depositSumary.DepositSummaryPricing.service_Summary_WithVat = depositSumary.DepositSummaryPricing.service_Summary + service_Summary_vat;

                        depositSumary.DepositSummaryPricing.totalDeposit_WithVat = depositSumary.DepositSummaryPricing.camOrAirService_Summary_WithVat + depositSumary.DepositSummaryPricing.rent_Summary_WithVat + depositSumary.DepositSummaryPricing.service_Summary_WithVat;
                    }

                    depositSumary.AdvanceDepositAmount = eachOppDeposit.Price__c;
                    depositSumary.TypeGroup = eachOppDeposit.TypeGroup__c;
                    depositSumary.Type = eachOppDeposit.Type__c;
                    depositSumary.InstallmentList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

                    Map<String,Decimal> installmentPrice_subTypeMap = new Map<String,Decimal>();
                    Map<String,Decimal> installmentPrice_withVAT_subTypeMap = new Map<String,Decimal>();
                    Decimal amount = 0;
                    Decimal amount_withVat = 0;

                    for (OpportunityPrice__c eachOppPrice :oppPrice.get(eachOppDeposit.Id)){
                        if (installmentPrice_subTypeMap.containsKey(String.valueof(eachOppPrice.Installment__c))) {
                            amount = installmentPrice_subTypeMap.get(String.valueof(eachOppPrice.Installment__c));
                            amount +=  eachOppPrice.Price__c;
                            installmentPrice_subTypeMap.put(String.valueof(eachOppPrice.Installment__c), amount);
                        }else{
                            installmentPrice_subTypeMap.put(String.valueof(eachOppPrice.Installment__c),eachOppPrice.Price__c);
                        }

                        if (installmentPrice_withVAT_subTypeMap.containsKey(String.valueof(eachOppPrice.Installment__c))) {
                            amount_withVat = installmentPrice_withVAT_subTypeMap.get(String.valueof(eachOppPrice.Installment__c));
                            amount_withVat +=  (eachOppPrice.InstallmentPriceWithVAT__c!=null)?eachOppPrice.InstallmentPriceWithVAT__c:0;
                            installmentPrice_withVAT_subTypeMap.put(String.valueof(eachOppPrice.Installment__c), amount_withVat);
                        }else{
                            installmentPrice_withVAT_subTypeMap.put(String.valueof(eachOppPrice.Installment__c),(eachOppPrice.InstallmentPriceWithVAT__c!=null)?eachOppPrice.InstallmentPriceWithVAT__c:0);
                        }
                    }

                    Decimal installmentNumber = 0;
                    for (OpportunityPrice__c eachOppPrice :oppPrice.get(eachOppDeposit.Id)) {
                         eachInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
                         eachInstallment.Id = eachOppPrice.Id;
                         eachInstallment.InstallmentNumber = String.valueof(eachOppPrice.Installment__c);
                         eachInstallment.InstallmentAmount = (installmentPrice_subTypeMap.get(String.valueof(eachOppPrice.Installment__c))).setscale(2);
                         eachInstallment.InstallmentAmountWithVat = (installmentPrice_withVAT_subTypeMap.get(String.valueof(eachOppPrice.Installment__c))).setscale(2);
                         eachInstallment.PaymentDueDate = (oppDetail.isAllowChangeOptionToRenew) ? ((eachOppPrice.PaymentDueDate__c!=null)? eachOppPrice.PaymentDueDate__c : null) :((eachOppPrice.PaymentDueDate__c!=null)?eachOppPrice.PaymentDueDate__c:eachOppPrice.To__c);
                         eachInstallment.PaymentMethod = eachOppPrice.PaymentType__c;
                         eachInstallment.remark = eachOppPrice.Remark__c;
                         eachInstallment.InstallmentVAT = eachInstallment.InstallmentAmountWithVat.setScale(2) - eachInstallment.InstallmentAmount.setScale(2);


                         System.debug('eachInstallment.InstallmentAmount' + eachInstallment.InstallmentAmount);
                         System.debug('Summary Deposit' + totalInstallment);

                         if (installmentNumber != eachOppPrice.Installment__c && eachOppPrice.Installment__c != null) {

                            totalInstallment += eachInstallment.InstallmentAmount;
                            totalInstallment_WithVat += eachInstallment.InstallmentAmountWithVat;
                            totalInstallment_Vat += eachInstallment.InstallmentVAT;

                            depositSumary.InstallmentList.add(eachInstallment);
                            installmentNumber = eachOppPrice.Installment__c;
                         }
                    }
                    depositSumary.TotalInstallment = totalInstallment;
                    depositSumary.TotalInstallment_WithVat = totalInstallment_WithVat;
                    depositSumary.TotalInstallment_VAT = totalInstallment_Vat;
                }else{
                    totalInstallment = 0;
                    totalInstallment_WithVat = 0;

                    eachOtherDeposit = new QuotationComponentDataWrapper.DepositOtherWrapper();
                    eachOtherDeposit.otherDepositId = eachOppDeposit.Id;
                    eachOtherDeposit.TypeGroup = eachOppDeposit.TypeGroup__c;
                    eachOtherDeposit.Type = eachOppDeposit.Type__c;
                    eachOtherDeposit.Remark =  eachOppDeposit.Remark__c;
                    eachOtherDeposit.TotalAmount = eachOppDeposit.Price__c;
                    eachOtherDeposit.NumberOfInstallment = Integer.valueof(eachOppDeposit.NumberOfInstallment__c);
                    eachOtherDeposit.InstallmentList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

                    for (OpportunityPrice__c eachOppPrice :oppPrice.get(eachOppDeposit.Id)) {
                         eachInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
                         eachInstallment.Id = eachOppPrice.Id;
                         eachInstallment.InstallmentNumber = String.valueof(eachOppPrice.Installment__c);
                         eachInstallment.InstallmentAmount = eachOppPrice.Price__c;
                         eachInstallment.PaymentDueDate = (eachOppPrice.PaymentDueDate__c!=null)?eachOppPrice.PaymentDueDate__c:eachOppPrice.To__c;
                         eachInstallment.PaymentMethod = eachOppPrice.PaymentType__c;
                         eachInstallment.remark = eachOppPrice.Remark__c;

                         totalInstallment += eachInstallment.InstallmentAmount;
                         eachOtherDeposit.InstallmentList.add(eachInstallment);
                    }
                    eachOtherDeposit.TotalInstallment = totalInstallment;
                    depositObject.OtherDepositList.add(eachOtherDeposit);
                }
            }
            depositObject.DepositSummary = depositSumary;
            res = JSON.serialize(depositObject);
        }
        return res;
    }

	// #region Get Picklist
    @AuraEnabled
    public static Map<String,String> getPicklistValueFromPageSettingFromContractType(String contractType, String screenToDisplay, List<String> mesurementListId){
        Map<String,String> options = new Map<String,String>();
        List<QuotationPreparationScreenMaster__c> masterList = new List<QuotationPreparationScreenMaster__c>();
        String queryStr = 'SELECT Type__c,Subtype__c,SpecificMeasurement__c FROM QuotationPreparationScreenMaster__c WHERE ScreentoDisplay__c= \'' +screenToDisplay +'\' AND ContractType__c= \''+contractType+'\' AND IsActive__c = TRUE';
        masterList = Database.query(queryStr);
        System.debug('mesurementListId' + mesurementListId);

        if (!masterList.isEmpty()) {

            for(QuotationPreparationScreenMaster__c eachValue : masterList){
                if (mesurementListId != null) {
                    if (eachValue.SpecificMeasurement__c != null) {
                        if(mesurementListId.contains(eachValue.SpecificMeasurement__c)){
                            options.put(eachValue.Type__c, eachValue.Type__c);
                        }
                    }else{
                        options.put(eachValue.Type__c, eachValue.Type__c);
                    }
                }else{
                    options.put(eachValue.Type__c, eachValue.Type__c);
                }
            }
        }
        return options;
    }

    @AuraEnabled
    public static Map<String,String> getPicklistValueFromPageSettingFromRentType(String rentType, String screenToDisplay, List<String> mesurementListId){
        Map<String,String> options = new Map<String,String>();
        List<QuotationPreparationScreenMaster__c> masterList = new List<QuotationPreparationScreenMaster__c>();
        String queryStr = 'SELECT Type__c,Subtype__c,SpecificMeasurement__c FROM QuotationPreparationScreenMaster__c WHERE ScreentoDisplay__c= \'' +screenToDisplay +'\' AND RentalType__c= \''+rentType+'\' AND IsActive__c = TRUE';
        masterList = Database.query(queryStr);
        System.debug('mesurementListId' + mesurementListId);

        if (!masterList.isEmpty()) {

            for(QuotationPreparationScreenMaster__c eachValue : masterList){
                if (mesurementListId != null) {
                    if (eachValue.SpecificMeasurement__c != null) {
                        if(mesurementListId.contains(eachValue.SpecificMeasurement__c)){
                            options.put(eachValue.Type__c, eachValue.Type__c);
                        }
                    }else{
                        options.put(eachValue.Type__c, eachValue.Type__c);
                    }
                }else{
                    options.put(eachValue.Type__c, eachValue.Type__c);
                }
            }
        }
        return options;
    }

    @AuraEnabled
    public static Map<String,String> getPicklistValueFromPageSetting(String conditionField, String conditionValue, String contractType){
        List<QuotationPreparationScreenMaster__c> masterList = new List<QuotationPreparationScreenMaster__c>();
        String queryStr = 'SELECT Type__c,Subtype__c FROM QuotationPreparationScreenMaster__c WHERE '+ conditionField + '= \'' +conditionValue +'\' AND IsActive__c = TRUE AND ContractType__c = \''+contractType+'\'';
        masterList = Database.query(queryStr);
        Map<String,String> options;

        if (!masterList.isEmpty()) {
            options = new Map<String,String>();
            for(QuotationPreparationScreenMaster__c eachValue : masterList){
                options.put(eachValue.Type__c, eachValue.Type__c);
            }
        }
        return options;
    }

    @AuraEnabled
    public static Map<String,String> getPicklistValueFromPageSettingByTargetField(String conditionField, String conditionValue, String targetField, String contractType ){
        List<QuotationPreparationScreenMaster__c> masterList = new List<QuotationPreparationScreenMaster__c>();
        String queryStr = 'SELECT Type__c,Subtype__c FROM QuotationPreparationScreenMaster__c WHERE '+ conditionField + '= \'' +conditionValue +'\' AND IsActive__c = TRUE AND ContractType__c = \''+contractType+'\'';
        masterList = Database.query(queryStr);
        Map<String,String> options = new Map<String,String>();

        if (!masterList.isEmpty()) {

            for(QuotationPreparationScreenMaster__c eachValue : masterList){
                options.put((String)eachValue.get(targetField), (String)eachValue.get(targetField));
            }
        }

        return options;
    }

    @AuraEnabled
    public static Map<String,String> getOtherExpenseOption(String rentType){
        List<QuotationPreparationScreenMaster__c> masterList = [SELECT
                                                                    Format__c,
                                                                    IsActive__c,
                                                                    ScreentoDisplay__c,
                                                                    Type__c,
                                                                    RentalType__c
                                                                    FROM QuotationPreparationScreenMaster__c
                                                                    WHERE ScreentoDisplay__c =: Constant.TYPE_EXPENSEANDFEE AND IsActive__c =: TRUE AND RentalType__c =: rentType ];
        Map<String,String> options = new Map<String,String>();
        if (!masterList.isEmpty()) {
            for(QuotationPreparationScreenMaster__c eachValue : masterList){
                options.put(eachValue.Type__c, eachValue.Type__c);
            }
        }
        return options;
    }

    @AuraEnabled
    public static Map<String,String> getOtherExpenseSubtype(String rentType ){
        List<QuotationPreparationScreenMaster__c> masterList = new List<QuotationPreparationScreenMaster__c>();
        String queryStr = 'SELECT Type__c,Subtype__c FROM QuotationPreparationScreenMaster__c WHERE ScreentoDisplay__c = \'Expense and Fee\' AND IsActive__c = TRUE AND RentalType__c = \''+rentType+'\'';
        masterList = Database.query(queryStr);
        Map<String,String> options = new Map<String,String>();

        if (!masterList.isEmpty()) {

            for(QuotationPreparationScreenMaster__c eachValue : masterList){
                options.put((String)eachValue.get('Subtype__c'), (String)eachValue.get('Subtype__c'));
            }
        }
        return options;
    }

	// #region Get New CAM
    @AuraEnabled
    public static String getNewCAMPeriod(String selectedRoomJson, Integer periodLength){
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        System.debug('desrialize '+ selectedRoomList);
        Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);
        QuotationComponentDataWrapper.CAMYearPeriodWrapper camYearPeriod;
        List<QuotationComponentDataWrapper.MeasurmentWrapper> camMeasurementList;
        QuotationComponentDataWrapper.MeasurmentWrapper camMeasurement;
        QuotationComponentDataWrapper.UINumberInputClass measurmentTypeInput;
        Decimal totalArea = 0;
        String jsonResult = '';
        if (roMeasurementTypeMap!=null) {
            camYearPeriod = new QuotationComponentDataWrapper.CAMYearPeriodWrapper();
            camYearPeriod.isToDeleteRecord = false;
            camYearPeriod.Year = periodLength+1;
            camYearPeriod.DateTo = Date.today();
            camYearPeriod.DateFrom = Date.today();
            camYearPeriod.IsDisableInput = false;
            camYearPeriod.TotalPrice = 0;
            camYearPeriod.isRenewCAMPeriod = false;
            camYearPeriod.isOptionToRenew = false;
            camYearPeriod.isLockPeriod = false;

            camMeasurementList = new List<QuotationComponentDataWrapper.MeasurmentWrapper>();
            for(String eachROMeasurmentType : roMeasurementTypeMap.keySet()){

                camMeasurement = new QuotationComponentDataWrapper.MeasurmentWrapper();
                measurmentTypeInput = new QuotationComponentDataWrapper.UINumberInputClass(null,null);

                measurmentTypeInput.value = 0;

                if(!roMeasurementTypeMap.get(eachROMeasurmentType).isFOC){

                    camMeasurement.isFOC = false;
                    camMeasurement.measurementId = roMeasurementTypeMap.get(eachROMeasurmentType).measurementId;
                    camMeasurement.MeasurementArea = roMeasurementTypeMap.get(eachROMeasurmentType).measurementArea;
                    camMeasurement.Price = measurmentTypeInput;
                    camMeasurement.MeasurementType = eachROMeasurmentType;
                    camMeasurement.roMeasurementId = roMeasurementTypeMap.get(eachROMeasurmentType).roMeasurementId;
                    camMeasurement.isToDeleteRecord = false;

                    totalArea += camMeasurement.MeasurementArea;

                    camMeasurementList.add(camMeasurement);
                }
            }

            camYearPeriod.TotalArea = totalArea;
            camYearPeriod.CAMMeasurmentList = camMeasurementList;
        }

        jsonResult = JSON.serialize(camYearPeriod);
        return jsonResult;
    }

	// #region Get New Period
	/**
	 * CR Feb 2025
	 */
    @AuraEnabled
    public static String getNewPeriodJSON(String periodType, Integer periodNUmber, String selectedRoomJson, String oppUiWrapper){
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        Map<String,String> calculationMethodLabel = getPicklistOption('Opportunity', 'Calculation_Method__c');
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementTypeMap = getROMeasurmentTypeSet(selectedRoomJson);

        System.debug('selectedRoomJson' + selectedRoomJson);
        System.debug('roMeasurementTypeMap' + roMeasurementTypeMap);
        Map<String,String> repotingRuleValue = new Map<String,String>{'Sales before VAT' => 'Sales before VAT'};//getPicklistOption('tms_OpportunityGrading__c', 'tms_ReportingRule__c');

        QuotationComponentDataWrapper.PeriodPricing newPeriod = new QuotationComponentDataWrapper.PeriodPricing();
        newPeriod.isCustomPeriod = true;
        newPeriod.isToDeleteRecord = false;
        newPeriod.PeriodNumber = periodNUmber;
        newPeriod.PricingFrom = Date.today();
        newPeriod.PricingTo = Date.today();
        newPeriod.CalculationMethod = periodType;
        newPeriod.CalculationMethodLabel = calculationMethodLabel.get(periodType);
        newPeriod.IsIncludeCAM = false;
        newPeriod.OptionToRenew = false;
        newPeriod.IsAllSales = false;
        newPeriod.escalationRemark = '';
        if (periodType == Constant.CAL_METHOD_FIXED_RO) {
            newPeriod.FixedRentalObjectSection = new QuotationComponentDataWrapper.FixedRentalObjectSectionWrapper();
            newPeriod.FixedRentalObjectSection.rentalObjectList = new List<QuotationComponentDataWrapper.RentalObjectPricingWrapper>();

            Decimal totalRentalObjectArea = 0;
            Decimal totalRentalObjectLeasable = 0;
            Decimal totalRentalObjectPrice = 0;
            Decimal totalRentalObjectPricSQM = 0;

            List<QuotationComponentDataWrapper.RentalObjectPricingWrapper> roPricingList = new List<QuotationComponentDataWrapper.RentalObjectPricingWrapper>();
            QuotationComponentDataWrapper.RentalObjectPricingWrapper roPricing;

            for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList) {
                if (!eachSelectedRO.isToDeleteRecord) {
                    roPricing = new QuotationComponentDataWrapper.RentalObjectPricingWrapper();
                    roPricing.isToDeleteRecord = false;
                    roPricing.roId = eachSelectedRO.Id;
                    roPricing.roCode = eachSelectedRO.roCode;
                    roPricing.RentalObject = eachSelectedRO.roomNumber;
                    roPricing.TotalArea = eachSelectedRO.totalArea;
                    roPricing.LeasableArea = eachSelectedRO.leasableArea;
                    roPricing.Price = new QuotationComponentDataWrapper.UINumberInputClass(0, false);
                    roPricing.PriceSQM = new QuotationComponentDataWrapper.UINumberInputClass(0, false);
                    roPricing.roMeasurementList = new List<QuotationComponentDataWrapper.ROMeasurementClass>(eachSelectedRO.roMeasurmentList);
					/**
					 * CR Feb 2025
					 * Changed Detail: add more attribute in wrapper to init new period in Aura
					 */
					//
					//
					//
					// Changed end

                    totalRentalObjectArea += roPricing.TotalArea;
                    totalRentalObjectLeasable += roPricing.LeasableArea;
                    totalRentalObjectPrice += roPricing.Price.value;
                    totalRentalObjectPricSQM += roPricing.PriceSQM.value;
					/**
					 * CR Feb 2025
					 * Changed Detail: add more cumulative value
					 */
					//
					//
					//
					// Changed end

                    roPricingList.add(roPricing);
                }
            }
            if(oppDetail.rentType != 'Billboard_Rental') {
                newPeriod.FixedRentalObjectSection.MinType = 'Measurement';
            } else {
                newPeriod.FixedRentalObjectSection.MinType = 'Fixed';
            }
            newPeriod.FixedRentalObjectSection.rentalObjectList = roPricingList;
            newPeriod.FixedRentalObjectSection.TotalArea = totalRentalObjectArea;
            newPeriod.FixedRentalObjectSection.TotalLeasableArea = totalRentalObjectLeasable;
            newPeriod.FixedRentalObjectSection.TotalPrice = totalRentalObjectPrice;
            newPeriod.FixedRentalObjectSection.TotalPriceSQm = totalRentalObjectPricSQM;
			/**
			 * CR Feb 2025
			 * Changed Detail: assign more accumulative in wrapper
			 */
			//
			//
			//
			// Changed end
        }
        if (periodType == Constant.CAL_METHOD_FIXED_PRICE) {

            // Decimal totalRentalObjectLeasable = 0;
            // for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList){
            //     if (!eachSelectedRO.isToDeleteRecord){
            //         totalRentalObjectLeasable += eachSelectedRO.leasableArea;
            //     }
            // }

            // newPeriod.FixedPriceSection = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
            // newPeriod.FixedPriceSection.isToDeleteRecord = false;
            // newPeriod.FixedPriceSection.Price = 0;
            // newPeriod.FixedPriceSection.TotalArea = totalRentalObjectLeasable;
            // newPeriod.FixedPriceSection.PriceSQM = 0;
            // newPeriod.FixedPriceSection.IsDisabled = false;
            // newPeriod.FixedPriceSection.MinType = 'Measurement';
        }
        if (periodType == Constant.CAL_METHOD_FIXED_MEAS) {
            // newPeriod.FixedMeasurementSection = new QuotationComponentDataWrapper.FixedMeasurementSectionWrapper();
            // List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,false);

            // Decimal totalArea = 0;
            // Decimal totalPrice = 0;
            // Decimal totalSummary = 0;
            // for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

            //     totalArea += measurementPricing.Area;
            //     totalPrice += measurementPricing.Price.value;
            //     totalSummary += measurementPricing.Summary;
            // }

            // newPeriod.FixedMeasurementSection.pricingList = measurementPricingList;
            // newPeriod.FixedMeasurementSection.TotalArea = totalArea;
            // newPeriod.FixedMeasurementSection.TotalPrice = totalPrice;
            // newPeriod.FixedMeasurementSection.TotalSummary = totalSummary;
        }
        if (periodType == Constant.CAL_METHOD_GP_WITHMIN) {


            List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
            QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
            reportingRule.isToDeleteRecord = false;
            reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
            reportingRuleList.add(reportingRule);

           List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,false);

            Decimal totalArea = 0;
            Decimal totalPrice = 0;
            Decimal totalSummary = 0;
            Decimal totalLeasableArea = 0;

            for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                totalArea += measurementPricing.Area;
                totalPrice += measurementPricing.Price.value;
                totalSummary += measurementPricing.Summary;

                if (!measurementPricing.isFOC) {
                    totalLeasableArea += measurementPricing.Area;
                }
            }


            QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
            pricingSection.MinType = 'Measurement';
            pricingSection.MeasumentPricingList = measurementPricingList;
            pricingSection.TotalPrice = totalPrice;
            pricingSection.TotalLeasableArea = totalLeasableArea;
            pricingSection.TotalArea = totalArea;
            pricingSection.TotalSummary = totalSummary;
            pricingSection.FixedPricing = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
            pricingSection.FixedPricing.isToDeleteRecord = false;
            pricingSection.FixedPricing.Price = 0;
            pricingSection.FixedPricing.IsDisabled = false;


            newPeriod.GPWithMinSection = new QuotationComponentDataWrapper.GPWithMinSectionWrapper();
            newPeriod.GPWithMinSection.ReportingRuleList = reportingRuleList;
            newPeriod.GPWithMinSection.SalesMin = 0;
            newPeriod.GPWithMinSection.PricingSection = pricingSection;
        }
        if (periodType == Constant.CAL_METHOD_GP_NOMIN) {

            newPeriod.GPNoMinSection = new QuotationComponentDataWrapper.GPNoMinSectionWrapper();
            List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
            QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
            reportingRule.isToDeleteRecord = false;
            reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
            reportingRuleList.add(reportingRule);


            newPeriod.GPNoMinSection = new QuotationComponentDataWrapper.GPNoMinSectionWrapper();
            newPeriod.GPNoMinSection.ReportingRuleList = reportingRuleList;
        }
        if (periodType == Constant.CAL_METHOD_GP_ONTOP) {

            List<QuotationComponentDataWrapper.ReportingRuleWrapper> reportingRuleList= new List<QuotationComponentDataWrapper.ReportingRuleWrapper>();
            QuotationComponentDataWrapper.ReportingRuleWrapper reportingRule = new QuotationComponentDataWrapper.ReportingRuleWrapper(oppDetail.oppSalesForCalculation,repotingRuleValue.get(oppDetail.oppSalesForCalculation));
            reportingRule.isToDeleteRecord = false;
            reportingRule.ReportingRuleDetailList.add(new QuotationComponentDataWrapper.ReportingRuleDetailWrapper());
            reportingRuleList.add(reportingRule);

           List<QuotationComponentDataWrapper.MeasurementPricingList> measurementPricingList = getMeasurementPricingList(roMeasurementTypeMap,false);

            Decimal totalArea = 0;
            Decimal totalPrice = 0;
            Decimal totalSummary = 0;
            Decimal totalLeasableArea = 0;
            for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : measurementPricingList){

                totalArea += measurementPricing.Area;
                totalPrice += measurementPricing.Price.value;
                totalSummary += measurementPricing.Summary;

                if (!measurementPricing.isFOC) {
                    totalLeasableArea += measurementPricing.Area;
                }
            }


            QuotationComponentDataWrapper.PricingSectionWrapper pricingSection = new QuotationComponentDataWrapper.PricingSectionWrapper();
            pricingSection.MinType = 'Measurement';
            pricingSection.MeasumentPricingList = measurementPricingList;
            pricingSection.TotalPrice = totalPrice;
            pricingSection.TotalArea = totalArea;
            pricingSection.TotalSummary = totalSummary;
            pricingSection.TotalLeasableArea = totalLeasableArea;
            pricingSection.FixedPricing = new QuotationComponentDataWrapper.FixedPriceSectionWrapper();
            pricingSection.FixedPricing.isToDeleteRecord = false;
            pricingSection.FixedPricing.Price = 0;
            pricingSection.FixedPricing.IsDisabled = false;

            newPeriod.GPOnTopSection = new QuotationComponentDataWrapper.GPOnTopSectionWrapper();
            newPeriod.GPOnTopSection.ReportingRuleList = reportingRuleList;
            newPeriod.GPOnTopSection.PricingSection = pricingSection;

        }
        newPeriod.Proportion = new QuotationComponentDataWrapper.ProportionWrapper();

        Decimal proportionRent = 0;
        Decimal proportionService = 0;
        if(oppDetail.rentType != 'Event_Rental') {
            proportionRent = OpportunitySetting__c.getInstance().RentProportion__c;
            proportionService = OpportunitySetting__c.getInstance().ServiceProportion__c;
        } else {
            proportionRent = OpportunitySetting__c.getInstance().RentEventProportion__c;
            proportionService = OpportunitySetting__c.getInstance().ServiceEventProportion__c;
        }

        newPeriod.Proportion.Proportion = periodType;
        newPeriod.Proportion.Rent = proportionRent;
        newPeriod.Proportion.Service = proportionService;

        // newPeriod.Proportion.add(proportion);

        String res = JSON.serialize(newPeriod);
        System.debug('new Period ' + res);
        return res;
    }

	// #region Get New Reporting
    @AuraEnabled
    public static String getNewReportingRuleJson(String reportingRule, String reportingRuleLabel){
        QuotationComponentDataWrapper.ReportingRuleWrapper reportingRuleObject = new QuotationComponentDataWrapper.ReportingRuleWrapper(reportingRule,reportingRuleLabel);
        return JSON.serialize(reportingRuleObject);
    }

	// #region Save Pricing
    @AuraEnabled
    public static MessageDialog savePricingApex(String camorAirServiceJson,String rentServiceJson,String periodPricingJson, String oppUiWrapper, Id oppId){
        OpportunityController oppController = new OpportunityController();
        MessageDialog targetMessageDialog = new MessageDialog();

        System.debug('Incomming JSON Pricing' + periodPricingJson);
        System.debug('In Controller Opp' + oppUiWrapper);

        try{
            QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
            QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camorAirServiceJson, QuotationComponentDataWrapper.CAMPricingWrapper.class);
            QuotationComponentDataWrapper.RentServicePricingWrapper rentAndService = (QuotationComponentDataWrapper.RentServicePricingWrapper) JSON.deserialize(rentServiceJson, QuotationComponentDataWrapper.RentServicePricingWrapper.class);
            List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
            //Opportunity currentOpp = [SELECT Id, IsMigrate__c FROM Opportunity WHERE Id =: oppId];

            System.debug('camOrAirServiceObject '+ camOrAirServiceObject);
            System.debug('rentAndService '+ rentAndService);
            System.debug('periodPricing '+ periodPricing);

            Boolean isValidCAMPeriod = (oppDetail.isNoCAM || (oppDetail.leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก' && !oppDetail.isAllowLongLeaseChangePeriod))? true : validateCAMPeriod(camOrAirServiceObject,oppDetail.contractStartDateForm, oppDetail.contractEndDateFrom,oppDetail);
            Boolean validateCAMPeriodOptionToRenew = (oppDetail.isNoCAM || (oppDetail.leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก'))? true : ((oppDetail.optionToRenewYear == 0 && oppDetail.optionToRenewMonth == 0)?true :validateCAMPeriodOptionToRenew(camOrAirServiceObject,oppDetail.contractStartDateForm, oppDetail.contractEndDateFrom, oppDetail.optionToRenewYear, oppDetail.optionToRenewMonth));
            Boolean isValidPricingPeriod = (oppDetail.leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก' && !oppDetail.isAllowLongLeaseChangePeriod)? true : validatePricingPeriod(periodPricing,oppDetail.contractStartDateForm, oppDetail.contractEndDateFrom,oppDetail);
            Boolean isValidPricingPeriodOptionToRenew = (oppDetail.leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก')? true : ((oppDetail.optionToRenewYear == 0 && oppDetail.optionToRenewMonth == 0)?true : validatePricingPeriodOptionToRenew(periodPricing,oppDetail.contractStartDateForm, oppDetail.contractEndDateFrom, oppDetail.optionToRenewYear, oppDetail.optionToRenewMonth));
            //Boolean isMigrationProfile = Utility.isValidateMigrationProfile(currentOpp);
            Boolean isMigrationProfile = false;
            Boolean isValidPriceValue = (isMigrationProfile)?true:validatePriceValue(periodPricing);
            Boolean isValidProportion = validatePricingProportion(periodPricing, oppDetail.leaseType, oppDetail.longleaseType);
            Boolean isValidReportingRule = validateMultipleReportingRule(periodPricing);
            Boolean isValidGPRange = (isMigrationProfile)?true:validateGPRange(periodPricing,oppDetail.pricingType);
            Boolean isValidGPPeriod = validateGPPeriod(periodPricing,oppDetail.pricingType);
            //Boolean validateGPCalculationReporting = validateGPCalculationReporting(oppDetail);
            Boolean validateGPCalculationReporting = true;
            Boolean isValidIncludeCAM = validateIncludeCAM(camOrAirServiceObject,periodPricing);
            Boolean isValidEstimateRevenue = validateEstimateRevenue(periodPricing, oppDetail.pricingType);

            if(isValidCAMPeriod && validateCAMPeriodOptionToRenew && isValidPricingPeriod && isValidPricingPeriodOptionToRenew && isValidPriceValue && isValidProportion && isValidReportingRule && isValidGPRange && isValidGPPeriod && validateGPCalculationReporting && isValidIncludeCAM && isValidEstimateRevenue) {
                oppController.processPricing(camOrAirServiceObject,periodPricing, rentAndService, oppDetail);
            }else{
                if (!isValidCAMPeriod) {
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : CAM Period Date not Valid', true, false));
                }else if(!isValidPricingPeriod){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Pricing Period Date not Valid', true, false));
                }else if(!isValidPriceValue){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Price input can not be 0', true, false));
                }else if (!isValidProportion) {
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Invalid Proportion', true, false));
                }else if(!isValidReportingRule){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Please specify sales description', true, false));
                }else if (!isValidGPRange) {
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : GP Range should have at least valid 1 range', true, false));
                }else if (!isValidPricingPeriodOptionToRenew) {
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Pricing Option to Renew Period Date not Valid', true, false));
                }else if (!isValidGPPeriod) {
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Each period should have at least 1 GP', true, false));
                }else if (!validateGPCalculationReporting){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Please Select Calculation and Reporting', true, false));
                }else if(!isValidIncludeCAM){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : หากต้องการระบุราคา CAM ของแต่ละประเภทพื้นที่ไม่เท่ากัน และ Include CAM กรุณาเลือก Calculation Method: Fixed Measurement (ราคาต่อประเภทพื้นที่)', true, false));
                }else if(!validateCAMPeriodOptionToRenew){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : CAM Option to Renew Period Date not Valid', true, false));
                }else if(!isValidEstimateRevenue){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Please input Estimate Revenue', true, false));
                }

            }


        }catch(Exception ex){
            targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Error : ' + ex.getMessage(), true, false));
            System.debug('Fail '+ ex.getMessage());
            System.debug(ex.getStackTraceString());
            System.debug(ex.getLineNumber());
        }

        return targetMessageDialog;

    }

	// #region Validate CAM
    public static Boolean validateCAMPeriod(QuotationComponentDataWrapper.CAMPricingWrapper camPricing, Date contractStartDate, Date contractEndDate, QuotationComponentDataWrapper.OppUIWrapper oppDetail){

        Boolean res = true;
        List<Date> camDateFromList = new List<Date>();
        List<Date> camDateToList = new List<Date>();
        Map<Date,Decimal> dateMap = new Map<Date,Decimal>();
        Decimal countDate = 0;

        if (!camPricing.CAMYearPeriod.isEmpty()) {

            if (oppDetail.leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก' && oppDetail.isAllowLongLeaseChangePeriod){
                /*for ( QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camPricing.CAMYearPeriod){
                    if (Utility.isPeriodOverlap(contractStartDate, contractEndDate, eachCAMPeriod.DateFrom, eachCAMPeriod.DateTo)){
                        if (contractStartDate.isSameDay(eachCAMPeriod.DateFrom)) {
                            if(!Date.newInstance(eachCAMPeriod.DateFrom.year(),12,31).isSameDay(Date.newInstance(eachCAMPeriod.DateTo.year(),eachCAMPeriod.DateTo.month(),eachCAMPeriod.DateTo.day()))){
                                return false;
                            }
                        }else{
                            return false;
                        }
                    }else{
                        return false;
                    }
                }*/
            }else{
                for ( QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camPricing.CAMYearPeriod) {
                    if (!eachCAMPeriod.isToDeleteRecord && !eachCAMPeriod.isOptionToRenew) {
                        camDateFromList.add(eachCAMPeriod.DateFrom);
                        camDateToList.add(eachCAMPeriod.DateTo);

                        if (dateMap.containsKey(eachCAMPeriod.DateFrom) || dateMap.containsKey(eachCAMPeriod.DateTo)) {

                            if (dateMap.containsKey(eachCAMPeriod.DateFrom)) {
                                countDate = dateMap.get(eachCAMPeriod.DateFrom);
                                countDate = countDate +1;
                                dateMap.put(eachCAMPeriod.DateFrom, countDate);
                            }

                            if(dateMap.containsKey(eachCAMPeriod.DateTo)){
                                countDate = dateMap.get(eachCAMPeriod.DateTo);
                                countDate = countDate +1;
                                dateMap.put(eachCAMPeriod.DateTo, countDate);
                            }

                        }else{
                            dateMap.put(eachCAMPeriod.DateFrom, 1);
                            dateMap.put(eachCAMPeriod.DateTo, 1);
                        }
                    }
                }
                System.debug('dateMap' + dateMap);
                if (!dateMap.isEmpty()) {

                    for (Decimal eachValue : dateMap.values()) {
                        if (eachValue>1 ) {
                            return false;
                        }
                    }
                }
                camDateFromList.sort();
                camDateToList.sort();
                System.debug('camDateFromList'+camDateFromList);
                System.debug('camDateToList'+camDateToList);

                Date minDate = camDateFromList.get(0);
                Date maxDate = camDateToList.get(camDateToList.size()-1);
                System.debug('minDate'+minDate);
                System.debug('maxDate'+maxDate);

                System.debug('contractStartDate'+contractStartDate);
                System.debug('contractEndDate'+contractEndDate);

                System.debug('contractStartDate.isSameDay(minDate)'+contractStartDate.isSameDay(minDate));
                System.debug('contractEndDate.isSameDay(maxDate)'+contractEndDate.isSameDay(maxDate));

                if (!contractStartDate.isSameDay(minDate) || !contractEndDate.isSameDay(maxDate)) {
                    return false;
                }

                Date tomorrowDate;
                for (Date eachDateTo : camDateToList) {
                    tomorrowDate = eachDateTo;
                    tomorrowDate = tomorrowDate.addDays(1);

                    System.debug('eachDateTo' + eachDateTo);
                    System.debug('tomorrowDate' + tomorrowDate);
                    System.debug('camDateFromList.contains(tomorrowDate)' + camDateFromList.contains(tomorrowDate));

                    if (!camDateFromList.contains(tomorrowDate)) {
                        System.debug('contractEndDate.isSameDay(eachDateTo)'+ contractEndDate.isSameDay(eachDateTo));
                        if (contractEndDate.isSameDay(eachDateTo)) {
                            res = true;
                        }else{
                            return false;
                        }
                    }else{
                        for (Date eachDateFrom : camDateFromList){
                            if (camDateFromList.indexOf(tomorrowDate) <= camDateToList.indexOf(eachDateTo)) {
                                return false;
                            }
                        }
                    }
                }
            }
        }else{
            return false;
        }
        return res;
    }

    public static Boolean validateCAMPeriodOptionToRenew(QuotationComponentDataWrapper.CAMPricingWrapper camPricing, Date contractStartDate, Date contractEndDate, Decimal optionTorenewYear, Decimal optionTorenewMonth){
        Boolean res = true;
        Map<Date,Decimal> dateMap = new Map<Date,Decimal>();
        Decimal countDate = 0;
        List<Date> camDateFromList = new List<Date>();
        List<Date> camDateToList = new List<Date>();

        Date optionToRenewStartDate = contractEndDate.addDays(1);
        Date optionToRenewEndDate = Date.newInstance(optionToRenewStartDate.year() + Integer.valueof(optionTorenewYear), optionToRenewStartDate.month() + Integer.valueof(optionTorenewMonth), optionToRenewStartDate.day()-1);
        if (!camPricing.CAMYearPeriod.isEmpty()) {
            for ( QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camPricing.CAMYearPeriod) {
                if (!eachCAMPeriod.isToDeleteRecord && eachCAMPeriod.isOptionToRenew) {
                    camDateFromList.add(eachCAMPeriod.DateFrom);
                    camDateToList.add(eachCAMPeriod.DateTo);

                    if (dateMap.containsKey(eachCAMPeriod.DateFrom) || dateMap.containsKey(eachCAMPeriod.DateTo)) {

                        if (dateMap.containsKey(eachCAMPeriod.DateFrom)) {
                            countDate = dateMap.get(eachCAMPeriod.DateFrom);
                            countDate = countDate +1;
                            dateMap.put(eachCAMPeriod.DateFrom, countDate);
                        }

                        if(dateMap.containsKey(eachCAMPeriod.DateTo)){
                            countDate = dateMap.get(eachCAMPeriod.DateTo);
                            countDate = countDate +1;
                            dateMap.put(eachCAMPeriod.DateTo, countDate);
                        }

                    }else{
                        dateMap.put(eachCAMPeriod.DateFrom, 1);
                        dateMap.put(eachCAMPeriod.DateTo, 1);
                    }
                }
            }
            if (!dateMap.isEmpty()) {

                for (Decimal eachValue : dateMap.values()) {
                    if (eachValue>1 ) {
                        return false;
                    }
                }
            }
            camDateFromList.sort();
            camDateToList.sort();

            if(!camDateFromList.isEmpty() && !camDateToList.isEmpty()){
                Date minDate = camDateFromList.get(0);
                Date maxDate = camDateToList.get(camDateToList.size()-1);
                if (!optionToRenewStartDate.isSameDay(minDate) || !optionToRenewEndDate.isSameDay(maxDate)) {
                    return false;
                }

                Date tomorrowDate;
                for (Date eachDateTo : camDateToList) {
                    tomorrowDate = eachDateTo;
                    tomorrowDate = tomorrowDate.addDays(1);

                    if (!camDateFromList.contains(tomorrowDate)) {

                        if (optionToRenewEndDate.isSameDay(eachDateTo)) {
                            res = true;
                        }else{
                            return false;
                        }
                    }else{
                        for (Date eachDateFrom : camDateFromList){
                            if (camDateFromList.indexOf(tomorrowDate) <= camDateToList.indexOf(eachDateTo)) {
                                return false;
                            }
                        }
                    }
                }
            }
        }else{
            return false;
        }
        return res;
    }

	// #region Validate Pricing
    public static Boolean validatePricingPeriod(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod, Date contractStartDate, Date contractEndDate, QuotationComponentDataWrapper.OppUIWrapper oppDetail){
        Boolean res = true;
        List<Date> pricingDateFromList = new List<Date>();
        List<Date> pricingDateToList = new List<Date>();
        Map<Date,Decimal> dateMap = new Map<Date,Decimal>();
        Decimal countDate = 0;
        System.debug('pricingPeriod' + pricingPeriod);
        System.debug('contractStartDate' + contractStartDate);
        System.debug('contractEndDate' + contractEndDate);

        if (!pricingPeriod.isEmpty()) {

            if (oppDetail.leaseType == 'Long-Term' && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก' && oppDetail.isAllowLongLeaseChangePeriod){
                // for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod){
                //     if (Utility.isPeriodOverlap(contractStartDate, contractEndDate, eachPricingPeriod.PricingFrom, eachPricingPeriod.PricingTo)) {
                //         if(contractStartDate.isSameDay(eachPricingPeriod.PricingFrom)){
                //             if(!Date.newInstance(eachPricingPeriod.PricingFrom.year(),12,31).isSameDay(Date.newInstance(eachPricingPeriod.PricingTo.year(), eachPricingPeriod.PricingTo.month(), eachPricingPeriod.PricingTo.day()))){
                //                 return false;
                //             }
                //         }else{
                //             return false;
                //         }
                //     }else{
                //         return false;
                //     }
                // }
            }else{

                for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod) {
                    if (!eachPricingPeriod.isToDeleteRecord && eachPricingPeriod.OptionToRenew != true) {

                        System.debug('Validate Period '+ eachPricingPeriod);

                        pricingDateFromList.add(eachPricingPeriod.PricingFrom);
                        pricingDateToList.add(eachPricingPeriod.PricingTo);


                        if (dateMap.containsKey(eachPricingPeriod.PricingFrom) || dateMap.containsKey(eachPricingPeriod.PricingTo)) {

                            if (dateMap.containsKey(eachPricingPeriod.PricingFrom)) {
                                countDate = dateMap.get(eachPricingPeriod.PricingFrom);
                                countDate = countDate +1;
                                dateMap.put(eachPricingPeriod.PricingFrom, countDate);
                            }

                            if(dateMap.containsKey(eachPricingPeriod.PricingTo)){
                                countDate = dateMap.get(eachPricingPeriod.PricingTo);
                                countDate = countDate +1;
                                dateMap.put(eachPricingPeriod.PricingTo, countDate);
                            }
                        }else{
                            dateMap.put(eachPricingPeriod.PricingFrom, 1);
                            dateMap.put(eachPricingPeriod.PricingTo, 1);
                        }
                    }
                }
                System.debug('dateMap' + dateMap);

                if (!dateMap.isEmpty()) {

                    for (Decimal eachValue : dateMap.values()) {
                        if (eachValue>1 ) {
                            return false;
                        }
                    }
                }
                pricingDateFromList.sort();
                pricingDateToList.sort();

                if(!pricingDateFromList.isEmpty() && !pricingDateToList.isEmpty()){
                    System.debug('pricingDateFromList'+ pricingDateFromList);
                    System.debug('pricingDateToList'+ pricingDateToList);

                    Date minDate = pricingDateFromList.get(0);
                    Date maxDate = pricingDateToList.get(pricingDateToList.size()-1);
                    System.debug('minDate' + minDate);
                    System.debug('maxDate' + maxDate);
                    if (!contractStartDate.isSameDay(minDate) || !contractEndDate.isSameDay(maxDate)) {
                        return false;
                    }

                    Date tomorrowDate;
                    for (Date eachDateTo : pricingDateToList) {
                        tomorrowDate = eachDateTo;
                        tomorrowDate = tomorrowDate.addDays(1);
                        if (!pricingDateFromList.contains(tomorrowDate)) {

                            if (contractEndDate.isSameDay(eachDateTo)) {
                                res = true;
                            }else{
                                return false;
                            }
                        }else{
                            for (Date eachDateFrom : pricingDateFromList){
                                if (pricingDateFromList.indexOf(tomorrowDate) <= pricingDateToList.indexOf(eachDateTo)) {
                                    return false;
                                }
                            }
                        }
                    }
                }else{
                    return false;
                }
            }
        }else{
            return false;
        }
        return res;
    }

    public static Boolean validatePricingPeriodOptionToRenew(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod, Date contractStartDate, Date contractEndDate, Decimal optionTorenewYear, Decimal optionTorenewMonth){
        Boolean res = true;
        List<Date> pricingDateFromList = new List<Date>();
        List<Date> pricingDateToList = new List<Date>();
        Map<Date,Decimal> dateMap = new Map<Date,Decimal>();
        Decimal countDate = 0;
        Date optionToRenewStartDate = contractEndDate.addDays(1);
        Date optionToRenewEndDate = Date.newInstance(optionToRenewStartDate.year() + Integer.valueof(optionTorenewYear), optionToRenewStartDate.month() + Integer.valueof(optionTorenewMonth), optionToRenewStartDate.day()-1);

        if (!pricingPeriod.isEmpty()) {
            for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod) {
                if (!eachPricingPeriod.isToDeleteRecord && eachPricingPeriod.OptionToRenew == true) {
                    pricingDateFromList.add(eachPricingPeriod.PricingFrom);
                    pricingDateToList.add(eachPricingPeriod.PricingTo);


                    if (dateMap.containsKey(eachPricingPeriod.PricingFrom) || dateMap.containsKey(eachPricingPeriod.PricingTo)) {

                        if (dateMap.containsKey(eachPricingPeriod.PricingFrom)) {
                            countDate = dateMap.get(eachPricingPeriod.PricingFrom);
                            countDate = countDate +1;
                            dateMap.put(eachPricingPeriod.PricingFrom, countDate);
                        }

                        if(dateMap.containsKey(eachPricingPeriod.PricingTo)){
                            countDate = dateMap.get(eachPricingPeriod.PricingTo);
                            countDate = countDate +1;
                            dateMap.put(eachPricingPeriod.PricingTo, countDate);
                        }

                    }else{
                        dateMap.put(eachPricingPeriod.PricingFrom, 1);
                        dateMap.put(eachPricingPeriod.PricingTo, 1);
                    }
                }

            }

            if (!dateMap.isEmpty()) {

                for (Decimal eachValue : dateMap.values()) {
                    if (eachValue>1 ) {
                        return false;
                    }
                }
            }
            pricingDateFromList.sort();
            pricingDateToList.sort();

            if(!pricingDateFromList.isEmpty() && !pricingDateToList.isEmpty()){
                Date minDate = pricingDateFromList.get(0);
                Date maxDate = pricingDateToList.get(pricingDateToList.size()-1);
                if (!optionToRenewStartDate.isSameDay(minDate) || !optionToRenewEndDate.isSameDay(maxDate)) {
                    return false;
                }

                Date tomorrowDate;
                for (Date eachDateTo : pricingDateToList) {
                    tomorrowDate = eachDateTo;
                    tomorrowDate = tomorrowDate.addDays(1);
                    if (!pricingDateFromList.contains(tomorrowDate)) {
                        if (optionToRenewEndDate.isSameDay(eachDateTo)) {
                            res = true;
                        }else{
                            return false;
                        }
                    }else{
                        for (Date eachDateFrom : pricingDateFromList){
                            if (pricingDateFromList.indexOf(tomorrowDate) <= pricingDateToList.indexOf(eachDateTo)) {
                                return false;
                            }
                        }
                    }
                }
            }else{
                return false;
            }
        }else{
            return false;
        }
        return res;
    }
	/**
	 * CR Feb 2025
	 */
    public static Boolean validatePriceValue(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod){
        Boolean res = true;
        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod) {
            if (!eachPricingPeriod.isToDeleteRecord) {
                if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_PRICE) {
                        // if (eachPricingPeriod.FixedPriceSection.Price == 0) {
                        //     return false;
                        // }
                }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_RO) {
                    for (QuotationComponentDataWrapper.RentalObjectPricingWrapper eachRO: eachPricingPeriod.FixedRentalObjectSection.rentalObjectList) {
                        if (eachRO.Price.value == 0 && eachRO.LeasableArea > 0) {
                            return false;
                        }
						/**
						 * CR Feb 2025
						 * Changed Detail: add condition to check from other attribute (valuePerDay)
						 */
						//
						//
						//
						// Changed end
                    }
                }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_MEAS) {
                    // for (QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement: eachPricingPeriod.FixedMeasurementSection.pricingList) {

                    //     if (eachMeasurement.Price.value == 0) {
                    //         return false;
                    //     }
                    // }
                }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
                    if (eachPricingPeriod.GPWithMinSection.PricingSection.MinType == 'Measurement') {
                        for (QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement: eachPricingPeriod.GPWithMinSection.PricingSection.MeasumentPricingList) {
                            if (eachMeasurement.Price.value == 0) {
                                return false;
                            }
                        }
                    }else if(eachPricingPeriod.GPWithMinSection.PricingSection.MinType == 'Fixed'){
                        if(eachPricingPeriod.GPWithMinSection.PricingSection.FixedPricing.Price == 0){
                            return false;
                        }
                    }
                }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {
                    if (eachPricingPeriod.GPOnTopSection.PricingSection.MinType == 'Measurement') {
                        for (QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement: eachPricingPeriod.GPOnTopSection.PricingSection.MeasumentPricingList) {
                            if (eachMeasurement.Price.value == 0) {
                                return false;
                            }
                        }
                    }else if(eachPricingPeriod.GPOnTopSection.PricingSection.MinType == 'Fixed'){
                        if(eachPricingPeriod.GPOnTopSection.PricingSection.FixedPricing.Price == 0){
                            return false;
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validatePricingProportion(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod, String leaseType, String longleaseType){
        Boolean res = true;
        Decimal rentValue = 0;
        Decimal serviceValue = 0;

        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod){
            if (!eachPricingPeriod.isToDeleteRecord) {
                rentValue = (eachPricingPeriod.Proportion.Rent != null)?eachPricingPeriod.Proportion.Rent:0;
                serviceValue = (eachPricingPeriod.Proportion.Service != null)?eachPricingPeriod.Proportion.Service:0;

                if (leaseType == 'Long-Term' && longleaseType == 'ระบุราคาปีปฏิทินแรก') {
                    // if ((rentValue + serviceValue) != 100) {
                    //     return false;
                    // }
                }else if(leaseType == 'Short-Term' || (leaseType == 'Long-Term' && longleaseType == 'ระบุราคาทุกปีตามปีสัญญา')){
                    if ((rentValue + serviceValue) != 100) {
                        return false;
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateMultipleReportingRule(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod){
        Boolean res = true;
        Integer numberOfDeleteRecord = 0;

        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod){
            numberOfDeleteRecord = 0;
            if(!eachPricingPeriod.isToDeleteRecord){
                if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN) {
                    if (!eachPricingPeriod.GPNoMinSection.ReportingRuleList.isEmpty() && eachPricingPeriod.GPNoMinSection.ReportingRuleList.size()>1) {
                        for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPNoMinSection.ReportingRuleList){
                            if (eachReportingRule.isToDeleteRecord){
                                numberOfDeleteRecord++ ;
                            }
                        }

                        if (numberOfDeleteRecord != (eachPricingPeriod.GPNoMinSection.ReportingRuleList.size()-1)) {
                            for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPNoMinSection.ReportingRuleList){
                                if (!eachReportingRule.isToDeleteRecord) {
                                    if (eachReportingRule.ReportingRuleDescription == null) {
                                        return false;
                                    }else{
                                        if (String.isEmpty(eachReportingRule.ReportingRuleDescription.trim()) || eachReportingRule.ReportingRuleDescription.trim().isWhitespace()) {
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
                    if (!eachPricingPeriod.GPWithMinSection.ReportingRuleList.isEmpty() && eachPricingPeriod.GPWithMinSection.ReportingRuleList.size()>1) {
                        for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPWithMinSection.ReportingRuleList){
                            if (eachReportingRule.isToDeleteRecord){
                                numberOfDeleteRecord++ ;
                            }
                        }

                        if (numberOfDeleteRecord != (eachPricingPeriod.GPWithMinSection.ReportingRuleList.size()-1)){
                            for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPWithMinSection.ReportingRuleList){
                                if (!eachReportingRule.isToDeleteRecord){
                                    if (eachReportingRule.ReportingRuleDescription == null) {
                                        return false;
                                    }else{
                                        if (String.isEmpty(eachReportingRule.ReportingRuleDescription.trim()) || eachReportingRule.ReportingRuleDescription.trim().isWhitespace()) {
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {
                    if (!eachPricingPeriod.GPOnTopSection.ReportingRuleList.isEmpty() && eachPricingPeriod.GPOnTopSection.ReportingRuleList.size()>1) {
                        for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPOnTopSection.ReportingRuleList){
                            if (eachReportingRule.isToDeleteRecord){
                                numberOfDeleteRecord++ ;
                            }
                        }

                        if (numberOfDeleteRecord != (eachPricingPeriod.GPOnTopSection.ReportingRuleList.size()-1)){
                            for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPOnTopSection.ReportingRuleList){
                                if (!eachReportingRule.isToDeleteRecord){
                                    if (eachReportingRule.ReportingRuleDescription == null) {
                                        return false;
                                    }else{
                                        if (String.isEmpty(eachReportingRule.ReportingRuleDescription.trim()) || eachReportingRule.ReportingRuleDescription.trim().isWhitespace()) {
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateGPRange(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod, String pricingType){
        Boolean res = true;
        Integer numberOfDeleteRecord = 0;

        if (pricingType == Constant.OPP_PRICING_TYPE_GP) {
            for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod){
                if (!eachPricingPeriod.isToDeleteRecord) {
                    if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN) {
                        if (!eachPricingPeriod.GPNoMinSection.ReportingRuleList.isEmpty()) {
                            for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPNoMinSection.ReportingRuleList){
                                numberOfDeleteRecord = 0;
                                if (!eachReportingRule.isToDeleteRecord) {
                                    if (eachReportingRule.ReportingRuleDetailList.isEmpty()) {
                                        return false;
                                    }else{
                                        for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                                            if (eachReportingRuleDetail.isToDeleteRecord) {
                                                numberOfDeleteRecord++;
                                            }else{
                                                if (eachReportingRuleDetail.rangFrom == 0 && eachReportingRuleDetail.rangTo == 0 && eachReportingRuleDetail.GPPercent == 0) {
                                                    return false;
                                                }
                                            }
                                        }

                                        if (numberOfDeleteRecord == eachReportingRule.ReportingRuleDetailList.size()) {
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                    }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
                        if (!eachPricingPeriod.GPWithMinSection.ReportingRuleList.isEmpty()) {
                            for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPWithMinSection.ReportingRuleList){
                                numberOfDeleteRecord = 0;
                                if (!eachReportingRule.isToDeleteRecord){
                                    if (eachReportingRule.ReportingRuleDetailList.isEmpty()) {
                                        return false;
                                    }else{
                                        for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                                            if (eachReportingRuleDetail.isToDeleteRecord) {
                                                numberOfDeleteRecord++;
                                            }else{
                                                if (eachReportingRuleDetail.rangFrom == 0 && eachReportingRuleDetail.rangTo == 0 && eachReportingRuleDetail.GPPercent == 0) {
                                                    return false;
                                                }
                                            }
                                        }

                                        if (numberOfDeleteRecord == eachReportingRule.ReportingRuleDetailList.size()) {
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                    }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {
                        if (!eachPricingPeriod.GPOnTopSection.ReportingRuleList.isEmpty()) {
                            for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPOnTopSection.ReportingRuleList){
                                numberOfDeleteRecord = 0;
                                if (!eachReportingRule.isToDeleteRecord){
                                    if (eachReportingRule.ReportingRuleDetailList.isEmpty()) {
                                        return false;
                                    }else{
                                        for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                                            if (eachReportingRuleDetail.isToDeleteRecord) {
                                                numberOfDeleteRecord++;
                                            }else{
                                                if (eachReportingRuleDetail.rangFrom == 0 && eachReportingRuleDetail.rangTo == 0 && eachReportingRuleDetail.GPPercent == 0) {
                                                    return false;
                                                }
                                            }
                                        }
                                        if (numberOfDeleteRecord == eachReportingRule.ReportingRuleDetailList.size()) {
                                            return false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateGPPeriod(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod, String pricingType){
        Boolean res = true;
        Integer numberOfDeleteRecord = 0;

        if (pricingType == Constant.OPP_PRICING_TYPE_GP) {
            for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod){
                if(!eachPricingPeriod.isToDeleteRecord){
                    numberOfDeleteRecord = 0;
                    if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN) {
                        if (eachPricingPeriod.GPNoMinSection.ReportingRuleList.isEmpty()) {
                            return false;
                        }else{
                            for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPNoMinSection.ReportingRuleList) {
                                if (eachReportingRule.isToDeleteRecord) {
                                    numberOfDeleteRecord++;
                                }
                            }

                            if (numberOfDeleteRecord == eachPricingPeriod.GPNoMinSection.ReportingRuleList.size()) {
                                return false;
                            }
                        }
                    }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
                        if (eachPricingPeriod.GPWithMinSection.ReportingRuleList.isEmpty()) {
                            return false;
                        }else{
                            for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPWithMinSection.ReportingRuleList) {
                                if (eachReportingRule.isToDeleteRecord) {
                                    numberOfDeleteRecord++;
                                }
                            }

                            if (numberOfDeleteRecord == eachPricingPeriod.GPWithMinSection.ReportingRuleList.size()) {
                                return false;
                            }
                        }
                    }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {
                        if (eachPricingPeriod.GPOnTopSection.ReportingRuleList.isEmpty()) {
                            return false;
                        }else{
                            for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPOnTopSection.ReportingRuleList) {
                                if (eachReportingRule.isToDeleteRecord) {
                                    numberOfDeleteRecord++;
                                }
                            }

                            if (numberOfDeleteRecord == eachPricingPeriod.GPOnTopSection.ReportingRuleList.size()) {
                                return false;
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    // public static Boolean validateGPCalculationReporting(QuotationComponentDataWrapper.OppUIWrapper oppDetail){
    //     Boolean res = true;

    //     if (oppDetail.pricingType == 'GP' && !oppDetail.isRetailzone) {
    //         if(String.isBlank(oppDetail.calculationAndReporting)) return false;
    //     }
    //     return res;
    // }

    public static Boolean validateIncludeCAM(QuotationComponentDataWrapper.CAMPricingWrapper camPricing, List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod){
        Boolean res = true;
        Boolean isContainFixedPriceFixedRo = false;
        Boolean isIncludeCAM = false;
        Boolean isContainMinTypeMeasurment = false;
        Boolean isMultipleMeasurement = false;
        Boolean isDiffCAMPrice = false;

        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : pricingPeriod){
            if(!eachPricingPeriod.isToDeleteRecord){
                if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_PRICE){
                    // isContainFixedPriceFixedRo = true;
                    // if (eachPricingPeriod.IsIncludeCAM) {
                    //     isIncludeCAM = true;
                    // }

                    // if (eachPricingPeriod.FixedPriceSection.MinType == 'Measurement') {
                    //     isContainMinTypeMeasurment = true;
                    // }
                }else if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_RO){
                    isContainFixedPriceFixedRo = true;
                    if (eachPricingPeriod.IsIncludeCAM){
                        isIncludeCAM = true;
                    }

                    if (eachPricingPeriod.FixedRentalObjectSection.MinType == 'Measurement') {
                        isContainMinTypeMeasurment = true;
                    }
                }
            }
        }

        if (!camPricing.CAMYearPeriod.isEmpty()) {
            for ( QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camPricing.CAMYearPeriod) {
                if (!eachCAMPeriod.isToDeleteRecord){
                    if (!eachCAMPeriod.CAMMeasurmentList.isEmpty() && eachCAMPeriod.CAMMeasurmentList.size() > 1) {
                        isMultipleMeasurement = true;
                        Decimal price = eachCAMPeriod.CAMMeasurmentList.get(0).Price.value;
                        for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
                            if (eachCAMMeasurement.Price.value != price) {
                                isDiffCAMPrice = true;
                            }
                        }
                    }
                }
            }
        }

        if (isContainFixedPriceFixedRo && isIncludeCAM && isContainMinTypeMeasurment && isMultipleMeasurement && isDiffCAMPrice) {
            return false;
        }
        return res;
    }

    public static Boolean validateEstimateRevenue(List<QuotationComponentDataWrapper.PeriodPricing> pricingPeriod, String pricingType){
        Boolean isValid = true;
        if (pricingType == Constant.OPP_PRICING_TYPE_GP) {
            for(QuotationComponentDataWrapper.PeriodPricing each :pricingPeriod){
                if(!each.isToDeleteRecord && (each.EstimateRevernue == null || each.EstimateRevernue <= 0)){
                    isValid = false;
                }
            }
        }

        return isValid;
    }

	// #region Deposit JSON
    @AuraEnabled
    public static String getDepositObjectJson(String camORAirServiceCondition, Decimal camPrice, Decimal rentPrice, Decimal servicePrice, Decimal depositMonth, Id parentContract, String oppUiWrapper){
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
        Map<String,String> depositOptionMap = getPicklistOption('OpportunityDepositExpense__c', 'DepositOption__c');
        List<String> depositOptionKey = new List<String>(depositOptionMap.keySet());

        Decimal airServiceCarriedDeposit = 0;
        Decimal camCarriedDeposit = 0;
        Decimal rentCarriedDeposit = 0;
        Decimal serviceCarriedDeposit = 0;
        System.debug(oppUiWrapper);
        Decimal depositMonths = (depositMonth!=0 || depositMonth != null)?depositMonth:0;
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);

        QuotationComponentDataWrapper.DepositWrapper depositObject = new QuotationComponentDataWrapper.DepositWrapper();
        depositObject.DepositMonth = depositMonths;
        depositObject.NumberOfInstallment = 1;
        depositObject.DepositCalculationType = 'System Calculation';
        depositObject.DepositRemark = '';
        depositObject.DepositOption = depositOptionKey.get(0);

        QuotationComponentDataWrapper.ParentContractPaidDeposit paidDeposit;
        if (oppDetail.isAllowChangeOptionToRenew) {
            if (oppDetail.oppStageName == Constant.OPP_STAGE_QUOTATIONPREPARATION) {
                List<ContractDepositExpense__c> contractDepositExpenseList = ObjectSelector.getContractDepositAndExpense(oppDetail.parentContractId, 'Deposit');
                if (!contractDepositExpenseList.isEmpty()){
                    ContractDepositExpense__c contractDepositExpense = contractDepositExpenseList.get(0);
                    paidDeposit = new QuotationComponentDataWrapper.ParentContractPaidDeposit(oppDetail.parentContractCAMOrAirService);
                    paidDeposit.camOrAirService_BankGuaruntee = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((contractDepositExpense.PaidDepositCAM_BG__c != null)?contractDepositExpense.PaidDepositCAM_BG__c : 0);
                    paidDeposit.rent_BankGuaruntee = (contractDepositExpense.PaidDepositRent_BG__c != null)?contractDepositExpense.PaidDepositRent_BG__c : 0;
                    paidDeposit.service_BankGuaruntee = (contractDepositExpense.PaidDepositService_BG__c != null)?contractDepositExpense.PaidDepositService_BG__c : 0;
                    // paidDeposit.camOrAirService_Cash = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((camORAirServiceCondition == Constant.TYPE_CAM)?((contractDepositExpense.PaidDepositCAM__c != null)?contractDepositExpense.PaidDepositCAM__c : 0):0);
                    // paidDeposit.rent_Cash = (contractDepositExpense.PaidDepositRent__c != null)?contractDepositExpense.PaidDepositRent__c : 0;
                    // paidDeposit.service_Cash = (contractDepositExpense.PaidDepositService__c != null)?contractDepositExpense.PaidDepositService__c : 0;
                    paidDeposit.camOrAirService_Cash = (oppDetail.parentContractIsNoCAM || oppDetail.camOrAirService == Constant.CAL_METHOD_AIR) ? 0 : ((camORAirServiceCondition == Constant.TYPE_CAM)?((contractDepositExpense.CAMDeposit__c != null)?contractDepositExpense.CAMDeposit__c : 0):0);
                    paidDeposit.rent_Cash = (contractDepositExpense.RentDeposit__c != null)?contractDepositExpense.RentDeposit__c : 0;
                    paidDeposit.service_Cash = (contractDepositExpense.ServiceDeposit__c != null)?contractDepositExpense.ServiceDeposit__c : 0;
                    paidDeposit.camOrAirService_Summary = paidDeposit.camOrAirService_BankGuaruntee + paidDeposit.camOrAirService_Cash;
                    paidDeposit.rent_Summary = paidDeposit.rent_BankGuaruntee + paidDeposit.rent_Cash;
                    paidDeposit.service_Summary = paidDeposit.service_BankGuaruntee + paidDeposit.service_Cash;

                    //camCarriedDeposit = (contractDepositExpense.PaidDepositCAM__c != null) ? contractDepositExpense.PaidDepositCAM__c : 0;
                    camCarriedDeposit = paidDeposit.camOrAirService_Cash;
                    rentCarriedDeposit = paidDeposit.rent_Cash;
                    serviceCarriedDeposit = paidDeposit.service_Cash;

                }
            }
        }
        depositObject.DepositSummary = new QuotationComponentDataWrapper.DepositSummaryWrapper(oppDetail.isNoCAM,camORAirServiceCondition,depositMonths,camPrice,rentPrice,servicePrice,camCarriedDeposit,rentCarriedDeposit,serviceCarriedDeposit);
        depositObject.DepositSummary.ParentContractPaidDeposit = paidDeposit;

            if (oppDetail.isNoCAM) {
                depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = 0;
                depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Vat = 0;
                depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = 0;
                depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = 0;

                depositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit = camCarriedDeposit + serviceCarriedDeposit;
                depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit = 0;
            }

            Decimal rentTotalDeposit = (depositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit != null)? depositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit :0;
            Decimal serviceTotalDeposit = (depositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit != null)? depositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit :0;
            Decimal camOrAirServiceTotalDeposit = (depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit != null)? depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit :0;


            rentCarriedDeposit = (depositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit != null)?(depositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
            serviceCarriedDeposit = (depositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit != null)?(depositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
            Decimal camOrAirServiceCarriedDeposit = (depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit != null)?(depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;

            depositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentTotalDeposit;
            depositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceTotalDeposit;
            depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceTotalDeposit;

            Decimal rentActualDDeposit = depositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit;
            Decimal serviceActualDDeposit = depositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit;
            Decimal camOrAirServiceActualDDeposit = depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit;

            Decimal rentSummaryDeposit =  rentActualDDeposit - rentCarriedDeposit;
            Decimal serviceSummaryDeposit =  serviceActualDDeposit - serviceCarriedDeposit;
            Decimal camOrAirServiceSummaryDeposit =  camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit;

            depositObject.DepositSummary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
            depositObject.DepositSummary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
            depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
            depositObject.DepositSummary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;

            Decimal camOrAirService_Summary_vat = (depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100)).setscale(2, RoundingMode.HALF_UP);
            Decimal service_Summary_vat = (depositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100)).setscale(2, RoundingMode.HALF_UP);
            Decimal rent_Summary_vat = (oppDetail.isWindowDisplay)? (depositObject.DepositSummary.DepositSummaryPricing.rent_Summary*(vatPercent/100)).setscale(2, RoundingMode.HALF_UP) : 0;

            depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
            depositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = depositObject.DepositSummary.DepositSummaryPricing.rent_Summary + rent_Summary_vat;
            depositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = depositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

            depositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + depositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + depositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;

        QuotationComponentDataWrapper.InstallmentWrapper newInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
        newInstallment.InstallmentNumber = '1';
        newInstallment.InstallmentAmount = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit;
        newInstallment.InstallmentVAT = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat - depositObject.DepositSummary.DepositSummaryPricing.totalDeposit;
        newInstallment.InstallmentAmountWithVat = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat;
        newInstallment.PaymentDueDate = (oppDetail.isAllowChangeOptionToRenew && newInstallment.InstallmentAmount <= 0) ? null : newInstallment.PaymentDueDate;
        newInstallment.PaymentMethod = (oppDetail.isAllowChangeOptionToRenew && newInstallment.InstallmentAmount <= 0) ? null : newInstallment.PaymentMethod;

        depositObject.DepositSummary.InstallmentList.add(newInstallment);
        depositObject.DepositSummary.TotalInstallment = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit;
        depositObject.DepositSummary.TotalInstallment_VAT = newInstallment.InstallmentVAT;
        depositObject.DepositSummary.TotalInstallment_WithVat = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat;

        depositObject.OtherDepositList = new List<QuotationComponentDataWrapper.DepositOtherWrapper>();
        return JSON.serialize(depositObject);
    }

	// #region Save Deposit
    @AuraEnabled
    public static MessageDialog saveDepositApex(String depositJson, Id oppId, String oppUiWrapper, Boolean isInitialDeposit){
        MessageDialog targetMessageDialog = new MessageDialog();
        OpportunityController oppController = new OpportunityController();
        System.debug('depositJson' + depositJson);

        try{
            QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
            QuotationComponentDataWrapper.DepositWrapper depositObject = (QuotationComponentDataWrapper.DepositWrapper) JSON.deserialize(depositJson, QuotationComponentDataWrapper.DepositWrapper.class);
            //Opportunity currentOpp = [SELECT Id, tms_IsMigrate__c FROM Opportunity WHERE Id =: oppId];

            System.debug('depositObject' + depositObject);

            //Boolean isMigrationProfile = tms_Utility.isValidateMigrationProfile(currentOpp);
            Boolean isMigrationProfile = false;
            Boolean validateNumberOfInstallment = (isMigrationProfile)?true:(oppDetail.isAllowChangeOptionToRenew)? true :validateInstallmentDeposit(depositObject);
            Boolean validateInstallmentAmount = (isMigrationProfile)?true:validateInstallmentAmountOfDeposit(depositObject);
            Boolean validateOtherDepositType = validateOtherDepositType(depositObject);
            Boolean validateDepositPaymentDuedate = validateDepositInstallmentPaymentDueDate(depositObject);
            Boolean validateAdvanceTotalDeposit = validateAdvanceTotalDeposit(depositObject);
            Boolean validateDepositLastInstallmentAmount = (isMigrationProfile)?true:(oppDetail.isAllowChangeOptionToRenew)? true :validateDepositLastInstallmentAmount(depositObject);
            Boolean validateInstallmentPaymentMethod = (!oppDetail.isAllowChangeOptionToRenew)? true : validateInstallmentPaymentMethod(depositObject);
            // Boolean validateCarriedDepositWhenRenewOpp_And_NoCAM = (oppDetail.isAllowChangeOptionToRenew && !isInitialDeposit)? validateCarriedDepositWhenRenewOpp_And_NoCAM(depositObject) : true;

            // if (validateNumberOfInstallment && validateInstallmentAmount && validateOtherDepositType && validateDepositPaymentDuedate && validateAdvanceTotalDeposit && validateDepositLastInstallmentAmount && validateInstallmentPaymentMethod && validateCarriedDepositWhenRenewOpp_And_NoCAM) {
            if (validateNumberOfInstallment && validateInstallmentAmount && validateOtherDepositType && validateDepositPaymentDuedate && validateAdvanceTotalDeposit && validateDepositLastInstallmentAmount && validateInstallmentPaymentMethod) {

                oppController.processSecurityDeposit(oppId,depositObject,oppDetail);
                oppController.processDeposit(oppId,depositObject,oppDetail);
            }else{
                if (!validateNumberOfInstallment) {
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Number of Installment cannot be 0', true, false));
                }else if(!validateInstallmentAmount){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Sum of installments should equal to total amount', true, false));
                }else if(!validateOtherDepositType){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Other Deposit Type should not Dupliate', true, false));
                }else if(!validateDepositPaymentDuedate){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Installment Payment Duedate should not Dupliate', true, false));
                }else if(!validateAdvanceTotalDeposit){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Deposit Amount not Valid', true, false));
                }else if(!validateDepositLastInstallmentAmount){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Last Installment should more than 0.', true, false));
                }else if(!validateInstallmentPaymentMethod){
                    targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Please Select Payment Method.', true, false));
                }
                // else if(!validateCarriedDepositWhenRenewOpp_And_NoCAM){
                //     targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Total Carried Deposit Should Equal to Total Paid Carried (Cash).', true, false));
                // }
            }
        }catch(Exception ex){
            targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Error : ' + ex.getMessage(), true, false));
            System.debug('Fail '+ ex.getMessage());
            System.debug(ex.getStackTraceString());
            System.debug(ex.getLineNumber());
        }
        return targetMessageDialog;
    }

    public static Boolean validateInstallmentDeposit(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        List<QuotationComponentDataWrapper.InstallmentWrapper> installmentToDeleteList;
        if (depositObject.DepositSummary != null) {
            if (depositObject.DepositSummary.DepositSummaryPricing.totalDeposit != 0){

                if (depositObject.NumberOfInstallment == 0 || depositObject.DepositSummary.InstallmentList.isEmpty()) {
                    return false;
                }else{
                    if (!depositObject.DepositSummary.InstallmentList.isEmpty()) {
                        installmentToDeleteList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

                        for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : depositObject.DepositSummary.InstallmentList){
                            if (eachInstallment.isToDeleteRecord) {
                                installmentToDeleteList.add(eachInstallment);
                            }
                        }

                        if (installmentToDeleteList.size() == depositObject.DepositSummary.InstallmentList.size()) {
                            return false;
                        }
                    }
                }
            }
        }else{
            return false;
        }

        if (!depositObject.OtherDepositList.isEmpty()) {
            for (QuotationComponentDataWrapper.DepositOtherWrapper eachOtherInstallment: depositObject.OtherDepositList) {

                if (!eachOtherInstallment.isToDeleteRecord) {
                    if (eachOtherInstallment.NumberOfInstallment == 0 || eachOtherInstallment.InstallmentList.isEmpty()) {
                        return false;
                    }else{
                        if (!eachOtherInstallment.InstallmentList.isEmpty()) {
                            installmentToDeleteList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();
                            for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachOtherInstallment.InstallmentList){
                                if (eachInstallment.isToDeleteRecord) {
                                    installmentToDeleteList.add(eachInstallment);
                                }
                            }

                            if (installmentToDeleteList.size() == eachOtherInstallment.InstallmentList.size()) {
                                return false;
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateInstallmentAmountOfDeposit(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        Decimal sumAmount  = 0;
        System.debug('Deposit to Validate '+ depositObject);
        if (depositObject.DepositSummary != null){
            System.debug('Validate Deposit Summary');
            sumAmount  = 0;
            if (!depositObject.DepositSummary.InstallmentList.isEmpty()){
                for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : depositObject.DepositSummary.InstallmentList){
                    if (!eachInstallment.isToDeleteRecord) {
                        sumAmount += eachInstallment.InstallmentAmount;
                    }
                }

                System.debug('sumAmount ' + sumAmount);
                System.debug('totalDeposit ' + depositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
                if (sumAmount != depositObject.DepositSummary.DepositSummaryPricing.totalDeposit) {
                    return false;
                }
            }
        }

        if (depositObject.OtherDepositList != null && !depositObject.OtherDepositList.isEmpty()){
            for (QuotationComponentDataWrapper.DepositOtherWrapper eachOtherInstallment: depositObject.OtherDepositList){
                sumAmount  = 0;
                System.debug('Validate Other Deposit');

                if (!eachOtherInstallment.InstallmentList.isEmpty()){
                    for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachOtherInstallment.InstallmentList){
                        if (!eachInstallment.isToDeleteRecord) {
                            sumAmount += eachInstallment.InstallmentAmount;
                        }
                    }
                    System.debug('sumAmount ' + sumAmount);
                    System.debug('totalDeposit ' + eachOtherInstallment.TotalAmount);

                    if (sumAmount != eachOtherInstallment.TotalAmount) {
                        return false;
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateOtherDepositType(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        Decimal sumAmount  = 0;
        Set<String> typeSet = new Set<String>();
        if (depositObject.OtherDepositList != null && !depositObject.OtherDepositList.isEmpty()){
            for (QuotationComponentDataWrapper.DepositOtherWrapper eachOtherInstallment: depositObject.OtherDepositList){
                if (!eachOtherInstallment.isToDeleteRecord) {
                    if (typeSet.contains(eachOtherInstallment.Type)) {
                        return false;
                    }else{
                        typeSet.add(eachOtherInstallment.Type);
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateDepositInstallmentPaymentDueDate(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        Set<Date> paymentDuadateSet = new Set<Date>();
        if (depositObject.DepositSummary != null){
            System.debug('Validate Deposit Summary');
            if (!depositObject.DepositSummary.InstallmentList.isEmpty()){
                paymentDuadateSet = new Set<Date>();
                for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : depositObject.DepositSummary.InstallmentList){
                    if (!eachInstallment.isToDeleteRecord) {
                        if (paymentDuadateSet.contains(eachInstallment.PaymentDueDate)) {
                            return false;
                        }else{
                            paymentDuadateSet.add(eachInstallment.PaymentDueDate);
                        }
                    }
                }
            }
        }

        if (depositObject.OtherDepositList != null && !depositObject.OtherDepositList.isEmpty()){
            for (QuotationComponentDataWrapper.DepositOtherWrapper eachOtherInstallment: depositObject.OtherDepositList){
                paymentDuadateSet = new Set<Date>();
                if(!eachOtherInstallment.isToDeleteRecord){
                    if (!eachOtherInstallment.InstallmentList.isEmpty()){
                        for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachOtherInstallment.InstallmentList){
                           if (!eachInstallment.isToDeleteRecord) {
                                if (paymentDuadateSet.contains(eachInstallment.PaymentDueDate)) {
                                    return false;
                                }else{
                                    paymentDuadateSet.add(eachInstallment.PaymentDueDate);
                                }
                           }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateAdvanceTotalDeposit(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        if (depositObject.DepositCalculationType == 'Advance' && depositObject.DepositSummary != null){
           Decimal advanceDepositAmount = depositObject.DepositSummary.AdvanceDepositAmount;
           Decimal rent_TotalDeposit = depositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit;
           Decimal service_TotalDeposit = depositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit;
           Decimal cam_TotalDeposit = depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit;
           Decimal totalDeposit = rent_TotalDeposit + service_TotalDeposit + cam_TotalDeposit;

           if (advanceDepositAmount != totalDeposit) {
               return false;
           }
        }
        return res;
    }

    public static Boolean validateDepositLastInstallmentAmount(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        Decimal totalDepositSumary  = 0;
        Decimal rentDepositSummary = 0;
        Decimal serviceDepositSummary = 0;
        Decimal camOrAirserviceDepositSummary = 0;

        if (depositObject.DepositSummary != null){
            System.debug('Validate Deposit Summary');
            rentDepositSummary = (depositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit != null)?depositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit:0;
            serviceDepositSummary = (depositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit != null)?depositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit:0;
            camOrAirserviceDepositSummary = (depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit != null)?depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit:0;
            totalDepositSumary = rentDepositSummary + serviceDepositSummary + camOrAirserviceDepositSummary;
            if (!depositObject.DepositSummary.InstallmentList.isEmpty()){
                if (totalDepositSumary > 0) {
                    for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : depositObject.DepositSummary.InstallmentList){
                        if (!eachInstallment.isToDeleteRecord) {
                            if (eachInstallment.InstallmentAmount <= 0) {
                                return false;
                            }
                        }
                    }
                }
            }
        }

        if (depositObject.OtherDepositList != null && !depositObject.OtherDepositList.isEmpty()){
            for (QuotationComponentDataWrapper.DepositOtherWrapper eachOtherInstallment: depositObject.OtherDepositList){
                if(!eachOtherInstallment.isToDeleteRecord){
                    if (!eachOtherInstallment.InstallmentList.isEmpty()){
                        for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachOtherInstallment.InstallmentList){
                           if (!eachInstallment.isToDeleteRecord) {
                                if (eachInstallment.InstallmentAmount <= 0) {
                                    return false;
                                }
                           }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateInstallmentPaymentMethod(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        if (depositObject.DepositSummary != null){
            System.debug('Validate Deposit Summary');
            if (!depositObject.DepositSummary.InstallmentList.isEmpty()){
                for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : depositObject.DepositSummary.InstallmentList){
                    if (!eachInstallment.isToDeleteRecord) {
                        if (depositObject.DepositSummary.DepositSummaryPricing.totalDeposit>0) {
                            if (eachInstallment.PaymentMethod == null || String.isBlank(eachInstallment.PaymentMethod)) {
                                return false;
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateCarriedDepositWhenRenewOpp_And_NoCAM(QuotationComponentDataWrapper.DepositWrapper depositObject){
        Boolean res = true;
        if (depositObject.DepositSummary != null){
            Decimal summaryPaidCarriedDepositCash = depositObject.DepositSummary.ParentContractPaidDeposit.camOrAirService_Cash + depositObject.DepositSummary.ParentContractPaidDeposit.rent_Cash + depositObject.DepositSummary.ParentContractPaidDeposit.service_Cash;
            Decimal totalNewCarriedDeposit = depositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit + depositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit + depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit;

            if (totalNewCarriedDeposit != summaryPaidCarriedDepositCash) {
                return false;
            }
        }
        return res;
    }

	// #region Other Deposit JSON
    @AuraEnabled
    public static String getNewOtherDepositJson(){
        QuotationComponentDataWrapper.DepositOtherWrapper  otherDepositObject = new QuotationComponentDataWrapper.DepositOtherWrapper();
        QuotationComponentDataWrapper.InstallmentWrapper newInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
        newInstallment.InstallmentNumber = '1';

        otherDepositObject.NumberOfInstallment = 1;
        otherDepositObject.InstallmentList.add(newInstallment);
        return JSON.serialize(otherDepositObject);
    }

	// #region Inst JSON
    @AuraEnabled
    public static String getNewInstallmentJson(){
        QuotationComponentDataWrapper.InstallmentWrapper installmentObject = new QuotationComponentDataWrapper.InstallmentWrapper();
        return JSON.serialize(installmentObject);
    }

	// #region Other Expense JSON
    @AuraEnabled
    public static String getNewOtherExpenseJson(String rentType, String targetType){
        String res;
        QuotationPreparationScreenMaster__c pageMasterListQuery = [SELECT
                                                                        Format__c,
                                                                        IsActive__c,
                                                                        ScreentoDisplay__c,
                                                                        Type__c,
                                                                        RentalType__c,
                                                                        Sequence__c
                                                                        FROM QuotationPreparationScreenMaster__c
                                                                        WHERE ScreentoDisplay__c =: Constant.TYPE_EXPENSEANDFEE AND IsActive__c =: TRUE AND RentalType__c =: rentType AND Type__c =: targetType LIMIT 1];
        QuotationComponentDataWrapper.FixedOtherExpenseFormat fixedFormat;
        QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat rateAndAreaFormat;

        if(pageMasterListQuery.Format__c == Constant.PAGE_MASTER_FORMAT_FIXED){
            fixedFormat = new QuotationComponentDataWrapper.FixedOtherExpenseFormat(pageMasterListQuery.Type__c);
            fixedFormat.ExpenseOtherType = pageMasterListQuery.Format__c;
            fixedFormat.Sequence = pageMasterListQuery.Sequence__c;
            res = JSON.serialize(fixedFormat);

        }else if(pageMasterListQuery.Format__c == Constant.PAGE_MASTER_FORMAT_RATE_AND_AREA){
            rateAndAreaFormat = new QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat(pageMasterListQuery.Type__c);
            rateAndAreaFormat.ExpenseOtherType = pageMasterListQuery.Format__c;
            rateAndAreaFormat.Sequence = pageMasterListQuery.Sequence__c;
            res = JSON.serialize(rateAndAreaFormat);
        }
        return res;
    }

	// #region Save Other Expense
    @AuraEnabled
    public static MessageDialog saveOtherExpense(String expenseJson, Id oppId, String oppUiWrapper){
        OpportunityController oppController = new OpportunityController();
        MessageDialog targetMessageDialog = new MessageDialog();

        System.debug('Incomming expenseJson' + expenseJson);
        try{
            QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
            QuotationComponentDataWrapper.OtherWrapper otherExpenseObject = (QuotationComponentDataWrapper.OtherWrapper) JSON.deserialize(expenseJson, QuotationComponentDataWrapper.OtherWrapper.class);
            System.debug('deserialize otherExpenseObject' + otherExpenseObject);

            if (otherExpenseObject != null) {
                // Boolean validateAdditionalOverArea = validateAdditionalOverArea(otherExpenseObject,oppDetail);
                // Boolean validateAdditionalNoArea = validateAdditionalNoArea(otherExpenseObject,oppDetail);

                // if (validateAdditionalOverArea && validateAdditionalNoArea) {
                    oppController.processOtherExpense(oppId, oppDetail, otherExpenseObject);
                // }else{
                //     if (!validateAdditionalOverArea) {
                //         targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Area should not more than total measurement areas.', true, false));
                //     }else if (!validateAdditionalNoArea) {
                //         targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Area should not be 0.', true, false));
                //     }
                // }
            }
        }catch(Exception ex){
            targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Error : ' + ex.getMessage(), true, false));
            System.debug('Fail '+ ex.getMessage());
        }
        return targetMessageDialog;
    }

    // public static Boolean validateAdditionalOverArea(QuotationComponentDataWrapper.OtherWrapper otherExpenseObject, QuotationComponentDataWrapper.OppUIWrapper oppDetail){
    //     Boolean res = true;

    //     if (!otherExpenseObject.rateAndAreaFormatList.isEmpty()) {
    //         for(QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat eachOtherExpense : otherExpenseObject.rateAndAreaFormatList) {
    //             if (eachOtherExpense.SubType == 'Additional' && eachOtherExpense.Area > oppDetail.totalMeasurmentArea) {
    //                 return false;
    //             }
    //         }
    //     }
    //     return res;
    // }

    // public static Boolean validateAdditionalNoArea(QuotationComponentDataWrapper.OtherWrapper otherExpenseObject, QuotationComponentDataWrapper.OppUIWrapper oppDetail){
    //     Boolean res = true;

    //     if (!otherExpenseObject.rateAndAreaFormatList.isEmpty()) {
    //         for(QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat eachOtherExpense : otherExpenseObject.rateAndAreaFormatList) {
    //             if (eachOtherExpense.SubType == 'Additional' && (eachOtherExpense.Area == 0 || eachOtherExpense.Area == null)) {
    //                 return false;
    //             }
    //         }
    //     }
    //     return res;
    // }

    @AuraEnabled
    public static String getNewExpenseINstallmentJsonForLeaseHold(String selectedRoomJson, String oppUiWrapper, Boolean includSummary, Integer initNumberInstallment){
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        Set<String> measurementIdSet = new Set<String>();
        for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList){
            if(!eachSelectedRO.isToDeleteRecord){
                for(QuotationComponentDataWrapper.ROMeasurementClass eachROMeasurement :  eachSelectedRO.roMeasurmentList){
                    measurementIdSet.add(eachROMeasurement.measurementId);
                }
            }
        }

        List<QuotationPreparationScreenMaster__c> screenSetting  = [SELECT
                                                                            Type__c,
                                                                            Subtype__c,
                                                                            SpecificMeasurement__c,
                                                                            Format__c
                                                                        FROM QuotationPreparationScreenMaster__c
                                                                        WHERE
                                                                            Format__c =: Constant.DEP_EXP_TYPE_LEASEHOLD AND
                                                                            ScreentoDisplay__c =: Constant.TYPE_OTHER AND
                                                                            RentalType__c =: oppDetail.rentType AND
                                                                            Type__c IN: oppDetail.spetialOtherTypePicklist AND
                                                                            SpecificMeasurement__c IN: measurementIdSet];

        List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseInstallmentList  = new List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>();
        Decimal totalArea = 0;
        Integer leaseHoldIndex = 0;
        for (QuotationPreparationScreenMaster__c eachScreenMaster : screenSetting) {
            totalArea = 0;
            QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper  expenseInstallment = new QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper();
            expenseInstallment.isLEASEHOLD = true;
            expenseInstallment.isLeaseHoldDisableINstallment = (leaseHoldIndex>0)?true:false;
            expenseInstallment.Type = eachScreenMaster.Type__c;
            expenseInstallment.SubType = 'สิทธิการเช่า';
            Map<String,QuotationComponentDataWrapper.LeaseHoldFloorInfoTable> leaseHoldFloorMap  = new Map<String,QuotationComponentDataWrapper.LeaseHoldFloorInfoTable>();
            for (QuotationComponentDataWrapper.RentalObjectClass eachSelectedRO : selectedRoomList){
                if(!eachSelectedRO.isToDeleteRecord){
                    if(leaseHoldFloorMap.containsKey(eachSelectedRO.floor)){
                        QuotationComponentDataWrapper.LeaseHoldFloorInfoTable leaseHoldFloor = leaseHoldFloorMap.get(eachSelectedRO.floor);
                        for(QuotationComponentDataWrapper.ROMeasurementClass eachROMeasurement :  eachSelectedRO.roMeasurmentList){
                            if(eachROMeasurement.measurementId == eachScreenMaster.SpecificMeasurement__c){
                                leaseHoldFloor.area += eachROMeasurement.measurementArea;
                                totalArea += eachROMeasurement.measurementArea;
                            }
                        }
                    }else{
                        QuotationComponentDataWrapper.LeaseHoldFloorInfoTable leaseHoldFloor = new QuotationComponentDataWrapper.LeaseHoldFloorInfoTable();
                        for(QuotationComponentDataWrapper.ROMeasurementClass eachROMeasurement :  eachSelectedRO.roMeasurmentList){
                            if(eachROMeasurement.measurementId == eachScreenMaster.SpecificMeasurement__c){
                                leaseHoldFloor.floorName = eachSelectedRO.floor;
                                leaseHoldFloor.price = 0;
                                leaseHoldFloor.totalAmount = 0;
                                leaseHoldFloor.area = eachROMeasurement.measurementArea;
                                leaseHoldFloor.floorId = eachSelectedRO.floorId;
                                leaseHoldFloor.measurementId = eachROMeasurement.measurementId;
                                totalArea += leaseHoldFloor.area;
                                leaseHoldFloorMap.put(eachSelectedRO.floor, leaseHoldFloor);
                            }
                        }
                    }
                }
            }
            expenseInstallment.leaseHoldInfo = leaseHoldFloorMap.values();
            expenseInstallment.leaseHoldTotalArea = totalArea;

            if(includSummary){
                QuotationComponentDataWrapper.InstallmentWrapper newInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
                newInstallment.InstallmentNumber = '1';

                expenseInstallment.NumberOfInstallment = 1;
                expenseInstallment.InstallmentList.add(newInstallment);
            }else{
                QuotationComponentDataWrapper.InstallmentWrapper newInstallmentSummaryLeaseHold ;

                for(Integer i = 0; i < initNumberInstallment; i++){
                    newInstallmentSummaryLeaseHold = new QuotationComponentDataWrapper.InstallmentWrapper();
                    newInstallmentSummaryLeaseHold.InstallmentNumber = String.valueof(i+1);
                    expenseInstallment.InstallmentList.add(newInstallmentSummaryLeaseHold);
                }

                expenseInstallment.NumberOfInstallment = initNumberInstallment;
            }
            expenseInstallmentList.add(expenseInstallment);
            leaseHoldIndex++;
        }

        if(includSummary){
            QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper  expenseInstallmentSummaryLeaseHold = new QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper();
            expenseInstallmentSummaryLeaseHold.Type = 'Summary สิทธิการเช่า';
            expenseInstallmentSummaryLeaseHold.SubType = 'Summary สิทธิการเช่า';
            expenseInstallmentSummaryLeaseHold.isLEASEHOLDSUMMARY = true;
            expenseInstallmentSummaryLeaseHold.isLEASEHOLD = false;
            expenseInstallmentSummaryLeaseHold.isLeaseHoldDisableINstallment = true;

            QuotationComponentDataWrapper.InstallmentWrapper newInstallmentSummaryLeaseHold = new QuotationComponentDataWrapper.InstallmentWrapper();
            newInstallmentSummaryLeaseHold.InstallmentNumber = '1';

            expenseInstallmentSummaryLeaseHold.NumberOfInstallment = 1;
            expenseInstallmentSummaryLeaseHold.InstallmentList.add(newInstallmentSummaryLeaseHold);

            expenseInstallmentList.add(expenseInstallmentSummaryLeaseHold);
        }
        return JSON.serialize(expenseInstallmentList);
    }

    @AuraEnabled
    public static String getNewExpenseINstallmentJson(){
        QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper  expenseInstallment = new QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper();

        QuotationComponentDataWrapper.InstallmentWrapper newInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
        newInstallment.InstallmentNumber = '1';

        expenseInstallment.NumberOfInstallment = 1;
        expenseInstallment.InstallmentList.add(newInstallment);

        return JSON.serialize(expenseInstallment);
    }

    @AuraEnabled
    public static MessageDialog saveExpenseInstallment(String installmentJson, Id oppId, String oppUiWrapper){
        // System.debug('Selected Room To save '+ selectedRoomJson);
        OpportunityController oppController = new OpportunityController();
        System.debug('In Comming Installment List '+installmentJson);
        MessageDialog targetMessageDialog = new MessageDialog();
        try{
            QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppUiWrapper, QuotationComponentDataWrapper.OppUIWrapper.class);
            List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList = (List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>) JSON.deserialize(installmentJson, List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>.class);
            System.debug('desrialize '+ expenseAndFeeList);
            if(expenseAndFeeList != null){
                Boolean valdateExpenseType = validateExpenseType(expenseAndFeeList);
                Boolean valdateExpenseInstallment = validateInstallmentExpenseAndFee(expenseAndFeeList);
                Boolean validateInstallmentAmount = validateInstallmentAmount(expenseAndFeeList);
                Boolean validateExpenseInstallmentPaymentDueDate = validateExpenseInstallmentPaymentDueDate(expenseAndFeeList);
                Boolean validateExpenseLastInstallmentAmount = validateExpenseLastInstallmentAmount(expenseAndFeeList);
                Boolean validateContractTypeForLeseHold = (oppDetail.contractTypeValue == Constant.OPP_CONTRACT_TYPE_LONGLEASE_FIXED || oppDetail.contractTypeValue == Constant.OPP_CONTRACT_TYPE_LONGLEASE_GP) ? validateExpenseTypeWhenContractTypeLongLease(expenseAndFeeList) : true;

                if (valdateExpenseType && valdateExpenseInstallment&&validateInstallmentAmount&&validateExpenseInstallmentPaymentDueDate&&validateExpenseLastInstallmentAmount) {
                    oppController.processExpenseAndFee(oppId,expenseAndFeeList,oppDetail);
                }else{
                    if (!valdateExpenseType) {
                        targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Expense Type cannot Dupliate', true, false));
                    }else if(!valdateExpenseInstallment){
                        targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Number of Installment cannot be 0', true, false));
                    }else if(!validateInstallmentAmount){
                        targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Sum of installments should equal to total amount', true, false));
                    }else if(!validateExpenseInstallmentPaymentDueDate){
                        targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Payment Duedate should not Duplicate', true, false));
                    }else if(!validateExpenseLastInstallmentAmount){
                        targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Last Installment should more than 0.', true, false));
                    }else if(!validateContractTypeForLeseHold){
                        targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Validate Error : Opportunity Contract Type Long-Lease must include Type  \'สิทธิการเช่า\' ', true, false));
                    }
                }
            }
        }catch(Exception ex){
            targetMessageDialog = new messageDialog (new MessageDialogAuraWrapper('Error : ' + ex.getMessage(), true, false));
            System.debug('Fail '+ ex.getMessage());
            System.debug(ex.getStackTraceString());
            System.debug(ex.getLineNumber());
        }
        return targetMessageDialog;
    }

    public static Boolean validateExpenseType(List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList){
        Boolean res = true;
        Map<String,Decimal> expenseTypeMap = new Map<String,Decimal>();
        Decimal numberOfTypeRecord = 0;

        if (expenseAndFeeList != null) {
            for (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpense : expenseAndFeeList) {
                if(!eachExpense.isToDeleteRecord){
                    if (expenseTypeMap.containsKey(eachExpense.Type)) {
                        numberOfTypeRecord = expenseTypeMap.get(eachExpense.Type);
                        numberOfTypeRecord = numberOfTypeRecord+1;
                        expenseTypeMap.put(eachExpense.Type,numberOfTypeRecord);

                    }else{
                        expenseTypeMap.put(eachExpense.Type,1);
                    }
                }
            }
            if (!expenseTypeMap.isEmpty()) {
                for (Decimal eachResult : expenseTypeMap.values()) {
                    if (eachResult>1) {
                        return false;
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateExpenseTypeWhenContractTypeLongLease(List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList){
        Boolean res = false;
        Decimal sumAmount  = 0;
        Set<String> expenseTypeToSave = new Set<String>();
        List<QuotationPreparationScreenMaster__c> quotationMaster = [SELECT
                                                                        Format__c,
                                                                        Type__c,
                                                                        ScreentoDisplay__c
                                                                        FROM QuotationPreparationScreenMaster__c
                                                                        WHERE Format__c =: Constant.DEP_EXP_TYPE_LEASEHOLD
                                                                        AND ScreentoDisplay__c =: Constant.DEP_EXP_TYPE_GROUP_OTHER];
        if(expenseAndFeeList != null){
            for (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpense : expenseAndFeeList){
                if (!eachExpense.isToDeleteRecord) {
                    expenseTypeToSave.add(eachExpense.Type);
                }
            }
        }
        for(QuotationPreparationScreenMaster__c eachScreenMaster : quotationMaster){
            if(expenseTypeToSave.contains(eachScreenMaster.Type__c)){
                return true;
            }
        }
        return res;
    }

    public static Boolean validateInstallmentAmount(List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList){
        Boolean res = true;
        Decimal sumAmount  = 0;
        if(expenseAndFeeList != null){
            for (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpense : expenseAndFeeList){
                if (!eachExpense.isToDeleteRecord) {
                    if (!eachExpense.InstallmentList.isEmpty()) {
                        sumAmount = 0;
                        for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpense.InstallmentList){
                            if (!eachInstallment.isToDeleteRecord) {
                                sumAmount += eachInstallment.InstallmentAmount;
                            }
                        }
                        if(sumAmount != eachExpense.TotalAmount){
                            return false;
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateExpenseInstallmentPaymentDueDate(List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList){
        Boolean res = true;
        Set<Date> paymentDuadateSet = new Set<Date>();
        if (expenseAndFeeList != null) {
            for (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpense : expenseAndFeeList){
                if (!eachExpense.isToDeleteRecord) {
                    if (!eachExpense.InstallmentList.isEmpty()) {
                        paymentDuadateSet = new Set<Date>();
                        for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpense.InstallmentList){
                            if (!eachInstallment.isToDeleteRecord) {
                                 if (paymentDuadateSet.contains(eachInstallment.PaymentDueDate)) {
                                    return false;
                                }else{
                                    paymentDuadateSet.add(eachInstallment.PaymentDueDate);
                                }
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateExpenseLastInstallmentAmount(List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList){
        Boolean res = true;
        if(expenseAndFeeList != null){
            for (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpense : expenseAndFeeList){
                if (!eachExpense.isToDeleteRecord) {
                    if(!eachExpense.InstallmentList.isEmpty() && eachExpense.InstallmentList != null){
                        for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpense.InstallmentList){
                            if (!eachInstallment.isToDeleteRecord) {
                                if (eachInstallment.InstallmentAmount <= 0) {
                                    return false;
                                }
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    public static Boolean validateInstallmentExpenseAndFee(List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList){
        Boolean res = true;
        List<QuotationComponentDataWrapper.InstallmentWrapper> installmentToDeleteList;
        if (expenseAndFeeList != null) {
            for (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpense : expenseAndFeeList){
                if (!eachExpense.isToDeleteRecord) {
                    if (eachExpense.NumberOfInstallment == 0 || eachExpense.InstallmentList.isEmpty()) {
                        return false;
                    }else{
                        if (!eachExpense.InstallmentList.isEmpty()) {
                            installmentToDeleteList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();
                            for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpense.InstallmentList){
                                if (eachInstallment.isToDeleteRecord) {
                                    installmentToDeleteList.add(eachInstallment);
                                }
                            }
                            if (installmentToDeleteList.size() == eachExpense.InstallmentList.size()) {
                                return false;
                            }
                        }
                    }
                }
            }
        }
        return res;
    }

    @AuraEnabled
    public static String updateOppLineItem(String selectedRoomJson){
        List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);
        Set<Id> oppLineIdSet  = new Set<Id>();
        Map<Id,QuotationComponentDataWrapper.RentalObjectClass> oppLineMapArea  = new Map<Id,QuotationComponentDataWrapper.RentalObjectClass>();

        for(QuotationComponentDataWrapper.RentalObjectClass rentalObject : selectedRoomList){
            oppLineIdSet.add(rentalObject.oppLineId);
            oppLineMapArea.put(rentalObject.oppLineId, rentalObject);

            rentalObject.oppLineLeasableArea = rentalObject.leasableArea;
            rentalObject.oppLineTotalArea = rentalObject.measurement;
        }

        List<OpportunityLineItem__c> oppLineToUpdate = [SELECT Id, TotalArea__c, LeasableArea__c FROM OpportunityLineItem__c WHERE Id IN: oppLineIdSet];
        if (!oppLineToUpdate.isEmpty()) {

            for (OpportunityLineItem__c eachOppLineToUpdate : oppLineToUpdate) {
                eachOppLineToUpdate.LeasableArea__c = oppLineMapArea.get(eachOppLineToUpdate.Id).oppLineLeasableArea;
                eachOppLineToUpdate.TotalArea__c = oppLineMapArea.get(eachOppLineToUpdate.Id).oppLineTotalArea;
            }

            update oppLineToUpdate;
        }
        return JSON.serialize(selectedRoomList);
    }

    @AuraEnabled
    public static String editExpenseAndFeeWhenMeasurementChanged(Id oppId, String expenseAndFeeObjectJson, String selectedRoomJson, String oppUiWrapper){
        String returnNewExpenseAnd;
        if(expenseAndFeeObjectJson != null){
            List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList = (List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>) JSON.deserialize(expenseAndFeeObjectJson, List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>.class);
            List<QuotationComponentDataWrapper.RentalObjectClass> selectedRoomList = (List<QuotationComponentDataWrapper.RentalObjectClass>) JSON.deserialize(selectedRoomJson, List<QuotationComponentDataWrapper.RentalObjectClass>.class);

            Map<String, QuotationComponentDataWrapper.ROMeasurementClass> roMeasurementMapFloor = new Map<String, QuotationComponentDataWrapper.ROMeasurementClass>();
            for(QuotationComponentDataWrapper.RentalObjectClass eachSelectedRoom : selectedRoomList){
                if(!eachSelectedRoom.isToDeleteRecord){
                    for (QuotationComponentDataWrapper.ROMeasurementClass eachROMeasurement : eachSelectedRoom.roMeasurmentList) {
                        String mapKey = eachSelectedRoom.floorId + '_' +  eachROMeasurement.measurementId;
                        roMeasurementMapFloor.put(mapKey,eachROMeasurement);
                    }
                }
            }
            Decimal totalSummaryOfInstallment = 0;
            Decimal totalLeaseHoldArea = 0;
            Decimal totalSummary = 0;
            Decimal totalPriceInput = 0;
            for (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpenseAndFee : expenseAndFeeList) {
                if(eachExpenseAndFee.isLEASEHOLD){
                    totalLeaseHoldArea = 0;
                    totalSummary = 0;
                    totalPriceInput = 0;
                    for(QuotationComponentDataWrapper.LeaseHoldFloorInfoTable eachLeaseHoldFloor : eachExpenseAndFee.leaseHoldInfo){
                        String keyForGetMap = eachLeaseHoldFloor.floorId + '_' + eachLeaseHoldFloor.measurementId;
                        Decimal newArea = roMeasurementMapFloor.get(keyForGetMap).measurementArea;

                        eachLeaseHoldFloor.area = newArea;
                        eachLeaseHoldFloor.totalAmount = (eachLeaseHoldFloor.price * newArea).setScale(2,RoundingMode.HALF_UP);

                        totalLeaseHoldArea += newArea;
                        totalSummary += eachLeaseHoldFloor.totalAmount;
                        totalPriceInput += eachLeaseHoldFloor.price;
                    }
                    eachExpenseAndFee.leaseHoldTotalArea = totalLeaseHoldArea;
                    eachExpenseAndFee.TotalAmount = totalSummary;
                    eachExpenseAndFee.leaseHoldTotalPrice = totalPriceInput;
                    totalSummaryOfInstallment += totalSummary;

                    for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpenseAndFee.InstallmentList ){
                        eachInstallment.isToDeleteRecord = true;
                    }
                    QuotationComponentDataWrapper.InstallmentWrapper newInstallmentObject = new QuotationComponentDataWrapper.InstallmentWrapper();
                    newInstallmentObject.InstallmentNumber = '1';
                    newInstallmentObject.InstallmentAmount = totalSummary;
                    eachExpenseAndFee.InstallmentList.add(newInstallmentObject);
                    eachExpenseAndFee.TotalInstallment = totalSummary;
                    eachExpenseAndFee.NumberOfInstallment = 1;

                }else if(eachExpenseAndFee.isLEASEHOLDSUMMARY){
                    for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpenseAndFee.InstallmentList ){
                        eachInstallment.isToDeleteRecord = true;
                    }
                    QuotationComponentDataWrapper.InstallmentWrapper newInstallmentObject = new QuotationComponentDataWrapper.InstallmentWrapper();
                    newInstallmentObject.InstallmentNumber = '1';
                    newInstallmentObject.InstallmentAmount = totalSummaryOfInstallment;
                    eachExpenseAndFee.InstallmentList.add(newInstallmentObject);
                    eachExpenseAndFee.TotalAmount = totalSummaryOfInstallment;
                    eachExpenseAndFee.TotalInstallment = totalSummaryOfInstallment;
                    eachExpenseAndFee.NumberOfInstallment = 1;
                }
            }

            String expenseAndFeeJson = JSON.serialize(expenseAndFeeList);
            MessageDialog targetMessageDialog = saveExpenseInstallment(expenseAndFeeJson, oppId, oppUiWrapper);
            System.debug('Test Error ' +targetMessageDialog.messageAura.message);

            if(!targetMessageDialog.messageAura.isError){
                returnNewExpenseAnd = getSavedExpenseINstallmentJson(oppId);
            }
        }
        return returnNewExpenseAnd;
    }

    @AuraEnabled
    public static String getNewReportingRuleDetailJson(){
        QuotationComponentDataWrapper.ReportingRuleDetailWrapper reportingRuleDetailObject = new QuotationComponentDataWrapper.ReportingRuleDetailWrapper();
        return JSON.serialize(reportingRuleDetailObject);
    }

}