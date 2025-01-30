public without sharing class DiscountController {

    public final static String DISCOUNT_TYPE_GP = 'Discount GP';
    public final static String DISCOUNT_TYPE_RENT = 'Discount Rent';
    public final static String DISCOUNT_TYPE_CAM = 'Discount CAM';
    public final static String DISCOUNT_TYPE_SERVICE = 'Discount Service';
    public final static Map<String, Integer> monthMap = new Map<String, Integer>{
        'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5, 'JUN' => 6,
        'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12
    };
    public final static List<String> GP_METHODS = new List<String>{
        Constant.CAL_METHOD_GP_NOMIN, Constant.CAL_METHOD_GP_WITHMIN, Constant.CAL_METHOD_GP_ONTOP
    };
    public final static String DISCOUNT_STATUS_NEW = 'New';
    public final static String DISCOUNT_STATUS_PENDING = 'Pending';
    public final static String DISCOUNT_STATUS_APPROVED = 'Approved';
    public final static String DISCOUNT_STATUS_REJECTED = 'Rejected';

    private List<Contract__c> contracts { get;set; }
    private Map<Id, Contract__c> mapContract { get;set; }
    private Map<Id, Decimal> mapTotalArea { get;set; }

    public class DiscountPerMonth{
        public String contractId { get;set; }
        public List<String> discountIdLst { get;set; }
        public Decimal rentDiscount { get;set; }
        public Decimal serviceDiscount { get;set; }
        public Decimal camDiscount { get;set; }
        public Decimal totalGPRevenue { get;set; }
        public Decimal totalGPRevenueDiscount { get;set; }
        public Decimal discountGPAmount { get;set; }
    }

    public DiscountController(List<Contract__c> contracts){
        this.contracts = contracts;
        mapContract = convertToMapContract(contracts);
    }

    public void stampMonthlyRevenueDiscount(List<Monthly_Revenue__c> monthlyRevenue){
        Map<String, DiscountPerMonth> mapDiscountByContract = breakdownDiscountIntoMonths();
        for(Monthly_Revenue__c each :monthlyRevenue){
            Contract__c contract = mapContract.get(each.Contract__c);
            Date endContractDate = contract.Status__c == Constant.CONTRACT_STAGE_TERMINATED && contract.Termination_Date__c != null? contract.Termination_Date__c : contract.Contract_End_Date__c;
            String key = each.Contract__c + '_' + each.Month__c + '_' + each.Year__c;
            DiscountPerMonth disPerMonth = mapDiscountByContract.get(key);
            Decimal totalArea = contract.Total_Leasable_Area__c;
            Decimal areaRatio = totalArea != null && totalArea != 0? (each.Area__c != null ? each.Area__c / totalArea : 0) : 1;
            // System.debug(LoggingLevel.DEBUG, 'disPerMonth : ' + disPerMonth);
            if (disPerMonth != null) {
                each.Discount_Rent__c = getDiscountValueOrDefault(disPerMonth.rentDiscount) * areaRatio;
                each.Discount_CAM__c = getDiscountValueOrDefault(disPerMonth.camDiscount) * areaRatio;
                each.Discount_Service__c = getDiscountValueOrDefault(disPerMonth.serviceDiscount) * areaRatio;
                each.Discount_GP__c = getDiscountValueOrDefault(disPerMonth.discountGPAmount) * areaRatio;
            }
            else{
                each.Discount_Rent__c = 0;
                each.Discount_CAM__c = 0;
                each.Discount_Service__c = 0;
                each.Discount_GP__c = 0;
            }

            DateTime dt = DateTime.newInstanceGmt(Integer.valueOf(each.Year__c), monthMap.get(each.Month__c), 1);
            Date firstDateCurMonth = dt.dateGMT();
            Date lastDateOfMonth = getLastDateOfMonth(firstDateCurMonth);
            Integer thisMonthDays = lastDateOfMonth.day();

            Integer graceDay = Integer.valueOf(contract.Grace_Day__c);
            Integer graceMonth = Integer.valueOf(contract.Grace_Month__c);
            if((graceDay > 0 || graceMonth > 0) && firstDateCurMonth < endContractDate){
                Decimal diffMonthFromStart = getDifferenceInMonths(contract.Contract_Start_Date__c, firstDateCurMonth);
                Integer graceDaysBeforeEndContract = null;
                Integer curDay = firstDateCurMonth.day();
                Integer curMonth = firstDateCurMonth.month();
                Integer curYear = firstDateCurMonth.year();
                Integer endContractDay = endContractDate.day();
                Integer endContractMonth = endContractDate.month();
                Integer endContractYear = endContractDate.year();
                Date dateAfterGraceMonth = Date.newInstance(contract.Contract_Start_Date__c.year(), contract.Contract_Start_Date__c.month(), 1);
                dateAfterGraceMonth = graceMonth > 0? dateAfterGraceMonth.addMonths(graceMonth) : dateAfterGraceMonth;
                Integer diffDaysAfterGraceMonth = dateAfterGraceMonth.daysBetween(firstDateCurMonth);
                if (curMonth == endContractMonth && curYear == endContractYear) {
                    if(curDay != endContractDay){
                        graceDaysBeforeEndContract = firstDateCurMonth.daysBetween(endContractDate) + 1;
                    }
                }

                if(diffMonthFromStart <= graceMonth){
                    each.Discount_Grace__c = graceDaysBeforeEndContract != null?  each.Total_Rent__c / thisMonthDays * graceDaysBeforeEndContract : each.Total_Rent__c;
                }
                else if(graceDay > diffDaysAfterGraceMonth){
                    Integer graceDayThisMonth = graceDay - diffDaysAfterGraceMonth > thisMonthDays? thisMonthDays : graceDay - diffDaysAfterGraceMonth;
                    each.Discount_Grace__c = each.Total_Rent__c / thisMonthDays * graceDayThisMonth;
                }
                else{
                    each.Discount_Grace__c = 0;
                }
            }
            else{
                each.Discount_Grace__c = 0;
            }
        }
    }

    public Map<String, DiscountPerMonth> breakdownDiscountIntoMonths(){
        Set<String> contractIds = new Set<String>();
        for(Contract__c contract :contracts){
            contractIds.add(contract.Id);
        }
        Map<String, DiscountPerMonth> mapDiscountByContract = new Map<String, DiscountPerMonth>();
        for(Discount__c discount :[SELECT Id, Name, Contract__c, Contract__r.ContractGrading__c, Contract__r.Contract_Start_Date__c, 
                                    Contract__r.Contract_End_Date__c, Contract__r.Termination_Date__c, Contract__r.Status__c, Contract__r.Calculation_Method__c,
                                    Discount_Type__c, Discount_Start_Date__c, Discount_End_Date__c, Discount_Price_per_Month__c, Discount_Percent__c
                                   FROM Discount__c 
                                   WHERE Contract__c IN :contractIds AND Status__c = :DISCOUNT_STATUS_APPROVED]){
            Date currentMonth = getFirstDateOfMonth(discount.Discount_Start_Date__c);
            Date endDiscount = discount.Contract__r.Status__c == Constant.CONTRACT_STAGE_TERMINATED && discount.Contract__r.Termination_Date__c != null? discount.Contract__r.Termination_Date__c : discount.Contract__r.Contract_End_Date__c;
            if(discount.Discount_End_Date__c < endDiscount){
                endDiscount = discount.Discount_End_Date__c;
            }
            while(currentMonth < discount.Discount_End_Date__c){
                Datetime dt = Datetime.newInstance(currentMonth.year(), currentMonth.month(), currentMonth.day());
                String key = discount.Contract__c + '_' + dt.format('MMM').toUpperCase() + '_' + dt.format('yyyy');
                Date recordDate = dt.date();
                Date lastDateOfMonth = getLastDateOfMonth(recordDate);
                Integer thisMonthDays = lastDateOfMonth.day();
                Integer rentDays = 0;
                if(currentMonth < discount.Discount_Start_Date__c){
                    rentDays = discount.Discount_Start_Date__c.daysBetween(lastDateOfMonth);
                }
                else if(currentMonth > endDiscount){
                    rentDays = 0;
                }
                else if(endDiscount < lastDateOfMonth){
                    rentDays = currentMonth.daysBetween(endDiscount);
                }
                else{
                    rentDays = currentMonth.daysBetween(lastDateOfMonth);
                }
                rentDays = rentDays > 0? rentDays + 1 : 0;
                // System.debug(LoggingLevel.DEBUG, 'recordDate : ' + recordDate);
                // System.debug(LoggingLevel.DEBUG, 'rentDays : ' + rentDays);
                // update data if same contract, another discount type
                DiscountPerMonth disPerMonth = mapDiscountByContract.containsKey(key)? mapDiscountByContract.get(key) : new DiscountPerMonth();
                if(disPerMonth.discountIdLst == null){
                    disPerMonth.discountIdLst = new List<String>();
                }
                disPerMonth.contractId = discount.Contract__c;
                disPerMonth.discountIdLst.add(discount.Id);
                if(discount.Discount_Type__c == DISCOUNT_TYPE_GP){
                    Contract__c contract = mapContract.get(discount.Contract__c);
                    List<ContractPeriod__c> thisMonthPeriods = new List<ContractPeriod__c>();
                    for(ContractPeriod__c period :contract.Contract_Periods__r){
                        if(GP_METHODS.contains(period.CalculationMethod__c)){
                            if(currentMonth >= period.PeriodFrom__c && currentMonth <= period.PeriodTo__c){
                                thisMonthPeriods.add(period);
                            }
                            // same month but out of period range
                            else{
                                Integer curMonth = currentMonth.month();
                                Integer curYear = currentMonth.year();

                                Integer periodFromMonth = period.PeriodFrom__c.month();
                                Integer periodFromYear = period.PeriodFrom__c.year();

                                Integer periodToMonth = period.PeriodTo__c.month();
                                Integer periodToYear = period.PeriodTo__c.year();
                                if ((curMonth == periodFromMonth && curYear == periodFromYear) || (curMonth == periodToMonth && curYear == periodToYear)) {
                                    thisMonthPeriods.add(period);
                                }
                            }
                        }
                    }
                    disPerMonth.totalGPRevenue = 0;
                    disPerMonth.totalGPRevenueDiscount = 0;
                    Decimal totalRentMonth = 0;
                    for(ContractPeriod__c period :thisMonthPeriods){
                        Date periodStart = period.PeriodFrom__c >= currentMonth? period.PeriodFrom__c : currentMonth;
                        Date periodEnd = period.PeriodTo__c >= lastDateOfMonth? period.PeriodTo__c : lastDateOfMonth;
                        Integer periodDays =  periodStart.daysBetween(periodEnd) + 1;
                        Integer discountDays = Math.min(periodDays, rentDays);
                        Decimal estimatedRevenue = period.EstimateRevenue__c != null? period.EstimateRevenue__c : 0;
                        disPerMonth.totalGPRevenue += calculateGPRevenue(discount.Contract__r.ContractGrading__c, estimatedRevenue, currentMonth, null);
                        disPerMonth.totalGPRevenueDiscount += calculateGPRevenue(discount.Contract__r.ContractGrading__c, estimatedRevenue, currentMonth, discount.Discount_Percent__c);
                        if(rentDays != thisMonthDays || periodDays != thisMonthDays){
                            disPerMonth.totalGPRevenue = callDiscountByMonthDays(disPerMonth.totalGPRevenue, thisMonthDays, discountDays);
                            disPerMonth.totalGPRevenueDiscount = callDiscountByMonthDays(disPerMonth.totalGPRevenueDiscount, thisMonthDays, discountDays);
                        }
                        if(discount.Contract__r.Calculation_Method__c == Constant.CAL_METHOD_GP_WITHMIN){
                            totalRentMonth += period.RentMonth__c + period.ServiceMonth__c;
                        }
                    }
                    disPerMonth.discountGPAmount = disPerMonth.discountGPAmount != null? disPerMonth.discountGPAmount : 0;
                    disPerMonth.discountGPAmount += disPerMonth.totalGPRevenue - disPerMonth.totalGPRevenueDiscount;
                    if(discount.Contract__r.Calculation_Method__c == Constant.CAL_METHOD_GP_WITHMIN){
                        // if revenue from %GP of Estimate Revenue less than Fix Price Rent then No GP Revenue
                        if(disPerMonth.totalGPRevenue <= totalRentMonth){
                            disPerMonth.discountGPAmount = 0;
                        }
                    }
                } 
                else if(discount.Discount_Type__c == DISCOUNT_TYPE_RENT){
                    // if not a full month, cal discount per day
                    disPerMonth.rentDiscount = disPerMonth.rentDiscount != null? disPerMonth.rentDiscount : 0;
                    disPerMonth.rentDiscount += rentDays != thisMonthDays? callDiscountByMonthDays(discount.Discount_Price_per_Month__c, thisMonthDays, rentDays) : discount.Discount_Price_per_Month__c;
                }
                else if(discount.Discount_Type__c == DISCOUNT_TYPE_CAM){
                    disPerMonth.camDiscount = disPerMonth.camDiscount != null? disPerMonth.camDiscount : 0;
                    disPerMonth.camDiscount += rentDays != thisMonthDays? callDiscountByMonthDays(discount.Discount_Price_per_Month__c, thisMonthDays, rentDays) : discount.Discount_Price_per_Month__c;
                }
                else if(discount.Discount_Type__c == DISCOUNT_TYPE_SERVICE){
                    disPerMonth.serviceDiscount = disPerMonth.serviceDiscount != null? disPerMonth.serviceDiscount : 0;
                    disPerMonth.serviceDiscount += rentDays != thisMonthDays? callDiscountByMonthDays(discount.Discount_Price_per_Month__c, thisMonthDays, rentDays) : discount.Discount_Price_per_Month__c;
                }
                
                mapDiscountByContract.put(key, disPerMonth);
                currentMonth = currentMonth.addMonths(1);
            }
        }
        return mapDiscountByContract;
    }

    private static Map<Id, Contract__c> convertToMapContract(List<Contract__c> contracts){
        Map<Id, Contract__c> mapContract = new Map<Id, Contract__c>();
        for(Contract__c each :contracts){
            mapContract.put(each.Id, each);
        }
        return mapContract;
    }

    public static Decimal calculateGPRevenue(String oppGradingJson, Decimal estimatedRevenue, Date currentMonth, Decimal discountGP){
        Decimal totalGPRevenue = 0;
        // Decimal remainingAmount = estimatedRevenue;
        if (oppGradingJson != null) {
            List<ContractGradingModel.Data> oppGrading = ContractGradingModel.parse(oppGradingJson);
            List<GradingGPWrapper> currentPeriodGrading = new List<GradingGPWrapper>();
            for(ContractGradingModel.Data each :oppGrading) {
                if(currentMonth >= each.GradingPeriodForm && currentMonth <= each.GradingPeriodTo && estimatedRevenue >= each.fromR){
                    GradingGPWrapper gradingGP = new GradingGPWrapper();
                    gradingGP.fromR = each.FromR;
                    gradingGP.toR = each.ToR;
                    gradingGP.gp = discountGP == null? each.GP : (discountGP > each.GP? 0 : each.GP - discountGP);
                    currentPeriodGrading.add(gradingGP);
                }
            }
            currentPeriodGrading.sort();
            // คิดแบบขั้นบันไดภาษี
            // for(GradingGPWrapper grading :currentPeriodGrading) {
            //     if (remainingAmount > 0) {
            //         // ToR = 0, range is >= FromR (to infinity)
            //         Decimal rangeAmount = grading.toR == 0? remainingAmount : Math.min(remainingAmount, grading.toR) - grading.fromR;
            //         remainingAmount -= rangeAmount;
            //         totalGPRevenue += rangeAmount * grading.gp / 100;
            //     }
            // }

            // คิดแบบเอาช่วงราคาเดียวที่ Estimate ถึงช่วงเริ่มต้น
            if(currentPeriodGrading.size() > 0){
                totalGPRevenue += estimatedRevenue * currentPeriodGrading[currentPeriodGrading.size() - 1].gp / 100;
            }
        }
        
        return totalGPRevenue;
    }

    public static Decimal callDiscountByMonthDays(Decimal totalAmount, Integer thisMonthDays, Integer rentDays){
        if(rentDays == 0 || totalAmount == null){
            return 0;
        }
        Decimal realDiscount = (totalAmount / thisMonthDays) * rentDays;
        return realDiscount;
    }

    public static Date getFirstDateOfMonth(Date targetDate){
        return targetDate.toStartOfMonth();
    }

    public static Date getLastDateOfMonth(Date targetDate){
        return targetDate.toStartOfMonth().addMonths(1).addDays(-1);
    }

    public static Integer getDifferenceInMonths(Date startDate, Date endDate) {
        Integer startYear = startDate.year();
        Integer endYear = endDate.year();
        Integer startMonth = startDate.month();
        Integer endMonth = endDate.month();

        return (endYear - startYear) * 12 + (endMonth - startMonth) + 1;
    }

    private Decimal getDiscountValueOrDefault(Decimal discountValue) {
        return discountValue != null ? discountValue : 0;
    }

    public class GradingGPWrapper implements Comparable{
        public Decimal fromR {get; set;}
        public Decimal toR {get; set;}
        public Decimal gp {get; set;}

        public Integer compareTo(Object obj) {
            GradingGPWrapper other = (GradingGPWrapper)obj;
            if (this.fromR < other.fromR) {
                return -1;
            } else if (this.fromR == other.fromR) {
                return 0;
            } else {
                return 1;
            }
        }
    }
}