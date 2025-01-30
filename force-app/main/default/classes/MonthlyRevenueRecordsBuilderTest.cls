@isTest
public with sharing class MonthlyRevenueRecordsBuilderTest {
    @TestSetup
    static void makeData() {
        Datetime todayDate = Datetime.now();
        String month = todayDate.formatGmt('MMM').toUpperCase();
        String year = todayDate.formatGmt('yyyy');

        Branch__c branch = new Branch__c (
        	Name = 'Design Village บางนา',
            Branch_Code__c = 'DVB'
        );
        insert branch;

        Building__c building = new Building__c (
            Name = 'Design Village - บางนา_A',
            Building_Name_TH__c = 'ดีไซน์ วิลเลจ บางนา',
            Building_Abbreviated__c = 'A',
            Active__c = false,
            Branch__c = branch.Id
        );
        insert building;

        Floor__c floor = new Floor__c(
            Building__c = building.Id,
            Name = 'Test Floor Name',
            Floor_Code__c = 'F1000',
            Floor_Short_Name__c = 'F10'
        );
        insert floor;

        String category;
        Map<String, sObjectField> objectResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectResult.get('Category__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if (ple.size() > 0) {
            category = ple.get(0).getValue();
        }

        String branchPrefix;
        String buildingPrefix;
        String categoryPrefix;
        String branchCategoryPrefix;
        List<Roll_up_by_Branch__mdt> rollUpBranchMdt = Roll_up_by_Branch__mdt.getAll().values();
        for (Roll_up_by_Branch__mdt rollUpByBranchItem : rollUpBranchMdt) {
            if (branch.Name == rollUpByBranchItem.Branch_Name__c && building.Name == rollUpByBranchItem.Building_Name__c && rollUpByBranchItem.Is_Active__c == true) {
                branchPrefix = rollUpByBranchItem.Prefix_Branch__c;
                buildingPrefix = rollUpByBranchItem.Prefix_Branch_Building__c;
            }
        }

        List<Roll_up_by_Category__mdt> rollUpCategoryMdt = Roll_up_by_Category__mdt.getAll().values();
        for (Roll_up_by_Category__mdt rollUpCategoryItem : rollUpCategoryMdt) {
            if (category == rollUpCategoryItem.Category__c && branch.Name == rollUpCategoryItem.Branch_Name__c && rollUpCategoryItem.Is_Active__c == true) {
                categoryPrefix = rollUpCategoryItem.Prefix_Category__c;
                branchCategoryPrefix = rollUpCategoryItem.Prefix_Branch_Category__c;
            }
        }

        String branchExt = branchPrefix+month+'_'+year;
        Roll_up_Area_Branch__c rollupBranch = new Roll_up_Area_Branch__c();
        rollupBranch.Month__c = month;
        rollupBranch.Year__c = year;
        rollupBranch.Name = branchExt;
        rollupBranch.External_Id__c = branchExt;
        rollupBranch.Branch__c = branch.Id;
        insert rollupBranch;

        String buildingExt = buildingPrefix+month+'_'+year;
        Roll_up_Area_Building__c rollupBuilding = new  Roll_up_Area_Building__c();
        rollupBuilding.Month__c = month;
        rollupBuilding.Year__c = year;
        rollupBuilding.Name = buildingExt;
        rollupBuilding.External_Id__c = buildingExt;
        rollupBuilding.Branch__c = building.Branch__c;
        rollupBuilding.Building__c = building.Id;
        rollupBuilding.Roll_up_Area_Branch__c = rollupBranch.Id;
        insert rollupBuilding;

        String categoryExt = categoryPrefix+month+'_'+year;
        Roll_up_Category__c rollupCategory = new Roll_up_Category__c();
        rollupCategory.Month__c = month;
        rollupCategory.Year__c = year;
        rollupCategory.Name = categoryExt;
        rollupCategory.External_Id__c = categoryExt;
        rollupCategory.Category__c = category;
        insert rollupCategory;

        String branchCategoryExt = branchCategoryPrefix+month+'_'+year;
        Roll_up_Category_and_Branch__c rollupBranchCategory = new Roll_up_Category_and_Branch__c();
        rollupBranchCategory.Month__c = month;
        rollupBranchCategory.Year__c = year;
        rollupBranchCategory.Name = categoryExt;
        rollupBranchCategory.External_Id__c = categoryExt;
        rollupBranchCategory.Category__c = category;
        rollupBranchCategory.Branch__c = branch.Id;
        rollupBranchCategory.Roll_up_Category__c = rollupCategory.Id;
        insert rollupBranchCategory;
    }

    @isTest
    public static void test_gp_noMinCalculation() {
        Datetime todayDate = Datetime.now();
        String month = todayDate.formatGmt('MMM').toUpperCase();
        String year = todayDate.formatGmt('yyyy');

        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        Floor__c floor = [SELECT Id FROM Floor__c LIMIT 1];

        Units__c unit = new Units__c(
            Building__c = building.Id,
            Floor__c = floor.Id,
            Usage_Type__c = 'Office Rental'
        ); 
        insert unit;

        String category;
        Map<String, sObjectField> objectResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectResult.get('Category__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if (ple.size() > 0) {
            category = ple.get(0).getValue();
        }

        Contact contact = new Contact();
        contact.LastName = 'Dummy';
        contact.Email = 'test@gmail.com';
        insert contact;

        Account account = new Account(Name = 'Test');
        account.Address__c = 'Address';
        account.Subdistrict__c = 'Subdistrict';
        account.District__c = 'District';
        account.Province__c = 'Province';
        account.ZipCode__c = 'ZipCode';
        account.Mobile_Phone__c = '0990000000';
        insert account;

        Opportunity opp = new Opportunity(Name = 'Test');
        opp.AccountId = account.Id;
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        opp.OpportunityGrading__c = '[{}]';
        opp.OpportunityLeaseholdFloor__c = '[{}]';
        opp.DepositMeasurement__c = '[{}]';
        opp.Contract_Type__c = 'Long-Term GP Rent';
        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_NOMIN;
        opp.Category__c = category;
        opp.Revenue_Collected_By__c = 'BTA เก็บเงิน';
        insert opp;

        Id RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId();
        Contract__c contract = new Contract__c();
        contract.Name = 'My Contract';
        contract.Contract_Start_Date__c = Date.today().addYears(-2);
        contract.Contract_End_Date__c = Date.today().addYears(2);
        contract.Status__c = Constant.CONTRACT_STATUS_TERMINATED;
        contract.ContractGrading__c = '[{}]';
        // Calculation_Method__c = Formula
        contract.Termination_Date__c = Date.today().addYears(1);
        // Category__c = Formula
        contract.Building__c = building.Id;
        contract.Opportunity_Name__c = opp.Id;
        contract.Actual_of_Billing_Rent_Service__c = Date.today().addYears(-2);
        contract.Actual_of_Billing_Insurance__c = Date.today().addYears(-2);
        contract.Actual_of_Decorate_the_Space__c = Date.today().addYears(-2);
        contract.Actual_of_Delivery_the_Area__c = Date.today().addYears(-2);
        contract.Actual_of_Design_Guideline__c = Date.today().addYears(-2);
        contract.Actual_of_Signed_Contract__c = Date.today().addYears(-2);
        contract.Actual_of_Shop_Open__c = Date.today().addYears(-2);
        contract.Termination_Fee__c = 0;
        contract.Termination_Period_Day__c = 0;
        contract.Termiation_Period_Months__c = 0;
        contract.RecordTypeId = RecordTypeId;
        insert contract;

        ContractLineItem__c cli = new ContractLineItem__c();
        cli.Contract__c = contract.Id;
        cli.Unit__c = unit.Id;
        cli.LeasableArea__c = 100;
        insert cli;

        List<ContractPeriod__c> cpList = new List<ContractPeriod__c>();
        ContractPeriod__c cpPrice = new ContractPeriod__c();
        cpPrice.Contract__c = contract.Id;
        cpPrice.PeriodFrom__c = Date.today().addYears(-2);
        cpPrice.PeriodTo__c = Date.today();
        cpPrice.RentMonth__c = 0;
        cpPrice.ServiceMonth__c = 0;
        cpPrice.EstimateRevenue__c = 400000;
        cpPrice.CalculationMethod__c = Constant.CAL_METHOD_GP_NOMIN;
        cpPrice.Sequence__c = 1;
        cpList.add(cpPrice);

        ContractPeriod__c cpCAM = new ContractPeriod__c();
        cpCAM.Contract__c = contract.Id;
        cpCAM.PeriodFrom__c = Date.today().addYears(-2);
        cpCAM.PeriodTo__c = Date.today();
        cpCAM.CAMMonth__c = 20000;
        cpCAM.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM.Sequence__c = 1;
        cpList.add(cpCAM);

        ContractPeriod__c cpPrice2 = new ContractPeriod__c();
        cpPrice2.Contract__c = contract.Id;
        cpPrice2.PeriodFrom__c = Date.today().addDays(1);
        cpPrice2.PeriodTo__c = Date.today().addYears(2);
        cpPrice2.RentMonth__c = 0;
        cpPrice2.ServiceMonth__c = 0;
        cpPrice2.EstimateRevenue__c = 400000;
        cpPrice2.CalculationMethod__c = Constant.CAL_METHOD_GP_NOMIN;
        cpPrice2.Sequence__c = 2;
        cpList.add(cpPrice2);

        ContractPeriod__c cpCAM2 = new ContractPeriod__c();
        cpCAM2.Contract__c = contract.Id;
        cpCAM2.PeriodFrom__c = Date.today().addDays(1);
        cpCAM2.PeriodTo__c = Date.today().addYears(2);
        cpCAM2.CAMMonth__c = 22000;
        cpCAM2.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM2.Sequence__c = 2;
        cpList.add(cpCAM2);

        insert cpList;

        
        contract.ContractGrading__c = '[{"ToR":500000,"SalesDescription":"","ReportingRule":null,"Name":null,"IsIncludeCAM":true,"IsGrading":true,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"'+String.valueOf(Date.today().addYears(2))+'","GradingPeriodForm":"'+String.valueOf(Date.today().addYears(-2))+'","GPRangeNo":"0","GP":8,"FromR":0,"ContractPeriodId":"'+cpPrice.Id+'","ContractId":"'+contract.Id+'"},'+
        '{"ToR":500000,"SalesDescription":"","ReportingRule":null,"Name":null,"IsIncludeCAM":true,"IsGrading":true,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"'+String.valueOf(Date.today().addYears(2))+'","GradingPeriodForm":"'+String.valueOf(Date.today().addYears(-2))+'","GPRangeNo":"0","GP":10,"FromR":0,"ContractPeriodId":"'+cpPrice2.Id+'","ContractId":"'+contract.Id+'"}]';
        update contract;

        Test.startTest();
        Date startDate = Date.today().addYears(-3);
        Date endDate = Date.today().addYears(3);
        List<Contract__c> scope = [SELECT Id, Name, Account_Name__c, Building__c, Building__r.Name, Building__r.Branch_Name__c, Calculation_Method__c, Category__c, 
        Termination_Date__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, ContractGrading__c , Total_Leasable_Area__c, Record_Type_Name__c, 
            (SELECT Id, IsDeleted, Name, CalculationMethod__c, CAMMonth__c, RentMonth__c, ServiceMonth__c, EstimateRevenue__c, IsIncludeCAM__c, LeasableArea__c, Contract__c, 
                RentPercent__c, ServicePercent__c, PeriodFrom__c, PeriodTo__c, SalesMin__c, Sequence__c, Total__c, TotalArea__c FROM Contract_Periods__r)
        FROM Contract__c WHERE Contract_End_Date__c >= :startDate AND Contract_Start_Date__c <= :endDate AND (Status__c = 'Activated' OR Status__c = 'Terminated')];

        MonthlyRevenueRecordsBuilder mrrBuilder = new MonthlyRevenueRecordsBuilder(scope, startDate, endDate);
        List<Monthly_Revenue__c> result = mrrBuilder.createMonthlyRevenueRecords();
        Test.stopTest();

        Date contractStart = Date.today().addYears(-2);
        Date contractEnd = Date.today().addYears(2);
        Integer NumberOfMonth = 0;
        Date currentDate = contractStart;
        while (currentDate.toStartOfMonth() <= contractEnd) {
            NumberOfMonth += 1;
            currentDate = currentDate.addMonths(1);
        }
        System.assertEquals(NumberOfMonth ,result.size());
    }

    @isTest
    public static void test_gp_withMinCalculation() {
        Datetime todayDate = Datetime.now();
        String month = todayDate.formatGmt('MMM').toUpperCase();
        String year = todayDate.formatGmt('yyyy');

        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        Floor__c floor = [SELECT Id FROM Floor__c LIMIT 1];

        Units__c unit = new Units__c(
            Building__c = building.Id,
            Floor__c = floor.Id,
            Usage_Type__c = 'Office Rental'
        ); 
        insert unit;

        String category;
        Map<String, sObjectField> objectResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectResult.get('Category__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if (ple.size() > 0) {
            category = ple.get(0).getValue();
        }

        Contact contact = new Contact();
        contact.LastName = 'Dummy';
        contact.Email = 'test@gmail.com';
        insert contact;

        Account account = new Account(Name = 'Test');
        account.Address__c = 'Address';
        account.Subdistrict__c = 'Subdistrict';
        account.District__c = 'District';
        account.Province__c = 'Province';
        account.ZipCode__c = 'ZipCode';
        account.Mobile_Phone__c = '0990000000';
        insert account;

        Opportunity opp = new Opportunity(Name = 'Test');
        opp.AccountId = account.Id;
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        opp.OpportunityGrading__c = '[{}]';
        opp.OpportunityLeaseholdFloor__c = '[{}]';
        opp.DepositMeasurement__c = '[{}]';
        opp.Contract_Type__c = 'Long-Term GP Rent';
        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_WITHMIN;
        opp.Category__c = category;
        opp.Revenue_Collected_By__c = 'BTA เก็บเงิน';
        insert opp;

        Contract__c contract = new Contract__c();
        Id RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId();
        contract.RecordTypeId = RecordTypeId;
        contract.Name = 'My Contract';
        contract.Contract_Start_Date__c = Date.today().addYears(-2);
        contract.Contract_End_Date__c = Date.today().addYears(2);
        contract.Status__c = Constant.CONTRACT_STATUS_TERMINATED;
        contract.ContractGrading__c = '[{}]';
        // Calculation_Method__c = Formula
        contract.Termination_Date__c = Date.today().addYears(1);
        // Category__c = Formula
        contract.Building__c = building.Id;
        contract.Opportunity_Name__c = opp.Id;
        contract.Actual_of_Billing_Rent_Service__c = Date.today().addYears(-2);
        contract.Actual_of_Billing_Insurance__c = Date.today().addYears(-2);
        contract.Actual_of_Decorate_the_Space__c = Date.today().addYears(-2);
        contract.Actual_of_Delivery_the_Area__c = Date.today().addYears(-2);
        contract.Actual_of_Design_Guideline__c = Date.today().addYears(-2);
        contract.Actual_of_Signed_Contract__c = Date.today().addYears(-2);
        contract.Actual_of_Shop_Open__c = Date.today().addYears(-2);
        contract.Termination_Fee__c = 0;
        contract.Termination_Period_Day__c = 0;
        contract.Termiation_Period_Months__c = 0;
        insert contract;

        ContractLineItem__c cli = new ContractLineItem__c();
        cli.Contract__c = contract.Id;
        cli.Unit__c = unit.Id;
        cli.LeasableArea__c = 100;
        insert cli;

        List<ContractPeriod__c> cpList = new List<ContractPeriod__c>();
        ContractPeriod__c cpPrice = new ContractPeriod__c();
        cpPrice.Contract__c = contract.Id;
        cpPrice.PeriodFrom__c = Date.today().addYears(-2);
        cpPrice.PeriodTo__c = Date.today();
        cpPrice.RentMonth__c = 0;
        cpPrice.ServiceMonth__c = 0;
        cpPrice.SalesMin__c = 200000;
        cpPrice.EstimateRevenue__c = 0;
        cpPrice.CalculationMethod__c = Constant.CAL_METHOD_GP_WITHMIN;
        cpPrice.Sequence__c = 1;
        cpList.add(cpPrice);

        ContractPeriod__c cpCAM = new ContractPeriod__c();
        cpCAM.Contract__c = contract.Id;
        cpCAM.PeriodFrom__c = Date.today().addYears(-2);
        cpCAM.PeriodTo__c = Date.today();
        cpCAM.CAMMonth__c = 20000;
        cpCAM.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM.Sequence__c = 1;
        cpList.add(cpCAM);

        ContractPeriod__c cpPrice2 = new ContractPeriod__c();
        cpPrice2.Contract__c = contract.Id;
        cpPrice2.PeriodFrom__c = Date.today().addDays(1);
        cpPrice2.PeriodTo__c = Date.today().addYears(2);
        cpPrice2.RentMonth__c = 0;
        cpPrice2.ServiceMonth__c = 0;
        cpPrice2.EstimateRevenue__c = 400000;
        cpPrice2.CalculationMethod__c = Constant.CAL_METHOD_GP_WITHMIN;
        cpPrice2.Sequence__c = 2;
        cpList.add(cpPrice2);

        ContractPeriod__c cpCAM2 = new ContractPeriod__c();
        cpCAM2.Contract__c = contract.Id;
        cpCAM2.PeriodFrom__c = Date.today().addDays(1);
        cpCAM2.PeriodTo__c = Date.today().addYears(2);
        cpCAM2.CAMMonth__c = 22000;
        cpCAM2.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM2.Sequence__c = 2;
        cpList.add(cpCAM2);

        insert cpList;

        
        contract.ContractGrading__c = '[{"ToR":500000,"SalesDescription":"","ReportingRule":null,"Name":null,"IsIncludeCAM":true,"IsGrading":true,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"'+String.valueOf(Date.today().addYears(2))+'","GradingPeriodForm":"'+String.valueOf(Date.today().addYears(-2))+'","GPRangeNo":"0","GP":8,"FromR":0,"ContractPeriodId":"'+cpPrice.Id+'","ContractId":"'+contract.Id+'"},'+
        '{"ToR":500000,"SalesDescription":"","ReportingRule":null,"Name":null,"IsIncludeCAM":true,"IsGrading":true,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"'+String.valueOf(Date.today().addYears(2))+'","GradingPeriodForm":"'+String.valueOf(Date.today().addYears(-2))+'","GPRangeNo":"0","GP":10,"FromR":0,"ContractPeriodId":"'+cpPrice2.Id+'","ContractId":"'+contract.Id+'"}]';
        update contract;

        Test.startTest();
        Date startDate = Date.today().addYears(-3);
        Date endDate = Date.today().addYears(3);
        List<Contract__c> scope = [SELECT Id, Name, Account_Name__c, Building__c, Building__r.Name, Building__r.Branch_Name__c, Calculation_Method__c, Category__c, 
        Termination_Date__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, ContractGrading__c, Total_Leasable_Area__c, Record_Type_Name__c,  
            (SELECT Id, IsDeleted, Name, CalculationMethod__c, CAMMonth__c, RentMonth__c, ServiceMonth__c, EstimateRevenue__c, IsIncludeCAM__c, LeasableArea__c, Contract__c, 
                RentPercent__c, ServicePercent__c, PeriodFrom__c, PeriodTo__c, SalesMin__c, Sequence__c, Total__c, TotalArea__c FROM Contract_Periods__r)
        FROM Contract__c WHERE Contract_End_Date__c >= :startDate AND Contract_Start_Date__c <= :endDate AND (Status__c = 'Activated' OR Status__c = 'Terminated')];

        MonthlyRevenueRecordsBuilder mrrBuilder = new MonthlyRevenueRecordsBuilder(scope, startDate, endDate);
        List<Monthly_Revenue__c> result = mrrBuilder.createMonthlyRevenueRecords();
        Test.stopTest();

        Date contractStart = Date.today().addYears(-2);
        Date contractEnd = Date.today().addYears(2);
        Integer NumberOfMonth = 0;
        Date currentDate = contractStart;
        while (currentDate.toStartOfMonth() <= contractEnd) {
            NumberOfMonth += 1;
            currentDate = currentDate.addMonths(1);
        }
        System.assertEquals(NumberOfMonth ,result.size());
    }

    @isTest
    public static void test_gp_onTopCalculation() {
        Datetime todayDate = Datetime.now();
        String month = todayDate.formatGmt('MMM').toUpperCase();
        String year = todayDate.formatGmt('yyyy');

        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        Floor__c floor = [SELECT Id FROM Floor__c LIMIT 1];

        Units__c unit = new Units__c(
            Building__c = building.Id,
            Floor__c = floor.Id,
            Usage_Type__c = 'Office Rental'
        ); 
        insert unit;

        String category;
        Map<String, sObjectField> objectResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectResult.get('Category__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if (ple.size() > 0) {
            category = ple.get(0).getValue();
        }

        Contact contact = new Contact();
        contact.LastName = 'Dummy';
        contact.Email = 'test@gmail.com';
        insert contact;

        Account account = new Account(Name = 'Test');
        account.Address__c = 'Address';
        account.Subdistrict__c = 'Subdistrict';
        account.District__c = 'District';
        account.Province__c = 'Province';
        account.ZipCode__c = 'ZipCode';
        account.Mobile_Phone__c = '0990000000';
        insert account;

        Opportunity opp = new Opportunity(Name = 'Test');
        opp.AccountId = account.Id;
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        opp.OpportunityGrading__c = '[{}]';
        opp.OpportunityLeaseholdFloor__c = '[{}]';
        opp.DepositMeasurement__c = '[{}]';
        opp.Contract_Type__c = 'Long-Term GP Rent';
        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_ONTOP;
        opp.Category__c = category;
        opp.Revenue_Collected_By__c = 'BTA เก็บเงิน';
        insert opp;

        Contract__c contract = new Contract__c();
        Id RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId();
        contract.RecordTypeId = RecordTypeId;
        contract.Name = 'My Contract';
        contract.Contract_Start_Date__c = Date.today().addYears(-2);
        contract.Contract_End_Date__c = Date.today().addYears(2);
        contract.Status__c = Constant.CONTRACT_STATUS_TERMINATED;
        contract.ContractGrading__c = '[{}]';
        // Calculation_Method__c = Formula
        contract.Termination_Date__c = Date.today().addYears(1);
        // Category__c = Formula
        contract.Building__c = building.Id;
        contract.Opportunity_Name__c = opp.Id;
        contract.Actual_of_Billing_Rent_Service__c = Date.today().addYears(-2);
        contract.Actual_of_Billing_Insurance__c = Date.today().addYears(-2);
        contract.Actual_of_Decorate_the_Space__c = Date.today().addYears(-2);
        contract.Actual_of_Delivery_the_Area__c = Date.today().addYears(-2);
        contract.Actual_of_Design_Guideline__c = Date.today().addYears(-2);
        contract.Actual_of_Signed_Contract__c = Date.today().addYears(-2);
        contract.Actual_of_Shop_Open__c = Date.today().addYears(-2);
        contract.Termination_Fee__c = 0;
        contract.Termination_Period_Day__c = 0;
        contract.Termiation_Period_Months__c = 0;
        insert contract;

        ContractLineItem__c cli = new ContractLineItem__c();
        cli.Contract__c = contract.Id;
        cli.Unit__c = unit.Id;
        cli.LeasableArea__c = 100;
        insert cli;

        List<ContractPeriod__c> cpList = new List<ContractPeriod__c>();
        ContractPeriod__c cpPrice = new ContractPeriod__c();
        cpPrice.Contract__c = contract.Id;
        cpPrice.PeriodFrom__c = Date.today().addYears(-2);
        cpPrice.PeriodTo__c = Date.today();
        cpPrice.RentMonth__c = 0;
        cpPrice.ServiceMonth__c = 0;
        cpPrice.EstimateRevenue__c = 400000;
        cpPrice.CalculationMethod__c = Constant.CAL_METHOD_GP_ONTOP;
        cpPrice.Sequence__c = 1;
        cpList.add(cpPrice);

        ContractPeriod__c cpCAM = new ContractPeriod__c();
        cpCAM.Contract__c = contract.Id;
        cpCAM.PeriodFrom__c = Date.today().addYears(-2);
        cpCAM.PeriodTo__c = Date.today();
        cpCAM.CAMMonth__c = 20000;
        cpCAM.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM.Sequence__c = 1;
        cpList.add(cpCAM);

        ContractPeriod__c cpPrice2 = new ContractPeriod__c();
        cpPrice2.Contract__c = contract.Id;
        cpPrice2.PeriodFrom__c = Date.today().addDays(1);
        cpPrice2.PeriodTo__c = Date.today().addYears(2);
        cpPrice2.RentMonth__c = 0;
        cpPrice2.ServiceMonth__c = 0;
        cpPrice2.EstimateRevenue__c = 400000;
        cpPrice2.CalculationMethod__c = Constant.CAL_METHOD_GP_ONTOP;
        cpPrice2.Sequence__c = 2;
        cpList.add(cpPrice2);

        ContractPeriod__c cpCAM2 = new ContractPeriod__c();
        cpCAM2.Contract__c = contract.Id;
        cpCAM2.PeriodFrom__c = Date.today().addDays(1);
        cpCAM2.PeriodTo__c = Date.today().addYears(2);
        cpCAM2.CAMMonth__c = 22000;
        cpCAM2.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM2.Sequence__c = 2;
        cpList.add(cpCAM2);

        insert cpList;

        
        contract.ContractGrading__c = '[{"ToR":500000,"SalesDescription":"","ReportingRule":null,"Name":null,"IsIncludeCAM":true,"IsGrading":true,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"'+String.valueOf(Date.today().addYears(2))+'","GradingPeriodForm":"'+String.valueOf(Date.today().addYears(-2))+'","GPRangeNo":"0","GP":8,"FromR":0,"ContractPeriodId":"'+cpPrice.Id+'","ContractId":"'+contract.Id+'"},'+
        '{"ToR":500000,"SalesDescription":"","ReportingRule":null,"Name":null,"IsIncludeCAM":true,"IsGrading":true,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"'+String.valueOf(Date.today().addYears(2))+'","GradingPeriodForm":"'+String.valueOf(Date.today().addYears(-2))+'","GPRangeNo":"0","GP":10,"FromR":0,"ContractPeriodId":"'+cpPrice2.Id+'","ContractId":"'+contract.Id+'"}]';
        update contract;

        Test.startTest();
        Date startDate = Date.today().addYears(-3);
        Date endDate = Date.today().addYears(3);
        List<Contract__c> scope = [SELECT Id, Name, Account_Name__c, Building__c, Building__r.Name, Building__r.Branch_Name__c, Calculation_Method__c, Category__c, 
        Termination_Date__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, ContractGrading__c, Total_Leasable_Area__c, Record_Type_Name__c, 
            (SELECT Id, IsDeleted, Name, CalculationMethod__c, CAMMonth__c, RentMonth__c, ServiceMonth__c, EstimateRevenue__c, IsIncludeCAM__c, LeasableArea__c, Contract__c, 
                RentPercent__c, ServicePercent__c, PeriodFrom__c, PeriodTo__c, SalesMin__c, Sequence__c, Total__c, TotalArea__c FROM Contract_Periods__r)
        FROM Contract__c WHERE Contract_End_Date__c >= :startDate AND Contract_Start_Date__c <= :endDate AND (Status__c = 'Activated' OR Status__c = 'Terminated')];

        MonthlyRevenueRecordsBuilder mrrBuilder = new MonthlyRevenueRecordsBuilder(scope, startDate, endDate);
        List<Monthly_Revenue__c> result = mrrBuilder.createMonthlyRevenueRecords();
        Test.stopTest();

        Date contractStart = Date.today().addYears(-2);
        Date contractEnd = Date.today().addYears(2);
        Integer NumberOfMonth = 0;
        Date currentDate = contractStart;
        while (currentDate.toStartOfMonth() <= contractEnd) {
            NumberOfMonth += 1;
            currentDate = currentDate.addMonths(1);
        }
        System.assertEquals(NumberOfMonth ,result.size());
    }

    @isTest
    public static void test_fixPriceCalculation() {
        Datetime todayDate = Datetime.now();
        String month = todayDate.formatGmt('MMM').toUpperCase();
        String year = todayDate.formatGmt('yyyy');

        Branch__c branch = [SELECT Id FROM Branch__c LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        Floor__c floor = [SELECT Id FROM Floor__c LIMIT 1];

        Units__c unit = new Units__c(
            Building__c = building.Id,
            Floor__c = floor.Id,
            Usage_Type__c = 'Office Rental'
        ); 
        insert unit;

        String category;
        Map<String, sObjectField> objectResult = Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldResult = objectResult.get('Category__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if (ple.size() > 0) {
            category = ple.get(0).getValue();
        }

        Contact contact = new Contact();
        contact.LastName = 'Dummy';
        contact.Email = 'test@gmail.com';
        insert contact;

        Account account = new Account(Name = 'Test');
        account.Address__c = 'Address';
        account.Subdistrict__c = 'Subdistrict';
        account.District__c = 'District';
        account.Province__c = 'Province';
        account.ZipCode__c = 'ZipCode';
        account.Mobile_Phone__c = '0990000000';
        insert account;

        Opportunity opp = new Opportunity(Name = 'Test');
        opp.AccountId = account.Id;
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        opp.OpportunityGrading__c = '[{}]';
        opp.OpportunityLeaseholdFloor__c = '[{}]';
        opp.DepositMeasurement__c = '[{}]';
        opp.Contract_Type__c = 'Long-Term Fixed Rent';
        opp.Calculation_Method__c = Constant.CAL_METHOD_FIXED_RO;
        opp.Category__c = category;
        insert opp;

        Contract__c contract = new Contract__c();
        Id RecordTypeId = Schema.SObjectType.Contract__c.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId();
        contract.RecordTypeId = RecordTypeId;
        contract.Name = 'My Contract';
        contract.Contract_Start_Date__c = Date.today().addYears(-2);
        contract.Contract_End_Date__c = Date.today().addYears(2);
        contract.Status__c = Constant.CONTRACT_STATUS_TERMINATED;
        contract.ContractGrading__c = '[{}]';
        // Calculation_Method__c = Formula
        contract.Termination_Date__c = Date.today().addYears(1);
        // Category__c = Formula
        contract.Building__c = building.Id;
        contract.Opportunity_Name__c = opp.Id;
        contract.Actual_of_Billing_Rent_Service__c = Date.today().addYears(-2);
        contract.Actual_of_Billing_Insurance__c = Date.today().addYears(-2);
        contract.Actual_of_Decorate_the_Space__c = Date.today().addYears(-2);
        contract.Actual_of_Delivery_the_Area__c = Date.today().addYears(-2);
        contract.Actual_of_Design_Guideline__c = Date.today().addYears(-2);
        contract.Actual_of_Signed_Contract__c = Date.today().addYears(-2);
        contract.Actual_of_Shop_Open__c = Date.today().addYears(-2);
        contract.Termination_Fee__c = 0;
        contract.Termination_Period_Day__c = 0;
        contract.Termiation_Period_Months__c = 0;
        insert contract;


        ContractLineItem__c cli = new ContractLineItem__c();
        cli.Contract__c = contract.Id;
        cli.Unit__c = unit.Id;
        cli.LeasableArea__c = 100;
        insert cli;

        List<ContractPeriod__c> cpList = new List<ContractPeriod__c>();
        ContractPeriod__c cpPrice = new ContractPeriod__c();
        cpPrice.Contract__c = contract.Id;
        cpPrice.PeriodFrom__c = Date.today().addYears(-2);
        cpPrice.PeriodTo__c = Date.today();
        cpPrice.RentMonth__c = 60000;
        cpPrice.ServiceMonth__c = 40000;
        cpPrice.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
        cpPrice.Sequence__c = 1;
        cpList.add(cpPrice);

        ContractPeriod__c cpCAM = new ContractPeriod__c();
        cpCAM.Contract__c = contract.Id;
        cpCAM.PeriodFrom__c = Date.today().addYears(-2);
        cpCAM.PeriodTo__c = Date.today();
        cpCAM.CAMMonth__c = 20000;
        cpCAM.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM.Sequence__c = 1;
        cpList.add(cpCAM);

        ContractPeriod__c cpPrice2 = new ContractPeriod__c();
        cpPrice2.Contract__c = contract.Id;
        cpPrice2.PeriodFrom__c = Date.today().addDays(1);
        cpPrice2.PeriodTo__c = Date.today().addYears(2);
        cpPrice2.RentMonth__c = 66000;
        cpPrice2.ServiceMonth__c = 44000;
        cpPrice2.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
        cpPrice2.Sequence__c = 2;
        cpList.add(cpPrice2);

        ContractPeriod__c cpCAM2 = new ContractPeriod__c();
        cpCAM2.Contract__c = contract.Id;
        cpCAM2.PeriodFrom__c = Date.today().addDays(1);
        cpCAM2.PeriodTo__c = Date.today().addYears(2);
        cpCAM2.CAMMonth__c = 22000;
        cpCAM2.CalculationMethod__c = Constant.CAL_METHOD_CAM;
        cpCAM2.Sequence__c = 2;
        cpList.add(cpCAM2);

        insert cpList;

        Test.startTest();
        Date startDate = Date.today().addYears(-3);
        Date endDate = Date.today().addYears(3);
        List<Contract__c> scope = [SELECT Id, Name, Account_Name__c, Building__c, Building__r.Name, Building__r.Branch_Name__c, Calculation_Method__c, Category__c, 
        Termination_Date__c, Contract_Start_Date__c, Contract_End_Date__c, Status__c, ContractGrading__c, Total_Leasable_Area__c, Record_Type_Name__c, 
            (SELECT Id, IsDeleted, Name, CalculationMethod__c, CAMMonth__c, RentMonth__c, ServiceMonth__c, EstimateRevenue__c, IsIncludeCAM__c, LeasableArea__c, Contract__c, 
                RentPercent__c, ServicePercent__c, PeriodFrom__c, PeriodTo__c, SalesMin__c, Sequence__c, Total__c, TotalArea__c FROM Contract_Periods__r)
        FROM Contract__c WHERE Contract_End_Date__c >= :startDate AND Contract_Start_Date__c <= :endDate AND (Status__c = 'Activated' OR Status__c = 'Terminated')];

        MonthlyRevenueRecordsBuilder mrrBuilder = new MonthlyRevenueRecordsBuilder(scope, startDate, endDate);
        List<Monthly_Revenue__c> result = mrrBuilder.createMonthlyRevenueRecords();
        Test.stopTest();

        Date contractStart = Date.today().addYears(-2);
        Date contractEnd = Date.today().addYears(2);
        Integer NumberOfMonth = 0;
        Date currentDate = contractStart;
        while (currentDate.toStartOfMonth() <= contractEnd) {
            NumberOfMonth += 1;
            currentDate = currentDate.addMonths(1);
        }
        System.assertEquals(NumberOfMonth ,result.size());
    }
}