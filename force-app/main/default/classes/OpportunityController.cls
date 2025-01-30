public without sharing class OpportunityController {
    public static final String OBJECTNAME = 'Opportunity';
    public static final String MULTI_CONTACTINFO_FORMAT = 'Contact {0} : [{1}]';
    public static final String SPLITTER_INLINE_CONTACTINFO = ' ';
    public static final String SPLITTER_MULTILINE_CONTACTINFO = ',';
    public static final String ROLE_AR = 'AR';
    public static final String ROLE_TC = 'TC';
    public static final String CONSTANTS_SQUAREMETER = 'Sqm';

    public static final String STAGE_QUOTEPREPARE = 'Quotation Preparation';
    public static final String STAGE_PENDINGFORQUOTATIONAPPROVAL = 'Pending for Quotation Approval';
    public static final String STAGE_QUOTATIONAPPROVED = 'Quotation Approved';
    public static final String STAGE_NEGOTIATIONINPROGRESS = 'Negotiation in Progress';
    public static final String STAGE_PENDINGFORCONTRACTCREATIONAPPROVAL = 'Pending for Contract Creation Approval';
    public static final String STAGE_CONTRACTAPPROVED = 'Contract Approved';
    public static final String STAGE_CANCELLED = 'Cancelled';

    public static final String AUTO_CANCEL_REASON = 'มีการทำสัญญาที่โอกาสการขายอื่นที่เลือกห้องเดียวกัน';

    public static final String MINTYPE_FIXED = 'Fixed';
    public static final String MINTYPE_MEASUREMENT = 'Measurement';

    public static final String TYPE_DEFAULT = 'Default';
    public static final String TYPE_FULL = 'Full';
    public static final String TYPE_INSTALLMENT = 'Installment';
    public static final String TYPE_AMORTIZED = 'Amortized';

    public static final String MYOPENED_LISTVIEW_DEVNAME = 'tms_MyOpenedOpportunities';
    public static final String ALL_LISTVIEW_DEVNAME = 'AllOpportunities';
    public static final String MYOPP_LISTVIEW_DEVNAME = 'MyOpportunities';
    public static final String RECENTLY_LISTVIEW_DEVNAME = 'RecentlyViewedOpportunities';

    public static final String CONDITION_AUTO_GENERATED = 'Auto-Generated';
    public static final String CONDITION_PROPERTY_TAX = 'Property Tax';
    public static final String CONDITION_DUTY_STAMP = 'Duty Stamp';

    public static final String CONDITION_INIT_SBR_TECHNICAL2 = 'Z301';
    public static final String CONDITION_INIT_SBR_STAT2 = 'Z304';
    public static final String CONDITION_INIT_SBR_RENT2 = 'Z311';
    public static final String CONDITION_INIT_SBR_SERVICES2 = 'Z321';


    public static final Set<String> CONDITIONTYPE_FOR_SECONDSALESRULES = new Set<String>{ CONDITION_INIT_SBR_TECHNICAL2,
                                                                                   CONDITION_INIT_SBR_STAT2,
                                                                                   CONDITION_INIT_SBR_RENT2,
                                                                                   CONDITION_INIT_SBR_SERVICES2 };

    public static final Set<String> STAGE_BEFORE_CONTRACTAPPROVE = new Set<String>{ STAGE_QUOTEPREPARE,
                                                                                    STAGE_PENDINGFORQUOTATIONAPPROVAL,
                                                                                    STAGE_QUOTATIONAPPROVED,
                                                                                    STAGE_NEGOTIATIONINPROGRESS,
                                                                                    STAGE_PENDINGFORCONTRACTCREATIONAPPROVAL};

    public static final List<String> RECORDTYPE_RETAILZONE = new List<String> {'tms_RetailZoneProcess'};

    public class SumIncludedCAM {
        public Date ValidFrom {get; set;}
        public Date ValidTo {get; set;}
        public Double CAMUnitPrice {get; set;}
        /*public Double CAMTotalPrice {get; set;}*/
        public Double CAMUnitPricePerSQM {get; set;}
        public Double CAMPrice {get; set;}
        public Double CAMTotalArea {get; set;}
        public Map<Id, Double> CAMPricePerRO {get; set;}

        public SumIncludedCAM(Date dateFrom, Date dateTo, Double unitPrice, Double totalArea, Double price) {
            system.debug('totalArea : '+totalArea);
            ValidFrom = dateFrom;
            ValidTo = dateTo;
            CAMUnitPrice = unitPrice;
            CAMTotalArea = totalArea;
            /*CAMTotalPrice = unitPrice*totalArea;*/
            CAMPrice = price;
            CAMUnitPricePerSQM = (totalArea > 0)?CAMPrice/totalArea:CAMPrice;
            CAMPricePerRO = new Map<Id, Double>();
        }
    }

    public class IncludedCAMInfoByMeasurement {
        public Date ValidFrom {get; set;}
        public Date ValidTo {get; set;}
        public Map<String, Double> CAMUnitPriceMap {get; set;}

        public IncludedCAMInfoByMeasurement(Date dateFrom, Date dateTo, Map<String, Double> priceMap) {
            ValidFrom = dateFrom;
            ValidTo = dateTo;
            CAMUnitPriceMap = priceMap;
        }
    }

    public class SummaryPrice {
        public Decimal TotalPrice {get; set;}
        public Decimal FirstPriceSqm {get; set;}
        public Decimal LastPriceSqm {get; set;}
        public Decimal FirstPrice {get; set;}
        public Decimal LastPrice {get; set;}

        public SummaryPrice() {
            TotalPrice = FirstPriceSqm = LastPriceSqm = FirstPrice = LastPrice = 0;
        }
    }

    public List<QuotationComponentDataWrapper.RentalObjectClass> processSelectedRentalObject(Opportunity oppInfo, List<QuotationComponentDataWrapper.RentalObjectClass> rentalObjectModelList) {
        System.debug('processSelectedRentalObject');
        List<OpportunityLineItem__c> upsertOppLineItemList = new List<OpportunityLineItem__c>();
        List<OpportunityLineItem__c> deleteOppLineItemList = new List<OpportunityLineItem__c>();

        List<String> roomNumberList = new List<String>();
        Set<String> floorSet = new Set<String>();
        for(QuotationComponentDataWrapper.RentalObjectClass rentalObject : rentalObjectModelList) {
            if(!rentalObject.isToDeleteRecord) {
                roomNumberList.add(rentalObject.roomNumber);
                floorSet.add(rentalObject.floorShortName);
            }
        }
        String floorNumber = String.join(new List<String>(floorSet), ',');

        String roomNumber = roomNumberList.isEmpty() != true ? String.join(roomNumberList, ',') : null;
        Opportunity opp = new Opportunity(Id = oppInfo.Id,
                                          Leasable_Area__c = oppInfo.Leasable_Area__c,
                                          Total_Area_sq_m__c = oppInfo.Total_Area_sq_m__c,
                                          RoomNumber__c = roomNumber,
                                          FloorNumber__c = floorNumber);
        update opp;

        Set<Id> targetClearOppPrice = new Set<Id>();
        for(QuotationComponentDataWrapper.RentalObjectClass rentalObject : rentalObjectModelList) {
            OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c(
                                                            Opportunity__c = oppInfo.Id,
                                                            Unit__c = rentalObject.Id,
                                                            TotalArea__c = rentalObject.totalArea,
                                                            LeasableArea__c = RentalObject.leasableArea);
            oppLineItem.Id = !String.isBlank(rentalObject.oppLineId) ? rentalObject.oppLineId : null;

            if(rentalObject.isToDeleteRecord && oppLineItem.Id != null) {
                deleteOppLineItemList.add(oppLineItem);
            } else if (!rentalObject.isToDeleteRecord){
                upsertOppLineItemList.add(oppLineItem);
                if(targetClearOppPrice.size() == 0 && oppLineItem.Id == null) {
                    targetClearOppPrice.add(oppInfo.Id);
                }
            }
        }
        if(deleteOppLineItemList.size() > 0) {
            Database.delete(deleteOppLineItemList, false);
            targetClearOppPrice.add(oppInfo.Id);
        }
        if(upsertOppLineItemList.size() > 0) upsert upsertOppLineItemList;
        if(targetClearOppPrice.size() > 0) clearPricingRecord(targetClearOppPrice);

        for(QuotationComponentDataWrapper.RentalObjectClass rentalObject : rentalObjectModelList) {
            for(OpportunityLineItem__c oppLineItem : upsertOppLineItemList) {
                if(rentalObject.id == oppLineItem.Unit__c) {
                    rentalObject.oppLineId = oppLineItem.Id;
                    break;
                }
            }
        }
        return rentalObjectModelList;
    }

    private void clearPricingRecord(Set<Id> oppIdSet) {
        List<OpportunityPeriod__c> oppPeriodList = (List<OpportunityPeriod__c>)OpportunitySelector.getRelatedOpportunityInfoByOppId('OpportunityPeriod__c', oppIdSet);
        List<OpportunityDepositExpense__c> oppDepositExpenseList = (List<OpportunityDepositExpense__c>)OpportunitySelector.getRelatedOpportunityInfoByOppId('OpportunityDepositExpense__c', oppIdSet);
        List<OpportunityPrice__c> oppPriceList = (List<OpportunityPrice__c>)OpportunitySelector.getRelatedOpportunityInfoByOppId('OpportunityPrice__c', oppIdSet);
        //List<tms_OpportunityGrading__c> oppGradingList = (List<tms_OpportunityGrading__c>)OpportunitySelector.getRelatedOpportunityInfoByOppId('tms_OpportunityGrading__c', oppIdSet);
        //List<OpportunityLeaseholdFloorModel.Data> oppleaseHoldFloor = (List<OpportunityLeaseholdFloorModel.Data>)OpportunitySelector.getRelatedOpportunityInfoByOppId('OpportunityLeaseholdFloorModel.Data', oppIdSet);

        delete oppPriceList;
        delete oppDepositExpenseList;
        delete oppPeriodList;
        //delete oppGradingList;
        //delete oppleaseHoldFloor;

        List<Opportunity> toUpdate = new List<Opportunity>();
        for(Id oppId : oppIdSet) {
            Opportunity opp = new Opportunity(   Id = oppId, OpportunityGrading__c = null, OpportunityLeaseholdFloor__c = null);
            opp.Quotation_Preparation_Completed__c = false;
            opp.Total_CAM_THB__c = opp.Total_Rent_THB__c = opp.Total_Service_THB__c = 0;
            opp.TotalRentGP__c = opp.TotalServiceGP__c = opp.TotalEstimatGPRevernue__c = 0;
            opp.Total_Other_Expense_Amount_THB__c = opp.TotalDeposit__c = opp.Internet_cable__c = 0;
            opp.Monthly_Water__c = opp.Monthly_Electricity__c = opp.Monthly_Gas__c = 0;
            opp.Electricity_Per_Unit__c = opp.Water_Per_Unit__c = opp.Gas_Per_Unit__c = 0;
            opp.Year_1_Monthly_CAM__c = opp.Year_Last_Monthly_CAM__c = 0;
            opp.Year_1_Monthly_CAM_Sq_m__c = opp.Year_Last_Monthly_CAM_Sq_m__c = 0;
            opp.Year_1_Monthly_Service__c = opp.Year_Last_Monthly_Service__c = 0;
            opp.Year_1_Monthly_Service_Sq_m__c = opp.Year_Last_Monthly_Service_Sq_m__c = 0;
            opp.Year_1_Monthly_Rental__c = opp.Year_Last_Monthly_Rental__c = 0;
            opp.Year_1_Monthly_Rent_Sq_m__c = opp.Year_Last_Monthly_Rent_Sq_m__c = 0;
            opp.Rent_Percent_Last_Period__c = opp.ServicePercentLastPeriod__c = null;
            opp.TotalMinRentServiceTHB__c = opp.TotalMinRevenueTHB__c = 0;
            opp.CAM_Type__c = 'แบบปกติ';
            opp.Number_of_Installment_Deposit__c = 1;
            toUpdate.add(opp);
        }
        CacheTrigger.isRunningOpportunityTrigger = false;
        update(toUpdate);
        CacheTrigger.isRunningOpportunityTrigger = true;
    }

	/**
	 * CR Feb 2025
	 */
    public void processPricing(QuotationComponentDataWrapper.CAMPricingWrapper CAMInfo, List<QuotationComponentDataWrapper.PeriodPricing> priceInfoList, QuotationComponentDataWrapper.RentServicePricingWrapper rentServiceInfo, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        system.debug('cam info : '+CAMInfo);
        system.debug('priceInfoList : '+priceInfoList);
        system.debug('rentServiceInfo : '+rentServiceInfo);
        system.debug('uiWrapper : '+uiWrapper);
        String contractType = getContractType((Id)uiWrapper.oppId);
        List<Opportunity> targetOpportunity = OpportunitySelector.getOpportunityInfoByOppId(new Set<Id>{CAMInfo.oppId});

        // #region Process CAM
        SummaryPrice summaryCAM = processCalculateTotalCAM(CAMInfo);
        //System.debug('totalCAM : '+totalCAM);

        // Decimal totalMinRentService = processCalculateTotalMinRentService(priceInfoList);
        // * Update CAM Information on Opportunity
        Opportunity opp = new Opportunity(Id = CAMInfo.oppId,
                                          CAMEscalationType__c = CAMInfo.CAMCondition,
                                          CAMEscalationRate__c = CAMInfo.CAMEscationRate.value,
                                          RentAndServiceEscalationType__c = rentServiceInfo.RentCondition ,
                                          RentAndServiceEscalationRate__c = rentServiceInfo.RentServiceEscalationRate.value,
                                          Total_CAM_THB__c = summaryCAM.TotalPrice,
                                          Year_1_Monthly_CAM__c = summaryCAM.FirstPrice,
                                          Year_Last_Monthly_CAM__c = summaryCAM.LastPrice,
                                          Year_1_Monthly_CAM_Sq_m__c = summaryCAM.FirstPriceSqm,
                                          Year_Last_Monthly_CAM_Sq_m__c = summaryCAM.LastPriceSqm,
                                          Is_Period_Date_Changed__c = uiWrapper.isRenewChangeOppPeriod);

        // * Generate Opportunity Period for CAM
        Map<QuotationComponentDataWrapper.CAMYearPeriodWrapper, OpportunityPeriod__c> oppPeriodMap = new Map<QuotationComponentDataWrapper.CAMYearPeriodWrapper, OpportunityPeriod__c>();
        List<QuotationComponentDataWrapper.CAMYearPeriodWrapper> CAMYearPeriodList = CAMInfo.CAMYearPeriod;
        List<OpportunityPeriod__c> oppPeriodToUpsert = new List<OpportunityPeriod__c>();

        List<OpportunityPeriod__c> deleteOppPeriodList = new List<OpportunityPeriod__c>();

        if (!uiWrapper.isNoCAM) {
            for(QuotationComponentDataWrapper.CAMYearPeriodWrapper CAMYearPeriod : CAMYearPeriodList) {
                System.debug(CAMYearPeriod);
                OpportunityPeriod__c oppPeriod = generateOppPeriodForCAM(CAMInfo.oppId, CAMYearPeriod, uiWrapper);
                oppPeriod.CalculationMethod__c = CAMInfo.CAMOrAirService;
                if(!CAMYearPeriod.isToDeleteRecord) {
                    oppPeriodMap.put(CAMYearPeriod, oppPeriod);
                } else {
                    if(oppPeriod.Id != null) {
                        deleteOppPeriodList.add(oppPeriod);
                    }
                }
            }
        }

        OpportunityPeriod__c oppRentServicePeriod = new OpportunityPeriod__c();
        if (rentServiceInfo != null ) {
            oppRentServicePeriod = generateOppPeriodForRentService(CAMInfo.oppId, rentServiceInfo, uiWrapper);
            oppPeriodToUpsert.add(oppRentServicePeriod);
        }

        oppPeriodToUpsert.addAll(oppPeriodMap.values());
        upsert oppPeriodToUpsert;

        //List<DepositMeasurementModel.Data> deleteDepositMeasurementList = (List<DepositMeasurementModel.Data>)OpportunitySelector.getRelatedOpportunityInfoByOppId('tms_DepositMeasurement__c', new Set<Id>{(Id)uiWrapper.oppId});
        //if(deleteDepositMeasurementList != null) delete deleteDepositMeasurementList;
        //update(new Opportunity(Id = uiWrapper.oppId, DepositMeasurement__c = null));

        List<DepositMeasurementModel.Data> upsertDepositMeasurementList = new List<DepositMeasurementModel.Data>();

        // * Generate Opportunity Price for CAM
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        System.debug('oppPeriodMap' + oppPeriodMap);
        Set<Id> measurementIdSet = new Set<Id>();
        if (!uiWrapper.isNoCAM){

            Integer lastActiveCAMIndex = 0;
            Decimal numberOfActiveCAM = 0;
            for(Integer index=0; index < CAMYearPeriodList.size(); index++) {
                QuotationComponentDataWrapper.CAMYearPeriodWrapper CAMYearPeriod = CAMYearPeriodList.get(index);
                if(CAMYearPeriod.isToDeleteRecord || CAMYearPeriod.isOptionToRenew) { continue; }
                lastActiveCAMIndex = index;

                if (!CAMYearPeriod.isRenewCAMPeriod) {
                    numberOfActiveCAM++;
                }
            }

            opp.TotalCAMPeriods__c = numberOfActiveCAM;

            for(Integer index=0; index < CAMYearPeriodList.size(); index++) {
                List<DepositMeasurementModel.Data> eachDepositMeasurementList = null;
                QuotationComponentDataWrapper.CAMYearPeriodWrapper CAMYearPeriod = CAMYearPeriodList.get(index);
                System.debug('CAMYearPeriod : ' + CAMYearPeriod);
                System.debug('oppPeriodMap.get(CAMYearPeriod)' + oppPeriodMap.get(CAMYearPeriod));
                OpportunityPeriod__c updatedOppPeriod = oppPeriodMap.get(CAMYearPeriod);
                System.debug('updatedOppPeriod' + updatedOppPeriod);
                CAMYearPeriod.id = updatedOppPeriod?.Id;
                if(CAMYearPeriod.isToDeleteRecord) { continue; }

                if(index == lastActiveCAMIndex) {
                    eachDepositMeasurementList = new List<DepositMeasurementModel.Data>();
                }
                oppPriceList.addAll(generateOppPriceForCAM(CAMInfo.oppId, uiWrapper, CAMInfo.CAMOrAirService, priceInfoList, CAMYearPeriod, eachDepositMeasurementList, measurementIdSet));

                if(eachDepositMeasurementList != null) { upsertDepositMeasurementList.addAll(eachDepositMeasurementList); }

            }
        }

        System.debug('ADD All CAM '+ oppPriceList);

        Set<Id> oppPeriodIdSetForRemoveOppPrice = new Set<Id>();
        if (rentServiceInfo != null ){
            oppPriceList.addAll(generateOppPriceForRentService(CAMInfo.oppId, rentServiceInfo, uiWrapper, oppRentServicePeriod.Id));
            oppPeriodIdSetForRemoveOppPrice.add(oppRentServicePeriod.Id);
        }
        // #endregion

        // #region Process Pricing

        // * Generate Opportunity Period for Calculation Method
        Map<QuotationComponentDataWrapper.PeriodPricing, OpportunityPeriod__c> oppPricingPeriodMap = new Map<QuotationComponentDataWrapper.PeriodPricing, OpportunityPeriod__c>();

        Integer lastSequence = 0;
        Double lastRentPercent = 0;
        Double lastServicePercent = 0;
        Integer numberOfOptionToRenew = 0;
        Decimal numberOfPeriod = 0;
        Decimal totalGPRevernue = 0;
        Decimal totalRentGP = 0;
        Decimal totalServiceGP = 0;
        Decimal rate;
        Boolean haveIncludeCAM = false;

        // * Generate Opportunity Grading for Calculation Method
        List<OpportunityGradingModel.Data> oppGradingList = new List<OpportunityGradingModel.Data>();
        for(QuotationComponentDataWrapper.PeriodPricing priceInfo : priceInfoList) {

            OpportunityPeriod__c oppPeriod = generateOppPeriodForCalculationMethod(CAMInfo.oppId, priceInfo, uiWrapper);
            oppPeriod.EstimateRevernue__c = priceInfo.EstimateRevernue;
            oppPeriod.EstimateGPRevernue__c = priceInfo.EstimateGPRevernue;
            System.debug('generateOppPeriodForCalculationMethod' + oppPeriod);
            if(priceInfo.isToDeleteRecord && priceInfo.Id != null) {
                deleteOppPeriodList.add(oppPeriod);
            } else if(!priceInfo.isToDeleteRecord) {
                oppPricingPeriodMap.put(priceInfo, oppPeriod);

                if(!oppPeriod.IsOptionToRenew__c && oppPeriod.Sequence__c > lastSequence) {
                    lastSequence = (Integer)oppPeriod.Sequence__c;
                    lastRentPercent = priceInfo.Proportion.Rent;
                    lastServicePercent = priceInfo.Proportion.Service;
                }

                if (!oppPeriod.IsOptionToRenew__c) {
                    numberOfPeriod++;
                }

                if(priceInfo.IsIncludeCAM) haveIncludeCAM = true;

                List<OpportunityGradingModel.Data> oppGrading = generateOppGradingForCalculationMethod(CAMInfo.oppId, priceInfo);
                if(oppGrading != null) {
                    rate = 0;
                    for(OpportunityGradingModel.Data grade : oppGrading) {
                        if(grade.FromR == 0 && grade.ToR == 0) {
                            rate = grade.GP;
                        } else if(grade.FromR <= priceInfo.EstimateRevernue && grade.ToR >= priceInfo.EstimateRevernue) {
                            rate = grade.GP;
                        }
                    }
                    priceInfo.EstimateGPRevernue = priceInfo.EstimateRevernue * rate / 100;
                    //oppGradingList.addAll(oppGrading);

                    Decimal monthDiff = getMonthBetween(priceInfo.PricingFrom, priceInfo.PricingTo);
                    totalGPRevernue += priceInfo.EstimateGPRevernue * monthDiff;
                    totalRentGP += priceInfo.EstimateGPRevernue * monthDiff * priceInfo.Proportion.Rent / 100;
                    totalServiceGP += priceInfo.EstimateGPRevernue * monthDiff * priceInfo.Proportion.Service / 100;
                }
            }
            if(oppPeriod.IsOptionToRenew__c && !priceInfo.isToDeleteRecord) numberOfOptionToRenew++;
        }

        opp.TotalEstimatGPRevernue__c = totalGPRevernue;
        opp.TotalRentGP__c = totalRentGP;
        opp.TotalServiceGP__c = totalServiceGP;
        opp.Rent_Percent_Last_Period__c = lastRentPercent;
        opp.ServicePercentLastPeriod__c = lastServicePercent;
        opp.TotalPeriods__c = numberOfPeriod;
        if(haveIncludeCAM) opp.CAM_Type__c = 'แบบ All-in';
        else opp.CAM_Type__c = 'แบบปกติ';
        System.debug('ADD ALL Period ' + oppPricingPeriodMap);

        upsert oppPricingPeriodMap.values();

        Map<Id, Boolean> isOptionToRenewMap = new Map<Id, Boolean>();
        for(OpportunityPeriod__c oppPeriod : oppPricingPeriodMap.values()) {
            isOptionToRenewMap.put(oppPeriod.Id, oppPeriod.IsOptionToRenew__c);
        }

        //List<OpportunityGradingModel.Data> deleteOppGradingList = (List<OpportunityGradingModel.Data>)OpportunitySelector.getRelatedOpportunityInfoByOppId('tms_OpportunityGrading__c', new Set<Id>{opp.Id});
        //if(deleteOppGradingList.size() > 0) delete deleteOppGradingList;
        //update(new Opportunity(Id = uiWrapper.oppId, OpportunityGrading__c = null));

        Map<Integer, List<IncludedCAMInfo>> periodWithCAMMap = getPeriodMappingWithCAM(CAMInfo, priceInfoList);
        System.debug('getPeriodMappingWithCAM : ' + periodWithCAMMap);

        Integer lastIndexForDepositMeasurement = 0;
        for(Integer index=0; index < priceInfoList.size(); index++) {
            QuotationComponentDataWrapper.PeriodPricing priceInfo = priceInfoList.get(index);
            if(priceInfo.OptionToRenew || priceInfo.isToDeleteRecord) continue;
            if(lastIndexForDepositMeasurement < index) lastIndexForDepositMeasurement = index;
        }

        List<OpportunityPeriod__c> oppPeriodList = OpportunitySelector.getRelatedOpportunityInfoByOppId('OpportunityPeriod__c',new Set<Id>{CAMInfo.oppId});
        Map<String, OpportunityPeriod__c> mapOpportunityPeriodById = new Map<String, OpportunityPeriod__c>();
        for(OpportunityPeriod__c eachOppPeriod : oppPeriodList){
            mapOpportunityPeriodById.put(eachOppPeriod.Id, eachOppPeriod);
        }

		// #region Gen Opp Pricing
        for(Integer index=0; index < priceInfoList.size(); index++) {
            List<DepositMeasurementModel.Data> eachDepositMeasurementList = null;
            Set<Id> eachMeasurementIdSet = null;
            QuotationComponentDataWrapper.PeriodPricing priceInfo = priceInfoList.get(index);
            System.debug(index);
            System.debug(priceInfoList.size());
            System.debug(numberOfOptionToRenew);
            if(index == lastIndexForDepositMeasurement) {
                System.debug(index);
                System.debug(priceInfo);
                eachDepositMeasurementList = new List<DepositMeasurementModel.Data>();
                eachMeasurementIdSet = measurementIdSet;
                System.debug(priceInfo.isToDeleteRecord);
            }
            System.debug(eachMeasurementIdSet);
            if(priceInfo.isToDeleteRecord) { continue; }

            OpportunityPeriod__c updatedOppPricingPeriod = oppPricingPeriodMap.get(priceInfo);
            priceInfo.id = updatedOppPricingPeriod.Id;
            OpportunityPeriod__c queryOppPeriod = mapOpportunityPeriodById.get(priceInfo.id);
            oppPeriodIdSetForRemoveOppPrice.add(priceInfo.id);

            List<OpportunityGradingModel.Data> oppGrading = generateOppGradingForCalculationMethod(CAMInfo.oppId, priceInfo);
            if(oppGrading != null) oppGradingList.addAll(oppGrading);

            List<OpportunityPrice__c> oppPriceByCalculationMethodList = generateOppPriceForCalculationMethod(CAMInfo.oppId, uiWrapper, priceInfo, periodWithCAMMap, eachDepositMeasurementList, eachMeasurementIdSet, queryOppPeriod);
            oppPriceList.addAll(oppPriceByCalculationMethodList);
            List<OpportunityPrice__c> oppPriceProportion = assignProportion(priceInfo, oppPriceByCalculationMethodList);
            oppPriceList.addAll(oppPriceProportion);

            if(eachDepositMeasurementList != null) { upsertDepositMeasurementList.addAll(eachDepositMeasurementList); }
        }
        //if(upsertDepositMeasurementList != null && upsertDepositMeasurementList.size() > 0) upsert upsertDepositMeasurementList;
        System.debug(upsertDepositMeasurementList);
        System.debug('oppPriceList: '+oppPriceList.size());

        SummaryPrice summaryRent = new SummaryPrice();
        SummaryPrice summaryService = new SummaryPrice();
        Double totalRent = 0;
        Double totalService = 0;
        System.debug('From: '+uiWrapper.contractStartDateForm);
        System.debug('To: '+uiWrapper.contractEndDateFrom);
        for(OpportunityPrice__c oppPrice : oppPriceList) {

            if(oppPrice.OpportunityPeriod__c == null
                || !isOptionToRenewMap.containsKey(oppPrice.OpportunityPeriod__c)
                || isOptionToRenewMap.get(oppPrice.OpportunityPeriod__c)
                || oppPrice.Price__c <= 0) {
                continue;
            }

            System.debug('oppPrice: '+oppPrice);
            Date dateFrom = oppPrice.From__c;
            Date dateTo = oppPrice.To__c;
            Decimal monthDiff = getMonthBetween(dateFrom, dateTo);

			// #region Calculate Rent
            if(oppPrice.CalculationMethod__c != null && oppPrice.SubType__c == Constant.TYPE_RENT) {
                totalRent = totalRent + (oppPrice.TotalPrice__c * monthDiff).setScale(2);
                if(oppPrice.From__c == uiWrapper.contractStartDateForm) {
                    summaryRent.FirstPrice += oppPrice.TotalPrice__c;
                    if(oppPrice.MeasurementAmount__c != null) {
                        //summaryRent.FirstPriceSqm += oppPrice.TotalPrice__c / oppPrice.MeasurementAmount__c;
                        summaryRent.FirstPriceSqm += oppPrice.MeasurementAmount__c;
                    } else {
                        //summaryRent.FirstPriceSqm += oppPrice.Price__c;
                        summaryRent.FirstPriceSqm += 1;
                    }
                }
                if(oppPrice.To__c == uiWrapper.contractEndDateFrom) {
                    summaryRent.LastPrice += oppPrice.TotalPrice__c;
                    if(oppPrice.MeasurementAmount__c != null) {
                        //summaryRent.LastPriceSqm += oppPrice.TotalPrice__c / oppPrice.MeasurementAmount__c;
                        summaryRent.LastPriceSqm += oppPrice.MeasurementAmount__c;
                    } else {
                        //summaryRent.LastPriceSqm += oppPrice.Price__c;
                        summaryRent.LastPriceSqm += 1;
                    }
                }
            }

			// #region Calculate Service
            if(oppPrice.CalculationMethod__c != null && oppPrice.SubType__c == Constant.TYPE_SERVICE) {
                totalService = totalService + (oppPrice.TotalPrice__c * monthDiff).setScale(2);
                if(oppPrice.From__c == uiWrapper.contractStartDateForm) {
                    summaryService.FirstPrice += oppPrice.TotalPrice__c;
                    if(oppPrice.MeasurementAmount__c != null) {
                        //summaryService.FirstPriceSqm += oppPrice.TotalPrice__c / oppPrice.MeasurementAmount__c;
                        summaryService.FirstPriceSqm += oppPrice.MeasurementAmount__c;
                    } else {
                        //summaryService.FirstPriceSqm += oppPrice.Price__c;
                        summaryService.FirstPriceSqm += 1;
                    }
                }
                if(oppPrice.To__c == uiWrapper.contractEndDateFrom) {
                    summaryService.LastPrice += oppPrice.TotalPrice__c;
                    if(oppPrice.MeasurementAmount__c != null) {
                        //summaryService.LastPriceSqm += oppPrice.TotalPrice__c / oppPrice.MeasurementAmount__c;
                        summaryService.LastPriceSqm += oppPrice.MeasurementAmount__c;
                    } else {
                        //summaryService.LastPriceSqm += oppPrice.Price__c;
                        summaryService.LastPriceSqm += 1;
                    }
                }
            }
        }
        opp.Total_Rent_THB__c = totalRent;
        if(uiWrapper.rentType == 'Billboard_Rental') opp.Total_Rent_billboard__c = totalRent;
        opp.Total_Service_THB__c = totalService;
        opp.Year_1_Monthly_Rental__c = summaryRent.FirstPrice;
        if(uiWrapper.rentType == 'Billboard_Rental') opp.Monthly_Rent_Billboard__c = summaryRent.FirstPrice;
        opp.Year_1_Monthly_Rent_Sq_m__c = summaryRent.FirstPrice / (summaryRent.FirstPriceSqm == 0? 1 : summaryRent.FirstPriceSqm);
        opp.Year_Last_Monthly_Rental__c = summaryRent.LastPrice;
        opp.Year_Last_Monthly_Rent_Sq_m__c = summaryRent.LastPrice / (summaryRent.LastPriceSqm == 0? 1 : summaryRent.LastPriceSqm);
        opp.Year_1_Monthly_Service__c = summaryService.FirstPrice;
        opp.Year_1_Monthly_Service_Sq_m__c = summaryService.FirstPrice / (summaryService.FirstPriceSqm == 0? 1 : summaryService.FirstPriceSqm);
        opp.Year_Last_Monthly_Service__c = summaryService.LastPrice;
        opp.Year_Last_Monthly_Service_Sq_m__c = summaryService.LastPrice / (summaryService.LastPriceSqm == 0? 1 : summaryService.LastPriceSqm);

        Decimal totalMinRentService = totalRent + totalService;

        System.debug(uiWrapper.totalRent + '_' + uiWrapper.totalService);
        Decimal totalminRevenue = processCalculateTotalMinRevenue(summaryCAM.TotalPrice,CAMInfo,priceInfoList,totalMinRentService);

        opp.TotalMinRentServiceTHB__c = totalMinRentService;
        System.debug(opp.TotalMinRentServiceTHB__c);
        opp.TotalMinRevenueTHB__c = totalminRevenue;

        //update opp;

        //List<OpportunityPrice__c> taxOppPrice = generateDefaultCondition(CAMInfo.oppId);
        //oppPriceList.addAll(taxOppPrice);

        if(targetOpportunity[0].OwnCreditCard__c){
            OpportunityPrice__c ownCreditCard = generateOpportunityPriceForOneTime(CAMInfo.oppId, uiWrapper.calculationMethod, Constant.OPP_PRICE_CONDITION_TYPE_CREDITCARDSBR, null, null, null, 0);
            if(ownCreditCard != null) oppPriceList.add(ownCreditCard);
        }

        OpportunityPrice__c dutyStampPrice = generateOpportunityPriceForOneTime(CAMInfo.oppId, uiWrapper.calculationMethod, Constant.OPP_PRICE_CONDITION_TYPE_DUTYSTAMP, null, null, null, Decimal.valueOf(totalRent/1000).setScale(0, System.RoundingMode.CEILING).setScale(2) + 5);
        if(dutyStampPrice != null) oppPriceList.add(dutyStampPrice);

        // System.debug('uiWrapper.calculationMethod : '+uiWrapper.calculationMethod);
        // List<OpportunityPrice__c> oppPriceOneTimeList = generateOppPriceForCalculationMethodOneTime(CAMInfo.oppId, uiWrapper, priceInfoList);
        // if(oppPriceOneTimeList != null) { oppPriceList.addAll(oppPriceOneTimeList); }

        List<OpportunityPrice__c> targetRemoveOppPriceList = OpportunitySelector.getOpportunityPriceByOppPeriodId(oppPeriodIdSetForRemoveOppPrice);
        System.debug('targetRemoveOppPriceList' + targetRemoveOppPriceList);
        if(targetRemoveOppPriceList != null && targetRemoveOppPriceList.size() > 0) delete targetRemoveOppPriceList;

        if(deleteOppPeriodList.size() > 0) {
            Map<Id, OpportunityPeriod__c> deleteOppPeriodMap = new Map<Id, OpportunityPeriod__c>(deleteOppPeriodList);
            List<OpportunityPrice__c> deleteOppPriceList = OpportunitySelector.getOpportunityPriceByOppPeriodId(deleteOppPeriodMap.keySet());

            delete deleteOppPriceList;
            delete deleteOppPeriodList;
        }

        System.debug(oppGradingList);
        //if(oppGradingList.size() > 0) upsert oppGradingList;
        //Opportunity updateData = new Opportunity(Id = uiWrapper.oppId);
        //updateData.DepositMeasurement__c = DepositMeasurementModel.toString(upsertDepositMeasurementList);
        //updateData.OpportunityGrading__c = OpportunityGradingModel.toString(oppGradingList);
        //update(updateData);
        opp.DepositMeasurement__c = DepositMeasurementModel.toString(upsertDepositMeasurementList);
        opp.OpportunityGrading__c = OpportunityGradingModel.toString(oppGradingList);
        update(opp);
        if(oppPriceList.size() > 0) upsert oppPriceList;

        // #endregion
    }

    private List<OpportunityPrice__c> generateOppPriceForCAM(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, String calculationMethod, List<QuotationComponentDataWrapper.PeriodPricing> priceInfoList, QuotationComponentDataWrapper.CAMYearPeriodWrapper CAMYearPeriod, List<DepositMeasurementModel.Data> depositMeasurementList, Set<Id> measurementIdSet) {
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        System.debug('CAMYearPeriod.CAMMeasurmentList '+ CAMYearPeriod.CAMMeasurmentList);
        if(CAMYearPeriod.CAMMeasurmentList == null) {
            System.debug('Return null');
            return oppPriceList;
        }
        for(QuotationComponentDataWrapper.MeasurmentWrapper CAMMeasurement : CAMYearPeriod.CAMMeasurmentList) {
            oppPriceList.add(new OpportunityPrice__c(
                Id = CAMMeasurement.oppPriceId,
                Opportunity__c = oppId,
                OpportunityPeriod__c = CAMYearPeriod.id,
                From__c = CAMYearPeriod.DateFrom,
                To__c = CAMYearPeriod.DateTo,
                Price__c = CAMMeasurement.Price.value,
                TotalPrice__c = CAMMeasurement.Price.value * CAMMeasurement.MeasurementArea,
                MeasurementAmount__c = CAMMeasurement.MeasurementArea,
                PriceItem__c = CAMMeasurement.MeasurementType,
                CalculationMethod__c = calculationMethod,
                MeasurementType__c = CAMMeasurement.MeasurementType,
                Measurement__c = CAMMeasurement.roMeasurementId
            ));
        }

        if(depositMeasurementList != null) {
            Date lastValidFrom = uiWrapper.contractEndDateFrom;
            Boolean isAllowCreateOppPrice = false;
            QuotationComponentDataWrapper.PeriodPricing lastPeriod;
            for (QuotationComponentDataWrapper.PeriodPricing eachOppPeriod  : priceInfoList ) {
                if(uiWrapper.longleaseType == 'ระบุราคาปีปฏิทินแรก') {
                    lastPeriod = eachOppPeriod;
                } else if (eachOppPeriod.PricingTo == lastValidFrom) {
                    lastPeriod = eachOppPeriod;
                }
            }

            if (lastPeriod != null) {
                if(lastPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_PRICE){
                    if(lastPeriod.FixedPriceSection.MinType == MINTYPE_FIXED){
                        isAllowCreateOppPrice = false;
                    }else{
                        isAllowCreateOppPrice = true;
                    }
                } else if(lastPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_RO){
                    isAllowCreateOppPrice = false;
                } else if(lastPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_MEAS){
                    isAllowCreateOppPrice = true;
                } else if(lastPeriod.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN){
                    isAllowCreateOppPrice = false;
                } else if(lastPeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN){
                    if(lastPeriod.GPWithMinSection.PricingSection.MinType == MINTYPE_FIXED){
                        isAllowCreateOppPrice = false;
                    }else{
                        isAllowCreateOppPrice = true;
                    }
                } else if(lastPeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP){
                    if(lastPeriod.GPOnTopSection.PricingSection.MinType == MINTYPE_FIXED){
                        isAllowCreateOppPrice = false;
                    }else{
                        isAllowCreateOppPrice = true;
                    }
                }
            }

            for(OpportunityPrice__c oppPrice : oppPriceList) {
                if(oppPrice.Price__c != 0 && oppPrice.SubType__c == Constant.TYPE_CAM && isAllowCreateOppPrice) {
                    DepositMeasurementModel.Data depositMeasurement = generateDepositMeasurement(oppPrice.Opportunity__c, oppPrice.SubType__c, oppPrice.Price__c, oppPrice.Measurement__c);
                    depositMeasurementList.add(depositMeasurement);
                    measurementIdSet.add(oppPrice.Measurement__c);
                }
            }
        }
        return oppPriceList;
    }

    private String getContractType(Id opportunityId) {
        String contractType = null;
        List<Opportunity> oppList = OpportunitySelector.getOpportunityInfoByOppId(new Set<Id>{opportunityId});
        if(oppList != null && oppList.size() > 0) {
            if(oppList.get(0).Contract_Type__c == 'Short-Term Fixed Rent' || oppList.get(0).Contract_Type__c == 'Short-Term GP Rent') {
                contractType = 'Short-Lease';
            } else {
                contractType = 'Long-Lease';
            }
        }
        return contractType;
    }

    private SummaryPrice processCalculateTotalCAM(QuotationComponentDataWrapper.CAMPricingWrapper CAMInfo){
        Date periodStartDate;
        Date periodEndDate;
        Decimal month = 0;
        SummaryPrice result = new SummaryPrice();

        if (!CAMInfo.CAMYearPeriod.isEmpty()) {
            for ( QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : CAMInfo.CAMYearPeriod){
                if (!eachCAMPeriod.isToDeleteRecord) {
                    periodStartDate = eachCAMPeriod.DateFrom;
                    periodEndDate = eachCAMPeriod.DateTo;

                    month = getMonthBetween(periodStartDate,periodEndDate);
                    result.TotalPrice += eachCAMPeriod.TotalPrice * month;
                    if(result.FirstPrice == 0) {
                        result.FirstPrice = eachCAMPeriod.TotalPrice;
                        result.FirstPriceSqm = eachCAMPeriod.TotalPrice / eachCAMPeriod.TotalArea;
                    } else {
                        result.LastPrice = eachCAMPeriod.TotalPrice;
                        result.LastPriceSqm = eachCAMPeriod.TotalPrice / eachCAMPeriod.TotalArea;
                    }
                }
            }
        }

        return result;
    }

    public static Decimal getMonthBetween(Date startDate, Date endDate){
        Decimal monthDiff = startDate.monthsBetween(endDate);
        Decimal factor = 0;

        if(endDate.day() > startDate.day()) {
            monthDiff = monthDiff + 1;
        }

        if(startDate.addMonths((Integer)monthDiff).addDays(-1) == endDate) {
            return monthDiff;
        } else {
            Integer dateDiff = (startDate.addMonths((Integer)monthDiff).addDays(-1)).daysBetween(endDate);
            System.debug(dateDiff);
            Integer numberDays = date.daysInMonth(endDate.year(), endDate.month());
            factor = ((Decimal)dateDiff/numberDays);
            return (monthDiff + factor).setScale(2);
        }
    }

    private OpportunityPeriod__c generateOppPeriodForCAM(Id oppId, QuotationComponentDataWrapper.CAMYearPeriodWrapper CAMYearPeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = CAMYearPeriod.Id,
            Opportunity__c = oppId,
            Sequence__c = CAMYearPeriod.Year,
            PeriodFrom__c = CAMYearPeriod.DateFrom,
            PeriodTo__c = CAMYearPeriod.DateTo,
            Total__c = CAMYearPeriod.TotalPrice,
            CAMMonth__c = CAMYearPeriod.TotalPrice,
            TotalArea__c = uiWrapper.totalMeasurmentArea,
            LeasableArea__c = uiWrapper.totalLeasableArea,
            IsOptionToRenew__c = (CAMYearPeriod.isOptionToRenew != null)?CAMYearPeriod.isOptionToRenew:false
        );
        return oppPeriod;
    }

    private OpportunityPeriod__c generateOppPeriodForRentService(Id oppId, QuotationComponentDataWrapper.RentServicePricingWrapper rentService, QuotationComponentDataWrapper.OppUIWrapper oppDetail) {
        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = rentService.rentServicePeriodId,
            Sequence__c = 0,
            Opportunity__c = oppId,
            PeriodFrom__c = oppDetail.contractStartDateForm,
            PeriodTo__c = oppDetail.contractEndDateFrom,
            CalculationMethod__c = Constant.CAL_METHOD_RENT_SERVICE
        );
        return oppPeriod;
    }

    private OpportunityPeriod__c generateOppPeriodForCalculationMethod(Id oppId, QuotationComponentDataWrapper.PeriodPricing pricePeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        if(pricePeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_PRICE) {
            return generateOppPeriodForFixedPrice(oppId, pricePeriod, uiWrapper);
        } else if(pricePeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_RO) {
            return generateOppPeriodForFixedRentalObject(oppId, pricePeriod,uiWrapper);
        } else if(pricePeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_MEAS) {
            return generateOppPeriodForFixedMeasurement(oppId, pricePeriod, uiWrapper);
        } else if(pricePeriod.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN) {
            return generateOppPeriodForGPNoMin(oppId, pricePeriod, uiWrapper);
        } else if(pricePeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
            return generateOppPeriodForGPWithMin(oppId, pricePeriod, uiWrapper);
        } else if(pricePeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {
            return generateOppPeriodForGPOnTop(oppId, pricePeriod, uiWrapper);
        }
        return null;
    }

    @TestVisible
    private OpportunityPeriod__c generateOppPeriodForFixedPrice(Id oppId, QuotationComponentDataWrapper.PeriodPricing pricePeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        Decimal price = (pricePeriod.FixedPriceSection.MinType == MINTYPE_MEASUREMENT)?pricePeriod.FixedPriceSection.PriceSQM : pricePeriod.FixedPriceSection.Price;
        Double totalPriceWithoutVat = 0;
        Double pricewithoutVat = 0;
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;

        if (uiWrapper.isWindowDisplay) {
            pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
            totalPriceWithoutVat = ((pricePeriod.FixedPriceSection.MinType == MINTYPE_MEASUREMENT)?((pricewithoutVat*pricePeriod.FixedPriceSection.TotalArea).setScale(2)):(pricewithoutVat));
        }

        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = pricePeriod.Id,
            IsAddedPeriod__c = pricePeriod.isCustomPeriod,
            Opportunity__c = oppId,
            Sequence__c = pricePeriod.PeriodNumber,
            PeriodFrom__c = pricePeriod.PricingFrom,
            PeriodTo__c = pricePeriod.PricingTo,
            CalculationMethod__c = pricePeriod.CalculationMethod,
            IsOptionToRenew__c = pricePeriod.OptionToRenew,
            Total__c = (uiWrapper.isWindowDisplay) ? totalPriceWithoutVat : pricePeriod.FixedPriceSection.Price,
            TotalArea__c = uiWrapper.totalMeasurmentArea,
            LeasableArea__c = uiWrapper.totalLeasableArea,
            RentMonth__c = (uiWrapper.isWindowDisplay) ?  (pricePeriod.Proportion.Rent * totalPriceWithoutVat / 100): (pricePeriod.Proportion.Rent * pricePeriod.FixedPriceSection.Price / 100),
            ServiceMonth__c = (uiWrapper.isWindowDisplay) ?  (pricePeriod.Proportion.Service * totalPriceWithoutVat / 100): (pricePeriod.Proportion.Service * pricePeriod.FixedPriceSection.Price / 100),
            IsIncludeCAM__c = pricePeriod.IsIncludeCAM,
            RentPercent__c = pricePeriod.Proportion.Rent,
            ServicePercent__c = pricePeriod.Proportion.Service,
            MinType__c = pricePeriod.FixedPriceSection.MinType,
            EscalationRemark__c = pricePeriod.escalationRemark
        );
        return oppPeriod;
    }

	/**
	 * CR Feb 2025
	 */
    private OpportunityPeriod__c generateOppPeriodForFixedRentalObject(Id oppId, QuotationComponentDataWrapper.PeriodPricing pricePeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        Decimal totalRent  = 0 ;
        Decimal totalService = 0;
        Double totalPriceWithoutVat = 0;
        Double pricewithoutVat = 0;
        Decimal price = 0;
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;

        for(QuotationComponentDataWrapper.RentalObjectPricingWrapper eachRO : pricePeriod.FixedRentalObjectSection.rentalObjectList){
			/**
			 * CR Feb 2025
			 * Changed Detail: adjust logic to calculate price
			 */
            price = (pricePeriod.FixedRentalObjectSection.MinType == MINTYPE_MEASUREMENT)?Double.valueOf(eachRO.PriceSQM.value):Double.valueOf(eachRO.Price.value);
			// Changed end
            if (uiWrapper.isWindowDisplay) {
                pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                totalPriceWithoutVat += ((pricePeriod.FixedRentalObjectSection.MinType == MINTYPE_MEASUREMENT)?((pricewithoutVat*eachRO.LeasableArea).setScale(2)):(pricewithoutVat));
                totalRent += totalPriceWithoutVat * (pricePeriod.Proportion.Rent/100) ;
                totalService += totalPriceWithoutVat * (pricePeriod.Proportion.Service/100);
            }else{
                totalRent += (Double.valueOf(eachRO.Price.value)* (pricePeriod.Proportion.Rent/100)) ;
                totalService += (Double.valueOf(eachRO.Price.value) * (pricePeriod.Proportion.Service/100));
				/**
				 * CR Feb 2025
				 * Changed Detail: adjust logic to calculate total rent day , total service day
				 */
				//
				//
				// Changed end
            }
        }


        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = pricePeriod.Id,
            IsAddedPeriod__c = pricePeriod.isCustomPeriod,
            Opportunity__c = oppId,
            Sequence__c = pricePeriod.PeriodNumber,
            PeriodFrom__c = pricePeriod.PricingFrom,
            PeriodTo__c = pricePeriod.PricingTo,
            CalculationMethod__c = pricePeriod.CalculationMethod,
            IsOptionToRenew__c = pricePeriod.OptionToRenew,
            Total__c = (uiWrapper.isWindowDisplay) ? totalPriceWithoutVat :pricePeriod.FixedRentalObjectSection.TotalPrice,
            TotalArea__c = pricePeriod.FixedRentalObjectSection.TotalArea,
            LeasableArea__c = pricePeriod.FixedRentalObjectSection.TotalLeasableArea,
            RentMonth__c =  totalRent,
            ServiceMonth__c = totalService,
            IsIncludeCAM__c = pricePeriod.IsIncludeCAM,
            RentPercent__c = pricePeriod.Proportion.Rent,
            ServicePercent__c = pricePeriod.Proportion.Service,
            MinType__c = pricePeriod.FixedRentalObjectSection.MinType,
            EscalationRemark__c = pricePeriod.escalationRemark
			/**
			 * CR Feb 2025
			 * Changed Detail: assign new fields
			 */
			//
			//
			// Changed end
        );
        return oppPeriod;
    }

    @TestVisible
    private OpportunityPeriod__c generateOppPeriodForFixedMeasurement(Id oppId, QuotationComponentDataWrapper.PeriodPricing pricePeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        Decimal totalRent  = 0 ;
        Decimal totalService = 0;
        Double totalPriceWithoutVat = 0;
        Double pricewithoutVat = 0;
        Decimal price = 0;
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;

        for(QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement : pricePeriod.FixedMeasurementSection.pricingList){
            price = eachMeasurement.Price.value;
            if (uiWrapper.isWindowDisplay){
                pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                totalPriceWithoutVat += ((pricewithoutVat * eachMeasurement.Area).setScale(2));
                totalRent += (Double.valueOf(pricewithoutVat) * (pricePeriod.Proportion.Rent/100)) * eachMeasurement.Area;
                totalService += (Double.valueOf(pricewithoutVat) * (pricePeriod.Proportion.Service/100)) * eachMeasurement.Area;
            }else{
                totalRent += (Double.valueOf(eachMeasurement.Price.value) * (pricePeriod.Proportion.Rent/100)) * eachMeasurement.Area;
                totalService += (Double.valueOf(eachMeasurement.Price.value) * (pricePeriod.Proportion.Service/100)) * eachMeasurement.Area;
            }
        }

        System.debug('pricePeriod.IsIncludeCAM : ' + pricePeriod.IsIncludeCAM);
        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = pricePeriod.Id,
            IsAddedPeriod__c = pricePeriod.isCustomPeriod,
            Opportunity__c = oppId,
            Sequence__c = pricePeriod.PeriodNumber,
            PeriodFrom__c = pricePeriod.PricingFrom,
            PeriodTo__c = pricePeriod.PricingTo,
            CalculationMethod__c = pricePeriod.CalculationMethod,
            IsOptionToRenew__c = pricePeriod.OptionToRenew,
            Total__c = (uiWrapper.isWindowDisplay) ? totalPriceWithoutVat :pricePeriod.FixedMeasurementSection.TotalPrice,
            TotalArea__c = pricePeriod.FixedMeasurementSection.TotalArea,
            LeasableArea__c = uiWrapper.totalLeasableArea,
            RentMonth__c = totalRent,
            ServiceMonth__c = totalService,
            IsIncludeCAM__c = pricePeriod.IsIncludeCAM,
            RentPercent__c = pricePeriod.Proportion.Rent,
            ServicePercent__c = pricePeriod.Proportion.Service,
            EscalationRemark__c = pricePeriod.escalationRemark
        );
        return oppPeriod;
    }

    private OpportunityPeriod__c generateOppPeriodForGPNoMin(Id oppId, QuotationComponentDataWrapper.PeriodPricing pricePeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = pricePeriod.Id,
            IsAddedPeriod__c = pricePeriod.isCustomPeriod,
            Opportunity__c = oppId,
            Sequence__c = pricePeriod.PeriodNumber,
            PeriodFrom__c = pricePeriod.PricingFrom,
            PeriodTo__c = pricePeriod.PricingTo,
            CalculationMethod__c = pricePeriod.CalculationMethod,
            IsIncludeCAM__c = pricePeriod.IsIncludeCAM,
            IsOptionToRenew__c = pricePeriod.OptionToRenew,
            TotalArea__c = uiWrapper.totalMeasurmentArea,
            LeasableArea__c = uiWrapper.totalLeasableArea,
            RentPercent__c = pricePeriod.Proportion.Rent,
            ServicePercent__c = pricePeriod.Proportion.Service,
            IsAllSales__c = pricePeriod.IsAllSales,
            EscalationRemark__c = pricePeriod.escalationRemark
        );
        return oppPeriod;
    }

    private OpportunityPeriod__c generateOppPeriodForGPWithMin(Id oppId, QuotationComponentDataWrapper.PeriodPricing pricePeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        Decimal totalRent  = 0 ;
        Decimal totalService = 0;
        Double totalPriceWithoutVat = 0;
        Double pricewithoutVat = 0;
        Decimal price = 0;
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;

        if(pricePeriod.GPWithMinSection.PricingSection.MinType != MINTYPE_MEASUREMENT){
            price = pricePeriod.GPWithMinSection.PricingSection.FixedPricing.Price;
            if (uiWrapper.isWindowDisplay) {
                pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                totalPriceWithoutVat = (pricewithoutVat);
                totalRent += pricewithoutVat * (pricePeriod.Proportion.Rent/100);
                totalService += pricewithoutVat * (pricePeriod.Proportion.Service/100);
            }else{
                totalRent += pricePeriod.GPWithMinSection.PricingSection.FixedPricing.Price * (pricePeriod.Proportion.Rent/100);
                totalService += pricePeriod.GPWithMinSection.PricingSection.FixedPricing.Price * (pricePeriod.Proportion.Service/100);
            }

        }else{
            for(QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement : pricePeriod.GPWithMinSection.PricingSection.MeasumentPricingList){
                price = eachMeasurement.Price.value;

                if (uiWrapper.isWindowDisplay){
                    pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                    totalPriceWithoutVat += ((pricewithoutVat * eachMeasurement.Area).setScale(2));
                    totalRent += (Double.valueOf(pricewithoutVat) * (pricePeriod.Proportion.Rent/100)) * eachMeasurement.Area;
                    totalService += (Double.valueOf(pricewithoutVat) * (pricePeriod.Proportion.Service/100)) * eachMeasurement.Area;
                }else{

                    totalRent += (Double.valueOf(eachMeasurement.Price.value) * (pricePeriod.Proportion.Rent/100)) * eachMeasurement.Area;
                    totalService += (Double.valueOf(eachMeasurement.Price.value) * (pricePeriod.Proportion.Service/100)) * eachMeasurement.Area;
                }

            }
        }

        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = pricePeriod.Id,
            Opportunity__c = oppId,
            IsAddedPeriod__c = pricePeriod.isCustomPeriod,
            Sequence__c = pricePeriod.PeriodNumber,
            PeriodFrom__c = pricePeriod.PricingFrom,
            PeriodTo__c = pricePeriod.PricingTo,
            CalculationMethod__c = pricePeriod.CalculationMethod,
            IsOptionToRenew__c = pricePeriod.OptionToRenew,
            Total__c = (uiWrapper.isWindowDisplay) ? totalPriceWithoutVat :pricePeriod.GPWithMinSection.PricingSection.TotalPrice,
            TotalArea__c = pricePeriod.GPWithMinSection.PricingSection.TotalArea,
            LeasableArea__c = pricePeriod.GPWithMinSection.PricingSection.TotalLeasableArea,
            RentMonth__c = totalRent,
            ServiceMonth__c = totalService,
            IsIncludeCAM__c = pricePeriod.IsIncludeCAM,
            MinType__c = pricePeriod.GPWithMinSection.PricingSection.MinType,
            SalesMin__c = pricePeriod.GPWithMinSection.SalesMin,
            RentPercent__c = pricePeriod.Proportion.Rent,
            ServicePercent__c = pricePeriod.Proportion.Service,
            IsAllSales__c = pricePeriod.IsAllSales,
            EscalationRemark__c = pricePeriod.escalationRemark
        );
        return oppPeriod;
    }

    private OpportunityPeriod__c generateOppPeriodForGPOnTop(Id oppId, QuotationComponentDataWrapper.PeriodPricing pricePeriod, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        Decimal totalRent  = 0 ;
        Decimal totalService = 0;
        Double totalPriceWithoutVat = 0;
        Double pricewithoutVat = 0;
        Decimal price = 0;
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;

        if(pricePeriod.GPOnTopSection.PricingSection.MinType != MINTYPE_MEASUREMENT){
            price = pricePeriod.GPOnTopSection.PricingSection.FixedPricing.Price;
            if (uiWrapper.isWindowDisplay){
                pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                totalPriceWithoutVat = (pricewithoutVat);
                totalRent += pricewithoutVat * (pricePeriod.Proportion.Rent/100);
                totalService += pricewithoutVat * (pricePeriod.Proportion.Service/100);
            }else{
                totalRent += pricePeriod.GPOnTopSection.PricingSection.FixedPricing.Price * (pricePeriod.Proportion.Rent/100);
                totalService += pricePeriod.GPOnTopSection.PricingSection.FixedPricing.Price * (pricePeriod.Proportion.Service/100);
            }
        }else{
            for(QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement : pricePeriod.GPOnTopSection.PricingSection.MeasumentPricingList){
                price = eachMeasurement.Price.value;

                if (uiWrapper.isWindowDisplay){
                    pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                    totalPriceWithoutVat += ((pricewithoutVat * eachMeasurement.Area).setScale(2));
                    totalRent += (Double.valueOf(pricewithoutVat) * (pricePeriod.Proportion.Rent/100)) * eachMeasurement.Area;
                    totalService += (Double.valueOf(pricewithoutVat) * (pricePeriod.Proportion.Service/100)) * eachMeasurement.Area;
                }else{
                    totalRent += (Double.valueOf(eachMeasurement.Price.value) * (pricePeriod.Proportion.Rent/100)) * eachMeasurement.Area;
                    totalService += (Double.valueOf(eachMeasurement.Price.value) * (pricePeriod.Proportion.Service/100)) * eachMeasurement.Area;
                }
            }
        }

        OpportunityPeriod__c oppPeriod = new OpportunityPeriod__c(
            Id = pricePeriod.Id,
            IsAddedPeriod__c = pricePeriod.isCustomPeriod,
            Opportunity__c = oppId,
            Sequence__c = pricePeriod.PeriodNumber,
            PeriodFrom__c = pricePeriod.PricingFrom,
            PeriodTo__c = pricePeriod.PricingTo,
            CalculationMethod__c = pricePeriod.CalculationMethod,
            IsOptionToRenew__c = pricePeriod.OptionToRenew,
            Total__c = (uiWrapper.isWindowDisplay)?totalPriceWithoutVat :pricePeriod.GPOnTopSection.PricingSection.TotalPrice,
            TotalArea__c = pricePeriod.GPOnTopSection.PricingSection.TotalArea,
            LeasableArea__c = pricePeriod.GPOnTopSection.PricingSection.TotalLeasableArea,
            RentMonth__c = totalRent,
            ServiceMonth__c = totalService,
            IsIncludeCAM__c = pricePeriod.IsIncludeCAM,
            MinType__c = pricePeriod.GPOnTopSection.PricingSection.MinType,
            RentPercent__c = pricePeriod.Proportion.Rent,
            ServicePercent__c = pricePeriod.Proportion.Service,
            IsAllSales__c = pricePeriod.IsAllSales,
            EscalationRemark__c = pricePeriod.escalationRemark
        );
        return oppPeriod;
    }

    private List<OpportunityPrice__c> generateOppPriceForRentService(Id oppId, QuotationComponentDataWrapper.RentServicePricingWrapper rentServiceMeasurement, QuotationComponentDataWrapper.OppUIWrapper oppDetail, Id oppPeriodId) {
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        if(rentServiceMeasurement.RentServiceMeasurment == null) { return oppPriceList; }
        for(QuotationComponentDataWrapper.MeasurmentWrapper eachRentServiceMeasurement : rentServiceMeasurement.RentServiceMeasurment) {
            for(QuotationComponentDataWrapper.RentalObjectClass eachRentalObject : rentServiceMeasurement.RentalObjectList) {

                if(!eachRentalObject.isToDeleteRecord){
                    for(QuotationComponentDataWrapper.ROMeasurementClass eachROMeasurment : eachRentalObject.roMeasurmentList) {
                        if(eachROMeasurment.measurementId  == eachRentServiceMeasurement.measurementId){
                            oppPriceList.add(new OpportunityPrice__c(
                                Opportunity__c = oppId,
                                OpportunityPeriod__c = oppPeriodId,
                                From__c = oppDetail.contractStartDateForm,
                                To__c = oppDetail.contractEndDateFrom,
                                Measurement__c = eachROMeasurment.roMeasurementId,
                                Unit__c = eachRentalObject.id,
                                MeasurementAmount__c = eachROMeasurment.measurementArea,
                                Price__c = (eachRentServiceMeasurement.Price != null)?Double.valueOf(eachRentServiceMeasurement.Price.value):0,
                                SubType__c = Constant.CAL_METHOD_RENT_SERVICE,
                                TotalPrice__c = (eachRentServiceMeasurement.Price != null)?Double.valueOf(eachRentServiceMeasurement.Price.value):0,
                                PriceItem__c = eachRentServiceMeasurement.MeasurementType,
                                CalculationMethod__c = Constant.CAL_METHOD_RENT_SERVICE,
                                MeasurementType__c = eachROMeasurment.measurementId
                            ));
                        }
                    }
                }
            }
        }
        return oppPriceList;
    }

    // Mapping CAM with Period
    public static Map<Integer, List<IncludedCAMInfo>> getPeriodMappingWithCAM(QuotationComponentDataWrapper.CAMPricingWrapper CAMInfo, List<QuotationComponentDataWrapper.PeriodPricing> periodInfoList) {
        Map<Integer, List<IncludedCAMInfo>> includedCAMInfoMapByPeriod = new Map<Integer, List<IncludedCAMInfo>>();

        Integer periodIndex = 0;
        Integer camIndex = 0;
        Boolean processMapPeriod = true;
        Integer count = 0;
        while (processMapPeriod) {
            System.debug('count : ' + count);
            count++;
            if(periodIndex >= periodInfoList.size()) { processMapPeriod = false; continue; }
            QuotationComponentDataWrapper.PeriodPricing periodInfo = periodInfoList.get(periodIndex);

            Date targetDateFrom = periodInfo.PricingFrom;
            Date targetDateTo = periodInfo.PricingTo;

            System.debug('periodInfo : ' + periodInfo);
            // * Process "Not include CAM"
            if((!periodInfo.IsIncludeCAM) && (periodInfo.isToDeleteRecord != null && periodInfo.isToDeleteRecord == false)) {
                System.debug('periodInfo.PeriodNumber : ' + periodInfo.PeriodNumber);
                IncludedCAMInfo includeCAMInfo = new IncludedCAMInfo(targetDateFrom, targetDateTo, null, 0, 0);
                includedCAMInfoMapByPeriod.put(periodInfo.PeriodNumber, new List<IncludedCAMInfo>{ includeCAMInfo });
                periodIndex = periodIndex + 1;
                continue;
            }

            if(camIndex >= CAMInfo.CAMYearPeriod.size()) {
                camIndex = camIndex - 1;
                periodIndex = periodIndex + 1;
                continue;
            }
            QuotationComponentDataWrapper.CAMYearPeriodWrapper CAMPeriod = CAMInfo.CAMYearPeriod.get(camIndex);

            // Check is delete CAM
            if(CAMPeriod.isToDeleteRecord != null && CAMPeriod.isToDeleteRecord) {
                camIndex = camIndex + 1;
                continue;
            }

            // Check is delete period
            if(periodInfo.isToDeleteRecord != null && periodInfo.isToDeleteRecord) {
                periodIndex = periodIndex + 1;
                continue;
            }

            // * Handle Change period
            if(CAMPeriod.DateTo < periodInfo.PricingFrom) {
                camIndex = camIndex + 1;
                continue;
            } else if(periodInfo.PricingTo < CAMPeriod.DateFrom) {
                periodIndex = periodIndex + 1;
                continue;
            }

            // * Process include CAM
            if(periodInfo.PricingFrom == CAMPeriod.DateFrom && periodInfo.PricingTo == CAMPeriod.DateTo) {
                camIndex = camIndex + 1;
                periodIndex = periodIndex + 1;
            } else {
                if(Utility.isPeriodOverlap(periodInfo.PricingFrom, periodInfo.PricingTo, CAMPeriod.DateFrom, CAMPeriod.DateTo)) {
                    if(CAMPeriod.DateFrom <= periodInfo.PricingFrom) {
                        targetDateFrom = periodInfo.PricingFrom;
                    } else if(CAMPeriod.DateFrom >= periodInfo.PricingFrom) {
                        targetDateFrom = CAMPeriod.DateFrom;
                    }
                    if(CAMPeriod.DateTo <= periodInfo.PricingTo) {
                        targetDateTo = CAMPeriod.DateTo;
                        camIndex = camIndex + 1;
                    } else if(CAMPeriod.DateTo >= periodInfo.PricingTo) {
                        targetDateTo = periodInfo.PricingTo;
                        periodIndex = periodIndex + 1;
                    }
                }
            }

            // * Process in each measurement
            for(QuotationComponentDataWrapper.MeasurmentWrapper measurementWrapper : CAMPeriod.CAMMeasurmentList) {
                IncludedCAMInfo includeCAMInfo = new IncludedCAMInfo(targetDateFrom, targetDateTo, measurementWrapper.MeasurementType, (Double)measurementWrapper.Price.value, (Double)measurementWrapper.MeasurementArea);

                System.debug(includeCAMInfo);
                if(includedCAMInfoMapByPeriod.containsKey(periodInfo.PeriodNumber)) {
                    includedCAMInfoMapByPeriod.get(periodInfo.PeriodNumber).add(includeCAMInfo);
                } else {
                    includedCAMInfoMapByPeriod.put(periodInfo.PeriodNumber, new List<IncludedCAMInfo>{includeCAMInfo});
                }
            }
        }
        return includedCAMInfoMapByPeriod;
    }

    public class IncludedCAMInfo {
        public Date ValidFrom {get; set;}
        public Date ValidTo {get; set;}
        public String MeasurementCode {get; set;}
        public Double CAMUnitPrice {get; set;}
        public Double CAMArea {get; set;}
        public Double CAMPrice {get; set;}

        public IncludedCAMInfo(Date dateFrom, Date dateTo, String measurement, Double price, Double area) {
            ValidFrom = dateFrom;
            ValidTo = dateTo;
            MeasurementCode = measurement;
            CAMUnitPrice = price;
            CAMArea = area;
            CAMPrice = price*area;
        }
    }

    // #region Generate Opp Grading
    private List<OpportunityGradingModel.Data> generateOppGradingForCalculationMethod(Id oppId, QuotationComponentDataWrapper.PeriodPricing priceInfo) {
        System.debug(priceInfo);
        if(priceInfo.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN) {
            return generateOppGrading(oppId, priceInfo, priceInfo.GPNoMinSection.ReportingRuleList);
        } else if(priceInfo.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
            return generateOppGrading(oppId, priceInfo, priceInfo.GPWithMinSection.ReportingRuleList);
        } else if(priceInfo.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {
            return generateOppGrading(oppId, priceInfo, priceInfo.GPOnTopSection.ReportingRuleList);
        }
        return null;
    }

    private List<OpportunityGradingModel.Data> generateOppGrading(Id oppId, QuotationComponentDataWrapper.PeriodPricing priceInfo, List<QuotationComponentDataWrapper.ReportingRuleWrapper> GPTierList) {
        List<OpportunityGradingModel.Data> oppGradingList = new List<OpportunityGradingModel.Data>();
        for(QuotationComponentDataWrapper.ReportingRuleWrapper GPTier : GPTierList) {
            System.debug(GPTier.isToDeleteRecord);
            if(GPTier.isToDeleteRecord) { continue; }
            for(QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachTier : GPTier.ReportingRuleDetailList) {
                if(eachTier.isToDeleteRecord) { continue; }
                OpportunityGradingModel.Data oppGrading = new OpportunityGradingModel.Data();
                oppGrading.OpportunityId = oppId;
                oppGrading.OpportunityPeriodId = priceInfo.Id;
                oppGrading.GradingPeriodForm = priceInfo.PricingFrom;
                oppGrading.GradingPeriodTo = priceInfo.PricingTo;
                oppGrading.GPRangeNo = String.valueOf(eachTier.GradingIndex);
                oppGrading.FromR = eachTier.rangFrom;
                oppGrading.ToR = eachTier.rangTo;
                oppGrading.GP = eachTier.GPPercent;
                oppGrading.isIncludeCAM = eachTier.IsIncludeCam;
                oppGrading.IsGrading = GPTier.ReportingRuleDetailList.size() > 1 ? true : false;
                oppGrading.ReportingRule = GPTier.ReportingRule;
                oppGrading.SalesDescription = GPTier.ReportingRuleDescription;
                oppGrading.GroupNo = GPTier.GroupNumber;
                oppGrading.GradingTierOption = eachTier.gpYearlyTier;
                oppGradingList.add(oppGrading);
            }
        }
        return oppGradingList;
    }
    // #endregion

    @TestVisible
    private DepositMeasurementModel.Data generateDepositMeasurement(Id opportunityId, String subType, Decimal price, Id measurementId) {
        DepositMeasurementModel.Data res = new DepositMeasurementModel.Data();
        res.OpportunityId = opportunityId;
        res.SubType = subType;
        res.Price = price;
        res.Measurement = measurementId;
        return res;
    }

    private Decimal processCalculateTotalMinRevenue(Decimal totalCAM ,QuotationComponentDataWrapper.CAMPricingWrapper CAMInfo, List<QuotationComponentDataWrapper.PeriodPricing> priceInfoList, Decimal totalMinRentService){
        Decimal result = totalMinRentService;
        Date pricingPeriodStartDate;
        Date pricingPeriodEndDate;
        Decimal month = 0;
        boolean isIncludeCAM = false;

        for ( QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : CAMInfo.CAMYearPeriod){
            if (!eachCAMPeriod.isToDeleteRecord) {
                pricingPeriodStartDate = eachCAMPeriod.DateFrom;
                pricingPeriodEndDate = eachCAMPeriod.DateTo;
                month = getMonthBetween(pricingPeriodStartDate,pricingPeriodEndDate);
                for (Integer eachMonth = 0; eachMonth < month ; eachMonth++ ){
                    for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : priceInfoList){
                        if (!eachPricingPeriod.isToDeleteRecord && !eachPricingPeriod.IsIncludeCAM){
                            if (pricingPeriodStartDate.addMonths(eachMonth) >= eachPricingPeriod.PricingFrom && pricingPeriodStartDate.addMonths(eachMonth) <= eachPricingPeriod.PricingTo){
                                result += eachCAMPeriod.TotalPrice;
                            }
                        }
                    }
                }
            }
        }
        return result;
    }

    private OpportunityPrice__c generateOpportunityPriceForOneTime(Id opportunityId, String type, String conditionType, Date paymentDueDate, Date validFrom, Date validTo, Decimal price) {
        if(opportunityId == null || conditionType == null) { return null; }
        system.debug('opportunityId : '+opportunityId);
        system.debug('conditionType : '+conditionType);
        system.debug('type : '+type);
        List<Opportunity> opportunityInfoList = OpportunitySelector.getOpportunityInfoByOppId(new Set<Id> { opportunityId });
        Opportunity opportunityInfo = opportunityInfoList[0];
        String contractType = getContractType(opportunityId);
        if(opportunityInfo.Total_Rent_THB__c == 0 && (conditionType == Constant.OPP_PRICE_CONDITION_TYPE_DUTYSTAMP || conditionType == Constant.OPP_PRICE_CONDITION_TYPE_DUTYSTAMPGP)) return null;

        OpportunityPrice__c oppPrice = new OpportunityPrice__c(
            Opportunity__c = opportunityId,
            PaymentDueDate__c = paymentDueDate,
            From__c = validFrom != null ? validFrom : opportunityInfo.Estimated_Contract_End_Date__c,
            To__c = validTo != null ? validTo : opportunityInfo.Estimated_Contract_Start_Date__c,
            Price__c = price,
            TotalPrice__c = price
            );
        return oppPrice;
    }

    public void processSecurityDeposit(Id oppId, QuotationComponentDataWrapper.DepositWrapper depositInfo, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        String contractType = getContractType(oppId);
        System.debug(depositInfo);

        Opportunity updateOpp = new Opportunity(
            Id = oppId,
            Deposit_Month__c = depositInfo.DepositMonth,
            DepositType__c = depositInfo.DepositCalculationType,
            Number_of_Installment_Deposit__c = depositInfo.NumberOfInstallment,
            Is_Period_Date_Changed__c = uiWrapper.isRenewChangeOppPeriod
        );
        update updateOpp;

        List<OpportunityDepositExpense__c> deleteOppDepositExpenseList = OpportunitySelector.getSecurityDepositHeaderByOppId(new Set<Id> {oppId});
        List<OpportunityPrice__c> deleteOppPriceList = OpportunitySelector.getSecurityDepositPriceByOppId(new Set<Id> {oppId});

        if(deleteOppPriceList.size() > 0) delete deleteOppPriceList;
        if(deleteOppDepositExpenseList.size() > 0) delete deleteOppDepositExpenseList;

        Double totalDeposit = (depositInfo.DepositSummary.DepositSummaryPricing.rent_TotalDeposit
                                + depositInfo.DepositSummary.DepositSummaryPricing.service_TotalDeposit
                                + depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit);

        Decimal totalSummary = (depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary + depositInfo.DepositSummary.DepositSummaryPricing.service_Summary + depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_Summary);
        Double depositRentPercent = totalSummary != 0 ? ((depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary / totalSummary) * 100) : 0;
        Double depositServicePercent = totalSummary != 0 ? ((depositInfo.DepositSummary.DepositSummaryPricing.service_Summary / totalSummary) * 100) : 0;
        Double depositCAMPercent = totalSummary != 0 ? ((depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_Summary / totalSummary) * 100):0;

        System.debug('depositRentPercent : ' + depositRentPercent);
        System.debug('depositServicePercent : ' + depositServicePercent);
        System.debug('depositCAMPercent : ' + depositCAMPercent);
        /*DepositPercent depositPercent = new DepositPercent(depositRentPercent, depositServicePercent, depositCAMPercent);*/

        Decimal totalInstallment_rent_portion =0;
        Decimal totalInstallment_service_portion =0;
        Decimal totalInstallment_cam_portion =0;
        Decimal totalInstallment_airservice_portion =0;

        Decimal totalInstallment_rent_amount = 0;
        Decimal totalInstallment_service_amount = 0;
        Decimal totalInstallment_cam_amount = 0;

        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;

        QuotationComponentDataWrapper.DepositSummaryPricing depositPricing = depositInfo.DepositSummary.DepositSummaryPricing;

        if (uiWrapper.isAllowChangeOptionToRenew){
            Integer numberOfActiveInstallment = 0;
            for(QuotationComponentDataWrapper.InstallmentWrapper securityDepositInstallment : depositInfo.DepositSummary.InstallmentList){
                if(!securityDepositInstallment.isToDeleteRecord){
                    numberOfActiveInstallment++;
                }
            }

            if(depositInfo.DepositSummary.InstallmentList.isEmpty()){
                totalInstallment_service_portion = ((depositPricing.service_TotalDeposit - depositPricing.service_CarriedDeposit).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                totalInstallment_cam_portion = ((depositPricing.camOrAirService_TotalDeposit - depositPricing.camOrAirService_CarriedDeposit).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                if (uiWrapper.isWindowDisplay) {
                    totalInstallment_rent_portion = ((depositPricing.rent_TotalDeposit - depositPricing.rent_CarriedDeposit).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                }
            }else{
                if(numberOfActiveInstallment > 1){
                    for(QuotationComponentDataWrapper.InstallmentWrapper securityDepositInstallment : depositInfo.DepositSummary.InstallmentList){
                        if(!securityDepositInstallment.isToDeleteRecord){

                            if(Integer.valueOf(securityDepositInstallment.InstallmentNumber) == depositInfo.NumberOfInstallment){
                                Decimal finalInstallmentServiceAmount = (depositInfo.DepositSummary.DepositSummaryPricing.service_Summary - totalInstallment_service_amount).setScale(2,RoundingMode.HALF_UP);
                                totalInstallment_service_portion += (finalInstallmentServiceAmount * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);

                                Decimal finalInstallmentCamAmount = (depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_Summary - totalInstallment_cam_amount).setScale(2,RoundingMode.HALF_UP);
                                totalInstallment_cam_portion += (finalInstallmentCamAmount * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);

                                if (uiWrapper.isWindowDisplay){
                                    Decimal finalInstallmentRentAmount = (depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary - totalInstallment_rent_amount).setScale(2,RoundingMode.HALF_UP);
                                    totalInstallment_rent_portion += (finalInstallmentRentAmount * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);

                                }

                            }else{
                                totalInstallment_service_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositServicePercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                totalInstallment_service_amount += (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositServicePercent)/100)).setScale(2,RoundingMode.HALF_UP);

                                totalInstallment_cam_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositCAMPercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                totalInstallment_cam_amount += (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositCAMPercent)/100)).setScale(2,RoundingMode.HALF_UP);

                                if (uiWrapper.isWindowDisplay) {
                                    totalInstallment_rent_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositRentPercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                    totalInstallment_rent_amount += (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositRentPercent)/100)).setScale(2,RoundingMode.HALF_UP);
                                }
                            }

                        }
                    }
                }else{
                    for(QuotationComponentDataWrapper.InstallmentWrapper securityDepositInstallment : depositInfo.DepositSummary.InstallmentList){
                        if(!securityDepositInstallment.isToDeleteRecord){
                            if (securityDepositInstallment.InstallmentAmount > 0) {
                                totalInstallment_service_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositServicePercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                totalInstallment_cam_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositCAMPercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                if (uiWrapper.isWindowDisplay) {
                                    totalInstallment_rent_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositRentPercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                }
                            }else{
                                totalInstallment_service_portion = ((depositPricing.service_TotalDeposit - depositPricing.service_CarriedDeposit).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                totalInstallment_cam_portion = ((depositPricing.camOrAirService_TotalDeposit - depositPricing.camOrAirService_CarriedDeposit).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                if (uiWrapper.isWindowDisplay) {
                                    totalInstallment_rent_portion = ((depositPricing.rent_TotalDeposit - depositPricing.rent_CarriedDeposit).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                                }
                            }
                        }
                    }
                }
            }

        }else{
            for(QuotationComponentDataWrapper.InstallmentWrapper securityDepositInstallment : depositInfo.DepositSummary.InstallmentList){
                if(!securityDepositInstallment.isToDeleteRecord){

                    if(Integer.valueOf(securityDepositInstallment.InstallmentNumber) == depositInfo.NumberOfInstallment){
                        Decimal finalInstallmentServiceAmount = (depositInfo.DepositSummary.DepositSummaryPricing.service_Summary - totalInstallment_service_amount).setScale(2,RoundingMode.HALF_UP);
                        totalInstallment_service_portion += (finalInstallmentServiceAmount * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);

                        Decimal finalInstallmentCamAmount = (depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_Summary - totalInstallment_cam_amount).setScale(2,RoundingMode.HALF_UP);
                        totalInstallment_cam_portion += (finalInstallmentCamAmount * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);

                        if (uiWrapper.isWindowDisplay){
                            Decimal finalInstallmentRentAmount = (depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary - totalInstallment_rent_amount).setScale(2,RoundingMode.HALF_UP);
                            totalInstallment_rent_portion += (finalInstallmentRentAmount * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);

                        }

                    }else{
                        totalInstallment_service_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositServicePercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        totalInstallment_service_amount += (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositServicePercent)/100)).setScale(2,RoundingMode.HALF_UP);

                        totalInstallment_cam_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositCAMPercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        totalInstallment_cam_amount += (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositCAMPercent)/100)).setScale(2,RoundingMode.HALF_UP);

                        if (uiWrapper.isWindowDisplay) {
                            totalInstallment_rent_portion += ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositRentPercent)/100)).setScale(2,RoundingMode.HALF_UP) * (vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                            totalInstallment_rent_amount += (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * (Decimal.valueOf(depositRentPercent)/100)).setScale(2,RoundingMode.HALF_UP);
                        }
                    }
                }
            }
        }

        System.debug('totalInstallment_cam_portion ' + totalInstallment_cam_portion);
        System.debug('totalInstallment_rent_portion ' + totalInstallment_rent_portion);
        System.debug('totalInstallment_service_portion ' + totalInstallment_service_portion);


        OpportunityDepositExpense__c oppSecurityDepositExpense = new OpportunityDepositExpense__c(
            Opportunity__c = oppId,
            TypeGroup__c = depositInfo.DepositSummary.TypeGroup,
            Type__c = depositInfo.DepositSummary.Type,
            Price__c = Decimal.valueOf(totalDeposit).setScale(2),
            NumberOfInstallment__c = depositInfo.NumberOfInstallment,
            Remark__c = depositInfo.DepositRemark,
            HasRemark__c = String.isBlank(depositInfo.DepositRemark)? false : true,
            NumberOfMonth__c = depositInfo.DepositMonth,
            DepositInputMethod__c = depositInfo.DepositCalculationType,
            CarriedDepositRent__c = depositPricing.rent_CarriedDeposit,
            CarriedDepositService__c = depositPricing.service_CarriedDeposit,
            CarriedDepositCAM__c = depositPricing.camOrAirService_DepositType == Constant.CAL_METHOD_CAM ? depositPricing.camOrAirService_CarriedDeposit : null,
            CarriedDepositAirService__c = depositPricing.camOrAirService_DepositType == Constant.CAL_METHOD_AIR ? depositPricing.camOrAirService_CarriedDeposit : null,
            RentDeposit__c = depositPricing.rent_TotalDeposit,
            ServiceDeposit__c = depositPricing.service_TotalDeposit,
            CAMDeposit__c = depositPricing.camOrAirService_DepositType == Constant.CAL_METHOD_CAM ? depositPricing.camOrAirService_TotalDeposit : null,
            CAMDepositVat__c = totalInstallment_cam_portion.setScale(2,RoundingMode.HALF_UP),
            RentDepositVat__c = totalInstallment_rent_portion.setScale(2,RoundingMode.HALF_UP),
            ServiceDepositVat__c = totalInstallment_service_portion.setScale(2,RoundingMode.HALF_UP),
            ActualDepositCAM__c = (depositInfo.DepositOption == Constant.DEPOSIT_OPTION_NEW_DEPOSIT_CONTRACT)? depositPricing.camOrAirService_TotalDeposit : depositPricing.camOrAirService_ActualDeposit,
            ActualDepositRent__c = (depositInfo.DepositOption == Constant.DEPOSIT_OPTION_NEW_DEPOSIT_CONTRACT)? depositPricing.rent_TotalDeposit :depositPricing.rent_ActualDeposit,
            ActualDepositService__c = (depositInfo.DepositOption == Constant.DEPOSIT_OPTION_NEW_DEPOSIT_CONTRACT)? depositPricing.service_TotalDeposit :depositPricing.service_ActualDeposit,
            DepositOption__c = depositInfo.DepositOption
        );
        upsert oppSecurityDepositExpense;

        Date rentValidFromTo = uiWrapper.contractStartDateForm;
        Date serviceValidFromTo = uiWrapper.contractStartDateForm;
        Date camValidFromTo = uiWrapper.contractStartDateForm;

        List<OpportunityPrice__c> oppSecurityDepositPriceList = new List<OpportunityPrice__c>();

        Decimal totalRentPortion = 0;
        Decimal totalServicePortion = 0;
        Decimal totalCAMOrAirServicePortion = 0;
        List<String> listDepositType = new List<String>{Constant.TYPE_RENT, Constant.TYPE_SERVICE, Constant.TYPE_CAM};

        for(QuotationComponentDataWrapper.InstallmentWrapper securityDepositInstallment : depositInfo.DepositSummary.InstallmentList) {
            if(securityDepositInstallment.isToDeleteRecord) { continue; }
            system.debug('securityDepositInstallment : '+securityDepositInstallment);

            Date runningValidFromTo = null;
            for(String depositType : listDepositType) {
                Double depositPricePerInstallment = null;
                Double depositPricePerInstallmentVat = null;
                Double depositPricePerInstallmentWithVat = null;
                system.debug(depositInfo.DepositSummary.DepositSummaryPricing);
                if (Integer.valueOf(securityDepositInstallment.InstallmentNumber) == depositInfo.NumberOfInstallment){
                    if(depositType == Constant.TYPE_RENT){
                        // validate minus summary
                        //if(!isValidSecurityDeposit(depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary, sapMaster)) continue;

                        depositPricePerInstallment = depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary - totalRentPortion;
                        depositPricePerInstallmentWithVat = (uiWrapper.isWindowDisplay)?(depositPricePerInstallment + (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP)):depositPricePerInstallment;
                        depositPricePerInstallmentVat = (uiWrapper.isWindowDisplay)?(depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP):0;
                        runningValidFromTo = rentValidFromTo;
                        system.debug('depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary : '+depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary);
                        system.debug('= depositPricePerInstallment : '+depositPricePerInstallment);
                    }else if(depositType == Constant.TYPE_SERVICE){
                        // validate minus summary
                        //if(!isValidSecurityDeposit(depositInfo.DepositSummary.DepositSummaryPricing.service_Summary, sapMaster)) continue;

                        depositPricePerInstallment = depositInfo.DepositSummary.DepositSummaryPricing.service_Summary - totalServicePortion;
                        depositPricePerInstallmentWithVat = depositPricePerInstallment + (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        depositPricePerInstallmentVat = (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        runningValidFromTo = serviceValidFromTo;
                    }else if(depositType == Constant.TYPE_CAM){
                        // validate minus summary
                        //if(!isValidSecurityDeposit(depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_Summary, sapMaster)) continue;

                        depositPricePerInstallment = depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_Summary - totalCAMOrAirServicePortion;
                        depositPricePerInstallmentWithVat = depositPricePerInstallment + (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        depositPricePerInstallmentVat = (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        runningValidFromTo = camValidFromTo;
                    }
                }else{
                    if(depositType == Constant.TYPE_RENT) {
                        system.debug('amount : '+securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP));
                        // validate minus summary
                        //if(!isValidSecurityDeposit(depositInfo.DepositSummary.DepositSummaryPricing.rent_Summary, sapMaster)) continue;

                        depositPricePerInstallment = (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) - ((securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * Decimal.valueOf(depositServicePercent) / 100).setScale(2,RoundingMode.HALF_UP) + (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * Decimal.valueOf(depositCAMPercent) / 100).setScale(2,RoundingMode.HALF_UP)));
                        depositPricePerInstallmentWithVat = (uiWrapper.isWindowDisplay)?(depositPricePerInstallment + (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP)):depositPricePerInstallment;
                        depositPricePerInstallmentVat = (uiWrapper.isWindowDisplay)?((depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP)):0;
                        runningValidFromTo = rentValidFromTo;
                        totalRentPortion += depositPricePerInstallment;
                        system.debug('!= depositPricePerInstallment : '+depositPricePerInstallment);
                    } else if(depositType == Constant.TYPE_SERVICE) {
                        // validate minus summary
                        //if(!isValidSecurityDeposit(depositInfo.DepositSummary.DepositSummaryPricing.service_Summary, sapMaster)) continue;

                        depositPricePerInstallment = (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * Decimal.valueOf(depositServicePercent) / 100).setScale(2,RoundingMode.HALF_UP);
                        depositPricePerInstallmentWithVat = depositPricePerInstallment + (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        depositPricePerInstallmentVat = (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        runningValidFromTo = serviceValidFromTo;
                        totalServicePortion += depositPricePerInstallment;
                    } else if(depositType == Constant.TYPE_CAM) {
                        // validate minus summary
                        //if(!isValidSecurityDeposit(depositInfo.DepositSummary.DepositSummaryPricing.camOrAirService_Summary, sapMaster)) continue;

                        depositPricePerInstallment = (securityDepositInstallment.InstallmentAmount.setScale(2,RoundingMode.HALF_UP) * Decimal.valueOf(depositCAMPercent) / 100).setScale(2,RoundingMode.HALF_UP);
                        depositPricePerInstallmentWithVat = depositPricePerInstallment + (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        depositPricePerInstallmentVat = (depositPricePerInstallment*(vatPercent/100)).setScale(2,RoundingMode.HALF_UP);
                        runningValidFromTo = camValidFromTo;
                        totalCAMOrAirServicePortion += depositPricePerInstallment;
                    }
                }

                OpportunityPrice__c oppSecurityDepositPrice = new OpportunityPrice__c(
                    Opportunity__c = oppId,
                    OpportunityDepositExpense__c = oppSecurityDepositExpense.Id,
                    PaymentDueDate__c = securityDepositInstallment.InstallmentAmount <= 0 ? null : (securityDepositInstallment.PaymentDueDate != null) ? securityDepositInstallment.PaymentDueDate : uiWrapper.contractStartDateForm,
                    From__c = runningValidFromTo,
                    To__c = runningValidFromTo,
                    SubType__c = depositType,
                    Installment__c = securityDepositInstallment.InstallmentNumber != null ? Decimal.valueOf(securityDepositInstallment.InstallmentNumber) : null,
                    PaymentType__c = securityDepositInstallment.PaymentMethod,
                    Price__c = depositPricePerInstallment,
                    VAT__c = depositPricePerInstallmentVat,
                    TotalPrice__c = depositPricePerInstallment,
                    InstallmentPriceWithVAT__c = depositPricePerInstallmentWithVat,
                    Remark__c = securityDepositInstallment.remark
                );

                if(uiWrapper.isNoCAM && depositType == Constant.TYPE_CAM) continue;

                oppSecurityDepositPriceList.add(oppSecurityDepositPrice);

                if(securityDepositInstallment.InstallmentAmount != 0) {
                    if(depositType == Constant.TYPE_RENT) {
                        rentValidFromTo = rentValidFromTo.addDays(1);
                    } else if(depositType == Constant.TYPE_SERVICE) {
                        serviceValidFromTo = serviceValidFromTo.addDays(1);
                    } else if(depositType == Constant.TYPE_CAM) {
                        camValidFromTo = camValidFromTo.addDays(1);
                    }
                }
            }
        }
        /*
        for(tms_SAPMapping__c sapMaster : sapMasterMap.get(Constant.TYPE_CARRIED_DEPOSIT)) {
            Double carriedDepositPrice = null;
            Date runningValidFromTo = null;

            if(sapMaster.tms_Type__c == Constant.TYPE_RENT) {
                carriedDepositPrice = depositPricing.rent_CarriedDeposit.setScale(2,RoundingMode.HALF_UP);
                runningValidFromTo = rentValidFromTo;
            } else if(sapMaster.tms_Type__c == Constant.TYPE_SERVICE) {
                carriedDepositPrice = depositPricing.service_CarriedDeposit.setScale(2,RoundingMode.HALF_UP);
                runningValidFromTo = serviceValidFromTo;
            } else if(sapMaster.tms_Type__c == Constant.TYPE_CAM) {
                carriedDepositPrice = depositPricing.camOrAirService_CarriedDeposit.setScale(2,RoundingMode.HALF_UP);
                runningValidFromTo = camValidFromTo;
            }

            OpportunityPrice__c oppCarriedSecurityDepositPrice = new OpportunityPrice__c(
                Opportunity__c = oppId,
                OpportunityDepositExpense__c = oppSecurityDepositExpense.Id,
                tms_From__c = runningValidFromTo,
                tms_To__c = runningValidFromTo,
                tms_SubType__c = sapMaster.tms_Type__c,
                tms_Price__c = Decimal.valueOf(carriedDepositPrice).setScale(6,RoundingMode.HALF_UP),
                tms_PriceIntegration__c = Decimal.valueOf(carriedDepositPrice).setScale(6,RoundingMode.HALF_UP),
                tms_TotalPrice__c = Decimal.valueOf(carriedDepositPrice).setScale(6,RoundingMode.HALF_UP),
                tms_TotalPriceIntegration__c = Decimal.valueOf(carriedDepositPrice).setScale(6,RoundingMode.HALF_UP),
                tms_CarriedDeposit__c = Decimal.valueOf(carriedDepositPrice).setScale(6,RoundingMode.HALF_UP),
                tms_ConditionPurpose__c = sapMaster.tms_ConditionPurpose__c,
                tms_ConditionType__c = sapMaster.tms_ConditionType__c,
                tms_CalculationObject__c = sapMaster.tms_CalculationObject__c,
                tms_CalculationFormula__c = sapMaster.tms_CalculationFormula__c,
                tms_SAPMapping__c = sapMaster.Id
            );
            oppSecurityDepositPriceList.add(oppCarriedSecurityDepositPrice);
        }
        */
        upsert oppSecurityDepositPriceList;
    }

    public void processDeposit(Id oppId, QuotationComponentDataWrapper.DepositWrapper depositInfo, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        String contractType = getContractType(oppId);

        // #region Other Deposit
        Opportunity opp = new Opportunity(Id = oppId,
                                          TotalDeposit__c = depositInfo.DepositSummary.DepositSummaryPricing.totalDeposit,
                                          Deposit_Month__c = depositInfo.DepositMonth);
        update opp;

        List<QuotationComponentDataWrapper.DepositOtherWrapper> otherDepositList = depositInfo.OtherDepositList;
        Date otherDepositValidFrom = uiWrapper.contractStartDateForm;
        List<OpportunityDepositExpense__c> deleteOtherDepositList = new List<OpportunityDepositExpense__c>();
        List<OpportunityPrice__c> deleteOtherDepositPriceList = new List<OpportunityPrice__c>();

        Map<QuotationComponentDataWrapper.DepositOtherWrapper, OpportunityDepositExpense__c> oppDepositMap = new Map<QuotationComponentDataWrapper.DepositOtherWrapper, OpportunityDepositExpense__c>();
        Map<QuotationComponentDataWrapper.DepositOtherWrapper, List<OpportunityPrice__c>> oppPriceMap = new Map<QuotationComponentDataWrapper.DepositOtherWrapper, List<OpportunityPrice__c>>();
        for(QuotationComponentDataWrapper.DepositOtherWrapper otherDeposit : otherDepositList) {
            if(otherDeposit.isToDeleteRecord) {
                if(otherDeposit.otherDepositId != null) { deleteOtherDepositList.add(new OpportunityDepositExpense__c(Id = otherDeposit.otherDepositId)); }
            } else {
                System.debug(otherDeposit);
                OpportunityDepositExpense__c oppDepositExpense = new OpportunityDepositExpense__c(
                    Id = otherDeposit.otherDepositId,
                    Opportunity__c = oppId,
                    TypeGroup__c = 'Deposit',
                    Type__c = otherDeposit.Type,
                    Price__c = otherDeposit.TotalAmount.setScale(2),
                    NumberOfInstallment__c = otherDeposit.NumberOfInstallment,
                    Remark__c = otherDeposit.Remark,
                    HasRemark__c = String.isBlank(otherDeposit.Remark)? false : true
            );
                oppDepositMap.put(otherDeposit, oppDepositExpense);
            }

            for(QuotationComponentDataWrapper.InstallmentWrapper installmentInfo : otherDeposit.InstallmentList) {
                if(otherDeposit.isToDeleteRecord || installmentInfo.isToDeleteRecord) {
                    if(installmentInfo.Id != null) { deleteOtherDepositPriceList.add(new OpportunityPrice__c(Id = installmentInfo.Id)); }
                } else {
                    OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                        Id = installmentInfo.Id,
                        Opportunity__c = oppId,
                        PaymentDueDate__c = installmentInfo.PaymentDueDate,
                        From__c = otherDepositValidFrom,
                        To__c = otherDepositValidFrom,
                        Installment__c = Integer.valueOf(installmentInfo.InstallmentNumber),
                        Price__c = (installmentInfo.InstallmentAmount).setScale(2),
                        TotalPrice__c = (installmentInfo.InstallmentAmount).setScale(2),
                        Remark__c = installmentInfo.remark
                    );
                    if(!oppPriceMap.containsKey(otherDeposit)) {
                        oppPriceMap.put(otherDeposit, new List<OpportunityPrice__c>{oppPrice});
                    } else {
                        oppPriceMap.get(otherDeposit).add(oppPrice);
                    }

                    otherDepositValidFrom = otherDepositValidFrom.addDays(1);
                }
            }
        }
        if(deleteOtherDepositPriceList.size() > 0) delete deleteOtherDepositPriceList;
        if(deleteOtherDepositList.size() > 0) delete deleteOtherDepositList;
        System.debug('oppDepositMap: ' + oppDepositMap.size());
        upsert oppDepositMap.values();

        List<OpportunityPrice__c> upsertOppPriceList = new List<OpportunityPrice__c>();
        for(QuotationComponentDataWrapper.DepositOtherWrapper otherDeposit : oppDepositMap.keySet()) {
            for(OpportunityPrice__c oppPrice : oppPriceMap.get(otherDeposit)) {
                oppPrice.OpportunityDepositExpense__c = oppDepositMap.get(otherDeposit).Id;
                upsertOppPriceList.add(oppPrice);
            }
        }
        upsert upsertOppPriceList;
        // #endregion
    }

    //SAPMappingList
    private List<OpportunityPrice__c> generateOppPriceForCalculationMethod(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, QuotationComponentDataWrapper.PeriodPricing priceInfo, Map<Integer, List<IncludedCAMInfo>> includedCAMInfoMapByPeriod, List<DepositMeasurementModel.Data> depositMeasurementList, Set<Id> measurementIdSet, OpportunityPeriod__c oppPeriod) {
        system.debug('priceInfo : '+priceInfo);
        if(priceInfo.CalculationMethod == Constant.CAL_METHOD_FIXED_PRICE) {
            Map<Integer, List<SumIncludedCAM>> mapPeriodNumberWithCAMPricing = getSumPriceByPeriodMappingWithCAM(priceInfo.PeriodNumber, includedCAMInfoMapByPeriod);
            return generateOppPriceForFixedPrice(oppId, uiWrapper, priceInfo, mapPeriodNumberWithCAMPricing, depositMeasurementList, measurementIdSet, oppPeriod);
        }
        else if(priceInfo.CalculationMethod == Constant.CAL_METHOD_FIXED_RO) {
            return generateOppPriceForFixedRentalObject(oppId, uiWrapper, priceInfo, includedCAMInfoMapByPeriod, oppPeriod);
        }
        else if(priceInfo.CalculationMethod == Constant.CAL_METHOD_FIXED_MEAS) {
            return generateOppPriceForFixedMeasurement(oppId, uiWrapper, priceInfo, includedCAMInfoMapByPeriod, depositMeasurementList, oppPeriod);
        }
        else if(priceInfo.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN) {
            return generateOppPriceForGPNoMin(oppId, priceInfo, oppPeriod);
        }
        else if(priceInfo.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
            return generateOppPriceForGPWithMin(oppId, uiWrapper, priceInfo, includedCAMInfoMapByPeriod, depositMeasurementList, oppPeriod);
        }
        else if(priceInfo.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {
            return generateOppPriceForGPOnTop(oppId, uiWrapper, priceInfo, includedCAMInfoMapByPeriod, depositMeasurementList, oppPeriod);
        }
        return null;
    }

    public static Map<Integer, List<SumIncludedCAM>> getSumPriceByPeriodMappingWithCAM(Integer periodNumber, Map<Integer, List<IncludedCAMInfo>> includedCAMInfoMapByPeriod) {
        List<IncludedCAMInfo> includedCAMInfoList = includedCAMInfoMapByPeriod.get(periodNumber);
        Map<String, SumIncludedCAM> mapCAMPricing = new Map<String, SumIncludedCAM>();
        Map<Integer, List<SumIncludedCAM>> mapPeriodNumberWithCAMPricing = new Map<Integer, List<SumIncludedCAM>>();

        if(includedCAMInfoList == null) return mapPeriodNumberWithCAMPricing;
        for(IncludedCAMInfo eachIncludedCAM : includedCAMInfoList){
            system.debug(eachIncludedCAM.CAMUnitPrice);
            system.debug(eachIncludedCAM.CAMArea);
            String key = String.valueOf(eachIncludedCAM.ValidFrom);
            if(mapCAMPricing.containsKey(key)){
                SumIncludedCAM currentSumIncludedCAM = mapCAMPricing.get(key);
                currentSumIncludedCAM.CAMPrice += eachIncludedCAM.CAMPrice;
                currentSumIncludedCAM.CAMUnitPrice += eachIncludedCAM.CAMUnitPrice;
                currentSumIncludedCAM.CAMTotalArea += eachIncludedCAM.CAMArea;
                /*currentSumIncludedCAM.CAMTotalPrice = currentSumIncludedCAM.CAMUnitPrice*currentSumIncludedCAM.CAMTotalArea;*/
                currentSumIncludedCAM.CAMUnitPricePerSQM = (currentSumIncludedCAM.CAMTotalArea > 0)?currentSumIncludedCAM.CAMPrice/currentSumIncludedCAM.CAMTotalArea:currentSumIncludedCAM.CAMPrice;
                system.debug('currentSumIncludedCAM : '+currentSumIncludedCAM);
                mapCAMPricing.put(key, currentSumIncludedCAM);
            } else{
                SumIncludedCAM sumIncludedCAM = new SumIncludedCAM(eachIncludedCAM.ValidFrom, eachIncludedCAM.ValidTo, eachIncludedCAM.CAMUnitPrice, eachIncludedCAM.CAMArea, eachIncludedCAM.CAMPrice);
                system.debug('sumIncludedCAM : '+sumIncludedCAM);
                mapCAMPricing.put(key, sumIncludedCAM);
            }
        }

        for(String eachKey : mapCAMPricing.keySet()){
            SumIncludedCAM currentSumIncludedCAM = mapCAMPricing.get(eachKey);
            if(mapPeriodNumberWithCAMPricing.containsKey(periodNumber)){
                mapPeriodNumberWithCAMPricing.get(periodNumber).add(currentSumIncludedCAM);
            } else{
                mapPeriodNumberWithCAMPricing.put(periodNumber, new List<SumIncludedCAM>{currentSumIncludedCAM});
            }
        }
        return mapPeriodNumberWithCAMPricing;
    }

    @TestVisible
    private List<OpportunityPrice__c> generateOppPriceForFixedPrice(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, QuotationComponentDataWrapper.PeriodPricing priceInfo, Map<Integer, List<SumIncludedCAM>> mapPeriodNumberWithCAMPricing, List<DepositMeasurementModel.Data> depositMeasurementList, Set<Id> measurementIdSet, OpportunityPeriod__c oppPeriod) {
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
        if(priceInfo == null) { return oppPriceList; }

        List<SumIncludedCAM> CAMInfoList = mapPeriodNumberWithCAMPricing.get(priceInfo.PeriodNumber);
        Double price = (priceInfo.FixedPriceSection.MinType == MINTYPE_MEASUREMENT)?priceInfo.FixedPriceSection.PriceSQM : priceInfo.FixedPriceSection.Price;
        for(SumIncludedCAM eachSumIncludedCAM : CAMInfoList){
            system.debug('eachSumIncludedCAM : '+eachSumIncludedCAM);
            Double priceIntegration = (priceInfo.IsIncludeCAM)?(priceInfo.FixedPriceSection.MinType == MINTYPE_MEASUREMENT)?Decimal.valueOf(price-eachSumIncludedCAM.CAMUnitPricePerSQM).setScale(2) : Decimal.valueOf(price-eachSumIncludedCAM.CAMPrice).setScale(2) : Decimal.valueOf(price).setScale(2);
            /*Double pricewithoutVat = 0;
            Double priceVat = 0;
            if (uiWrapper.isWindowDisplay) {
                pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                priceVat = price;
            }*/
            OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                Opportunity__c = oppId,
                OpportunityPeriod__c = priceInfo.Id,
                From__c = eachSumIncludedCAM.ValidFrom,
                To__c = eachSumIncludedCAM.ValidTo,
                // PriceVAT__c = (uiWrapper.isWindowDisplay)?priceVat:0,
                // VAT__c = (uiWrapper.isWindowDisplay)?(Decimal.valueOf((priceVat - pricewithoutVat)).setScale(2)) : 0,
                // Price__c = (uiWrapper.isWindowDisplay)?pricewithoutVat : price,
                // TotalPrice__c = (uiWrapper.isWindowDisplay)?((priceInfo.FixedPriceSection.MinType == MINTYPE_MEASUREMENT)?((pricewithoutVat*priceInfo.FixedPriceSection.TotalArea).setScale(2)):(((priceInfo.FixedPriceSection.Price*100)/(100+vatPercent)).setScale(2))):priceInfo.FixedPriceSection.Price,
                // TotalPriceVAT__c = (uiWrapper.isWindowDisplay)?priceInfo.FixedPriceSection.Price:0,
                PriceVAT__c = price,
                VAT__c = 0,
                Price__c = price,
                TotalPrice__c = priceInfo.FixedPriceSection.Price,
                TotalPriceVAT__c = priceInfo.FixedPriceSection.Price,
                CalculationMethod__c = priceInfo.CalculationMethod,
                MeasurementAmount__c = priceInfo.FixedPriceSection.TotalArea
            );
            oppPriceList.add(oppPrice);
        }

        System.debug(measurementIdSet);
        if(measurementIdSet != null) {
            CAMInfoList =  mapPeriodNumberWithCAMPricing.get(priceInfo.PeriodNumber);
            // Date lastValidFrom = CAMInfoList.get(CAMInfoList.size()-1).ValidFrom;
            Date lastValidFrom = null;

            System.debug('priceInfo : ' + priceInfo);
            for(OpportunityPrice__c oppPrice : oppPriceList) {
                if(!priceInfo.OptionToRenew && priceInfo.FixedPriceSection.MinType == MINTYPE_MEASUREMENT) {
                    if((lastValidFrom == null || lastValidFrom < oppPrice.From__c) && oppPrice.SubType__c == Constant.TYPE_RENT || oppPrice.SubType__c == Constant.TYPE_SERVICE) {
                        lastValidFrom = oppPrice.From__c;
                    }
                }
            }

            System.debug('lastValidFrom : ' + lastValidFrom);
            for(OpportunityPrice__c oppPrice : oppPriceList) {
                if(!priceInfo.OptionToRenew && priceInfo.FixedPriceSection.MinType == MINTYPE_MEASUREMENT) {
                    System.debug('oppPrice.Id : ' + oppPrice.Id);
                    System.debug('oppPrice.From__c : ' + oppPrice.From__c);
                    if(lastValidFrom == oppPrice.From__c && oppPrice.SubType__c == Constant.TYPE_RENT || oppPrice.SubType__c == Constant.TYPE_SERVICE) {
                        for(Id measurementId : measurementIdSet) {
                            DepositMeasurementModel.Data depositMeasurement = generateDepositMeasurement(oppPrice.Opportunity__c, oppPrice.SubType__c, oppPrice.Price__c, measurementId);
                            depositMeasurementList.add(depositMeasurement);
                        }
                    }
                }
            }
        }
        return oppPriceList;
    }

	/**
	 * CR Feb 2025
	 */
    private List<OpportunityPrice__c> generateOppPriceForFixedRentalObject(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, QuotationComponentDataWrapper.PeriodPricing priceInfo,  Map<Integer, List<IncludedCAMInfo>> includedCAMInfoMapByPeriod, OpportunityPeriod__c oppPeriod) {
        System.debug('priceInfo.CalculationMethod ' + priceInfo.CalculationMethod);
        System.debug('priceInfo.FixedRentalObjectSection.rentalObjectList ' + priceInfo.FixedRentalObjectSection.rentalObjectList);
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        if(priceInfo == null) { return oppPriceList; }

        Double totalLeasableArea = priceInfo.FixedRentalObjectSection.TotalLeasableArea;
        String minType = priceInfo.FixedRentalObjectSection.MinType;

        Map<Date, IncludedCAMInfoByMeasurement> CAMPeriodMapByMeasurement = new Map<Date, IncludedCAMInfoByMeasurement>();
        List<IncludedCAMInfo> includedCAMInfoList = includedCAMInfoMapByPeriod.get(priceInfo.PeriodNumber);
        System.debug(includedCAMInfoList);
        for(IncludedCAMInfo includedCAMInfo : includedCAMInfoList) {
            if(!CAMPeriodMapByMeasurement.containsKey(includedCAMInfo.ValidFrom)) {
                System.debug(includedCAMInfo.MeasurementCode);
                CAMPeriodMapByMeasurement.put(includedCAMInfo.ValidFrom, new IncludedCAMInfoByMeasurement(
                                                                            includedCAMInfo.ValidFrom,
                                                                            includedCAMInfo.ValidTo,
                                                                            new Map<String, Double>{ includedCAMInfo.MeasurementCode => includedCAMInfo.CAMUnitPrice }));
            } else {
                CAMPeriodMapByMeasurement.get(includedCAMInfo.ValidFrom).CAMUnitPriceMap.put(includedCAMInfo.MeasurementCode, includedCAMInfo.CAMUnitPrice);
            }
        }

        for(QuotationComponentDataWrapper.RentalObjectPricingWrapper rentalObject : priceInfo.FixedRentalObjectSection.rentalObjectList) {
            Double price = (priceInfo.FixedRentalObjectSection.MinType == MINTYPE_MEASUREMENT)?Double.valueOf(rentalObject.PriceSQM.value):Double.valueOf(rentalObject.Price.value);
            for(Date key : CAMPeriodMapByMeasurement.keySet()) {

                Double avgCAM = 0;
                Double sumCAM = 0;
                Double totalArea = 0;
                Double multiplier = priceInfo.FixedRentalObjectSection.MinType == MINTYPE_MEASUREMENT ? rentalObject.LeasableArea : 1;
                if(priceInfo.IsIncludeCAM) {
                    List<QuotationComponentDataWrapper.ROMeasurementClass> measurementList = rentalObject.roMeasurementList;
                    for(QuotationComponentDataWrapper.ROMeasurementClass eachMeasurement : measurementList) {
                        if(eachMeasurement.isFOC) continue;
                        totalArea = totalArea + eachMeasurement.measurementArea;
                        System.debug(CAMPeriodMapByMeasurement.get(key));
                        System.debug(eachMeasurement.measurementName);
                        sumCAM = sumCAM + (eachMeasurement.measurementArea * CAMPeriodMapByMeasurement.get(key).CAMUnitPriceMap.get(eachMeasurement.measurementName));
                    }

                    if(priceInfo.FixedRentalObjectSection.MinType == MINTYPE_MEASUREMENT) {
                        avgCAM = Decimal.valueOf((sumCAM / totalArea)).setScale(2);
                    } else {
                        avgCAM = sumCAM;
                    }
                }

                System.debug((priceInfo.IsIncludeCAM) ? price-avgCAM : price);
                /*Double pricewithoutVat = 0;
                Double priceVat = 0;
                if (uiWrapper.isWindowDisplay) {
                    pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                    priceVat = price;
                }*/

                OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                    Opportunity__c = oppId,
                    OpportunityPeriod__c = priceInfo.Id,
                    From__c = CAMPeriodMapByMeasurement.get(key).ValidFrom,
                    To__c = CAMPeriodMapByMeasurement.get(key).ValidTo,
                    // PriceVAT__c = (uiWrapper.isWindowDisplay)?priceVat : 0,
                    // VAT__c = (uiWrapper.isWindowDisplay)?priceVat - pricewithoutVat : 0,
                    // Price__c = (uiWrapper.isWindowDisplay)?pricewithoutVat : price,
                    // TotalPrice__c = (uiWrapper.isWindowDisplay)?((priceInfo.FixedRentalObjectSection.MinType == MINTYPE_MEASUREMENT)?((pricewithoutVat*rentalObject.LeasableArea).setScale(2)):(pricewithoutVat)):Double.valueOf(rentalObject.Price.value),
                    // TotalPriceVAT__c = (uiWrapper.isWindowDisplay)?Double.valueOf(rentalObject.Price.value):0,
                    PriceVAT__c = price,
                    VAT__c = 0,
                    Price__c = price,
                    TotalPrice__c = Double.valueOf(rentalObject.Price.value),
                    TotalPriceVAT__c = Double.valueOf(rentalObject.Price.value),
                    MeasurementAmount__c = rentalObject.TotalArea,
                    Area__c = rentalObject.leasableArea,
                    Unit__c = rentalObject.roId,
                    CalculationMethod__c = priceInfo.CalculationMethod
					/**
					 * CR Feb 2025
					 * Changed Detail: assign new field values
					 */
					//
					//
					//
					// Changed end
                );

                oppPriceList.add(oppPrice);
            }
        }
        return oppPriceList;
    }

    @TestVisible
    private List<OpportunityPrice__c> generateOppPriceForFixedMeasurement(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, QuotationComponentDataWrapper.PeriodPricing priceInfo, Map<Integer, List<IncludedCAMInfo>> includedCAMInfoMapByPeriod, List<DepositMeasurementModel.Data> depositMeasurementList, OpportunityPeriod__c oppPeriod) {
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
        Map<Date, IncludedCAMInfoByMeasurement> CAMPeriodMapByMeasurement = new Map<Date, IncludedCAMInfoByMeasurement>();
        if(priceInfo == null) { return oppPriceList; }

        List<IncludedCAMInfo> includedCAMInfoList = includedCAMInfoMapByPeriod.get(priceInfo.PeriodNumber);
        for(IncludedCAMInfo includedCAMInfo : includedCAMInfoList) {
            if(!CAMPeriodMapByMeasurement.containsKey(includedCAMInfo.ValidFrom)) {
                CAMPeriodMapByMeasurement.put(includedCAMInfo.ValidFrom, new IncludedCAMInfoByMeasurement(
                                                                            includedCAMInfo.ValidFrom,
                                                                            includedCAMInfo.ValidTo,
                                                                            new Map<String, Double>{ includedCAMInfo.MeasurementCode => includedCAMInfo.CAMUnitPrice }));
            } else {
                CAMPeriodMapByMeasurement.get(includedCAMInfo.ValidFrom).CAMUnitPriceMap.put(includedCAMInfo.MeasurementCode, includedCAMInfo.CAMUnitPrice);
            }
        }

        for(QuotationComponentDataWrapper.MeasurementPricingList measurementPrice : priceInfo.FixedMeasurementSection.pricingList) {
            //if(initSBR.contains(Constant.OPP_PRICE_CONDITION_TYPE_INIT_SBR)) continue;
            Double price = Double.valueOf(measurementPrice.Price.value);
            System.debug(measurementPrice);
            /*Double pricewithoutVat = 0;
            Double priceVat = 0;
            if (uiWrapper.isWindowDisplay) {
                pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                priceVat = price;
            }*/

            for(Date key : CAMPeriodMapByMeasurement.keySet()) {
                System.debug('priceInfo.PeriodNumber' + priceInfo.PeriodNumber);
                System.debug('includedCAMInfoList' + includedCAMInfoList);
                System.debug('CAMPeriodMapByMeasurement.get(key)' + CAMPeriodMapByMeasurement.get(key));
                System.debug('measurementPrice.MeasurementType' + measurementPrice.MeasurementType);
                OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                    Opportunity__c = oppId,
                    OpportunityPeriod__c = priceInfo.Id,
                    From__c = CAMPeriodMapByMeasurement.get(key).ValidFrom,
                    To__c = CAMPeriodMapByMeasurement.get(key).ValidTo,
                    Measurement__c = measurementPrice.roMeasurementId,
                    Unit__c = measurementPrice.roId,
                    MeasurementAmount__c = measurementPrice.Area,
                    // PriceVAT__c = (uiWrapper.isWindowDisplay)?priceVat : 0,
                    // VAT__c = (uiWrapper.isWindowDisplay)?priceVat - pricewithoutVat : 0,
                    // Price__c = (uiWrapper.isWindowDisplay)?pricewithoutVat : price,
                    // TotalPrice__c = (uiWrapper.isWindowDisplay)?((pricewithoutVat * measurementPrice.Area).setScale(2)):Double.valueOf(measurementPrice.Price.value) * measurementPrice.Area,
                    // TotalPriceVAT__c = (uiWrapper.isWindowDisplay)?((priceVat * measurementPrice.Area).setScale(2)) : 0,
                    PriceVAT__c = price,
                    VAT__c = 0,
                    Price__c = price,
                    TotalPrice__c = Double.valueOf(measurementPrice.Price.value) * measurementPrice.Area,
                    TotalPriceVAT__c = Double.valueOf(measurementPrice.Price.value) * measurementPrice.Area,
                    PriceItem__c = measurementPrice.MeasurementType,
                    CalculationMethod__c = priceInfo.CalculationMethod,
                    MeasurementType__c = measurementPrice.measurementId
                );
                oppPriceList.add(oppPrice);
            }
        }

        if(depositMeasurementList != null) {
            Date lastValidFrom = new List<Date>(CAMPeriodMapByMeasurement.keySet())[CAMPeriodMapByMeasurement.keySet().size()-1];

            for(OpportunityPrice__c oppPrice : oppPriceList) {
                if(oppPrice.From__c == lastValidFrom && oppPrice.Price__c != 0
                    && (oppPrice.SubType__c == Constant.TYPE_RENT || oppPrice.SubType__c == Constant.TYPE_SERVICE)) {
                    DepositMeasurementModel.Data depositMeasurement = generateDepositMeasurement(oppPrice.Opportunity__c, oppPrice.SubType__c, oppPrice.Price__c, oppPrice.Measurement__c);
                    depositMeasurementList.add(depositMeasurement);
                }
            }
        }

        return oppPriceList;
    }

    private List<OpportunityPrice__c> generateOppPriceForGPNoMin(Id oppId, QuotationComponentDataWrapper.PeriodPricing priceInfo, OpportunityPeriod__c oppPeriod) {
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        Set<Boolean> isIncludedCAMSet = new Set<Boolean>();
        List<Boolean> isIncludedCAMList = new List<Boolean>();
        if(priceInfo == null) { return oppPriceList; }

        System.debug('priceInfo : ' + priceInfo);
        for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : priceInfo.GPNoMinSection.ReportingRuleList){
            //system.debug('eachReportingRule : '+eachReportingRule);
            for(QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList){
                isIncludedCAMSet.add(eachReportingRuleDetail.IsIncludeCam);
            }
        }
        isIncludedCAMList.addAll(isIncludedCAMSet);
        OpportunityPrice__c oppPrice = new OpportunityPrice__c(
            Opportunity__c = oppId,
            OpportunityPeriod__c = priceInfo.Id,
            From__c = priceInfo.PricingFrom,
            To__c = priceInfo.PricingTo,
            MeasurementAmount__c = priceInfo.TotalArea,
            Price__c = 0,
            PriceVAT__c = 0,
            VAT__c = 0,
            TotalPriceVAT__c = 0,
            TotalPrice__c = 0,
            CalculationMethod__c = priceInfo.CalculationMethod
        );
        oppPriceList.add(oppPrice);
        return oppPriceList;
    }

    private List<OpportunityPrice__c> generateOppPriceForGPWithMin(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, QuotationComponentDataWrapper.PeriodPricing priceInfo, Map<Integer, List<IncludedCAMInfo>> includedCAMInfoMapByPeriod, List<DepositMeasurementModel.Data> depositMeasurementList, OpportunityPeriod__c oppPeriod) {
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
        Map<String, OpportunityPrice__c> oppPriceMap = new Map<String, OpportunityPrice__c>();
        if(priceInfo == null) { return oppPriceList; }

        System.debug('priceInfo : ' + priceInfo);
        System.debug('priceInfo.GPWithMinSection : ' + priceInfo.GPWithMinSection);
        if(priceInfo.GPWithMinSection.PricingSection.MinType != MINTYPE_MEASUREMENT) {
            Map<Integer, List<SumIncludedCAM>> mapPeriodNumberWithCAMPricing = getSumPriceByPeriodMappingWithCAM(priceInfo.PeriodNumber, includedCAMInfoMapByPeriod);
            List<SumIncludedCAM> CAMInfoList = mapPeriodNumberWithCAMPricing.get(priceInfo.PeriodNumber);
            for(SumIncludedCAM eachSumIncludedCAM : CAMInfoList){
                if(MINTYPE_FIXED == priceInfo.GPWithMinSection.PricingSection.MinType) {
                    Double price = priceInfo.GPWithMinSection.PricingSection.FixedPricing.Price;
                    Double priceIntegration = (priceInfo.IsIncludeCAM) ? price-eachSumIncludedCAM.CAMPrice : price;

                    Double pricewithoutVat = 0;
                    Double priceVat = 0;
                    if (uiWrapper.isWindowDisplay) {
                        pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                        priceVat = price;
                    }

                    OpportunityPrice__c oppPrice = new OpportunityPrice__c();
                    oppPrice.Opportunity__c = oppId;
                    oppPrice.OpportunityPeriod__c = priceInfo.Id;
                    oppPrice.From__c = eachSumIncludedCAM.ValidFrom;
                    oppPrice.To__c = eachSumIncludedCAM.ValidTo;
                    oppPrice.PriceVAT__c = (uiWrapper.isWindowDisplay)?priceVat : 0;
                    oppPrice.VAT__c = (uiWrapper.isWindowDisplay)?priceVat - pricewithoutVat : 0;
                    oppPrice.Price__c = (uiWrapper.isWindowDisplay)?pricewithoutVat:price;
                    oppPrice.TotalPrice__c = (uiWrapper.isWindowDisplay)?pricewithoutVat:price;
                    oppPrice.TotalPriceVAT__c = (uiWrapper.isWindowDisplay)?price:0;
                    oppPrice.CalculationMethod__c = priceInfo.CalculationMethod;
                    oppPrice.MeasurementAmount__c = priceInfo.TotalArea;
                    System.debug(OppPrice);
                    oppPriceList.add(oppPrice);
                } else {
                    OpportunityPrice__c oppPrice = new OpportunityPrice__c();
                    oppPrice.Opportunity__c = oppId;
                    oppPrice.OpportunityPeriod__c = priceInfo.Id;
                    oppPrice.From__c = eachSumIncludedCAM.ValidFrom;
                    oppPrice.To__c = eachSumIncludedCAM.ValidTo;
                    oppPrice.Price__c = 0;
                    oppPrice.PriceVAT__c = 0;
                    oppPrice.VAT__c = 0;
                    oppPrice.TotalPriceVAT__c = 0;
                    oppPrice.TotalPrice__c = 0;
                    oppPrice.CalculationMethod__c = priceInfo.CalculationMethod;
                    oppPrice.MeasurementAmount__c = priceInfo.TotalArea;
                    oppPriceList.add(oppPrice);
                }
            }
            return oppPriceList;
        } else {
            Map<Date, IncludedCAMInfoByMeasurement> CAMPeriodMapByMeasurement = new Map<Date, IncludedCAMInfoByMeasurement>();
            List<IncludedCAMInfo> includedCAMInfoList = includedCAMInfoMapByPeriod.get(priceInfo.PeriodNumber);
            for(IncludedCAMInfo includedCAMInfo : includedCAMInfoList) {
                if(!CAMPeriodMapByMeasurement.containsKey(includedCAMInfo.ValidFrom)) {
                    CAMPeriodMapByMeasurement.put(includedCAMInfo.ValidFrom, new IncludedCAMInfoByMeasurement(
                                                                                includedCAMInfo.ValidFrom,
                                                                                includedCAMInfo.ValidTo,
                                                                                new Map<String, Double>{ includedCAMInfo.MeasurementCode => includedCAMInfo.CAMUnitPrice }));
                } else {
                    CAMPeriodMapByMeasurement.get(includedCAMInfo.ValidFrom).CAMUnitPriceMap.put(includedCAMInfo.MeasurementCode, includedCAMInfo.CAMUnitPrice);
                }
            }
            system.debug('CAMPeriodMapByMeasurement : '+CAMPeriodMapByMeasurement);
            for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : priceInfo.GPWithMinSection.PricingSection.MeasumentPricingList) {
                System.debug(' measurementPricing.MeasurementType : ' + measurementPricing.MeasurementType);
                if(priceInfo.isToDeleteRecord) {
                    System.debug('Continue');
                    continue;
                }
                System.debug(measurementPricing.measurementId);
                System.debug(priceInfo.GPWithMinSection.PricingSection.MinType);
                Double price = Double.valueOf(measurementPricing.Price.value);
                Double pricewithoutVat = 0;
                Double priceVat = 0;
                if (uiWrapper.isWindowDisplay) {
                    pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                    priceVat = price;
                }
                for(Date CAMkey : CAMPeriodMapByMeasurement.keySet()) {
                    Double priceIntegration = (priceInfo.IsIncludeCAM)? price-CAMPeriodMapByMeasurement.get(CAMkey).CAMUnitPriceMap.get(measurementPricing.MeasurementType) : price;
                    OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                        Opportunity__c = oppId,
                        OpportunityPeriod__c = priceInfo.Id,
                        From__c = CAMPeriodMapByMeasurement.get(CAMkey).ValidFrom,
                        To__c = CAMPeriodMapByMeasurement.get(CAMkey).ValidTo,
                        Measurement__c = measurementPricing.roMeasurementId,
                        PriceVAT__c = (uiWrapper.isWindowDisplay)?priceVat : 0,
                        VAT__c = (uiWrapper.isWindowDisplay)?priceVat - pricewithoutVat : 0,
                        Price__c = (uiWrapper.isWindowDisplay)?pricewithoutVat:price,
                        TotalPrice__c = ((uiWrapper.isWindowDisplay)? (measurementPricing.Area * pricewithoutVat) : measurementPricing.Area * Double.valueOf(measurementPricing.Price.value)),
                        TotalPriceVAT__c = ((uiWrapper.isWindowDisplay)?(measurementPricing.Area * pricewithoutVat):(measurementPricing.Area * Double.valueOf(measurementPricing.Price.value))),
                        MeasurementAmount__c = measurementPricing.Area,
                        CalculationMethod__c = priceInfo.CalculationMethod,
                        PriceItem__c = measurementPricing.MeasurementType,
                        Unit__c = measurementPricing.roId,
                        MeasurementType__c = measurementPricing.measurementId
                    );
                    String key = oppPrice.Opportunity__c + '_' + oppPrice.OpportunityPeriod__c + '_' + oppPrice.Measurement__c + '_' + oppPrice.From__c;
                    if(oppPriceMap.containsKey(key)) { continue; }
                    oppPriceMap.put(key, oppPrice);
                }
            }

            System.debug(depositMeasurementList);
            if(depositMeasurementList != null) {
                Date lastValidFrom = new List<Date>(CAMPeriodMapByMeasurement.keySet())[CAMPeriodMapByMeasurement.keySet().size()-1];

                for(OpportunityPrice__c oppPrice : oppPriceMap.values()) {
                    System.debug(oppPrice);
                    if(oppPrice.From__c == lastValidFrom && oppPrice.Price__c != 0
                        && (oppPrice.SubType__c == Constant.TYPE_RENT || oppPrice.SubType__c == Constant.TYPE_SERVICE)) {
                        DepositMeasurementModel.Data depositMeasurement = generateDepositMeasurement(oppPrice.Opportunity__c, oppPrice.SubType__c, oppPrice.Price__c, oppPrice.Measurement__c);
                        depositMeasurementList.add(depositMeasurement);
                    }
                    System.debug(depositMeasurementList);
                }
            }
            return oppPriceMap.values();
        }
    }

    private List<OpportunityPrice__c> generateOppPriceForGPOnTop(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, QuotationComponentDataWrapper.PeriodPricing priceInfo, Map<Integer, List<IncludedCAMInfo>> includedCAMInfoMapByPeriod, List<DepositMeasurementModel.Data> depositMeasurementList, OpportunityPeriod__c oppPeriod) {
        system.debug('priceInfo : '+priceInfo);
        List<OpportunityPrice__c> oppPriceList = new List<OpportunityPrice__c>();
        Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
        Map<String, OpportunityPrice__c> oppPriceMap = new Map<String, OpportunityPrice__c>();
        Set<Boolean> isIncludedCAMSet = new Set<Boolean>();
        List<Boolean> isIncludedCAMList = new List<Boolean>();
        for(QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : priceInfo.GPOnTopSection.ReportingRuleList){
            //system.debug('eachReportingRule : '+eachReportingRule);
            for(QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList){
                isIncludedCAMSet.add(eachReportingRuleDetail.IsIncludeCam);
            }
        }
        isIncludedCAMList.addAll(isIncludedCAMSet);
        system.debug('isIncludedCAMSet : '+isIncludedCAMSet);
        if(priceInfo == null) { return oppPriceList; }

        if(priceInfo.GPOnTopSection.PricingSection.MinType != MINTYPE_MEASUREMENT) {
            Map<Integer, List<SumIncludedCAM>> mapPeriodNumberWithCAMPricing = getSumPriceByPeriodMappingWithCAM(priceInfo.PeriodNumber, includedCAMInfoMapByPeriod);
            if(!priceInfo.isToDeleteRecord) {
                // if only one included cam
                List<SumIncludedCAM> CAMInfoList = mapPeriodNumberWithCAMPricing.get(priceInfo.PeriodNumber);
                //if(isIncludedCAMList.size() == 1){ continue;}
                for(SumIncludedCAM eachSumIncludedCAM : CAMInfoList){
                    if(MINTYPE_FIXED == priceInfo.GPOnTopSection.PricingSection.MinType) {
                        Double price = priceInfo.GPOnTopSection.PricingSection.FixedPricing.Price;
                        Double priceIntegration = (priceInfo.IsIncludeCAM) ? price-eachSumIncludedCAM.CAMPrice : price;
                        Double pricewithoutVat = 0;
                        Double priceVat = 0;
                        if (uiWrapper.isWindowDisplay) {
                            pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                            priceVat = price;
                        }

                        OpportunityPrice__c oppPrice = new OpportunityPrice__c();
                        oppPrice.Opportunity__c = oppId;
                        oppPrice.OpportunityPeriod__c = priceInfo.Id;
                        oppPrice.From__c = eachSumIncludedCAM.ValidFrom;
                        oppPrice.To__c = eachSumIncludedCAM.ValidTo;
                        oppPrice.PriceVAT__c = (uiWrapper.isWindowDisplay)?priceVat : 0;
                        oppPrice.VAT__c = (uiWrapper.isWindowDisplay)?priceVat - pricewithoutVat : 0;
                        oppPrice.Price__c = (uiWrapper.isWindowDisplay)?pricewithoutVat:price;
                        oppPrice.TotalPrice__c = (uiWrapper.isWindowDisplay)?pricewithoutVat:price;
                        oppPrice.TotalPriceVAT__c = (uiWrapper.isWindowDisplay)?price:0;
                        oppPrice.CalculationMethod__c = priceInfo.CalculationMethod;
                        oppPrice.MeasurementAmount__c = priceInfo.TotalArea;
                        oppPriceList.add(oppPrice);
                    } else {
                        OpportunityPrice__c oppPrice = new OpportunityPrice__c();
                        oppPrice.Opportunity__c = oppId;
                        oppPrice.OpportunityPeriod__c = priceInfo.Id;
                        oppPrice.From__c = priceInfo.PricingFrom;
                        oppPrice.To__c = priceInfo.PricingTo;
                        oppPrice.Price__c = 0;
                        oppPrice.PriceVAT__c = 0;
                        oppPrice.VAT__c = 0;
                        oppPrice.TotalPrice__c = 0;
                        oppPrice.TotalPriceVAT__c = 0;
                        oppPrice.CalculationMethod__c = priceInfo.CalculationMethod;
                        oppPrice.MeasurementAmount__c = priceInfo.TotalArea;
                        oppPriceList.add(oppPrice);
                    }
                }
            }
            return oppPriceList;
        } else {
            Map<Date, IncludedCAMInfoByMeasurement> CAMPeriodMapByMeasurement = new Map<Date, IncludedCAMInfoByMeasurement>();
            List<IncludedCAMInfo> includedCAMInfoList = includedCAMInfoMapByPeriod.get(priceInfo.PeriodNumber);
            for(IncludedCAMInfo includedCAMInfo : includedCAMInfoList) {
                if(!CAMPeriodMapByMeasurement.containsKey(includedCAMInfo.ValidFrom)) {
                    CAMPeriodMapByMeasurement.put(includedCAMInfo.ValidFrom, new IncludedCAMInfoByMeasurement(
                                                                                includedCAMInfo.ValidFrom,
                                                                                includedCAMInfo.ValidTo,
                                                                                new Map<String, Double>{ includedCAMInfo.MeasurementCode => includedCAMInfo.CAMUnitPrice }));
                } else {
                    CAMPeriodMapByMeasurement.get(includedCAMInfo.ValidFrom).CAMUnitPriceMap.put(includedCAMInfo.MeasurementCode, includedCAMInfo.CAMUnitPrice);
                }
            }

            for(QuotationComponentDataWrapper.MeasurementPricingList measurementPricing : priceInfo.GPOnTopSection.PricingSection.MeasumentPricingList) {
                if(priceInfo.isToDeleteRecord) { continue; }
                // if only one included cam
                //if(isIncludedCAMList.size() == 1){ continue;}

                Double price = Double.valueOf(measurementPricing.Price.value);
                Double pricewithoutVat = 0;
                Double priceVat = 0;
                if (uiWrapper.isWindowDisplay) {
                    pricewithoutVat = ((price*100)/(100+vatPercent)).setScale(2);
                    priceVat = price;
                }

                for(Date CAMkey : CAMPeriodMapByMeasurement.keySet()) {
                    Double priceIntegration = (priceInfo.IsIncludeCAM)? price-CAMPeriodMapByMeasurement.get(CAMkey).CAMUnitPriceMap.get(measurementPricing.MeasurementType) : price;
                    OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                        Opportunity__c = oppId,
                        OpportunityPeriod__c = priceInfo.Id,
                        From__c = CAMPeriodMapByMeasurement.get(CAMkey).ValidFrom,
                        To__c = CAMPeriodMapByMeasurement.get(CAMkey).ValidTo,
                        Measurement__c = measurementPricing.roMeasurementId,
                        PriceVAT__c = (uiWrapper.isWindowDisplay)?priceVat : 0,
                        VAT__c = (uiWrapper.isWindowDisplay)?priceVat - pricewithoutVat : 0,
                        Price__c = (uiWrapper.isWindowDisplay)?pricewithoutVat:Double.valueOf(measurementPricing.Price.value),
                        TotalPrice__c = ((uiWrapper.isWindowDisplay)? (measurementPricing.Area * pricewithoutVat) : (measurementPricing.Area * (measurementPricing.Price.value).setScale(2))),
                        TotalPriceVAT__c = ((uiWrapper.isWindowDisplay)?measurementPricing.Area * priceVat : 0),
                        MeasurementAmount__c = measurementPricing.Area,
                        CalculationMethod__c = priceInfo.CalculationMethod,
                        PriceItem__c = measurementPricing.MeasurementType,
                        Unit__c = measurementPricing.roId,
                        MeasurementType__c = measurementPricing.measurementId
                    );
                    String key = oppPrice.Opportunity__c + '_' + oppPrice.OpportunityPeriod__c + '_' + oppPrice.Measurement__c + '_' + oppPrice.From__c;
                    if(oppPriceMap.containsKey(key)) { continue; }
                    oppPriceMap.put(key, oppPrice);
                }
            }

            if(depositMeasurementList != null) {
                Date lastValidFrom = new List<Date>(CAMPeriodMapByMeasurement.keySet())[CAMPeriodMapByMeasurement.keySet().size()-1];

                for(OpportunityPrice__c oppPrice : oppPriceMap.values()) {
                    if(oppPrice.From__c == lastValidFrom && oppPrice.Price__c != 0
                        && (oppPrice.SubType__c == Constant.TYPE_RENT || oppPrice.SubType__c == Constant.TYPE_SERVICE)) {
                        DepositMeasurementModel.Data depositMeasurement = generateDepositMeasurement(oppPrice.Opportunity__c, oppPrice.SubType__c, oppPrice.Price__c, oppPrice.Measurement__c);
                        depositMeasurementList.add(depositMeasurement);
                    }
                }
            }
            return oppPriceMap.values();
        }
    }

	/**
	 * CR Feb 2025
	 */
    private List<OpportunityPrice__c> assignProportion(QuotationComponentDataWrapper.PeriodPricing priceInfo, List<OpportunityPrice__c> oppPriceList) {
        List<OpportunityPrice__c> result = new List<OpportunityPrice__c>();
        for(OpportunityPrice__c oppPrice : oppPriceList) {
            OpportunityPrice__c rent = oppPrice.clone(false, false, false, false);
            rent.SubType__c = Constant.TYPE_RENT;
            rent.ProportionPercent__c = priceInfo.Proportion.Rent;
            rent.Price__c = ((oppPrice.Price__c.setScale(2) * priceInfo.Proportion.Rent.setScale(2)) / 100).setScale(2);
            rent.PriceVAT__c = (oppPrice.PriceVAT__c>0)?(((oppPrice.PriceVAT__c.setScale(2) * priceInfo.Proportion.Rent.setScale(2)) / 100).setScale(2)):0;
            rent.VAT__c = (oppPrice.VAT__c>0)?(oppPrice.PriceVAT__c-oppPrice.Price__c):0;
            rent.TotalPrice__c = ((oppPrice.TotalPrice__c.setScale(2) * priceInfo.Proportion.Rent.setScale(2)).setScale(2) / 100).setScale(2);
            rent.TotalPriceVAT__c = ((oppPrice.TotalPriceVAT__c.setScale(2) * priceInfo.Proportion.Rent.setScale(2)).setScale(2) / 100).setScale(2);
            rent.MeasurementAmount__c = oppPrice.MeasurementAmount__c;
			/**
			 * CR Feb 2025
			 * Changed Detail: assign new field values
			 */
			//
			//
			//
			// Changed end
            result.add(rent);

            OpportunityPrice__c service = oppPrice.clone(false, false, false, false);
            service.SubType__c = Constant.TYPE_SERVICE;
            service.ProportionPercent__c = priceInfo.Proportion.Service;
            service.Price__c = ((oppPrice.Price__c.setScale(2) * priceInfo.Proportion.Service.setScale(2)).setScale(2) / 100).setScale(2);
            service.PriceVAT__c = (oppPrice.PriceVAT__c>0)?(((oppPrice.PriceVAT__c.setScale(2) * priceInfo.Proportion.Service.setScale(2)).setScale(2) / 100).setScale(2)):0;
            service.VAT__c = (oppPrice.VAT__c>0)?(oppPrice.PriceVAT__c-oppPrice.Price__c):0;
            service.TotalPrice__c = ((oppPrice.TotalPrice__c.setScale(2) * priceInfo.Proportion.Service.setScale(2)).setScale(2) / 100).setScale(2);
            service.TotalPriceVAT__c = ((oppPrice.TotalPriceVAT__c.setScale(2) * priceInfo.Proportion.Service.setScale(2)).setScale(2) / 100).setScale(2);
            service.MeasurementAmount__c = oppPrice.MeasurementAmount__c;
			/**
			 * CR Feb 2025
			 * Changed Detail: assign new field values
			 */
			//
			//
			//
			// Changed end
            result.add(service);
        }
        return result;
    }

    //sapMasterMap
    public void processOtherExpense(Id oppId, QuotationComponentDataWrapper.OppUIWrapper uiWrapper, QuotationComponentDataWrapper.OtherWrapper otherExpense) {
        String contractType = getContractType(oppId);
        Set<String> otherDepositExpenseKeySet = new Set<String>{'Exhaust System', 'Additional Request'};
        Boolean isHasOtherExpense = false;
        Decimal totalElectricity = 0;
        Decimal totalWater = 0;
        Decimal totalGas = 0;

        List<OpportunityDepositExpense__c> deleteOppDepositExpense = new List<OpportunityDepositExpense__c>();
        List<OpportunityPrice__c> deleteOppPrice = new List<OpportunityPrice__c>();

        Map<QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat, OpportunityDepositExpense__c> oppDepositWithRateAndAreaFormatMap = new Map<QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat, OpportunityDepositExpense__c>();
        Map<QuotationComponentDataWrapper.FixedOtherExpenseFormat, OpportunityDepositExpense__c> oppDepositWithFixedFormatMap = new Map<QuotationComponentDataWrapper.FixedOtherExpenseFormat, OpportunityDepositExpense__c>();
        Map<QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat, OpportunityPrice__c> oppPriceWithRateAndAreaFormatMap = new Map<QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat, OpportunityPrice__c>();
        Map<QuotationComponentDataWrapper.FixedOtherExpenseFormat, OpportunityPrice__c> oppPriceWithFixedFormatMap = new Map<QuotationComponentDataWrapper.FixedOtherExpenseFormat, OpportunityPrice__c>();

        Decimal totalElectric = totalWater = totalGas = 0;
        Decimal electricRate = 0;
        Decimal waterRate = 0;
        Decimal gasRate = 0;

        for(QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat rateAndAreaFormat : otherExpense.rateAndAreaFormatList) {
            if(rateAndAreaFormat.isToDeleteRecord) {
                if(rateAndAreaFormat.depositExpenseId != null && rateAndAreaFormat.oppPriceId != null) {
                    deleteOppDepositExpense.add(new OpportunityDepositExpense__c(Id = rateAndAreaFormat.depositExpenseId));
                    deleteOppPrice.add(new OpportunityPrice__c(Id = rateAndAreaFormat.oppPriceId));
                }
            } else {
                OpportunityDepositExpense__c oppDepositExpense = new OpportunityDepositExpense__c(
                    Id = rateAndAreaFormat.depositExpenseId,
                    Opportunity__c = oppId,
                    TypeGroup__c = rateAndAreaFormat.TypeGroup,
                    Type__c = rateAndAreaFormat.Type,
                    SubType__c = rateAndAreaFormat.SubType,
                    Price__c = rateAndAreaFormat.Total,
                    Remark__c = rateAndAreaFormat.Remark,
                    HasRemark__c = String.isBlank(rateAndAreaFormat.Remark)? false : true
                );
                oppDepositWithRateAndAreaFormatMap.put(rateAndAreaFormat, oppDepositExpense);

                OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                    Id = rateAndAreaFormat.oppPriceId,
                    Opportunity__c = oppId,
                    From__c = uiWrapper.contractStartDateForm,
                    To__c = uiWrapper.contractEndDateFrom,
                    SubType__c = rateAndAreaFormat.SubType,
                    Price__c = rateAndAreaFormat.Total.setScale(2),
                    Area__c = rateAndAreaFormat.Area,
                    Rate__c = rateAndAreaFormat.Rate
                );
                oppPriceWithRateAndAreaFormatMap.put(rateAndAreaFormat, oppPrice);

                if(rateAndAreaFormat.Type == 'Electric') {
                    totalElectric = rateAndAreaFormat.Total;
                    electricRate = rateAndAreaFormat.Rate;
                } else if(rateAndAreaFormat.Type == 'Water') {
                    totalWater = rateAndAreaFormat.Total;
                    waterRate = rateAndAreaFormat.Rate;
                } else if(rateAndAreaFormat.Type == 'Gas') {
                    totalGas = rateAndAreaFormat.Total;
                    gasRate = rateAndAreaFormat.Rate;
                }
            }
        }

        for(QuotationComponentDataWrapper.FixedOtherExpenseFormat fixedFormat : otherExpense.fixedFormatList) {
            if(fixedFormat.isToDeleteRecord) {
                if(fixedFormat.depositExpenseId != null && fixedFormat.oppPriceId != null) {
                    deleteOppDepositExpense.add(new OpportunityDepositExpense__c(Id = fixedFormat.depositExpenseId));
                    deleteOppPrice.add(new OpportunityPrice__c(Id = fixedFormat.oppPriceId));
                }
            } else {
                OpportunityDepositExpense__c oppDepositExpense = new OpportunityDepositExpense__c(
                    Id = fixedFormat.depositExpenseId,
                    Opportunity__c = oppId,
                    TypeGroup__c = fixedFormat.TypeGroup,
                    Type__c = fixedFormat.Type,
                    Price__c = fixedFormat.Monthly,
                    Remark__c = fixedFormat.Remark,
                    HasRemark__c = String.isBlank(fixedFormat.Remark)? false : true
                );
                oppDepositWithFixedFormatMap.put(fixedFormat, oppDepositExpense);

                System.debug('rateAndAreaFormat.Type' + fixedFormat.Type);
                if (otherDepositExpenseKeySet.contains(fixedFormat.Type)) {
                    isHasOtherExpense = true;
                    System.debug('isHasOtherExpense' + isHasOtherExpense);
                }

                OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                    Id = fixedFormat.oppPriceId,
                    Opportunity__c = oppId,
                    From__c = uiWrapper.contractStartDateForm,
                    To__c = uiWrapper.contractEndDateFrom,
                    Price__c = fixedFormat.Monthly.setScale(2)
                );
                oppPriceWithFixedFormatMap.put(fixedFormat, oppPrice);
            }
        }

        if(deleteOppPrice.size() > 0) delete deleteOppPrice;
        if(deleteOppDepositExpense.size() > 0) delete deleteOppDepositExpense;

        upsert oppDepositWithRateAndAreaFormatMap.values();
        upsert oppDepositWithFixedFormatMap.values();

        for(QuotationComponentDataWrapper.RateAndAreaOtherExpenseFormat key : oppPriceWithRateAndAreaFormatMap.keySet()) {
            oppPriceWithRateAndAreaFormatMap.get(key).OpportunityDepositExpense__c = oppDepositWithRateAndAreaFormatMap.get(key).Id;
        }

        for(QuotationComponentDataWrapper.FixedOtherExpenseFormat key : oppPriceWithFixedFormatMap.keySet()) {
            oppPriceWithFixedFormatMap.get(key).OpportunityDepositExpense__c = oppDepositWithFixedFormatMap.get(key).Id;
        }
        system.debug('oppPriceWithRateAndAreaFormatMap : '+oppPriceWithRateAndAreaFormatMap);
        system.debug('oppPriceWithFixedFormatMap : '+oppPriceWithFixedFormatMap);

        upsert oppPriceWithRateAndAreaFormatMap.values();
        upsert oppPriceWithFixedFormatMap.values();

        Opportunity opp = new Opportunity(Id = oppId,
                                          HasOtherExpense__c = isHasOtherExpense,
                                          Monthly_Electricity__c = totalElectric,
                                          Monthly_Water__c = totalWater,
                                          Monthly_Gas__c = totalGas,
                                          Electricity_Per_Unit__c = electricRate,
                                          Water_Per_Unit__c = waterRate,
                                          Gas_Per_Unit__c = gasRate,
                                          Is_Period_Date_Changed__c = uiWrapper.isRenewChangeOppPeriod);

        System.debug('opp to update' + opp);
        update opp;
    }

    public void processExpenseAndFee(Id oppId, List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList, QuotationComponentDataWrapper.OppUIWrapper uiWrapper) {
        String contractType = getContractType(oppId);
        Set<String> selectedTypeSet = new Set<String>{'Expense'};
        Set<String> hasFirstEntryFeeSet = new Set<String>{'First Entry Fee'};
        Set<String> hasLeaseHoldSet = new Set<String>{'ค่าสิทธิการเช่า Footprint','ค่าสิทธิการเช่า Mezzanine','ค่าสิทธิการเช่า Kitchen'};
        Set<String> hasConstructionSupportFeeSet = new Set<String>{'เงินช่วยค่าก่อสร้าง'};
        Boolean hasFirstEntryFee = false;
        Boolean hasLeaseHold = false;
        Boolean hasConstructionSupportFee = false;

        List<OpportunityDepositExpense__c> updateOppDepositExpenseList = new List<OpportunityDepositExpense__c>();
        List<OpportunityDepositExpense__c> deleteOppDepositExpenseList = new List<OpportunityDepositExpense__c>();
        List<OpportunityPrice__c> deleteOppPriceList = new List<OpportunityPrice__c>();
        List<OpportunityLeaseholdFloorModel.Data> deleteLeaseHoldFloor = new List<OpportunityLeaseholdFloorModel.Data>();
        Map<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper, OpportunityDepositExpense__c> expenseAndFeeHeaderMap = new Map<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper, OpportunityDepositExpense__c>();
        QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper leaseHoldSummayExpense;

        for(QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper expenseAndFee : expenseAndFeeList) {
            if(expenseAndFee.isToDeleteRecord) {
                if(expenseAndFee.Id != null) { deleteOppDepositExpenseList.add(new OpportunityDepositExpense__c(Id = expenseAndFee.Id)); }

                for(QuotationComponentDataWrapper.InstallmentWrapper installment : expenseAndFee.InstallmentList) {
                    System.debug('installment : ' + installment);
                    if(installment.Id != null) { deleteOppPriceList.add(new OpportunityPrice__c(Id = installment.Id)); }
                }

                if (expenseAndFee.isLEASEHOLD) {
                    for(QuotationComponentDataWrapper.LeaseHoldFloorInfoTable leaseHoldFloor : expenseAndFee.leaseHoldInfo){
                        OpportunityLeaseholdFloorModel.Data temp = new OpportunityLeaseholdFloorModel.Data();
                        temp.Id = leaseHoldFloor.Id;
                        if(leaseHoldFloor.Id != null) { deleteLeaseHoldFloor.add(temp); }
                    }
                }

                continue;
            }

            expenseAndFeeHeaderMap.put(expenseAndFee, new OpportunityDepositExpense__c(
                Id = expenseAndFee.Id,
                Opportunity__c = oppId,
                TypeGroup__c = expenseAndFee.TypeGroup,
                Type__c = expenseAndFee.Type,
                Price__c = expenseAndFee.TotalAmount,
                NumberOfInstallment__c = expenseAndFee.NumberOfInstallment,
                Remark__c = expenseAndFee.Remark
            ));

            if(expenseAndFee.isLEASEHOLDSUMMARY){
                leaseHoldSummayExpense = expenseAndFee;
            }

            if (hasFirstEntryFeeSet.contains(expenseAndFee.Type)) {
                hasFirstEntryFee = true;
            }

            if (hasLeaseHoldSet.contains(expenseAndFee.Type)) {
                hasLeaseHold = true;
            }

            if (hasConstructionSupportFeeSet.contains(expenseAndFee.Type)) {
                hasConstructionSupportFee = true;
            }
        }

        Opportunity updateOpp = new Opportunity(
            Id = oppId,
            HasFirstEntryFee__c = hasFirstEntryFee,
            HasLeaseHold__c = hasLeaseHold,
            HasConstructionSupportFee__c = hasConstructionSupportFee,
            Is_Period_Date_Changed__c = uiWrapper.isRenewChangeOppPeriod
        );
        //update updateOpp;
        upsert expenseAndFeeHeaderMap.values();

        List<OpportunityLeaseholdFloorModel.Data> oppLeaseHold  = new List<OpportunityLeaseholdFloorModel.Data>();
        List<OpportunityDepositExpense__c> expenseAndFeeToUpdate = new List<OpportunityDepositExpense__c>();

        System.debug('expenseAndFeeHeaderMap' + expenseAndFeeHeaderMap);
        if (!expenseAndFeeHeaderMap.isEmpty()) {
            for(QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper expenseAndFee : expenseAndFeeList){
                if(expenseAndFee.isLEASEHOLD && !expenseAndFee.isToDeleteRecord){
                    expenseAndFeeHeaderMap.get(expenseAndFee).OpportunityDepositExpense__c = expenseAndFeeHeaderMap.get(leaseHoldSummayExpense).Id;
                    expenseAndFeeToUpdate.add(expenseAndFeeHeaderMap.get(expenseAndFee));
                    for (QuotationComponentDataWrapper.LeaseHoldFloorInfoTable eachLeaseHoldFloor : expenseAndFee.leaseHoldInfo ) {
                        OpportunityLeaseholdFloorModel.Data temp = new OpportunityLeaseholdFloorModel.Data();
                        temp.Id = eachLeaseHoldFloor.Id;
                        temp.Floor = eachLeaseHoldFloor.floorName;
                        temp.OpportunityDepositExpense = expenseAndFeeHeaderMap.get(expenseAndFee).Id;
                        temp.PricePerSqm = eachLeaseHoldFloor.price;
                        temp.Area = eachLeaseHoldFloor.area;
                        temp.TotalPrice = eachLeaseHoldFloor.totalAmount;
                        temp.BuildingFloor = eachLeaseHoldFloor.floorId;
                        temp.Measurement = eachLeaseHoldFloor.measurementId;
                        temp.Opportunity = oppId;
                        oppLeaseHold.add(temp);
                    }
                }
            }
        }
        if(!expenseAndFeeToUpdate.isEmpty()) update expenseAndFeeToUpdate;
        if(!oppLeaseHold.isEmpty()) {
            updateOpp.OpportunityLeaseholdFloor__c = OpportunityLeaseholdFloorModel.toString(oppLeaseHold);
            //upsert oppLeaseHold;
        } else {
            updateOpp.OpportunityLeaseholdFloor__c = '[]';
        }

        List<OpportunityPrice__c> fullAndAmortizedPriceList = OpportunitySelector.getFullAndAmortizedPriceByOppId(new Set<Id> {oppId});
        if(fullAndAmortizedPriceList != null && fullAndAmortizedPriceList.size() > 0) deleteOppPriceList.addAll(fullAndAmortizedPriceList);

        Date expenseValidFrom = uiWrapper.contractStartDateForm;
        List<OpportunityPrice__c> upsertOppPriceList = new List<OpportunityPrice__c>();

        if(leaseHoldSummayExpense != null){
            for(QuotationComponentDataWrapper.InstallmentWrapper installment : leaseHoldSummayExpense.InstallmentList) {
                if(leaseHoldSummayExpense.isToDeleteRecord || installment.isToDeleteRecord) {
                    if(installment.Id != null) { deleteOppPriceList.add(new OpportunityPrice__c(Id = installment.Id)); }
                    continue;
                }
                OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                    Id = installment.Id,
                    Opportunity__c = oppId,
                    PaymentDueDate__c = installment.PaymentDueDate,
                    From__c = expenseValidFrom,
                    To__c = expenseValidFrom,
                    Price__c = Double.valueOf(installment.InstallmentAmount),
                    TotalPrice__c = Double.valueOf(installment.InstallmentAmount),
                    OpportunityDepositExpense__c = expenseAndFeeHeaderMap.get(leaseHoldSummayExpense).Id,
                    SubType__c = TYPE_INSTALLMENT,
                    Installment__c = Integer.valueOf(installment.InstallmentNumber),
                    Remark__c = installment.remark
                );
                upsertOppPriceList.add(oppPrice);
                expenseValidFrom = expenseValidFrom.addDays(1);
            }
        }
        // generate rent right

        Decimal cableAmount = 0;
        Decimal otherAmount = 0;
        Decimal generateBillboard = 0;
        Decimal installBillboard = 0;
        for(QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper expenseAndFee : expenseAndFeeHeaderMap.keySet()) {
            if (expenseAndFee.Type != 'Summary สิทธิการเช่า') {
                System.debug('expenseAndFee : ' + expenseAndFee);
                for(QuotationComponentDataWrapper.InstallmentWrapper installment : expenseAndFee.InstallmentList) {
                    System.debug('installment : ' + installment);
                    if(expenseAndFee.isToDeleteRecord || installment.isToDeleteRecord) {
                        if(installment.Id != null) { deleteOppPriceList.add(new OpportunityPrice__c(Id = installment.Id)); }
                        continue;
                    }

                    OpportunityPrice__c oppPrice = new OpportunityPrice__c(
                        Id = installment.Id,
                        Opportunity__c = oppId,
                        PaymentDueDate__c = installment.PaymentDueDate,
                        From__c = expenseValidFrom,
                        To__c = expenseValidFrom,
                        Price__c = Double.valueOf(installment.InstallmentAmount),
                        TotalPrice__c = Double.valueOf(installment.InstallmentAmount),
                        OpportunityDepositExpense__c = expenseAndFeeHeaderMap.get(expenseAndFee).Id,
                        SubType__c = TYPE_INSTALLMENT,
                        Installment__c = Integer.valueOf(installment.InstallmentNumber),
                        Remark__c = installment.remark
                    );
                    upsertOppPriceList.add(oppPrice);
                    expenseValidFrom = expenseValidFrom.addDays(1);

                    if(expenseAndFee.Type == 'ค่าให้บริการพื้นที่สำหรับลากสายโทรศัพท์') {
                        cableAmount += Double.valueOf(installment.InstallmentAmount);
                    } else if(expenseAndFee.Type == 'ค่าผลิตป้าย') {
                        generateBillboard += Double.valueOf(installment.InstallmentAmount);
                    } else if(expenseAndFee.Type == 'ค่าติดตั้งป้าย') {
                        installBillboard += Double.valueOf(installment.InstallmentAmount);
                    } else {
                        otherAmount += Double.valueOf(installment.InstallmentAmount);
                    }
                }
            }
        }
        System.debug('deleteOppPriceList' + deleteOppPriceList);
        System.debug('deleteOppDepositExpenseList' + deleteOppDepositExpenseList);

        updateOpp.Generate_Billboard_Amount__c = generateBillboard;
        updateOpp.Install_Billboard_Amount__c = installBillboard;
        updateOpp.Internet_cable__c = cableAmount;
        updateOpp.Total_Other_Expense_Amount_THB__c = otherAmount;
        update updateOpp;

        if(deleteOppPriceList.size() > 0) delete deleteOppPriceList;
        if(deleteOppDepositExpenseList.size() > 0) delete deleteOppDepositExpenseList;
        //if(deleteLeaseHoldFloor.size() > 0) delete deleteLeaseHoldFloor;

        upsert upsertOppPriceList;
    }

    public void stampOppName(Map<Id, SObject> oldMap, List<SObject> newRecords) {
        List<Opportunity> newOppList = (List<Opportunity>)newRecords;
        Set<Id> oppNameChangeIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> buildingIdSet = new Set<Id>();

        for(Opportunity newOpp : newOppList) {
            Opportunity oldOpp = oldMap != null && newOpp.Id != null ? (Opportunity)oldMap.get(newOpp.Id) : null;

            if(oldOpp == null || oldOpp.Building__c != newOpp.Building__c ||
                isRoomChange(oldOpp, newOpp) || isTotalAreaChange(oldOpp, newOpp)) {
                    oppNameChangeIdSet.add(newOpp.Id);
                    accountIdSet.add(newOpp.AccountId);
                    buildingIdSet.add(newOpp.Building__c);
            }
        }

        if(accountIdSet.isEmpty() || buildingIdSet.isEmpty()) { return; }
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: accountIdSet]);
        Map<Id, Building__c> buildingMap = new Map<Id, Building__c>(BuildingSelector.getBuildingInfoById(buildingIdSet));

        for(Opportunity newOpp : newOppList) {
            if(newOpp.Id != null && !oppNameChangeIdSet.contains(newOpp.Id)) { continue; }
            List<String> oppNameList = new List<String>();
            oppNameList.add(accountMap.get(newOpp.AccountId).Name);
            if(buildingMap.get(newOpp.Building__c) != null) oppNameList.add(buildingMap.get(newOpp.Building__c).Building_Abbreviated__c);
            if(newOpp.RoomNumber__c != null) oppNameList.add(newOpp.RoomNumber__c);
            if(newOpp.Total_Area_sq_m__c != null) oppNameList.add(String.valueOf(newOpp.Total_Area_sq_m__c.setScale(2))+CONSTANTS_SQUAREMETER);
            String tempOppName = String.join(oppNameList, '-');
            Integer oppMaxLength = Opportunity.Name.getDescribe().getLength() - 7;
            if(tempOppName.length() >= oppMaxLength) {
                tempOppName = tempOppName.substring(0, oppMaxLength - 1);
            }
            if(newOpp.CreatedDate != null) {
                tempOppName = tempOppName + '-' + newOpp.CreatedDate.format('YYYYMM');
            } else {
                tempOppName = tempOppName + '-' + Datetime.Now().format('YYYYMM');
            }
            newOpp.Name = tempOppName;
        }
    }

    private Boolean isRoomChange(Opportunity oldOpp, Opportunity newOpp) {
        return oldOpp.RoomNumber__c != newOpp.RoomNumber__c;
    }

    private Boolean isTotalAreaChange(Opportunity oldOpp, Opportunity newOpp) {
        return oldOpp.Total_Area_sq_m__c != newOpp.Total_Area_sq_m__c;
    }

    public void processClearPricingRecord(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) {
        if(oldMap != null && newMap != null){
            Set<Id> targetClearPriceOppIdSet = new Set<Id>();
            Set<Id> targetClearROOppIdSet = new Set<Id>();
            for(Id key : newMap.keySet()) {
                Opportunity oldOpp = (Opportunity)oldMap.get(key);
                Opportunity newOpp = (Opportunity)newMap.get(key);
                if(isClearPricingRecord(oldOpp, newOpp)) targetClearPriceOppIdSet.add(newOpp.Id);
            }
            if(!targetClearPriceOppIdSet.isEmpty()) clearPricingRecord(targetClearPriceOppIdSet);
        }
    }

    private Boolean isClearPricingRecord(Opportunity oldOpp, Opportunity newOpp) {
        Boolean isClear = false;
        if(newOpp.Parent_Contract__c != null) {
            isClear = oldOpp.Calculation_Method__c != newOpp.Calculation_Method__c;
        } else {
            isClear = oldOpp.Estimated_Contract_Start_Date__c != newOpp.Estimated_Contract_Start_Date__c
                      || oldOpp.Estimated_Contract_End_Date__c != newOpp.Estimated_Contract_End_Date__c
                      || oldOpp.Calculation_Method__c != newOpp.Calculation_Method__c
                      || oldOpp.OptionToRenewYear__c != newOpp.OptionToRenewYear__c
                      || oldOpp.OptionToRenewMonth__c != newOpp.OptionToRenewMonth__c;
        }
        System.debug('isClear: '+isClear);
        return isClear;
    }

    public void processResetSecurityDeposit(Map<Id, SObject> oldMap, List<SObject> newRecords){
        Set<Id> changeDepositMonthOppId  = new Set<Id>();
        if (newRecords != null) {
            for(SObject eachOpp : newRecords){
                Opportunity oldOpp = oldMap != null && eachOpp.Id != null ? (Opportunity)oldMap.get(eachOpp.Id) : null;
                Opportunity newOpp = newRecords != null  ? (Opportunity)eachOpp : null;
                if (oldOpp != null && newOpp != null) {
                    if (isDepositMonthChange(oldOpp,newOpp)) {
                        changeDepositMonthOppId.add(newOpp.Id);
                    }
                }
            }
            if (!changeDepositMonthOppId.isEmpty()) {
                List<OpportunityDepositExpense__c> oppExpenseToDelete = [SELECT Id FROM OpportunityDepositExpense__c
                                                                            WHERE Opportunity__c IN: changeDepositMonthOppId
                                                                            AND TypeGroup__c =: Constant.TYPE_DEPOSIT
                                                                            AND Type__c =: Constant.TYPE_SECURITY_DEPOSIT];

                List<OpportunityPrice__c> oppPriceToDelete = [SELECT Id FROM OpportunityPrice__c
                                                                 WHERE Opportunity__c IN: changeDepositMonthOppId
                                                                 AND OpportunityDepositExpense__c IN: oppExpenseToDelete
                                                                 AND TypeGroup__c =: Constant.TYPE_DEPOSIT
                                                                 AND DepositExpenseType__c =: Constant.TYPE_SECURITY_DEPOSIT];
                if (oppExpenseToDelete != null) {
                    if (oppPriceToDelete != null) {
                        delete oppPriceToDelete;
                    }
                    delete oppExpenseToDelete;
                }
            }
        }
    }

    private Boolean isDepositMonthChange(Opportunity oldOpp, Opportunity newOpp) {
        return oldOpp.Deposit_Month__c != newOpp.Deposit_Month__c;
    }

    public void processClearCAMDataWhenOppIsNoCAM(Map<Id, SObject> oldMap,List<SObject> newRecords){
        if (newRecords!= null) {
            List<Opportunity> newOppList = (List<Opportunity>)newRecords;
            if(newOppList.size() > 0){
                Set<Id> noCAMOppIdSet = new Set<Id>();
                Set<Id> recallCAMOppIdSet = new Set<Id>();
                for(Opportunity newOpp : newOppList){
                    Opportunity oldOpp = (oldMap != null && newOpp.Id != null) ? (Opportunity)oldMap.get(newOpp.Id) : null;
                    if (oldOpp != null && isNoCAMChange(oldOpp,newOpp) && newOpp.No_CAM__c) {
                        noCAMOppIdSet.add(newOpp.Id);
                    }else if(oldOpp != null && isNoCAMChange(oldOpp,newOpp) && !newOpp.No_CAM__c){
                        recallCAMOppIdSet.add(newOpp.Id);
                    }
                }

                if (!noCAMOppIdSet.isEmpty()) {
                    List<OpportunityPeriod__c> camPeriodToDelete = [SELECT Id
                                                                    FROM OpportunityPeriod__c
                                                                    WHERE Opportunity__c IN: noCAMOppIdSet AND (CalculationMethod__c =: Constant.CAL_METHOD_CAM OR CalculationMethod__c =: Constant.CAL_METHOD_AIR)];

                    List<OpportunityPrice__c> camPriceToDelete = [SELECT Id
                                                                    FROM OpportunityPrice__c
                                                                    WHERE Opportunity__c IN: noCAMOppIdSet AND OpportunityPeriod__c IN: camPeriodToDelete AND (CalculationMethod__c =: Constant.CAL_METHOD_CAM OR CalculationMethod__c =: Constant.CAL_METHOD_AIR)];

                    List<OpportunityPeriod__c> pricingPeriodToDelete  = [SELECT Id
                                                                        FROM OpportunityPeriod__c
                                                                        WHERE Opportunity__c IN: noCAMOppIdSet AND (CalculationMethod__c !=: Constant.CAL_METHOD_CAM OR CalculationMethod__c !=: Constant.CAL_METHOD_AIR)];

                    List<OpportunityPrice__c> oppPriceToDelete = [SELECT Id
                                                                FROM OpportunityPrice__c
                                                                WHERE Opportunity__c IN: noCAMOppIdSet AND OpportunityPeriod__c IN: pricingPeriodToDelete AND (CalculationMethod__c !=: Constant.CAL_METHOD_CAM OR CalculationMethod__c !=: Constant.CAL_METHOD_AIR)];

                    List<OpportunityDepositExpense__c> oppdepositToDelete = [SELECT Id
                                                                        FROM OpportunityDepositExpense__c
                                                                        WHERE Opportunity__c IN: noCAMOppIdSet AND Type__c =: Constant.TYPE_SECURITY_DEPOSIT AND TypeGroup__c =: Constant.TYPE_DEPOSIT ];

                    List<OpportunityPrice__c> securityDepositInstalmentToDelete = [SELECT Id
                                                                                    FROM OpportunityPrice__c
                                                                                    WHERE Opportunity__c IN: noCAMOppIdSet AND OpportunityDepositExpense__c IN: oppdepositToDelete AND TypeGroup__c =: Constant.TYPE_DEPOSIT AND DepositExpenseType__c =: Constant.TYPE_SECURITY_DEPOSIT];

                    Database.delete(oppPriceToDelete,false);
                    Database.delete(camPriceToDelete,false);
                    Database.delete(securityDepositInstalmentToDelete,false);
                    Database.delete(pricingPeriodToDelete,false);
                    Database.delete(camPeriodToDelete,false);
                    Database.delete(oppdepositToDelete,false);
                }

                if(!recallCAMOppIdSet.isEmpty()){
                    List<OpportunityPeriod__c> pricingPeriodToDelete  = [SELECT Id
                                                                        FROM OpportunityPeriod__c
                                                                        WHERE Opportunity__c IN: recallCAMOppIdSet AND (CalculationMethod__c !=: Constant.CAL_METHOD_CAM OR CalculationMethod__c !=: Constant.CAL_METHOD_AIR)];

                    List<OpportunityPrice__c> oppPriceToDelete = [SELECT Id
                                                                    FROM OpportunityPrice__c
                                                                    WHERE Opportunity__c IN: recallCAMOppIdSet AND OpportunityPeriod__c IN: pricingPeriodToDelete AND (CalculationMethod__c !=: Constant.CAL_METHOD_CAM OR CalculationMethod__c !=: Constant.CAL_METHOD_AIR)];

                    List<OpportunityDepositExpense__c> oppdepositToDelete = [SELECT Id
                                                                        FROM OpportunityDepositExpense__c
                                                                        WHERE Opportunity__c IN: recallCAMOppIdSet AND Type__c =: Constant.TYPE_SECURITY_DEPOSIT AND TypeGroup__c =: Constant.TYPE_DEPOSIT ];

                    List<OpportunityPrice__c> securityDepositInstalmentToDelete = [SELECT Id
                                                                                    FROM OpportunityPrice__c
                                                                                    WHERE Opportunity__c IN: recallCAMOppIdSet AND OpportunityDepositExpense__c IN: oppdepositToDelete AND TypeGroup__c =: Constant.TYPE_DEPOSIT AND DepositExpenseType__c =: Constant.TYPE_SECURITY_DEPOSIT];

                    Database.delete(oppPriceToDelete,false);
                    Database.delete(securityDepositInstalmentToDelete,false);
                    Database.delete(pricingPeriodToDelete,false);
                    Database.delete(oppdepositToDelete,false);
                }
            }
        }
    }

    private Boolean isNoCAMChange(Opportunity oldOpp, Opportunity newOpp) {
        return oldOpp.No_CAM__c != newOpp.No_CAM__c;
    }
}