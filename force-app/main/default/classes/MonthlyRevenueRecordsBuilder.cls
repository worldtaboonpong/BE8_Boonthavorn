public with sharing class MonthlyRevenueRecordsBuilder {
    
    private List<Contract__c> contractList;
    private Date periodStartDate;
    private Date periodEndDate;
    private List<Monthly_Revenue__c> mRevenueList = new List<Monthly_Revenue__c>();
    private final List<String> CAL_METHOD_GP = new List<String>{
        Constant.CAL_METHOD_GP_NOMIN,
        Constant.CAL_METHOD_GP_WITHMIN,
        Constant.CAL_METHOD_GP_ONTOP
    };
    public final static Map<String, String> MONTHLY_REVENUE_CONTRACT_RECORDTYPE_MAP = new Map<String, String>{
        'Rent_Event' => 'Event',
        'OP_Rental' => 'OP',
        'Rent_Space' => 'Space',
        'Rent_a_Billboard' => 'BillBoard'
    };

    public MonthlyRevenueRecordsBuilder(List<Contract__c> scope, Date periodStartDate, Date periodEndDate) {
        this.contractList = scope;
        this.periodStartDate = periodStartDate;
        this.periodEndDate = periodEndDate;
    }

    public List<Monthly_Revenue__c> createMonthlyRevenueRecords() {
        Set<Id> contractIdSet = new Map<Id, Contract__c>(this.contractList).keySet();

        List<Roll_up_by_Branch__mdt> rollupBranchMeta = Roll_up_by_Branch__mdt.getAll().values();
        Map<String, Roll_up_by_Branch__mdt> rollupBranchMap = new Map<String, Roll_up_by_Branch__mdt>();
        for (Roll_up_by_Branch__mdt metaItem : rollupBranchMeta) {
            String rollupBranchKeyName = ''+metaItem.Branch_Name__c+'_'+metaItem.Building_Name__c;
            if (!rollupBranchMap.containsKey(rollupBranchKeyName) && metaItem.Is_Active__c == true) {
                rollupBranchMap.put(rollupBranchKeyName, metaItem);
            }
        }
        List<Roll_up_by_Category__mdt> rollupCategoryMeta = Roll_up_by_Category__mdt.getAll().values();
        Map<String, Roll_up_by_Category__mdt> rollupCategoryMap = new Map<String, Roll_up_by_Category__mdt>();
        for (Roll_up_by_Category__mdt metaItem : rollupCategoryMeta) {
            String rollupCategoryKeyName = ''+metaItem.Branch_Name__c+'_'+metaItem.Category__c;
            if (!rollupCategoryMap.containsKey(rollupCategoryKeyName) && metaItem.Is_Active__c == true) {
                rollupCategoryMap.put(rollupCategoryKeyName, metaItem);
            }
        }

        List<ContractLineItem__c> contractLineItemList = [
            SELECT Id, IsDeleted, Name, Contract__c, LeasableArea__c, TotalArea__c, 
                Unit__c, Unit__r.Floor__c, Unit__r.Building__r.Name, Unit__r.Building__r.Branch__r.Name
            FROM ContractLineItem__c
            WHERE Contract__c IN :contractIdSet
        ];
        Map<Id, List<ContractLineItem__c>> contractIdMapContractLineItemList = new Map<Id, List<ContractLineItem__c>>();
        for (ContractLineItem__c cli : contractLineItemList) {
            if (!contractIdMapContractLineItemList.containsKey(cli.Contract__c)) {
                contractIdMapContractLineItemList.put(cli.Contract__c, new List<ContractLineItem__c>());
            }
            contractIdMapContractLineItemList.get(cli.Contract__c).add(cli);
        }
        
        Map<String, String> masterRollupAreaExternalId = new Map<String, String>();
        Map<String, String> masterRollupCategoryExternalId = new Map<String, String>();

        System.debug('contract to process : '+this.contractList.size());
        for (Contract__c contract : this.contractList) {
            List<ContractPeriod__c> contractPeriods = contract.Contract_Periods__r;
            List<ContractPeriod__c> listCAM = new List<ContractPeriod__c>();
            List<ContractPeriod__c> listCalculation = new List<ContractPeriod__c>();

            for (ContractPeriod__c contractPeriod : contractPeriods) {
                if (contractPeriod.CalculationMethod__c == Constant.CAL_METHOD_CAM) {
                    listCAM.add(contractPeriod);
                } else if (contractPeriod.CalculationMethod__c != Constant.CAL_METHOD_RENT_SERVICE) {
                    listCalculation.add(contractPeriod);
                }
            }

            Boolean isTerminated = (contract.Termination_Date__c != null) && (contract.Status__c == Constant.CONTRACT_STATUS_TERMINATED);
            Date terminationDate = isTerminated ? contract.Termination_Date__c : null;
            Date mainContractStartDate = (contract.Contract_Start_Date__c < this.periodStartDate) ? this.periodStartDate : contract.Contract_Start_Date__c;
            Date mainContractEndDate = (contract.Contract_End_Date__c > this.periodEndDate) ? this.periodEndDate : contract.Contract_End_Date__c;

            List<ContractLineItem__c> currentcontractLineItems = contractIdMapContractLineItemList.get(contract.Id);

            if (currentcontractLineItems == null) {
                System.debug('Error ::: There is no ContractLineItem__c record for Contract__c Id '+contract.Id);
                continue;
            }
            System.debug('method '+contract.Calculation_Method__c+' start assemble from '+mainContractStartDate+' - to '+mainContractEndDate);
            System.debug('contract status '+contract.Status__c+' terminationDate '+terminationDate);
            
            for (contractLineItem__c cli : currentcontractLineItems) {
                Date currentDate = mainContractStartDate;
                while (currentDate <= mainContractEndDate) {
                    Monthly_Revenue__c mRevenue = new Monthly_Revenue__c();

                    Integer totalDays = Date.daysInMonth(currentDate.year(), currentDate.month());
                    Date currentMonthStartDate = currentDate;
                    Date currentMonthEndDate = toEndOfMonth(currentDate);

                    if (isSameMonthYear(currentDate, mainContractEndDate)) {
                        currentMonthEndDate = mainContractEndDate;
                    }

                    List<ContractPeriod__c> listPeriodCal = findContractPeriods(currentDate, currentMonthEndDate, listCalculation);

                    if (listPeriodCal.isEmpty()) {
                        System.debug('Error ::: no contract period');
                        currentDate = currentDate.addMonths(1).toStartOfMonth();
                        continue;
                    }

                    List<ContractGradingModel.Data> contractGradingList = new List<ContractGradingModel.Data>();
                    if (contract.ContractGrading__c != null) {
                        contractGradingList = ContractGradingModel.parse(contract.ContractGrading__c);
                    }

                    Decimal priceCAM = 0;
                    Decimal priceServicePlusRent = 0;

                    for (ContractPeriod__c periodCal : listPeriodCal) {
                        Date dayFrom = periodCal.PeriodFrom__c >= currentMonthStartDate ? periodCal.PeriodFrom__c : currentMonthStartDate;
                        Date dayTo = periodCal.PeriodTo__c <= currentMonthEndDate ? periodCal.PeriodTo__c : currentMonthEndDate;
                        Decimal loopScopePriceCAM = 0;
                        Decimal loopScopePriceServicePlusRent = 0;
                        if (isTerminated && dayFrom >= terminationDate) {
                            continue;
                        } else if (isTerminated && dayTo >= terminationDate) {
                            dayTo = terminationDate.addDays(-1);
                        }
                        Integer period = dayFrom.daysBetween(dayTo) + 1;
                        ContractPeriod__c periodCAM = findContractPeriod(dayFrom, dayTo, listCAM);
                        
                        if (periodCAM != null) {
                            loopScopePriceCAM = calculateByRatio(periodCAM.CAMMonth__c, period, totalDays);
                        }

                        if (!CAL_METHOD_GP.contains(periodCal.CalculationMethod__c)) {
                            loopScopePriceServicePlusRent = calculateByRatio((periodCal.RentMonth__c + periodCal.ServiceMonth__c), period, totalDays);
                        } else if (contractGradingList.size() > 0) {
                            ContractGradingModel.Data grading = findContractGrading(contractGradingList, periodCal);
                            if (grading != null) {
                                switch on periodCal.CalculationMethod__c {
                                    when 'GP no Min' {
                                        loopScopePriceServicePlusRent = calculateByRatio((periodCal.EstimateRevenue__c * (grading.GP / 100)), period, totalDays);
                                    }
                                    when 'GP with Min' {
                                        if (periodCal.EstimateRevenue__c < periodCal.SalesMin__c) {
                                            loopScopePriceServicePlusRent = calculateByRatio((periodCal.RentMonth__c + periodCal.ServiceMonth__c), period, totalDays);
                                        } else {
                                            loopScopePriceServicePlusRent = calculateByRatio((periodCal.EstimateRevenue__c * (grading.GP / 100)), period, totalDays);
                                        }
                                    }
                                    when 'GP on Top' {
                                        Decimal onTopPrice = (periodCal.RentMonth__c + periodCal.ServiceMonth__c) + (periodCal.EstimateRevenue__c * (grading.GP / 100));
                                        loopScopePriceServicePlusRent = calculateByRatio(onTopPrice, period, totalDays);
                                    }
                                }
                            } else {
                                System.debug('Error ::: contract grading is not found');
                            }
                        }

                        if (periodCal.IsIncludeCAM__c) { loopScopePriceServicePlusRent -= loopScopePriceCAM; }
                        priceServicePlusRent += loopScopePriceServicePlusRent;
                        priceCAM += loopScopePriceCAM;
                    }

                    Datetime dt = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
                    mRevenue.External_ID__c = ''+contract.Id+'_'+cli.Unit__c+'_'+dt.format('MMM').toUpperCase()+'_'+dt.format('yyyy');
                    mRevenue.Month__c = dt.format('MMM').toUpperCase();
                    mRevenue.Year__c = dt.format('yyyy');
                    mRevenue.Contract__c = contract.Id;
                    mRevenue.Contract_Status__c = contract.Status__c;
                    mRevenue.Contract_Type1__c = MONTHLY_REVENUE_CONTRACT_RECORDTYPE_MAP.get(contract.Record_Type_Name__c) ?? 'BillBoard';
                    mRevenue.Floor__c = cli.Unit__r.Floor__c;
                    mRevenue.Area__c = cli.LeasableArea__c;
                    mRevenue.ONLA__c = cli.LeasableArea__c;
                    mRevenue.Unit__c = 1;

                    mRevenue.Total_Rent_no_CAM__c = calculateByRatio(priceServicePlusRent, cli.LeasableArea__c, contract.Total_Leasable_Area__c);
                    mRevenue.Total_Rent__c = calculateByRatio((priceServicePlusRent + priceCAM), cli.LeasableArea__c, contract.Total_Leasable_Area__c);
                    mRevenue.Revenue__c = mRevenue.Total_Rent__c;

                    String rollUpBranchMetaKey = cli.Unit__r.Building__r.Branch__r.Name+'_'+cli.Unit__r.Building__r.Name;
                    Roll_up_by_Branch__mdt rollUpBranchMetaItem = rollupBranchMap.get(rollUpBranchMetaKey);
                    String exKeyBranch;
                    if (rollUpBranchMetaItem != null) {
                        exKeyBranch = concatRollUpExternalId(rollUpBranchMetaItem, dt.format('MMM').toUpperCase(), dt.format('yyyy'));
                    }
                    masterRollupAreaExternalId.put(mRevenue.External_ID__c, exKeyBranch);

                    String rollUpCategoryMetaKey = cli.Unit__r.Building__r.Branch__r.Name+'_'+ (contract.Category__c != null? contract.Category__c : 'Event');
                    Roll_up_by_Category__mdt rollUpCategoryMetaItem = rollupCategoryMap.get(rollUpCategoryMetaKey);
                    String exKeyCategory;
                    if (rollUpCategoryMetaItem != null) {
                        exKeyCategory = concatRollUpExternalId(rollUpCategoryMetaItem, dt.format('MMM').toUpperCase(), dt.format('yyyy'));
                    }
                    masterRollupCategoryExternalId.put(mRevenue.External_ID__c, exKeyCategory);
                    
                    currentDate = currentDate.addMonths(1).toStartOfMonth();
                    this.mRevenueList.add(mRevenue);
                }
            }
        }

        List<Roll_up_Area_Building__c> masterRollupArea = [
            SELECT Id, IsDeleted, Name, RecordTypeId, External_ID__c, Month__c, Year__c, Building__c, Branch__c, Roll_up_Area_Branch__c
            FROM Roll_up_Area_Building__c
            WHERE IsDeleted != true AND External_ID__c IN :masterRollupAreaExternalId.values()
        ];
        Map<String, Roll_up_Area_Building__c> masterRollupAreaMap = new Map<String, Roll_up_Area_Building__c>();
        for (Roll_up_Area_Building__c mrArea : masterRollupArea) {
            masterRollupAreaMap.put(mrArea.External_ID__c, mrArea);
        }
        
        List<Roll_up_Category_and_Branch__c> masterRollupCategory = [
            SELECT Id, IsDeleted, Name, Roll_up_Category__c, Unit__c, Branch__c, Month__c, Year__c, External_ID__c
            FROM Roll_up_Category_and_Branch__c
            WHERE IsDeleted != true AND External_ID__c IN :masterRollupCategoryExternalId.values()
        ];
        Map<String, Roll_up_Category_and_Branch__c> masterRollupCategoryMap = new Map<String, Roll_up_Category_and_Branch__c>();
        for (Roll_up_Category_and_Branch__c mrCategory : masterRollupCategory) {
            masterRollupCategoryMap.put(mrCategory.External_ID__c, mrCategory);
        }

        for (Monthly_Revenue__c mRevenue : mRevenueList) {
            String rollupAreaExt = masterRollupAreaExternalId.get(mRevenue.External_ID__c);
            Roll_up_Area_Building__c rollupArea = masterRollupAreaMap.get(rollupAreaExt);
            if (rollUpArea != null) {
                mRevenue.Roll_up_Area_Building__c = rollupArea.Id;
            } else {
                System.debug('Error ::: not found Roll_up_Area_Building__c : ' + rollupAreaExt);
            }
            String rollupCategoryExt = masterRollupCategoryExternalId.get(mRevenue.External_ID__c);
            Roll_up_Category_and_Branch__c rollupCategory = masterRollupCategoryMap.get(rollupCategoryExt);
            if (rollupCategory != null) {
                mRevenue.Roll_up_Category_and_Branch__c = rollUpCategory.Id;
            }
            else {
                System.debug('Error ::: not found Roll_up_Category_and_Branch__c : ' + rollupCategoryExt);
            }
            System.debug('mRevenue >>> '+mRevenue);
        }
        System.debug('Size '+mRevenueList.size());
        return mRevenueList;
    }

    public static ContractGradingModel.Data findContractGrading(List<ContractGradingModel.Data> contractGrading, ContractPeriod__c contractPeriod) {
        ContractGradingModel.Data resultContractGrading;
        if (contractGrading.size() > 0 && contractPeriod != null) {
            for (ContractGradingModel.Data cg : contractGrading) {
                if (cg.ContractPeriodId != contractPeriod.Id) { continue; }
                if (contractPeriod.EstimateRevenue__c >= cg.FromR) {
                    if (contractPeriod.EstimateRevenue__c <= cg.ToR) {
                        resultContractGrading = cg;
                    }
                }
            }

            if (resultContractGrading == null) {
                Decimal maxFromR = 0;
                Decimal maxToR = 0;
                for (ContractGradingModel.Data cg : contractGrading) {
                    if (cg.ContractPeriodId != contractPeriod.Id) { continue; }
                    if (contractPeriod.EstimateRevenue__c > cg.FromR && contractPeriod.EstimateRevenue__c > cg.ToR) {
                        if (cg.FromR >= maxFromR && cg.ToR >= maxToR) {
                            maxFromR = cg.FromR;
                            maxToR = cg.ToR;
                            resultContractGrading = cg;
                        }
                    }
                }
            }
        }
        return resultContractGrading;
    }

    public static ContractPeriod__c findContractPeriod(Date startDate, Date endDate, List<ContractPeriod__c> cpList) {
        if (cpList != null) {
            for (ContractPeriod__c cp : cpList) {
                if ((startDate >= cp.PeriodFrom__c) && (endDate <= cp.PeriodTo__c)) {
                    return cp;
                }
            }
        }
        return null;
    }

    public static List<ContractPeriod__c> findContractPeriods(Date startDate, Date endDate, List<ContractPeriod__c> cpList) {
        List<ContractPeriod__c> result = new List<ContractPeriod__c>();
        if (cpList != null) {
            for (ContractPeriod__c cp : cpList) {
                if ((cp.PeriodFrom__c <= endDate) && (cp.PeriodTo__c >= startDate)) {
                    result.add(cp);
                }
            }
        }
        result.sort(new SequenceComparator());
        return result;
    }

    public static String concatRollUpExternalId(Roll_up_by_Category__mdt meta, String month, String year){
        String externalId = meta.Prefix_Branch_Category__c;
        externalId += month + '_' + year;
        return externalId;
    }

    public static String concatRollUpExternalId(Roll_up_by_Branch__mdt meta, String month, String year){
        String externalId = meta.Prefix_Branch_Building__c;
        externalId += month + '_' + year;
        return externalId;
    }

    public static Decimal calculateByRatio(Decimal value, Decimal numerator, Decimal denominator) {
        if (value == null || numerator == null || denominator == null || denominator == 0) { return 0; }
        Decimal revenue = (value / denominator) * numerator;
        revenue = revenue.setScale(4, RoundingMode.HALF_UP);
        return revenue;
    }

    public static Boolean isSameMonthYear(Date toCompareDate, Date targetDate) {
        if ((toCompareDate.month() == targetDate.month()) && (toCompareDate.year() == targetDate.year())) {
            return true;
        } else {
            return false;
        }
    }

    public static Date toEndOfMonth(Date currentDate) {
        return currentDate.toStartOfMonth().addMonths(1).addDays(-1);
    }

    private class SequenceComparator implements Comparator<ContractPeriod__c> {
        public Integer compare(ContractPeriod__c cp1, ContractPeriod__c cp2) {
            if (cp1 == null || cp2 == null) { return 0; }
            else if (cp1.Sequence__c == null || cp2.Sequence__c == null) { return 0; }
            else if (cp1.Sequence__c < cp2.Sequence__c) { return -1; }
            else if (cp1.Sequence__c > cp2.Sequence__c) { return 1; }
            else { return -1; }
        }
    }
}