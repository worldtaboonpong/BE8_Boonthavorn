global class QuotationComponentDataWrapper {
    global class RentalObjectClass {
        public String id;
        public Boolean isToDeleteRecord;
        public String roCode;
        public String oppLineId;
        public String roomNumber;
        public String floor;
        public String floorShortName;
        public Decimal totalArea;
        public String usageType;
        public String roType;
        public String roTypeLabel;
        public Boolean availableForSale;
        public Date validForm;
        public String meter;
        public Decimal leasableArea;
        public Decimal measurement;
        public Date validTo;
        public Boolean occupied;
        public List<ROMeasurementClass> roMeasurmentList;
        public List<ROMeterClass> roMeterList;
        public String requestHeader;
        public String currentAccount;
        public String currentContract;
        public Boolean isContracted;
        public Date contractEndDate;
        public String floorId;
        public String locationOnFloorId;
        public String locationOnFloor;
        public Boolean isRetailZone;
        public String usageTypeId;
        public Boolean isSubLease;
        public String buildingId;
        public String buildingName;
        public String currentShopname;
        public String currentContractIdLink;
        public Decimal oppLineTotalArea;
        public Decimal oppLineLeasableArea;
        public String requestName;
        public String selectedROURL;
        public String lastContractURL;
        public String lastContractId;
        public String lastContractName;
        public String lastContractAccountName;
        public String lastContractShopName;
        public String lastContractEndDate;
        public String lastContractStartDate;

        public RentalObjectClass(
            String id,
            String roomNumber,
            String floor,
            Decimal totalArea,
            String usageType,
            Boolean availableForSale,
            Date validForm,
            String meter,
            Decimal leasableArea,
            Decimal measurement,
            Date validTo,
            Boolean occupied,
            List<ROMeasurementClass> roMeasurmentList,
            List<ROMeterClass> roMeterList,
            Boolean isContracted,
            String currentAccount,
            String currentContract,
            Date contractEndDate,
            String requestHeader,
            String floorId,
            String locationOnFloorId,
            String locationOnFloor,
            Boolean isRetailZone,
            String usageTypeId,
            Boolean isSubLease,
            String buildingId,
            String buildingName
        ) {
            this.id = (id != null) ? id : '';
            this.roomNumber = (roomNumber != null) ? roomNumber : ' ';
            this.floor = (floor != null) ? floor : ' ';
            this.totalArea = (totalArea != null) ? totalArea : 0;
            this.usageType = (usageType != null) ? usageType : ' ';
            this.availableForSale = (availableForSale != null) ? availableForSale : true;
            this.validForm = (validForm != null) ? validForm : null;
            this.meter = (meter != null) ? meter : ' ';
            this.leasableArea = (leasableArea != null) ? leasableArea : 0;
            this.measurement = (measurement != null) ? measurement : 0;
            this.validTo = (validTo != null) ? validTo : null;
            this.occupied = (occupied != null) ? occupied : false;
            this.roMeasurmentList = (roMeasurmentList != null) ? roMeasurmentList : new List<ROMeasurementClass>();
            this.roMeterList = (roMeterList != null) ? roMeterList : new List<ROMeterClass>();
            this.requestHeader = requestHeader;
            this.currentAccount = currentAccount;
            this.currentContract = currentContract;
            this.isContracted = isContracted;
            this.contractEndDate = contractEndDate;
            this.floorId = (floorId != null) ? floorId : '';
            this.locationOnFloorId = (locationOnFloorId != null) ? locationOnFloorId : '';
            this.locationOnFloor = (locationOnFloor != null) ? locationOnFloor : '';
            this.isRetailZone = (isRetailZone != null) ? isRetailZone : false;
            this.usageTypeId = (usageTypeId != null) ? usageTypeId : '';
            this.isSubLease = (isSubLease != null) ? isSubLease : false;
            this.buildingId = (buildingId != null) ? buildingId : '';
            this.buildingName = (buildingName != null) ? buildingName : '';
            this.selectedROURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.id;
        }
    }

    global class ROMeasurementClass {
        public String measurementId;
        public String roMeasurementId;
        public String roId;
        public String roCode;
        public String measurementName;
        public String measurementCode;
        public Decimal measurementArea;
        public boolean isFOC;
        public Date validFrom;
        public Date validTo;
        public String id;

        public ROMeasurementClass(
            String measurementId,
            String measurementName,
            Decimal measurementArea,
            Boolean isFOC,
            Date validFrom,
            Date validTo,
            String id
        ) {
            this.measurementId = measurementId;
            this.measurementName = measurementName;
            this.measurementArea = measurementArea;
            this.isFOC = isFOC;
            this.validTo = validTo;
            this.validFrom = validFrom;
            this.id = id;
        }
    }

    global class ROMeterClass {
        public String id;
        public String name;
        public String rentalObjectId;
        public String measurementPoint;
        public String measurementPosition;
        public String meterType;
        public String meterTypeName;
        public Boolean isActive;
        public Date inactiveDate;

        public ROMeterClass(
            String id,
            String name,
            String rentalObjectId,
            String measurementPoint,
            String measurementPosition,
            String meterType,
            String meterTypeName,
            Boolean isActive,
            Date inactiveDate
        ) {
            this.id = id;
            this.name = name;
            this.rentalObjectId = rentalObjectId;
            this.measurementPoint = measurementPoint;
            this.measurementPosition = measurementPosition;
            this.meterType = meterType;
            this.meterTypeName = meterTypeName;
            this.isActive = isActive;
            this.inactiveDate = inactiveDate;
        }
    }

    global class OppUIWrapper {
        public Boolean isError;
        public String errorMessage;

        public String oppId;
        public String oppName;
        public String buildingName;
        public String buildingId;
        public String contractStartDate;
        public String contractEndate;
        public Decimal totalMeasurmentArea;
        public Decimal totalLeasableArea;
        public Decimal new_totalMeasurmentArea;
        public Decimal old_totalMeasurmentArea;
        public Decimal new_totalLeasableArea;
        public Decimal old_totalLeasableArea;
        public Date contractStartDateForm;
        public Date contractEndDateFrom;
        public Date renewStartDate;
        public Date renewEndDate;
        public String calculationMethod;
        public String rentType;
        public String contractType;
        public String contractTypeValue;
        public String leaseType;
        public String longleaseType;
        public String pricingType;
        public String camOrAirService;
        public String camOrAirEscalationType;
        public String original_Contract_CAMOrAirEscalationType;
        public Decimal camOrAirEscalationRate;
        public String rentServiceEscalationType;
        public Decimal rentServiiceEscalationRate;
        public String usageType;
        public Decimal optionToRenewYear;
        public Decimal optionToRenewMonth;
        public Decimal depositMonth;
        public String parentContractId;
        public Boolean isReadOnly;
        public Boolean optionToRenewWithPrince;
        public Boolean isRentedRO;
        public String floorNumber;
        public String roomNumber;
        public Decimal vatPercentValue;
        public Boolean isShowRentServicePriceWithVat;
        public Boolean isOwnCashier;
        public String recordtypeName;
        public Boolean isNoCAM;
        public Decimal totalRent;
        public Decimal totalService;
        public Boolean isRetailzone;
        public Boolean isWindowDisplay;
        public Boolean isAllowChangeOptionToRenew;
        public Boolean isRenew;
        public Boolean isAllowLongLeaseChangePeriod;
        public String oppStageName;
        public String oppSalesForCalculation;
        public Decimal totalQuotationPeriod;
        public String parentContractCAMOrAirService;
        public String depositRemarkTH;
        public String depositRemarkEN;
        public String quotationLanguage;
        public Boolean parentContractIsNoCAM;
        public List<String> spetialOtherTypePicklist;
        public String oppSupcategoryCode;
        public Map<String, Popupconfirmation> popupSetting;
        public Decimal paidDepositRent;
        public Decimal paidDepositService;
        public Decimal paidDepositCAM;
        public Boolean isMigration;
        public Boolean isGPYearlyTier;
        public Boolean isRenewChangeOppPeriod;
        public Decimal yearRange;
        public Decimal monthRange;
        public Date thirdYearOfPeriod;
        public Decimal defaultElectricity;
        public Decimal defaultWater;
        public Decimal defaultGas;

        public OppUIWrapper() {
        }

        public OppUIWrapper(
            String oppStage,
            String oppName,
            String buildingName,
            Date contractStartDate,
            Date contractEndate,
            Decimal totalMeasurmentArea,
            Decimal totalLeasableArea,
            String calculationMethod,
            String contractType,
            String camOrAirService,
            String camOrAirEscalationType,
            Decimal camOrAirEscalationRate,
            String rentServiceEscalationType,
            Decimal rentServiceEscalationRate,
            String usageType,
            Decimal optionToRenewYear,
            Decimal optionToRenewMonth,
            Decimal depositMonth,
            Id parentContractId,
            Boolean isOwnCashier
        ) {
            this.isError = false;
            Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
            String windowDisplayUsageType = OpportunitySetting__c.getInstance().UsageTypeRentWithVAT__c;
            this.vatPercentValue = vatPercent;

            this.oppStageName = oppStage;
            this.isReadOnly = (oppStage == Constant.OPP_STAGE_QUOTATIONPREPARATION) ? false : true;
            this.oppName = (oppName != null) ? oppName : 'Opportunity';
            this.buildingName = (buildingName != null) ? buildingName : ' ';
            this.contractStartDate = (contractStartDate != null) ? String.valueOf(contractStartDate) : ' ';
            this.contractEndate = (contractEndate != null) ? String.valueOf(contractEndate) : ' ';
            this.totalMeasurmentArea = (totalMeasurmentArea != null) ? totalMeasurmentArea : 0;
            this.totalLeasableArea = (totalLeasableArea != null) ? totalLeasableArea : 0;
            this.old_totalMeasurmentArea = this.totalMeasurmentArea;
            this.old_totalLeasableArea = this.totalLeasableArea;
            this.contractStartDateForm = contractStartDate;
            this.contractEndDateFrom = contractEndate;
            this.calculationMethod = calculationMethod;
            this.contractType = contractType;

            string[] splittString = (this.contractType != null) ? this.contractType.split(' ') : null;
            this.leaseType = (splittString != null) ? splittString[0] : null;
            this.pricingType = (splittString != null) ? splittString[1] : null;
            if (this.leaseType == 'Extra-Long-Term') {
                this.leaseType = 'Long-Term';
            }

            this.camOrAirService = (camOrAirService != null) ? camOrAirService : 'CAM';
            this.camOrAirEscalationType = camOrAirEscalationType;
            this.camOrAirEscalationRate = camOrAirEscalationRate;
            this.rentServiceEscalationType = rentServiceEscalationType;
            this.rentServiiceEscalationRate = rentServiceEscalationRate;
            this.usageType = usageType;
            this.optionToRenewYear = (optionToRenewYear != null) ? optionToRenewYear : 0;
            this.optionToRenewMonth = (optionToRenewMonth != null) ? optionToRenewMonth : 0;
            this.depositMonth = (depositMonth != null) ? depositMonth : 0;
            this.parentContractId = parentContractId;

            // String usageTypeToShowRentServiceWithVAT = OpportunitySetting__c.getInstance().UsageTypeRentwithVAT__c;
            //this.isShowRentServicePriceWithVat = (usageTypeToShowRentServiceWithVAT==usageType)?true:false;
            this.isShowRentServicePriceWithVat = false;
            this.isOwnCashier = (isOwnCashier == null) ? false : isOwnCashier;
            this.isWindowDisplay = (usageType != null) ? (usageType == windowDisplayUsageType) ? true : false : false;
            this.isAllowLongLeaseChangePeriod = (this.leaseType == 'Long-Term' &&
                this.parentContractId != null &&
                this.isRenew == true)
                ? true
                : false;
            //this.depositRemarkTH = OpportunitySetting__c.getInstance().DepositRemark_TH__c;
            //this.depositRemarkEN = OpportunitySetting__c.getInstance().DepositRemark_EN__c;
            this.popupSetting = new Map<String, Popupconfirmation>();
            this.popupSetting.put(
                'การลบ Rental Object',
                new Popupconfirmation('การลบ Rental Object', 'การลบ Rental Object', true, 'RO selection')
            );
            this.popupSetting.put(
                'การลบ GP ใน Period',
                new Popupconfirmation('การลบ GP ใน Period', 'การลบ GP ใน Period', true, 'Pricing')
            );
            this.popupSetting.put(
                'การลบ Other Deposit',
                new Popupconfirmation('การลบ Other Deposit', 'การลบ Other Deposit', true, 'Deposit')
            );
            this.popupSetting.put(
                'การลบ Pricing Period',
                new Popupconfirmation('การลบ Pricing Period', 'การลบ Pricing Period', true, 'Pricing')
            );
            this.popupSetting.put(
                'การลบ CAM Period',
                new Popupconfirmation('การลบ CAM Period', 'การลบ CAM Period', true, 'Pricing')
            );
            this.popupSetting.put(
                'การลบ Tier ของ GP',
                new Popupconfirmation('การลบ Tier ของ GP', 'การลบ Tier ของ GP', true, 'Pricing')
            );
            this.popupSetting.put('การลบ Other', new Popupconfirmation('การลบ Other', 'การลบ Other', true, 'Other'));
            this.popupSetting.put(
                'การลบ Expense and Fee',
                new Popupconfirmation('การลบ Expense and Fee', 'การลบ Expense and Fee', false, 'Expense and Fee')
            );
            this.popupSetting.put(
                'การลบ Installment',
                new Popupconfirmation('การลบ Installment', 'การลบ Installment', true, 'Deposit')
            );
        }
    }

    global class UINumberInputClass {
        public Decimal value;
        public Boolean IsDisabled;

        public UINumberInputClass(Decimal value, Boolean isDisabled) {
            this.value = value;
            this.IsDisabled = isDisabled;
        }
    }

    global class MeasurmentWrapper {
        public String oppPriceId;
        public Id RequestId;
        public Boolean isToDeleteRecord;
        public String roMeasurementId;
        public String MeasurementTypeCode;
        public String MeasurementType;
        public String measurementId;
        public Boolean isFOC;
        public UINumberInputClass Price;
        public Decimal MeasurementArea;
        public Decimal old_PriceIntegration;
        public Decimal old_TotalPriceIntegration;
    }

    //  CAM Section
    global class CAMPricingWrapper {
        // tms_Opportunity__c.tms_CAMOrAirEscalationType__c
        public Id oppId;
        public String CAMCondition;
        public String CAMOrAirService;
        // tms_Opportunity__c.tms_CAMOrAirEscalationRate__c
        public UINumberInputClass CAMEscationRate;
        public List<CAMYearPeriodWrapper> CAMYearPeriod;
        public List<CAMYearPeriodWrapper> CAMYearPeriod_Original_Contract;
        public Boolean isEnableButtonForChangeDate;
        public Boolean isEnableDatePriceForChangeDate;
        public Boolean isEnableEscalationTypeChangeDate;
        public Boolean isRequestOverYear;
        public Boolean isShowBulletText;
    }

    global class CAMYearPeriodWrapper {
        public Id Id;
        public Id RequestId;
        public Boolean isToDeleteRecord;
        public Boolean isEditRecord;
        public Date DateFrom;
        public Date DateTo;
        public Date old_DateFrom;
        public Date old_DateTo;
        public Integer Year;
        public Decimal TotalPrice;
        public Decimal old_TotalPrice;
        public Boolean IsDisableInput;
        public List<MeasurmentWrapper> CAMMeasurmentList;
        public Decimal TotalArea;
        public Boolean isRenewCAMPeriod;
        public Boolean isOptionToRenew;
        public Boolean isLockPeriod;
        public Boolean isStrikeThrough;
        public Boolean isAddBGColor;
    }

    //  ----------------------------------------

    // Rent service Section
    global class RentServicePricingWrapper {
        public String rentServicePeriodId;
        public Id RequestId;
        public String RentCondition;
        public UINumberInputClass RentServiceEscalationRate;
        public List<MeasurmentWrapper> RentServiceMeasurment;
        public List<RentalObjectClass> RentalObjectList;
        public Boolean isToDeleteRecord;
    }
    // ------------------------------------------

    //  Pricing Section
    global class PeriodPricing {
        public Id Id;
        public Id RequestId;
        public Boolean isEditRecord;
        public Boolean isToDeleteRecord;
        public Boolean isCustomPeriod;
        public Integer PeriodNumber;
        public Date PricingFrom;
        public Date PricingTo;
        public Date old_PricingFrom;
        public Date old_PricingTo;
        public String CalculationMethod;
        public String CalculationMethodLabel;
        public Boolean IsIncludeCAM;
        public Boolean IsAllSales;
        public Boolean OptionToRenew;
        public String escalationRemark;
        public Decimal TotalArea;
        public Decimal old_TotalArea;
        public Decimal RentMonth;
        public Decimal ServiceMonth;
        public FixedRentalObjectSectionWrapper FixedRentalObjectSection;
        public FixedPriceSectionWrapper FixedPriceSection;
        public FixedMeasurementSectionWrapper FixedMeasurementSection;
        public GPWithMinSectionWrapper GPWithMinSection;
        public GPNoMinSectionWrapper GPNoMinSection;
        public GPOnTopSectionWrapper GPOnTopSection;
        public ProportionWrapper Proportion;

        public Decimal EstimateRevernue;
        public Decimal EstimateGPRevernue;
    }

	/**
	 * CR Feb 2025
	 */
    global class FixedRentalObjectSectionWrapper {
        public List<RentalObjectPricingWrapper> rentalObjectList;
        public Decimal TotalArea;
        public Decimal TotalLeasableArea;
        public Decimal TotalPrice;
        public Decimal TotalPriceSQm;
        public Decimal TotalPrice_withOutVat;
        public Decimal TotalPriceSQm_withOutVat;
        public String MinType;
		/**
		 * CR Feb 2025
		 * Changed Detail: add more attribute
		 */
		//
		//
		//
		// Changed end
    }

	/**
	 * CR Feb 2025
	 */
    global class RentalObjectPricingWrapper {
        public String oppPriceId;
        public Id RequestId;
        public Boolean isToDeleteRecord;
        public String roId;
        public String roCode;
        public List<ROMeasurementClass> roMeasurementList;
        public String RentalObject;
        public Decimal TotalArea;
        public Decimal LeasableArea;
        public UINumberInputClass PriceSQM;
        public UINumberInputClass Price;
        public Decimal old_PriceIntegration;
        public Decimal old_TotalPriceIntegration;
        public Decimal PriceSQM_withoutVat;
        public Decimal Price_withoutVat;
		/**
		 * CR Feb 2025
		 * Changed Detail: add more attribute
		 */
		//
		//
		//
		// Changed end
    }

    global class FixedPriceSectionWrapper {
        public String oppPriceId;
        public Id RequestId;
        public Boolean isToDeleteRecord;
        public Decimal Price;
        public Decimal PriceSQM;
        public Decimal Price_withoutVat;
        public Decimal PriceSQM_withoutVat;
        public Decimal old_PriceIntegration;
        public Decimal old_TotalPriceIntegration;
        public Decimal TotalArea;
        public Boolean IsDisabled;
        public String MinType;
    }

    global class FixedMeasurementSectionWrapper {
        public List<MeasurementPricingList> pricingList;
        public Decimal TotalArea;
        public Decimal TotalLeasableArea;
        public Decimal TotalPrice;
        public Decimal TotalSummary;
        public Decimal TotalPrice_withoutVat;
        public Decimal TotalSummary_withoutVat;
    }

    global class MeasurementPricingList {
        public String oppPriceId;
        public Id RequestId;
        public Boolean isToDeleteRecord;
        public String roMeasurementId;
        public String measurementId;
        public String roId;
        public String roCode;
        public String MeasurementType;
        public Boolean isFOC;
        public Decimal Area;
        public UINumberInputClass Price;
        public Decimal Summary;
        public Decimal Price_withOutVat;
        public Decimal Summary_withOutVat;
        public Decimal old_PriceIntegration;
        public Decimal old_TotalPriceIntegration;
    }

    global class GPWithMinSectionWrapper {
        public List<ReportingRuleWrapper> ReportingRuleList;
        public PricingSectionWrapper PricingSection;
        public Decimal SalesMin;
    }

    global class GPNoMinSectionWrapper {
        public List<ReportingRuleWrapper> ReportingRuleList;
    }

    global class GPOnTopSectionWrapper {
        public List<ReportingRuleWrapper> ReportingRuleList;
        public PricingSectionWrapper PricingSection;
    }

    global class ReportingRuleWrapper {
        public String reportingRulId;
        public Boolean isToDeleteRecord;
        public String ReportingRule;
        public String ReportingRuleLabel;
        public String ReportingRuleDescription;
        public Integer GroupNumber;
        public List<ReportingRuleDetailWrapper> ReportingRuleDetailList;

        public ReportingRuleWrapper(String reportingRule, String reportingRuleLabel) {
            this.ReportingRule = reportingRule;
            this.ReportingRuleLabel = reportingRuleLabel;
            this.ReportingRuleDescription = '';
            this.ReportingRuleDetailList = new List<ReportingRuleDetailWrapper>();
            this.GroupNumber = 0;
            this.isToDeleteRecord = false;
        }

        public ReportingRuleWrapper() {
            this.ReportingRule = '';
            this.ReportingRuleLabel = '';
            this.ReportingRuleDescription = '';
            this.ReportingRuleDetailList = new List<ReportingRuleDetailWrapper>();
            this.GroupNumber = 0;
            this.isToDeleteRecord = false;
        }
    }

    global class ReportingRuleDetailWrapper {
        public String reportingRuleDetailId;
        public Integer GradingIndex;
        public Boolean isToDeleteRecord;
        public Decimal rangFrom;
        public Decimal rangTo;
        public Decimal GPPercent;
        public Boolean IsIncludeCam;
        public String gpYearlyTier;

        public ReportingRuleDetailWrapper() {
            Map<String, String> yearlyTierOption = Constant.OPPORUTNITY_GRADING_TIER;
            List<String> yearlyOptionValueList = new List<String>();

            for (String value : yearlyTierOption.keySet()) {
                yearlyOptionValueList.add(value);
            }

            this.rangFrom = 0;
            this.rangTo = 0;
            this.GPPercent = 0;
            this.IsIncludeCam = false;
            this.GradingIndex = 0;
            this.isToDeleteRecord = false;
            this.gpYearlyTier = yearlyOptionValueList.get(0);
        }
    }

    global class ProportionWrapper {
        public String Proportion;
        public Decimal Rent;
        public Decimal Service;
    }

    global class PricingSectionWrapper {
        public String MinType;
        public List<MeasurementPricingList> MeasumentPricingList;
        public FixedPriceSectionWrapper FixedPricing;
        public Decimal TotalArea;
        public Decimal TotalLeasableArea;
        public Decimal TotalPrice;
        public Decimal TotalSummary;
        public Decimal TotalPrice_withoutVat;
        public Decimal TotalSummary_withoutVat;
        public Decimal old_TotalPriceIntegration;

        public PricingSectionWrapper() {
            this.MinType = '';
            this.TotalArea = 0;
            this.TotalLeasableArea = 0;
            this.TotalPrice = 0;
            this.TotalSummary = 0;
            this.TotalPrice_withoutVat = 0;
            this.TotalSummary_withoutVat = 0;
        }
    }

    global class DatePeriod {
        public Date startDate;
        public Date endDate;
        public Boolean isOptionToRenew;

        public DatePeriod() {
            this.isOptionToRenew = false;
        }
    }

    global class LeaseHoldFloorInfoTable {
        public String Id;
        public String floorName;
        public String floorId;
        public String measurementId;
        public Decimal area;
        public Decimal old_area;
        public Decimal price;
        public Decimal old_price;
        public Decimal totalAmount;
        public Decimal old_totalAmount;
    }

    global class ExpenseAndDepositInstallmentWrapper {
        public String Id;
        public Boolean isToDeleteRecord;
        public String Type;
        public String SubType;
        public String TypeGroup;
        public Decimal TotalAmount;
        public Decimal old_TotalAmount;
        public Integer NumberOfInstallment;
        public Integer old_NumberOfInstallment;
        public String Remark;
        public Decimal TotalInstallment;
        public List<InstallmentWrapper> InstallmentList;
        public Boolean isLEASEHOLD;
        public Boolean isLEASEHOLDSUMMARY;
        public Boolean isLeaseHoldDisableINstallment;
        public List<LeaseHoldFloorInfoTable> leaseHoldInfo;
        public Decimal leaseHoldTotalArea;
        public Decimal leaseHoldTotalPrice;
        public Decimal old_leaseHoldTotalArea;
        public Decimal old_leaseHoldTotalPrice;

        public ExpenseAndDepositInstallmentWrapper() {
            this.isToDeleteRecord = false;
            this.Type = '';
            this.SubType = '';
            this.TypeGroup = 'Expense';
            this.TotalAmount = 0;
            this.NumberOfInstallment = 0;
            this.Remark = '';
            this.TotalInstallment = 0;
            this.InstallmentList = new List<InstallmentWrapper>();
            this.isLEASEHOLD = false;
            this.isLEASEHOLDSUMMARY = false;
            this.leaseHoldInfo = new List<LeaseHoldFloorInfoTable>();
            this.leaseHoldTotalArea = 0;
            this.leaseHoldTotalPrice = 0;
        }
    }

    global class InstallmentWrapper {
        public String Id;
        public String rentPriceId;
        public String servicePriceId;
        public String camPriceId;
        public Id RequestId;
        public Boolean isEditRecord;
        public Boolean isToDeleteRecord;
        public String InstallmentNumber;
        public Decimal InstallmentAmount;
        public Decimal InstallmentTopUpValue;
        public Decimal InstallmentAmountWithVat;
        public Decimal InstallmentVAT;
        public Date PaymentDueDate;
        public String PaymentMethod;
        public String remark;
        public Boolean isAdditionalPaidDeposit;
        public Boolean isTopUpInstallment;
        public Decimal old_InstallmentAmount;
        public Decimal old_InstallmentAmountWithVat;
        public Decimal old_InstallmentVAT;
        public Decimal old_rentPriceIntegration;
        public Decimal old_servicePriceIntegration;
        public Decimal old_camPriceIntegration;

        public InstallmentWrapper() {
            this.InstallmentNumber = '';
            this.InstallmentAmount = 0;
            this.InstallmentAmountWithVat = 0;
            this.InstallmentVAT = 0;
            this.old_InstallmentAmount = 0;
            this.old_InstallmentAmountWithVat = 0;
            this.old_InstallmentVAT = 0;
            this.InstallmentTopUpValue = 0;
            this.PaymentDueDate = Date.today();
            this.PaymentMethod = 'Cash';
            this.isToDeleteRecord = false;
            this.remark = '';
            this.isAdditionalPaidDeposit = false;
            this.isTopUpInstallment = false;
        }
    }

    global class DepositWrapper {
        public Decimal DepositMonth;
        public Integer NumberOfInstallment;
        public Integer old_NumberOfInstallment;
        public String DepositCalculationType;
        public String DepositOption;
        public String DepositRemark;
        public DepositSummaryWrapper DepositSummary;
        public List<DepositOtherWrapper> OtherDepositList;
    }

    global class DepositSummaryWrapper {
        public String depositSummaryId;
        public String RequestItemId;
        public Boolean isToDeleteRecord;
        public DepositSummaryPricing DepositSummaryPricing;
        public ParentContractPaidDeposit ParentContractPaidDeposit;
        public List<InstallmentWrapper> InstallmentList;
        public List<InstallmentWrapper> old_InstallmentList;
        public Decimal TotalInstallment;
        public Decimal TotalInstallment_VAT;
        public Decimal TotalInstallment_WithVat;
        public Decimal old_TotalInstallment;
        public Decimal old_TotalInstallment_VAT;
        public Decimal old_TotalInstallment_WithVat;
        public Decimal AdvanceDepositAmount;
        public String TypeGroup;
        public String Type;
        public Boolean hasTopUpInstallment;

        public DepositSummaryWrapper(
            Boolean isNoCAM,
            String camOrAirServiceCondition,
            Decimal depositMonth,
            Decimal camLastMonthRate,
            Decimal rentLastMonthRate,
            Decimal serviceLastMonthRate,
            Decimal camCarriedDeposit,
            Decimal rentCarriedDeposit,
            Decimal serviceCarriedDeposit
        ) {
            this.DepositSummaryPricing = new DepositSummaryPricing(
                isNoCAM,
                camOrAirServiceCondition,
                depositMonth,
                camLastMonthRate,
                rentLastMonthRate,
                serviceLastMonthRate,
                camCarriedDeposit,
                rentCarriedDeposit,
                serviceCarriedDeposit
            );
            this.InstallmentList = new List<InstallmentWrapper>();
            this.TotalInstallment = this.DepositSummaryPricing.totalDeposit;
            this.AdvanceDepositAmount = 0;
            this.TypeGroup = 'Deposit';
            this.Type = Constant.TYPE_SECURITY_DEPOSIT;
            this.isToDeleteRecord = false;
            this.hasTopUpInstallment = false;
            this.ParentContractPaidDeposit = new ParentContractPaidDeposit();
        }

        public DepositSummaryWrapper() {
            this.DepositSummaryPricing = new DepositSummaryPricing();
            this.InstallmentList = new List<InstallmentWrapper>();
            this.TotalInstallment = 0;
            this.AdvanceDepositAmount = 0;
            this.TypeGroup = 'Deposit';
            this.Type = Constant.TYPE_SECURITY_DEPOSIT;
            this.isToDeleteRecord = false;
            this.hasTopUpInstallment = false;
            this.ParentContractPaidDeposit = new ParentContractPaidDeposit();
        }
    }

    global class DepositOtherWrapper {
        public String otherDepositId;
        public String TypeGroup;
        public Boolean isToDeleteRecord;
        public String Type;
        public String Remark;
        public Decimal TotalAmount;
        public Integer NumberOfInstallment;
        public List<InstallmentWrapper> InstallmentList;
        public Decimal TotalInstallment;

        public DepositOtherWrapper() {
            this.TypeGroup = 'Deposit';
            this.Type = '';
            this.Remark = '';
            this.TotalAmount = 0;
            this.TotalInstallment = 0;
            this.NumberOfInstallment = 0;
            this.InstallmentList = new List<InstallmentWrapper>();
            this.isToDeleteRecord = false;
        }
    }

    global class ParentContractPaidDeposit {
        public String camOrAirService_DepositType;
        public String rent_DepositType;
        public String service_DepositType;

        public Decimal camOrAirService_BankGuaruntee;
        public Decimal rent_BankGuaruntee;
        public Decimal service_BankGuaruntee;

        public Decimal camOrAirService_Cash;
        public Decimal rent_Cash;
        public Decimal service_Cash;

        public Decimal camOrAirService_Summary;
        public Decimal rent_Summary;
        public Decimal service_Summary;

        public ParentContractPaidDeposit(String camORAirservice) {
            this.camOrAirService_DepositType = camORAirservice;
            this.rent_DepositType = Constant.TYPE_RENT;
            this.service_DepositType = Constant.TYPE_SERVICE;
            this.camOrAirService_BankGuaruntee = 0;
            this.rent_BankGuaruntee = 0;
            this.service_BankGuaruntee = 0;
            this.camOrAirService_Cash = 0;
            this.rent_Cash = 0;
            this.service_Cash = 0;
            this.camOrAirService_Summary = 0;
            this.rent_Summary = 0;
            this.service_Summary = 0;
        }

        public ParentContractPaidDeposit() {
            this.camOrAirService_DepositType = Constant.TYPE_CAM;
            this.rent_DepositType = Constant.TYPE_RENT;
            this.service_DepositType = Constant.TYPE_SERVICE;
            this.camOrAirService_BankGuaruntee = 0;
            this.rent_BankGuaruntee = 0;
            this.service_BankGuaruntee = 0;
            this.camOrAirService_Cash = 0;
            this.rent_Cash = 0;
            this.service_Cash = 0;
            this.camOrAirService_Summary = 0;
            this.rent_Summary = 0;
            this.service_Summary = 0;
        }
    }

    global class DepositSummaryPricing {
        public Decimal vatPercentValue;

        public String camOrAirService_DepositType;
        public String rent_DepositType;
        public String service_DepositType;

        public Decimal camOrAirService_LastMonthlyRate;
        public Decimal rent_LastMonthlyRate;
        public Decimal service_LastMonthlyRate;

        public Decimal camOrAirService_Vat;
        public Decimal rent_Vat;
        public Decimal rent_Vat_ToDisPlay;
        public Decimal service_Vat;

        public Decimal camOrAirService_LastMonthlyRateWithVat;
        public Decimal rent_LastMonthlyRateWithVat;
        public Decimal service_LastMonthlyRateWithVat;

        public Decimal camOrAirService_TotalDeposit;
        public Decimal rent_TotalDeposit;
        public Decimal service_TotalDeposit;

        public Decimal camOrAirService_CarriedDeposit;
        public Decimal rent_CarriedDeposit;
        public Decimal service_CarriedDeposit;

        public Decimal camOrAirService_ActualDeposit;
        public Decimal rent_ActualDeposit;
        public Decimal service_ActualDeposit;

        public Decimal camOrAirService_Summary;
        public Decimal rent_Summary;
        public Decimal service_Summary;

        public Decimal camOrAirService_Summary_WithVat;
        public Decimal rent_Summary_WithVat;
        public Decimal service_Summary_WithVat;

        public Decimal totalDeposit;
        public Decimal totalDeposit_WithVat;

        // ///////////////////////////////

        public Decimal old_camOrAirService_LastMonthlyRate;
        public Decimal old_rent_LastMonthlyRate;
        public Decimal old_service_LastMonthlyRate;

        public Decimal old_camOrAirService_Vat;
        public Decimal old_rent_Vat;
        public Decimal old_rent_Vat_ToDisPlay;
        public Decimal old_service_Vat;

        public Decimal old_camOrAirService_LastMonthlyRateWithVat;
        public Decimal old_rent_LastMonthlyRateWithVat;
        public Decimal old_service_LastMonthlyRateWithVat;

        public Decimal old_camOrAirService_TotalDeposit;
        public Decimal old_rent_TotalDeposit;
        public Decimal old_service_TotalDeposit;

        public Decimal old_camOrAirService_CarriedDeposit;
        public Decimal old_rent_CarriedDeposit;
        public Decimal old_service_CarriedDeposit;

        public Decimal old_camOrAirService_ActualDeposit;
        public Decimal old_rent_ActualDeposit;
        public Decimal old_service_ActualDeposit;

        public Decimal old_camOrAirService_Summary;
        public Decimal old_rent_Summary;
        public Decimal old_service_Summary;

        public Decimal old_camOrAirService_Summary_WithVat;
        public Decimal old_rent_Summary_WithVat;
        public Decimal old_service_Summary_WithVat;

        public Decimal old_totalDeposit;
        public Decimal old_totalDeposit_WithVat;

        public DepositSummaryPricing(
            Boolean isNoCAM,
            String depositCondition,
            String camOrAirServiceCondition,
            Decimal depositMonth,
            Decimal camDeposit,
            Decimal airServiceDeposit,
            Decimal rentDeposit,
            Decimal serviceDeposit,
            Decimal camCarrierDeposit,
            Decimal airServiceCarrierDeposit,
            Decimal rentCarrierDeposit,
            Decimal serviceCarrierDeposit
        ) {
            Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
            this.vatPercentValue = vatPercent;

            this.camOrAirService_DepositType = 'CAM';
            this.rent_DepositType = 'Rent';
            this.service_DepositType = (camOrAirServiceCondition == 'Air Service' && !isNoCAM)
                ? 'Service + Air Service'
                : 'Service';

            if (camOrAirServiceCondition == 'Air Service') {
                this.camOrAirService_TotalDeposit = 0;
            } else {
                this.camOrAirService_TotalDeposit = ((camDeposit != null) ? camDeposit.setscale(2) : 0);
            }
            this.rent_TotalDeposit = (rentDeposit != null) ? rentDeposit.setscale(2) : 0;
            this.service_TotalDeposit = (serviceDeposit != null) ? serviceDeposit.setscale(2) : 0;

            if (camOrAirServiceCondition == 'Air Service') {
                this.camOrAirService_CarriedDeposit = 0;
            } else {
                this.camOrAirService_CarriedDeposit = ((camCarrierDeposit != null) ? camCarrierDeposit.setscale(2) : 0);
            }
            this.rent_CarriedDeposit = (rentCarrierDeposit != null) ? rentCarrierDeposit.setscale(2) : 0;
            this.service_CarriedDeposit = (serviceCarrierDeposit != null) ? serviceCarrierDeposit.setscale(2) : 0;

            if (depositCondition == 'System Calculation') {
                this.camOrAirService_LastMonthlyRate = (depositMonth > 0)
                    ? this.camOrAirService_TotalDeposit / depositMonth
                    : 0;
                this.camOrAirService_LastMonthlyRate = this.camOrAirService_LastMonthlyRate.setscale(2);

                this.rent_LastMonthlyRate = (depositMonth > 0) ? this.rent_TotalDeposit / depositMonth : 0;
                this.rent_LastMonthlyRate = this.rent_LastMonthlyRate.setscale(2);

                this.service_LastMonthlyRate = (depositMonth > 0) ? this.service_TotalDeposit / depositMonth : 0;
                this.service_LastMonthlyRate = this.service_LastMonthlyRate.setscale(2);
            } else {
                this.camOrAirService_LastMonthlyRate = null;
                this.rent_LastMonthlyRate = null;
                this.service_LastMonthlyRate = null;
            }

            this.camOrAirService_Summary = this.camOrAirService_TotalDeposit - this.camOrAirService_CarriedDeposit;
            this.rent_Summary = this.rent_TotalDeposit - this.rent_CarriedDeposit;
            this.service_Summary = this.service_TotalDeposit - this.service_CarriedDeposit;
            this.totalDeposit = this.camOrAirService_Summary + this.rent_Summary + this.service_Summary;

            Decimal camOrAirService_Summary_vat = (this.camOrAirService_Summary * (vatPercent / 100));
            Decimal service_Summary_vat = (this.service_Summary * (vatPercent / 100));

            this.camOrAirService_Summary_WithVat =
                this.camOrAirService_Summary + camOrAirService_Summary_vat.setscale(2);
            this.rent_Summary_WithVat = this.rent_Summary;
            this.service_Summary_WithVat = this.service_Summary + service_Summary_vat.setscale(2);
            this.totalDeposit_WithVat =
                this.camOrAirService_Summary_WithVat.setscale(2) +
                this.rent_Summary_WithVat.setscale(2) +
                this.service_Summary_WithVat.setscale(2);
            this.totalDeposit_WithVat = this.totalDeposit_WithVat.setscale(2);

            this.camOrAirService_ActualDeposit = 0;
            this.rent_ActualDeposit = 0;
            this.service_ActualDeposit = 0;

            this.old_camOrAirService_LastMonthlyRate = this.camOrAirService_LastMonthlyRate;
            this.old_rent_LastMonthlyRate = this.rent_LastMonthlyRate;
            this.old_service_LastMonthlyRate = this.service_LastMonthlyRate;
            this.old_camOrAirService_Vat = this.camOrAirService_Vat;
            this.old_rent_Vat = this.rent_Vat;
            this.old_rent_Vat_ToDisPlay = this.rent_Vat_ToDisPlay;
            this.old_service_Vat = this.service_Vat;
            this.old_camOrAirService_LastMonthlyRateWithVat = this.camOrAirService_LastMonthlyRateWithVat;
            this.old_rent_LastMonthlyRateWithVat = this.rent_LastMonthlyRateWithVat;
            this.old_service_LastMonthlyRateWithVat = this.service_LastMonthlyRateWithVat;
            this.old_camOrAirService_TotalDeposit = this.camOrAirService_TotalDeposit;
            this.old_rent_TotalDeposit = this.rent_TotalDeposit;
            this.old_service_TotalDeposit = this.service_TotalDeposit;
            this.old_camOrAirService_CarriedDeposit = this.camOrAirService_CarriedDeposit;
            this.old_rent_CarriedDeposit = this.rent_CarriedDeposit;
            this.old_service_CarriedDeposit = this.service_CarriedDeposit;
            this.old_camOrAirService_ActualDeposit = this.camOrAirService_ActualDeposit;
            this.old_rent_ActualDeposit = this.rent_ActualDeposit;
            this.old_service_ActualDeposit = this.service_ActualDeposit;
            this.old_camOrAirService_Summary = this.camOrAirService_Summary;
            this.old_rent_Summary = this.rent_Summary;
            this.old_service_Summary = this.service_Summary;
            this.old_camOrAirService_Summary_WithVat = this.camOrAirService_Summary_WithVat;
            this.old_rent_Summary_WithVat = this.rent_Summary_WithVat;
            this.old_service_Summary_WithVat = this.service_Summary_WithVat;
            this.old_totalDeposit = this.totalDeposit;
            this.old_totalDeposit_WithVat = this.totalDeposit_WithVat;
        }

        public DepositSummaryPricing(
            Boolean isNoCAM,
            String camOrAirServiceCondition,
            Decimal depositMonth,
            Decimal camLastMonthRate,
            Decimal rentLastMonthRate,
            Decimal serviceLastMonthRate,
            Decimal camCarriedDeposit,
            Decimal rentCarriedDeposit,
            Decimal serviceCarriedDeposit
        ) {
            Decimal vatPercent = OpportunitySetting__c.getInstance().Tax__c;
            this.vatPercentValue = vatPercent;

            this.camOrAirService_DepositType = 'CAM';
            this.rent_DepositType = 'Rent';
            this.service_DepositType = (camOrAirServiceCondition == 'Air Service' && !isNoCAM)
                ? 'Service + Air Service'
                : 'Service';

            if (camOrAirServiceCondition == 'Air Service') {
                this.camOrAirService_LastMonthlyRate = 0;

                Decimal serviceLastMonthPrice = (serviceLastMonthRate != null &&
                    depositMonth > 0)
                    ? serviceLastMonthRate.setscale(2)
                    : 0;
                Decimal airserviceLastMonthPrice = (camLastMonthRate != null &&
                    depositMonth > 0)
                    ? camLastMonthRate.setscale(2)
                    : 0;

                this.service_LastMonthlyRate = serviceLastMonthPrice + airserviceLastMonthPrice;
            } else {
                this.camOrAirService_LastMonthlyRate = (camLastMonthRate != null &&
                    depositMonth > 0)
                    ? camLastMonthRate.setscale(2)
                    : 0;
                this.service_LastMonthlyRate = (serviceLastMonthRate != null &&
                    depositMonth > 0)
                    ? serviceLastMonthRate.setscale(2)
                    : 0;
            }
            this.rent_LastMonthlyRate = (rentLastMonthRate != null &&
                depositMonth > 0)
                ? rentLastMonthRate.setscale(2)
                : 0;

            this.camOrAirService_TotalDeposit = this.camOrAirService_LastMonthlyRate * depositMonth;
            this.camOrAirService_TotalDeposit = this.camOrAirService_TotalDeposit.setscale(2);

            this.rent_TotalDeposit = this.rent_LastMonthlyRate * depositMonth;
            this.rent_TotalDeposit = this.rent_TotalDeposit.setscale(2);

            this.service_TotalDeposit = this.service_LastMonthlyRate * depositMonth;
            this.service_TotalDeposit = this.service_TotalDeposit.setscale(2);

            this.camOrAirService_CarriedDeposit = (camCarriedDeposit != null) ? camCarriedDeposit.setscale(2) : 0;
            this.rent_CarriedDeposit = (rentCarriedDeposit != null) ? rentCarriedDeposit.setscale(2) : 0;
            this.service_CarriedDeposit = (serviceCarriedDeposit != null) ? serviceCarriedDeposit.setscale(2) : 0;

            this.camOrAirService_Summary = this.camOrAirService_TotalDeposit - this.camOrAirService_CarriedDeposit;
            this.camOrAirService_Summary = this.camOrAirService_Summary.setscale(2);

            this.rent_Summary = this.rent_TotalDeposit - this.rent_CarriedDeposit;
            this.rent_Summary = this.rent_Summary.setscale(2);

            this.service_Summary = this.service_TotalDeposit - this.service_CarriedDeposit;
            this.service_Summary = this.service_Summary.setscale(2);

            this.totalDeposit = this.camOrAirService_Summary + this.rent_Summary + this.service_Summary;

            Decimal camOrAirService_Summary_vat = (this.camOrAirService_Summary * (vatPercent / 100));
            Decimal service_Summary_vat = (this.service_Summary * (vatPercent / 100));

            this.camOrAirService_Summary_WithVat =
                this.camOrAirService_Summary + camOrAirService_Summary_vat.setscale(2);
            this.rent_Summary_WithVat = this.rent_Summary;
            this.service_Summary_WithVat = this.service_Summary + service_Summary_vat.setscale(2);

            this.totalDeposit_WithVat =
                this.camOrAirService_Summary_WithVat.setscale(2) +
                this.rent_Summary_WithVat.setscale(2) +
                this.service_Summary_WithVat.setscale(2);
            this.totalDeposit_WithVat = this.totalDeposit_WithVat.setscale(2);

            this.camOrAirService_ActualDeposit = 0;
            this.rent_ActualDeposit = 0;
            this.service_ActualDeposit = 0;

            this.old_camOrAirService_LastMonthlyRate = this.camOrAirService_LastMonthlyRate;
            this.old_rent_LastMonthlyRate = this.rent_LastMonthlyRate;
            this.old_service_LastMonthlyRate = this.service_LastMonthlyRate;
            this.old_camOrAirService_Vat = this.camOrAirService_Vat;
            this.old_rent_Vat = this.rent_Vat;
            this.old_rent_Vat_ToDisPlay = this.rent_Vat_ToDisPlay;
            this.old_service_Vat = this.service_Vat;
            this.old_camOrAirService_LastMonthlyRateWithVat = this.camOrAirService_LastMonthlyRateWithVat;
            this.old_rent_LastMonthlyRateWithVat = this.rent_LastMonthlyRateWithVat;
            this.old_service_LastMonthlyRateWithVat = this.service_LastMonthlyRateWithVat;
            this.old_camOrAirService_TotalDeposit = this.camOrAirService_TotalDeposit;
            this.old_rent_TotalDeposit = this.rent_TotalDeposit;
            this.old_service_TotalDeposit = this.service_TotalDeposit;
            this.old_camOrAirService_CarriedDeposit = this.camOrAirService_CarriedDeposit;
            this.old_rent_CarriedDeposit = this.rent_CarriedDeposit;
            this.old_service_CarriedDeposit = this.service_CarriedDeposit;
            this.old_camOrAirService_ActualDeposit = this.camOrAirService_ActualDeposit;
            this.old_rent_ActualDeposit = this.rent_ActualDeposit;
            this.old_service_ActualDeposit = this.service_ActualDeposit;
            this.old_camOrAirService_Summary = this.camOrAirService_Summary;
            this.old_rent_Summary = this.rent_Summary;
            this.old_service_Summary = this.service_Summary;
            this.old_camOrAirService_Summary_WithVat = this.camOrAirService_Summary_WithVat;
            this.old_rent_Summary_WithVat = this.rent_Summary_WithVat;
            this.old_service_Summary_WithVat = this.service_Summary_WithVat;
            this.old_totalDeposit = this.totalDeposit;
            this.old_totalDeposit_WithVat = this.totalDeposit_WithVat;
        }

        public DepositSummaryPricing() {
        }
    }

    global class OtherWrapper {
        // public ElectricDetailWrapper ElectricDetail;
        // public WaterDetailWrapper WaterDetail;
        // public GasDetailWrapper GasDetail;
        // public CashierDetailWrapper CashierDetail;
        // public FurnitureDetailWrapper FurnitureDetail;
        // public AdditionalRequestWrapper AdditionalRequest;
        // public AdditionalAirServiceWrapper AdditionalAirService;

        public List<RateAndAreaOtherExpenseFormat> rateAndAreaFormatList;
        public List<FixedOtherExpenseFormat> fixedFormatList;

        public OtherWrapper() {
            rateAndAreaFormatList = new List<RateAndAreaOtherExpenseFormat>();
            fixedFormatList = new List<FixedOtherExpenseFormat>();
        }
    }

    global class FixedOtherExpenseFormat {
        public String depositExpenseId;
        public String oppPriceId;
        public Boolean isToDeleteRecord;
        public Decimal Monthly;
        public String Remark;
        public String Type;
        public String TypeGroup;
        public String ExpenseOtherType;
        public Decimal Sequence;

        public FixedOtherExpenseFormat(String type) {
            this.Monthly = 0;
            this.Remark = '';
            this.Type = type;
            this.TypeGroup = Constant.DEP_EXP_TYPE_GROUP_OTHER;
            this.isToDeleteRecord = false;
        }

        public FixedOtherExpenseFormat() {
            this.isToDeleteRecord = false;
        }
    }

    global class RateAndAreaOtherExpenseFormat {
        public String depositExpenseId;
        public String oppPriceId;
        public Boolean isToDeleteRecord;
        public String Type;
        public String TypeGroup;
        public String SubType;
        public String Remark;
        public Decimal Area;
        public Decimal Total;
        public Decimal Rate;
        public Boolean isDisabledRateAndArea;
        public Boolean isDisabledRemark;
        public Boolean isDisabledTotal;
        public String ExpenseOtherType;
        public Decimal Sequence;

        public RateAndAreaOtherExpenseFormat(String type) {
            this.Type = type;
            this.TypeGroup = Constant.DEP_EXP_TYPE_GROUP_OTHER;
            this.SubType = 'Actual';
            this.Remark = '';
            this.Area = 0;
            this.Total = 0;
            this.Rate = 0;
            this.isDisabledRateAndArea = false;
            this.isDisabledTotal = false;
            this.isToDeleteRecord = false;
            this.isDisabledRemark = true;
        }

        public RateAndAreaOtherExpenseFormat() {
            this.isToDeleteRecord = false;
        }
    }

    global class ElectricDetailWrapper {
        public String depositExpenseId;
        public String oppPriceId;
        public String Type;
        public String TypeGroup;
        public String SubType;
        public String Remark;
        public Decimal Area;
        public Decimal Total;
        public Decimal Rate;

        public ElectricDetailWrapper() {
            this.Type = Constant.DEP_EXP_TYPE_ELECTRIC;
            this.TypeGroup = 'Other';
            this.SubType = '';
            this.Remark = '';
            this.Area = 0;
            this.Total = 0;
            this.Rate = 0;
        }
    }

    global class WaterDetailWrapper {
        public String depositExpenseId;
        public String oppPriceId;
        public String Type;
        public String TypeGroup;
        public String SubType;
        public String Remark;
        public Decimal Area;
        public Decimal Total;
        public Decimal Rate;

        public WaterDetailWrapper() {
            this.Type = Constant.DEP_EXP_TYPE_WATER;
            this.TypeGroup = 'Other';
            this.SubType = '';
            this.Remark = '';
            this.Area = 0;
            this.Total = 0;
            this.Rate = 0;
        }
    }

    global class GasDetailWrapper {
        public String depositExpenseId;
        public String oppPriceId;
        public String Type;
        public String TypeGroup;
        public String SubType;
        public String Remark;
        public Decimal Area;
        public Decimal Total;
        public Decimal Rate;

        public GasDetailWrapper() {
            this.Type = Constant.DEP_EXP_TYPE_GAS;
            this.TypeGroup = 'Other';
            this.SubType = '';
            this.Remark = '';
            this.Area = 0;
            this.Total = 0;
            this.Rate = 0;
        }
    }

    global class CashierDetailWrapper {
        public String depositExpenseId;
        public String oppPriceId;
        public Decimal Monthly;
        public String Remark;
        public String Type;
        public String TypeGroup;

        public CashierDetailWrapper() {
            this.Monthly = 0;
            this.Remark = '';
            this.Type = Constant.DEP_EXP_TYPE_CASHIER;
            this.TypeGroup = 'Other';
        }
    }

    global class FurnitureDetailWrapper {
        public String depositExpenseId;
        public String oppPriceId;
        public Decimal Monthly;
        public String Remark;
        public String Type;
        public String TypeGroup;

        public FurnitureDetailWrapper() {
            this.Monthly = 0;
            this.Remark = '';
            this.Type = Constant.DEP_EXP_TYPE_FURNITURE;
            this.TypeGroup = 'Other';
        }
    }

    global class AdditionalRequestWrapper {
        public String depositExpenseId;
        public String oppPriceId;
        public Decimal Monthly;
        public String Remark;
        public String Type;
        public String TypeGroup;

        public AdditionalRequestWrapper() {
            this.Monthly = 0;
            this.Remark = '';
            this.Type = Constant.DEP_EXP_TYPE_ADDITIONAL_REQUEST;
            this.TypeGroup = 'Other';
        }
    }

    global class AdditionalAirServiceWrapper {
        public String depositExpenseId;
        public String oppPriceId;
        public Decimal Monthly;
        public String Remark;
        public String Type;
        public String TypeGroup;

        public AdditionalAirServiceWrapper() {
            this.Monthly = 0;
            this.Remark = '';
            this.Type = Constant.DEP_EXP_TYPE_ADDITIONAL_AIR_SERVICE;
            this.TypeGroup = 'Other';
        }
    }
}
