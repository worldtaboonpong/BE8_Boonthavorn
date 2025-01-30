@isTest
public with sharing class DiscountControllerTest {

    @isTest
    private static void testNoDiscount(){
        Date today = Date.today();
        Date firstDay = Date.newInstance(today.year(), today.month(), 1);
        Date midMonth = today.addDays(15);
        Date lastDay = DiscountController.getLastDateOfMonth(today);

        Contract__c contract = MockUpDataFor_Test.getContractList(1)[0];
        contract.Contract_Start_Date__c = firstDay;
        contract.Contract_End_Date__c = lastDay;
        contract.Grace_Month__c = 0;
        contract.Grace_Day__c = 0;
        insert contract;

        Datetime month1 = Datetime.now();
        List<Monthly_Revenue__c> monthlyRevenueLst = new List<Monthly_Revenue__c>();
        Monthly_Revenue__c mr1 = new Monthly_Revenue__c();
        mr1.Contract__c = contract.Id;
        mr1.Month__c = month1.format('MMM').toUpperCase();
        mr1.Year__c = month1.format('yyyy');
        mr1.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr1);
        
        Test.startTest();
        List<Contract__c> ct = [SELECT Id, Termination_Date__c, Grace_Month__c, Grace_Day__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, Total_Leasable_Area__c, (SELECT Id, CalculationMethod__c, EstimateRevenue__c, Contract__c, PeriodFrom__c, PeriodTo__c, SalesMin__c FROM Contract_Periods__r) FROM Contract__c];
        DiscountController dc = new DiscountController(ct);
        dc.stampMonthlyRevenueDiscount(monthlyRevenueLst);
        Test.stopTest();

        System.assertEquals(0, monthlyRevenueLst[0].Discount_Grace__c, 'Grace Discount should = 0');
    }

    @isTest
    private static void testDiscountType(){
        Date today = Date.today();
        Date firstDay = Date.newInstance(today.year(), today.month(), 1);
        Date midMonth = today.addDays(15);
        Date lastDay = DiscountController.getLastDateOfMonth(today);

        Date threeMonthLater = today.addMonths(2);
        Date firstDay3 = Date.newInstance(threeMonthLater.year(), threeMonthLater.month(), 1);
        Date midMonth3 = threeMonthLater.addDays(15);
        Date lastDay3 = DiscountController.getLastDateOfMonth(threeMonthLater);

        Contract__c contract = MockUpDataFor_Test.getContractList(1)[0];
        contract.Contract_Start_Date__c = firstDay;
        contract.Contract_End_Date__c = lastDay3;
        contract.Grace_Month__c = 1;
        contract.Grace_Day__c = 10;
        insert contract;
        
        ContractPeriod__c contractPeriod = new ContractPeriod__c();
        contractPeriod.Contract__c = contract.Id;
        contractPeriod.PeriodFrom__c = firstDay;
        contractPeriod.PeriodTo__c = lastDay3; 
        contractPeriod.Sequence__c = 1;
        contractPeriod.CalculationMethod__c = Constant.CAL_METHOD_GP_NOMIN;
        contractPeriod.EstimateRevenue__c = 20000000;
        insert contractPeriod;
        
        ContractGradingModel.Data grading = MockUpDataFor_Test.createContractGrading(contract, contractPeriod, 0, 0);
        contract.ContractGrading__c = ContractGradingModel.toString(new List<ContractGradingModel.Data>{ grading });
        update contract;

        List<Discount__c> discounts = new List<Discount__c>();
        Discount__c rentDiscount = new Discount__c(Contract__c = contract.Id);
        rentDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_RENT;
        rentDiscount.Discount_Start_Date__c = firstDay3;
        rentDiscount.Discount_End_Date__c = lastDay3;
        rentDiscount.Discount_Price_per_Month__c = 30000;
        rentDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(rentDiscount);

        Discount__c serviceDiscount = new Discount__c(Contract__c = contract.Id);
        serviceDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_SERVICE;
        serviceDiscount.Discount_Start_Date__c = firstDay3;
        serviceDiscount.Discount_End_Date__c = lastDay3;
        serviceDiscount.Discount_Price_per_Month__c = 20000;
        serviceDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(serviceDiscount);
        
        Discount__c camDiscount = new Discount__c(Contract__c = contract.Id);
        camDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_CAM;
        camDiscount.Discount_Start_Date__c = firstDay3;
        camDiscount.Discount_End_Date__c = lastDay3;
        camDiscount.Discount_Price_per_Month__c = 10000;
        camDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(camDiscount);
        
        Discount__c gpDiscount = new Discount__c(Contract__c = contract.Id);
        gpDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_GP;
        gpDiscount.Discount_Start_Date__c = firstDay3;
        gpDiscount.Discount_End_Date__c = midMonth3;
        gpDiscount.Discount_Percent__c = 2;
        gpDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(gpDiscount);
        insert discounts;

        Datetime month1 = Datetime.now();
        Datetime month2 = month1.addMonths(1);
        Datetime month3 = month1.addMonths(2);
        List<Monthly_Revenue__c> monthlyRevenueLst = new List<Monthly_Revenue__c>();
        Monthly_Revenue__c mr1 = new Monthly_Revenue__c();
        mr1.Contract__c = contract.Id;
        mr1.Month__c = month1.format('MMM').toUpperCase();
        mr1.Year__c = month1.format('yyyy');
        mr1.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr1);
        Monthly_Revenue__c mr2 = new Monthly_Revenue__c();
        mr2.Contract__c = contract.Id;
        mr2.Month__c = month2.format('MMM').toUpperCase();
        mr2.Year__c = month2.format('yyyy');
        mr2.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr2);
        Monthly_Revenue__c mr3 = new Monthly_Revenue__c();
        mr3.Contract__c = contract.Id;
        mr3.Month__c = month3.format('MMM').toUpperCase();
        mr3.Year__c = month3.format('yyyy');
        mr3.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr3);

        Test.startTest();
        List<Contract__c> ct = [SELECT Id, Termination_Date__c, Grace_Month__c, Grace_Day__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, Total_Leasable_Area__c, (SELECT Id, CalculationMethod__c, EstimateRevenue__c, Contract__c, PeriodFrom__c, PeriodTo__c, SalesMin__c FROM Contract_Periods__r) FROM Contract__c];
        DiscountController dc = new DiscountController(ct);
        dc.stampMonthlyRevenueDiscount(monthlyRevenueLst);
        Test.stopTest();

        System.assertNotEquals(0, monthlyRevenueLst[0].Discount_Grace__c, 'Grace Discount first month should > 0');
        System.assertEquals(0, monthlyRevenueLst[2].Discount_Grace__c, 'Grace Discount last month should = 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_Rent__c, 'Rent Discount last month should > 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_CAM__c, 'CAM Discount last month should > 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_Service__c, 'Service Discount last month should > 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_GP__c, 'GP Discount last month should > 0');
    }

    @isTest
    private static void testCalDiscountPerDay(){
        Date today = Date.today();
        Date firstDay = Date.newInstance(today.year(), today.month(), 1);
        Date midMonth = today.addDays(15);
        Date lastDay = DiscountController.getLastDateOfMonth(today);

        Date twoMonthLater = today.addMonths(1);
        Date midMonth2 = twoMonthLater.addDays(15);

        Date threeMonthLater = today.addMonths(2);
        Date firstDay3 = Date.newInstance(threeMonthLater.year(), threeMonthLater.month(), 1);
        Date midMonth3 = threeMonthLater.addDays(15);
        Date lastDay3 = DiscountController.getLastDateOfMonth(threeMonthLater);

        Contract__c contract = MockUpDataFor_Test.getContractList(1)[0];
        contract.Contract_Start_Date__c = firstDay;
        contract.Contract_End_Date__c = midMonth3;
        contract.Grace_Month__c = 1;
        contract.Grace_Day__c = 10;
        insert contract;
        
        List<ContractPeriod__c> periods = new List<ContractPeriod__c>();
        ContractPeriod__c contractPeriod = new ContractPeriod__c();
        contractPeriod.Contract__c = contract.Id;
        contractPeriod.PeriodFrom__c = firstDay;
        contractPeriod.PeriodTo__c = midMonth; 
        contractPeriod.Sequence__c = 1;
        contractPeriod.CalculationMethod__c = Constant.CAL_METHOD_GP_NOMIN;
        contractPeriod.EstimateRevenue__c = 20000000;
        periods.add(contractPeriod);
        ContractPeriod__c contractPeriod2 = new ContractPeriod__c();
        contractPeriod2.Contract__c = contract.Id;
        contractPeriod2.PeriodFrom__c = midMonth;
        contractPeriod2.PeriodTo__c = midMonth2; 
        contractPeriod2.Sequence__c = 2;
        contractPeriod2.CalculationMethod__c = Constant.CAL_METHOD_GP_NOMIN;
        contractPeriod2.EstimateRevenue__c = 20000000;
        periods.add(contractPeriod2);
        ContractPeriod__c contractPeriod3 = new ContractPeriod__c();
        contractPeriod3.Contract__c = contract.Id;
        contractPeriod3.PeriodFrom__c = midMonth2;
        contractPeriod3.PeriodTo__c = midMonth3; 
        contractPeriod3.Sequence__c = 3;
        contractPeriod3.CalculationMethod__c = Constant.CAL_METHOD_GP_NOMIN;
        contractPeriod3.EstimateRevenue__c = 20000000;
        periods.add(contractPeriod3);
        insert periods;

        ContractGradingModel.Data grading = MockUpDataFor_Test.createContractGrading(contract, contractPeriod, 0, 2000000);
        contract.ContractGrading__c = ContractGradingModel.toString(new List<ContractGradingModel.Data>{ grading });
        update contract;

        List<Discount__c> discounts = new List<Discount__c>();
        Discount__c rentDiscount = new Discount__c(Contract__c = contract.Id);
        rentDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_RENT;
        rentDiscount.Discount_Start_Date__c = midMonth2;
        rentDiscount.Discount_End_Date__c = lastDay3;
        rentDiscount.Discount_Price_per_Month__c = 30000;
        rentDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(rentDiscount);

        Discount__c serviceDiscount = new Discount__c(Contract__c = contract.Id);
        serviceDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_SERVICE;
        serviceDiscount.Discount_Start_Date__c = midMonth2;
        serviceDiscount.Discount_End_Date__c = lastDay3;
        serviceDiscount.Discount_Price_per_Month__c = 20000;
        serviceDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(serviceDiscount);
        
        Discount__c camDiscount = new Discount__c(Contract__c = contract.Id);
        camDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_CAM;
        camDiscount.Discount_Start_Date__c = midMonth2;
        camDiscount.Discount_End_Date__c = lastDay3;
        camDiscount.Discount_Price_per_Month__c = 10000;
        camDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(camDiscount);
        
        Discount__c gpDiscount = new Discount__c(Contract__c = contract.Id);
        gpDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_GP;
        gpDiscount.Discount_Start_Date__c = firstDay;
        gpDiscount.Discount_End_Date__c = lastDay3;
        gpDiscount.Discount_Percent__c = 2;
        gpDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(gpDiscount);
        insert discounts;

        Datetime month1 = Datetime.now();
        Datetime month2 = month1.addMonths(1);
        Datetime month3 = month1.addMonths(2);
        List<Monthly_Revenue__c> monthlyRevenueLst = new List<Monthly_Revenue__c>();
        Monthly_Revenue__c mr1 = new Monthly_Revenue__c();
        mr1.Contract__c = contract.Id;
        mr1.Month__c = month1.format('MMM').toUpperCase();
        mr1.Year__c = month1.format('yyyy');
        mr1.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr1);
        Monthly_Revenue__c mr2 = new Monthly_Revenue__c();
        mr2.Contract__c = contract.Id;
        mr2.Month__c = month2.format('MMM').toUpperCase();
        mr2.Year__c = month2.format('yyyy');
        mr2.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr2);
        Monthly_Revenue__c mr3 = new Monthly_Revenue__c();
        mr3.Contract__c = contract.Id;
        mr3.Month__c = month3.format('MMM').toUpperCase();
        mr3.Year__c = month3.format('yyyy');
        mr3.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr3);

        Test.startTest();
        List<Contract__c> ct = [SELECT Id, Termination_Date__c, Grace_Month__c, Grace_Day__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, Total_Leasable_Area__c, (SELECT Id, CalculationMethod__c, EstimateRevenue__c, Contract__c, PeriodFrom__c, PeriodTo__c, SalesMin__c FROM Contract_Periods__r) FROM Contract__c];
        DiscountController dc = new DiscountController(ct);
        dc.stampMonthlyRevenueDiscount(monthlyRevenueLst);
        Test.stopTest();

        System.assertNotEquals(0, monthlyRevenueLst[0].Discount_Grace__c, 'Grace Discount first month should > 0');
        System.assertEquals(0, monthlyRevenueLst[2].Discount_Grace__c, 'Grace Discount last month should = 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_Rent__c, 'Rent Discount last month should > 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_CAM__c, 'CAM Discount last month should > 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_Service__c, 'Service Discount last month should > 0');
        System.assertNotEquals(0, monthlyRevenueLst[2].Discount_GP__c, 'GP Discount last month should > 0');
    }

    @isTest
    private static void testGPonTopNotReachMinRevenue(){
        Date today = Date.today();
        Date firstDay = Date.newInstance(today.year(), today.month(), 1);
        Date midMonth = today.addDays(15);
        Date lastDay = DiscountController.getLastDateOfMonth(today);


        Date threeMonthLater = today.addMonths(2);
        Date firstDay3 = Date.newInstance(threeMonthLater.year(), threeMonthLater.month(), 1);
        Date midMonth3 = threeMonthLater.addDays(15);
        Date lastDay3 = DiscountController.getLastDateOfMonth(threeMonthLater);

        Contract__c contract = MockUpDataFor_Test.getContractList(1)[0];
        contract.Contract_Start_Date__c = firstDay;
        contract.Contract_End_Date__c = lastDay3;
        contract.Grace_Month__c = 0;
        contract.Grace_Day__c = 0;
        insert contract;
        
        List<ContractPeriod__c> periods = new List<ContractPeriod__c>();
        ContractPeriod__c contractPeriod = new ContractPeriod__c();
        contractPeriod.Contract__c = contract.Id;
        contractPeriod.PeriodFrom__c = firstDay;
        contractPeriod.PeriodTo__c = lastDay3; 
        contractPeriod.Sequence__c = 1;
        contractPeriod.CalculationMethod__c = Constant.CAL_METHOD_GP_ONTOP;
        contractPeriod.EstimateRevenue__c = 2000000;
        periods.add(contractPeriod);
        insert periods;

        ContractGradingModel.Data grading = MockUpDataFor_Test.createContractGrading(contract, contractPeriod, 3000000, 0);
        contract.ContractGrading__c = ContractGradingModel.toString(new List<ContractGradingModel.Data>{ grading });
        update contract;

        List<Discount__c> discounts = new List<Discount__c>();
        Discount__c gpDiscount = new Discount__c(Contract__c = contract.Id);
        gpDiscount.Discount_Type__c = DiscountController.DISCOUNT_TYPE_GP;
        gpDiscount.Discount_Start_Date__c = firstDay;
        gpDiscount.Discount_End_Date__c = lastDay3;
        gpDiscount.Discount_Percent__c = 2;
        gpDiscount.Status__c = DiscountController.DISCOUNT_STATUS_APPROVED;
        discounts.add(gpDiscount);
        insert discounts;

        Datetime month1 = Datetime.now();
        List<Monthly_Revenue__c> monthlyRevenueLst = new List<Monthly_Revenue__c>();
        Monthly_Revenue__c mr1 = new Monthly_Revenue__c();
        mr1.Contract__c = contract.Id;
        mr1.Month__c = month1.format('MMM').toUpperCase();
        mr1.Year__c = month1.format('yyyy');
        mr1.Total_Rent__c = 3012500;
        monthlyRevenueLst.add(mr1);

        Test.startTest();
        List<Contract__c> ct = [SELECT Id, Termination_Date__c, Grace_Month__c, Grace_Day__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, Total_Leasable_Area__c, (SELECT Id, CalculationMethod__c, EstimateRevenue__c, Contract__c, PeriodFrom__c, PeriodTo__c, SalesMin__c FROM Contract_Periods__r) FROM Contract__c];
        DiscountController dc = new DiscountController(ct);
        dc.stampMonthlyRevenueDiscount(monthlyRevenueLst);
        Test.stopTest();

        System.assertEquals(0, monthlyRevenueLst[0].Discount_GP__c, 'GP Discount should = 0');
    }

    @isTest
    private static void testComparable(){
        List<DiscountController.GradingGPWrapper> currentPeriodGrading = new List<DiscountController.GradingGPWrapper>();
        DiscountController.GradingGPWrapper gradingGP = new DiscountController.GradingGPWrapper();
        gradingGP.fromR = 20000000;
        gradingGP.toR = 0;
        gradingGP.gp = 8;
        currentPeriodGrading.add(gradingGP);
        DiscountController.GradingGPWrapper gradingGP2 = new DiscountController.GradingGPWrapper();
        gradingGP2.fromR = 0;
        gradingGP2.toR = 20000000;
        gradingGP2.gp = 10;
        currentPeriodGrading.add(gradingGP2);
        currentPeriodGrading.sort();

        System.assertEquals(0, currentPeriodGrading[0].fromR, 'Sorting Result should be min to max');
    }
}