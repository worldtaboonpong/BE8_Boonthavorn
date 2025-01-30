@isTest
public with sharing class QuotatioPrepController_Test {

    public static String queryForSearchRO = 'WHERE Name LIKE  \'%rental object name%\' AND Available_for_Sales__c = true AND Usage_Type__c = \'Retail Shop\' AND IsRetailZone__c = FALSE  AND Type__c != \'Cancelled\' AND Building__c = ';

    public static void createShortLeaseFixOpp(Opportunity opp, String calculationMethod, Id buildingId){
        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(3);
        //opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_SHORTLEASE_FIXED;
        opp.Contract_Type__c = 'Short-Term Fixed Rent';
        opp.Calculation_Method__c = calculationMethod;
        //opp.CAMOrAirService__c = Constant.CAL_METHOD_CAM;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewYear__c = 3;
        opp.OptionToRenewwithPricing__c = true;
        opp.Building__c = buildingId;
        opp.Rental_Period_Year__c = 3;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationRate__c = 5;

    }

    public static void createLongLeaseFixOpp(Opportunity opp, String calculationMethod, Id buildingId){

        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(3);
        //opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_LONGLEASE_FIXED;
        opp.Contract_Type__c = 'Long-Term Fixed Rent';
        opp.Calculation_Method__c = calculationMethod;
        //opp.CAMOrAirService__c = Constant.CAL_METHOD_CAM;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewwithPricing__c = false;
        opp.Building__c = buildingId;
        opp.Rental_Period_Year__c = 3;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationRate__c = 5;
        //opp.LongLeasePriceOption__c = 'ระบุราคาปีปฏิทินแรก';

    }

    public static void createShortLeaseGPOpp(Opportunity opp, String calculationMethod, Id buildingId){

        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(3);
        //opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_SHORTLEASE_GP;
        opp.Contract_Type__c = 'Short-Term GP Rent';
        opp.Calculation_Method__c = calculationMethod;
        //opp.CAMOrAirService__c = Constant.CAL_METHOD_CAM;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewYear__c = 3;
        opp.OptionToRenewwithPricing__c = true;
        opp.Building__c = buildingId;
        opp.Rental_Period_Year__c = 3;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        //opp.SalesforCalculation__c = 'Z010';
        opp.Revenue_Collected_By__c = 'ผู้เช่าเก็บเงิน';
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        //opp.CalculationAndReporting__c = 'A1';
        opp.CAMEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationRate__c = 5;
    }

    public static void createLongLeaseGPOpp(Opportunity opp, String calculationMethod, Id buildingId){
        opp.Estimated_Contract_Start_Date__c = Date.today();
        opp.Estimated_Contract_End_Date__c = Date.today().addYears(3);
        //opp.Contract_Type__c = Constant.OPP_CONTRACT_TYPE_LONGLEASE_GP;
        opp.Contract_Type__c = 'Long-Term GP Rent';
        opp.Calculation_Method__c = calculationMethod;
        //opp.CAMOrAirService__c = Constant.CAL_METHOD_CAM;
        opp.Deposit_Month__c = 6;
        opp.OptionToRenewwithPricing__c = false;
        opp.Building__c = buildingId;
        opp.Rental_Period_Year__c = 3;
        opp.Rental_Period_Month__c = 0;
        opp.Rental_Period_Day__c = 0;
        //opp.SalesforCalculation__c = 'Z010';
        opp.Revenue_Collected_By__c = 'ผู้เช่าเก็บเงิน';
        opp.RentAndServiceEscalationRate__c = 5;
        opp.RentAndServiceEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        //opp.CalculationAndReporting__c = 'A1';
        opp.CAMEscalationType__c = Constant.RENT_SERVICE_ESCALATION;
        opp.CAMEscalationRate__c = 5;
        //opp.LongLeasePriceOption__c = 'ระบุราคาปีปฏิทินแรก';

    }

    @testSetup
    static void makeData(){
        MockUpDataFor_Test.generateOppSetting();
        
        TriggerActivation__c triggerSetting = MockUpDataFor_Test.mockupCustomSettingTrigger('Opportunity');
        insert triggerSetting;

        MockUpDataFor_Test.createQuotationPreparationScreenPack();
        
        List<QuotationPreparationScreenMaster__c> setupList = new List<QuotationPreparationScreenMaster__c>();
        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = Constant.TYPE_OTHER,
            Type__c = 'ค่าที่จอดรถ',
            Format__c = Constant.DEP_EXP_TYPE_LEASEHOLD,
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true
        ));

        setupList.add(new QuotationPreparationScreenMaster__c(
            ScreentoDisplay__c = Constant.TYPE_OTHER,
            Type__c = 'ค่าติดตั้งป้าย',
            Format__c = Constant.DEP_EXP_TYPE_LEASEHOLD,
            ContractType__c = 'Long-Term Fixed Rent',
            IsActive__c = true
        ));

        insert setupList;

        Opportunity opp = MockUpDataFor_Test.createOpportunityPack();
    }
  
    @isTest
    public static void test_constructure() {
        Test.startTest();
        QuotationPrepController res = new QuotationPrepController();
        Test.stopTest();
    }

    @isTest
    public static void test_getRecordTypeName() {
        Test.startTest();
        String res = QuotationPrepController.getRecordTypeName(IDGenerator.generate(Schema.getGlobalDescribe().get('Opportunity')));
        Test.stopTest();
    }

    @isTest
    static void testGetPicklistFROMScreenSetting(){
        List<Measurement__c> measurmentList =  [SELECT Id FROM Measurement__c];

        List<String> measurementIdList  = new List<String> ();
        for (Measurement__c eachMeasurment : measurmentList) {
            measurementIdList.add(String.valueOf(eachMeasurment.Id));
        }

        Test.startTest();
            QuotationPrepController.getPicklistValueFromPageSettingByTargetField('Subtype__c', 'Expense and Fee', 'ScreentoDisplay__c','Long-Term Fixed Rent');
            QuotationPrepController.getOtherExpenseOption('Long-Term Fixed Rent');
            QuotationPrepController.getPicklistValueFromPageSetting('ScreentoDisplay__c','Other Deposit','Long-Term Fixed Rent');
            QuotationPrepController.getPicklistValueFromPageSettingFromContractType('Long-Term Fixed Rent','Other',measurementIdList);
        Test.stopTest();
    }

    @isTest
    static void testGetNewOtherExpenseJson() {

        Test.startTest();
        QuotationPrepController.getNewOtherExpenseJson('Space_Rental','Electric');
        QuotationPrepController.getNewOtherExpenseJson('Space_Rental','Additional Air Service');
        Test.stopTest();
    }

    @isTest
    static void testSaveOtherExpenseJson() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', null);
        update opp;
        
        Test.startTest();
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String otherExpenseJSON = QuotationPrepController.getOtherExpenseJson('Space_Rental');

        QuotationPrepController.saveOtherExpense(otherExpenseJSON, opp.Id, oppDetailJSON);
        QuotationPrepController.getSavedOtherExpenseJson(opp.Id, 'Space_Rental');
        Test.stopTest();
    }

    @isTest 
    static void testgetSaveOtherDepositWithoutSaved() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;
        
        Test.startTest();
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationPrepController.getSavedOtherExpenseJson(opp.Id, 'Long-Term Fixed Rent');
        Test.stopTest();
    }

    @isTest
    static void testSaveExpenseInstallment() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', null);
        update opp;
    
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        String expenseJSon = QuotationPrepController.getNewExpenseINstallmentJson();
        QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper expenseObject = (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper) JSON.deserialize(expenseJSon, QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper.class);
        expenseObject.TotalAmount = 100;
        expenseObject.Type = 'First Entry Fee';
        for (QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : expenseObject.InstallmentList){
            eachInstallment.InstallmentAmount = 100;
            eachInstallment.InstallmentAmountWithVat = 107;
            eachInstallment.InstallmentVAT = 7;
        }
        
        List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseList = new List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>();
        expenseList.add(expenseObject);

        expenseJSon = JSON.serialize(expenseList);
        Test.startTest();
        QuotationPrepController.saveExpenseInstallment(expenseJSon, opp.Id, oppDetailJSON );
        QuotationPrepController.getSavedExpenseINstallmentJson( opp.Id );
        Test.stopTest();
        
    }

    @isTest
    static void testLeaseHoldExpenseInstallment() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createLongLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        Test.startTest();
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        System.debug('selectedRO:'+selectedRO);
        System.debug('oppDetailJSON:'+oppDetailJSON);
        String expenseAndFee = QuotationPrepController.getNewExpenseINstallmentJsonForLeaseHold(selectedRO, oppDetailJSON, true, 1);
        QuotationPrepController.getNewExpenseINstallmentJsonForLeaseHold(selectedRO, oppDetailJSON, false, 1);

        List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList = (List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>) JSON.deserialize(expenseAndFee, List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>.class);
        Decimal totalAmount  = 0;
        Decimal totalPrice  = 0;
        Decimal totalSummary = 0;

        for(QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper eachExpenseAndFee: expenseAndFeeList){
            
            totalAmount  = 0;
            totalPrice  = 0;

            if(eachExpenseAndFee.Type != 'Summary สิทธิการเช่า'){

                for (QuotationComponentDataWrapper.LeaseHoldFloorInfoTable eachLeaseHoldFloor : eachExpenseAndFee.leaseHoldInfo) {
                    eachLeaseHoldFloor.price = 100;
                    totalPrice += eachLeaseHoldFloor.price;
                    eachLeaseHoldFloor.totalAmount = (eachLeaseHoldFloor.price * eachLeaseHoldFloor.area).setScale(2,RoundingMode.HALF_UP);
                    totalAmount += eachLeaseHoldFloor.totalAmount;
                    eachLeaseHoldFloor.floorName = '1'; 

                }

                eachExpenseAndFee.leaseHoldTotalPrice = totalPrice;
                eachExpenseAndFee.TotalAmount = totalAmount;
                eachExpenseAndFee.TotalInstallment = totalAmount;

                totalSummary += totalAmount;
                
                for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpenseAndFee.InstallmentList){
                    eachInstallment.InstallmentAmount = totalAmount;
                }
            }else{
                for(QuotationComponentDataWrapper.InstallmentWrapper eachInstallment : eachExpenseAndFee.InstallmentList){
                    eachInstallment.InstallmentAmount = totalSummary;
                }
            }

        }

        expenseAndFee = JSON.serialize(expenseAndFeeList);

        String newExpenseAndFee = QuotationPrepController.editExpenseAndFeeWhenMeasurementChanged(opp.Id, expenseAndFee, selectedRO, oppDetailJSON);
        QuotationPrepController.getSavedExpenseINstallmentJson(opp.Id);

        Test.stopTest();
        
    }

    @isTest
    static void testGetNewOtherDepositJson() {
        QuotationPrepController.getNewOtherDepositJson();
        
    }
    @isTest
    static void testGetNewReportingRuleJson() {
        QuotationPrepController.getNewReportingRuleJson('Z010','Sales before VAT');
    }
    @isTest
    static void testGetNewReportingRuleDetailJson() {
        QuotationPrepController.getNewReportingRuleDetailJson();        
    }
    @isTest
    static void testGetNewInstallmentJson() {
        QuotationPrepController.getNewInstallmentJson();
    }
    @isTest
    static void testgetDepositObjectJsonAirService() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', null);
        update opp;
    
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String airServiceDeposit = QuotationPrepController.getDepositObjectJson(Constant.CAL_METHOD_AIR,100,100,100,6,null,oppDetailJSON);        
    }

    @isTest
    static void testSaveDepositObjectJson() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', null);
        update opp;
    
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String camDeposit = QuotationPrepController.getDepositObjectJson(Constant.CAL_METHOD_CAM,100,100,100,6,null,oppDetailJSON);
        QuotationComponentDataWrapper.DepositWrapper depositObject = (QuotationComponentDataWrapper.DepositWrapper) JSON.deserialize(camDeposit, QuotationComponentDataWrapper.DepositWrapper.class);

        List<QuotationComponentDataWrapper.DepositOtherWrapper> otherDepositList = new List<QuotationComponentDataWrapper.DepositOtherWrapper>();
        QuotationComponentDataWrapper.DepositOtherWrapper newOtherDeposit = new QuotationComponentDataWrapper.DepositOtherWrapper();
        newOtherDeposit.Type = 'Furniture Deposit';
        newOtherDeposit.Remark = 'Test Remark' ;
        newOtherDeposit.TotalAmount = 1000;
        newOtherDeposit.TotalInstallment =  1000;
        newOtherDeposit.NumberOfInstallment = 1;
        newOtherDeposit.InstallmentList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

        QuotationComponentDataWrapper.InstallmentWrapper newInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
        newInstallment.InstallmentNumber = '1';
        newInstallment.InstallmentAmount = 1000;
        newInstallment.InstallmentAmountWithVat = 1070; 
        newInstallment.InstallmentVAT = 70;

        newOtherDeposit.InstallmentList.add(newInstallment);

        otherDepositList.add(newOtherDeposit);
        depositObject.OtherDepositList = otherDepositList;

        camDeposit  = JSON.serialize(depositObject);
        
        Test.startTest();
        QuotationPrepController.saveDepositApex(camDeposit, opp.Id, oppDetailJSON, false);
        QuotationPrepController.getSavedDepositObjectJson(opp.Id, 'CAM', oppDetailJSON); 

        Test.stopTest();           
    }

    @isTest
    static void testSearchRo(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;

        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        Test.startTest();
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        Test.stopTest();
    }

    @isTest
    static void testSaveSelectedRo(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        Test.startTest();
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        System.debug('queryCondition: '+queryCondition);
        String selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        System.debug('selectedRO: '+selectedRO);
        String message = QuotationPrepController.validateBeforeSaveSelectedRO(null, selectedRO, oppDetailJSON);
        String newSelectedRO = QuotationPrepController.saveSelectedRentalObject(selectedRO, opp.Id, oppDetailJSON);
        System.debug('newSelectedRO: '+newSelectedRO);
        QuotationPrepController.getSavedSelectedRO(opp.Id, opp.Estimated_Contract_Start_Date__c,opp.Estimated_Contract_End_Date__c.addDays(-1));
        QuotationPrepController.updateOppLineItem(newSelectedRO);
        QuotationPrepController.updateOppArea(newSelectedRO, opp.Id, oppDetailJSON);
        Test.stopTest();
    }

    @isTest
    static void testGenerateShortLeaseCAMPricing(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;

        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));

        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c, 'Short-Term',5 ,true,0,0,oppDetailJSON);

        Test.stopTest();

    }
    @isTest
    static void testGenerateNewCAMPricing(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;

        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));

        String camPricingJSON = QuotationPrepController.getNewCAMPeriod(selectedRO,1);

        Test.stopTest();

    }
    @isTest
    static void testGenerateLongLeaseCAMPricing(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createLongLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c, 'Long-Term',5 ,true,0,0,oppDetailJSON);
        Test.stopTest();
    }

    @isTest
    static void testGenerateRentAndServicePricing(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
        Test.stopTest();
    }

    @isTest
    static void testGeneratePriningPeriodShortLeaseFix(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];       

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';
        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);
        
        // opp.CalculationMethod__c = Constant.CAL_METHOD_FIXED_RO;
        // update opp;
        // oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        // periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        // opp.CalculationMethod__c = Constant.CAL_METHOD_FIXED_MEAS;
        // update opp;
        // oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        // periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);
        
        Test.stopTest();
    }

    @isTest
    static void testGeneratePriningPeriodLongLeaseFix(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createLongLeaseFixOpp(opp, 'Fixed Rental Object', building.Id);
        update opp;
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';
        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Long-Term' , 0, 0, oppDetailJSON);
        
        // opp.Calculation_Method__c = Constant.CAL_METHOD_FIXED_RO;
        // update opp;
        // oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        // periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Long-Term' , 0, 0, oppDetailJSON);

        // opp.Calculation_Method__c = Constant.CAL_METHOD_FIXED_MEAS;
        // update opp;
        // oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        // periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Long-Term' , 0, 0, oppDetailJSON);
        
        Test.stopTest();
    }

    @isTest
    static void testGenerateNewPriningPeriodFix(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseFixOpp(opp, Constant.CAL_METHOD_FIXED_RO, building.Id);
        update opp;
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        periodPricingJson = QuotationPrepController.getNewPeriodJSON(Constant.CAL_METHOD_FIXED_RO , 4, selectedRO ,oppDetailJSON);
        
        // opp.Calculation_Method__c = Constant.CAL_METHOD_FIXED_RO;
        // update opp;
        // oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        // periodPricingJson = QuotationPrepController.getNewPeriodJSON(Constant.CAL_METHOD_FIXED_RO , 4, selectedRO ,oppDetailJSON);

        // opp.Calculation_Method__c = Constant.CAL_METHOD_FIXED_MEAS;
        // update opp;
        // oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        // periodPricingJson = QuotationPrepController.getNewPeriodJSON(Constant.CAL_METHOD_FIXED_MEAS , 4, selectedRO ,oppDetailJSON);
        
        Test.stopTest();
    }

    @isTest
    static void testGeneratePriningPeriodShortLeaseGP(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_NOMIN, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Long-Term' , 0, 0, oppDetailJSON);

        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_WITHMIN;
        update opp;
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Long-Term' , 0, 0, oppDetailJSON);

        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_ONTOP;
        update opp;
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Long-Term' , 0, 0, oppDetailJSON);

        Test.stopTest();
    }

    @isTest
    static void testGeneratePriningPeriodLongLeaseGP(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createLongLeaseGPOpp(opp, Constant.CAL_METHOD_GP_NOMIN, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_WITHMIN;
        update opp;
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_ONTOP;
        update opp;
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        Test.stopTest();
    }

    @isTest
    static void testGenerateNewPriningPeriodGP(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_NOMIN, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        periodPricingJson = QuotationPrepController.getNewPeriodJSON(Constant.CAL_METHOD_GP_NOMIN , 4, selectedRO ,oppDetailJSON);

        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_WITHMIN;
        update opp;
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        periodPricingJson = QuotationPrepController.getNewPeriodJSON(Constant.CAL_METHOD_GP_WITHMIN , 4, selectedRO ,oppDetailJSON);

        opp.Calculation_Method__c = Constant.CAL_METHOD_GP_ONTOP;
        update opp;
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);

        periodPricingJson = QuotationPrepController.getNewPeriodJSON(Constant.CAL_METHOD_GP_ONTOP , 4, selectedRO ,oppDetailJSON);

        Test.stopTest();
    }

    // @isTest
    // static void testSavePricingFixPrice(){
    //     Opportunity opp = [SELECT Id,
    //                                 Name,
    //                                 Usage_Type__c,
    //                                 CloseDate,
    //                                 RecordTypeId,
    //                                 StageName,
    //                                 AccountId,
    //                                 Building__c,
    //                                 Shop_Name__c,
    //                                 Rental_Period_Year__c,
    //                                 Contact_Name__c,
    //                                 Estimated_Contract_Start_Date__c,
    //                                 Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 
    //     createShortLeaseFixOpp(opp, Constant.CAL_METHOD_FIXED_PRICE, null);
    //     update opp;

    //     String oppDetailJSON = '';
        
    //     oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
    //     QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

    //     Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];

    //     String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
    //     String selectedRO = '';
    //     String periodPricingJson = '';

    //     System.debug('oppDetailJSON' + oppDetailJSON);
    //     oppDetail.totalMeasurmentArea = 100;
    //     oppDetail.totalLeasableArea = 100;
    //     oppDetailJSON = JSON.serialize(oppDetail);

    //     Test.startTest();
    //     selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
    //     String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
    //     String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
    //     periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);


    //     Decimal camyearTotalPricing = 0;
    //     QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
    //     for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
    //         camyearTotalPricing = 0;
            
    //         for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
    //             eachCAMMeasurement.Price.value = 100;
    //             eachCAMMeasurement.MeasurementArea = 50;
    //             camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
    //         }

    //         eachCAMPeriod.TotalPrice = camyearTotalPricing; 
    //         eachCAMPeriod.TotalArea = 100;
    //     }

    //     camPricingJSON = JSON.serialize(camOrAirServiceObject);

    //     List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
    //     for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
    //         if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_RO) {
    //             eachPricingPeriod.FixedPriceSection.Price = 100;
                
    //         }
    //     }

    //     periodPricingJson = JSON.serialize(periodPricing);

    //     QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
    //     QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
    //     QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);
    //     QuotationPrepController.getSavedRentServicePricingDetail(opp.Id,selectedRO, oppDetail.rentServiceEscalationType, 5, oppDetailJSON);
    //     Test.stopTest();
    // }

    @isTest
    static void testSavePricingFixRO(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 
        createShortLeaseFixOpp(opp, Constant.CAL_METHOD_FIXED_RO, null);
        update opp;

        String oppDetailJSON = '';
        
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];

        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        System.debug('oppDetailJSON' + oppDetailJSON);
        oppDetail.totalMeasurmentArea = 100;
        oppDetail.totalLeasableArea = 100;
        oppDetailJSON = JSON.serialize(oppDetail);

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        System.debug('Test selectedRO' + selectedRO);
        Decimal camyearTotalPricing = 0;
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
            camyearTotalPricing = 0;
            
            for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
                eachCAMMeasurement.Price.value = 100;
                eachCAMMeasurement.MeasurementArea = 50;
                camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
            }

            eachCAMPeriod.TotalPrice = camyearTotalPricing; 
            eachCAMPeriod.TotalArea = 100;
        }

        camPricingJSON = JSON.serialize(camOrAirServiceObject);

        Decimal totalPrice = 0;
        Decimal totalPriceSQM = 0;
        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
            if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_RO) {
                totalPrice = 0;
                totalPriceSQM = 0;
                for (QuotationComponentDataWrapper.RentalObjectPricingWrapper eachRentalObject : eachPricingPeriod.FixedRentalObjectSection.rentalObjectList) {
                    eachRentalObject.PriceSQM.value = 100;
                    eachRentalObject.Price.value = 500;

                    totalPrice += eachRentalObject.Price.value;
                    totalPriceSQM += eachRentalObject.PriceSQM.value;

                }

                eachPricingPeriod.FixedRentalObjectSection.TotalPrice = totalPrice;
                eachPricingPeriod.FixedRentalObjectSection.TotalPriceSQm = totalPriceSQM;
                
            }
        }

        periodPricingJson = JSON.serialize(periodPricing);

        QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
        QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
        QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);
        QuotationPrepController.getSavedRentServicePricingDetail(opp.Id,selectedRO, oppDetail.rentServiceEscalationType, 5, oppDetailJSON);
        Test.stopTest();
    }
    
    // @isTest
    // static void testSavePricingFixMeasurement(){
    //     Opportunity opp = [SELECT Id,
    //                                 Name,
    //                                 Usage_Type__c,
    //                                 CloseDate,
    //                                 RecordTypeId,
    //                                 StageName,
    //                                 AccountId,
    //                                 Building__c,
    //                                 Shop_Name__c,
    //                                 Rental_Period_Year__c,
    //                                 Contact_Name__c,
    //                                 Estimated_Contract_Start_Date__c,
    //                                 Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 
    //     createShortLeaseFixOpp(opp, Constant.CAL_METHOD_FIXED_MEAS, null);
    //     update opp;

    //     String oppDetailJSON = '';
        
    //     Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];

    //     oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
    //     QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

    //     String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
    //     String selectedRO = '';
    //     String periodPricingJson = '';

    //     System.debug('oppDetailJSON' + oppDetailJSON);
    //     oppDetail.totalMeasurmentArea = 100;
    //     oppDetail.totalLeasableArea = 100;
    //     oppDetailJSON = JSON.serialize(oppDetail);

    //     Test.startTest();
    //     selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
    //     String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
    //     String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
    //     periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

    //     System.debug('Test selectedRO' + selectedRO);
    //     Decimal camyearTotalPricing = 0;
    //     QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
    //     for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
    //         camyearTotalPricing = 0;
            
    //         for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
    //             eachCAMMeasurement.Price.value = 100;
    //             eachCAMMeasurement.MeasurementArea = 50;
    //             camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
    //         }

    //         eachCAMPeriod.TotalPrice = camyearTotalPricing; 
    //         eachCAMPeriod.TotalArea = 100;
    //     }

    //     camPricingJSON = JSON.serialize(camOrAirServiceObject);

    //     Decimal totalPrice = 0;
    //     Decimal totalSummary = 0;
    //     List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
    //     for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
    //         if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_FIXED_MEAS) {
    //             totalPrice = 0;
    //             totalSummary = 0;
    //             for (QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement : eachPricingPeriod.FixedMeasurementSection.pricingList) {
    //                 eachMeasurement.Price.value = 500;
    //                 eachMeasurement.Summary = eachMeasurement.Price.value * eachMeasurement.Area;

    //                 totalPrice += eachMeasurement.Price.value;
    //                 totalSummary += eachMeasurement.Summary;

    //             }

    //             eachPricingPeriod.FixedMeasurementSection.TotalPrice = totalPrice;
    //             eachPricingPeriod.FixedMeasurementSection.TotalSummary = totalSummary;
                
    //         }
    //     }

    //     periodPricingJson = JSON.serialize(periodPricing);

    //     QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
    //     QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
    //     QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);
    //     Test.stopTest();
    // }

    @isTest
    static void testSavePricingGPNoMin(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_NOMIN, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        System.debug('oppDetailJSON' + oppDetailJSON);
        oppDetail.totalMeasurmentArea = 100;
        oppDetail.totalLeasableArea = 100;
        oppDetailJSON = JSON.serialize(oppDetail);

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        System.debug('Test selectedRO' + selectedRO);
        Decimal camyearTotalPricing = 0;
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
            camyearTotalPricing = 0;
            
            for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
                eachCAMMeasurement.Price.value = 100;
                eachCAMMeasurement.MeasurementArea = 50;
                camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
            }

            eachCAMPeriod.TotalPrice = camyearTotalPricing; 
            eachCAMPeriod.TotalArea = 100;
        }

        camPricingJSON = JSON.serialize(camOrAirServiceObject);

        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
            if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_NOMIN) {
                
                for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPNoMinSection.ReportingRuleList) {
                    eachReportingRule.ReportingRuleDescription = 'Test';
                    eachReportingRule.ReportingRule = 'Z010';
                    eachReportingRule.ReportingRuleLabel = 'Sales before VAT';
                    for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                        eachReportingRuleDetail.GPPercent = 10;
                    }

                }
            }
        }

        periodPricingJson = JSON.serialize(periodPricing);
        QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
        QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
        QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);

        Test.stopTest();
    }
    @isTest
    static void testSavePricingGPWithMin(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_WITHMIN, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        System.debug('oppDetailJSON' + oppDetailJSON);
        oppDetail.totalMeasurmentArea = 100;
        oppDetail.totalLeasableArea = 100;
        oppDetailJSON = JSON.serialize(oppDetail);

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        System.debug('Test selectedRO' + selectedRO);
        Decimal camyearTotalPricing = 0;
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
            camyearTotalPricing = 0;
            
            for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
                eachCAMMeasurement.Price.value = 100;
                eachCAMMeasurement.MeasurementArea = 50;
                camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
            }

            eachCAMPeriod.TotalPrice = camyearTotalPricing; 
            eachCAMPeriod.TotalArea = 100;
        }

        camPricingJSON = JSON.serialize(camOrAirServiceObject);
        Decimal totalPrice = 0;
        Decimal totalSummary = 0;

        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
            if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
                
                eachPricingPeriod.GPWithMinSection.SalesMin = 1000000;


                for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPWithMinSection.ReportingRuleList) {
                    eachReportingRule.ReportingRuleDescription = 'Test';
                    eachReportingRule.ReportingRule = 'Z010';
                    eachReportingRule.ReportingRuleLabel = 'Sales before VAT';

                    for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                        eachReportingRuleDetail.GPPercent = 10;
                    }

                }

                totalPrice = 0;
                totalSummary = 0;

                for (QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement : eachPricingPeriod.GPWithMinSection.PricingSection.MeasumentPricingList) {
                    eachMeasurement.Price.value = 500;
                    eachMeasurement.Summary = eachMeasurement.Price.value * eachMeasurement.Area;

                    totalPrice += eachMeasurement.Price.value;
                    totalSummary += eachMeasurement.Summary;
                }

                // eachPricingPeriod.GPWithMinSection.PricingSection.MinType = 'Fixed';
                // eachPricingPeriod.GPWithMinSection.PricingSection.FixedPricing.Price = 10000;
                eachPricingPeriod.GPWithMinSection.PricingSection.TotalPrice = totalPrice;
                eachPricingPeriod.GPWithMinSection.PricingSection.TotalSummary =totalSummary;

            }
        }

        periodPricingJson = JSON.serialize(periodPricing);
        QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
        QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
        QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);

        Test.stopTest();
    }
    @isTest
    static void testSavePricingGPOnTop(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_ONTOP, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        System.debug('oppDetailJSON' + oppDetailJSON);
        oppDetail.totalMeasurmentArea = 100;
        oppDetail.totalLeasableArea = 100;
        oppDetailJSON = JSON.serialize(oppDetail);

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        System.debug('Test selectedRO' + selectedRO);
        Decimal camyearTotalPricing = 0;
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
            camyearTotalPricing = 0;
            
            for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
                eachCAMMeasurement.Price.value = 100;
                eachCAMMeasurement.MeasurementArea = 50;
                camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
            }

            eachCAMPeriod.TotalPrice = camyearTotalPricing; 
            eachCAMPeriod.TotalArea = 100;
        }

        camPricingJSON = JSON.serialize(camOrAirServiceObject);
        Decimal totalPrice = 0;
        Decimal totalSummary = 0;

        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
            if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {


                for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPOnTopSection.ReportingRuleList) {
                    eachReportingRule.ReportingRuleDescription = 'Test';
                    eachReportingRule.ReportingRule = 'Z010';
                    eachReportingRule.ReportingRuleLabel = 'Sales before VAT';

                    for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                        eachReportingRuleDetail.GPPercent = 10;
                    }

                }

                totalPrice = 0;
                totalSummary = 0;

                for (QuotationComponentDataWrapper.MeasurementPricingList eachMeasurement : eachPricingPeriod.GPOnTopSection.PricingSection.MeasumentPricingList) {
                    eachMeasurement.Price.value = 500;
                    eachMeasurement.Summary = eachMeasurement.Price.value * eachMeasurement.Area;

                    totalPrice += eachMeasurement.Price.value;
                    totalSummary += eachMeasurement.Summary;
                }

                // eachPricingPeriod.GPWithMinSection.PricingSection.MinType = 'Fixed';
                // eachPricingPeriod.GPWithMinSection.PricingSection.FixedPricing.Price = 10000;
                eachPricingPeriod.GPOnTopSection.PricingSection.TotalPrice = totalPrice;
                eachPricingPeriod.GPOnTopSection.PricingSection.TotalSummary =totalSummary;

            }
        }

        System.debug('Test GPONTOP ' + periodPricing);
        periodPricingJson = JSON.serialize(periodPricing);
        QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
        QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
        QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);
        Test.stopTest();
    }

    @isTest
    static void testSavePricingGPWithMin_MinTypeFixed(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_WITHMIN, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        System.debug('oppDetailJSON' + oppDetailJSON);
        oppDetail.totalMeasurmentArea = 100;
        oppDetail.totalLeasableArea = 100;
        oppDetailJSON = JSON.serialize(oppDetail);

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        System.debug('Test selectedRO' + selectedRO);
        Decimal camyearTotalPricing = 0;
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
            camyearTotalPricing = 0;
            
            for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
                eachCAMMeasurement.Price.value = 100;
                eachCAMMeasurement.MeasurementArea = 50;
                camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
            }

            eachCAMPeriod.TotalPrice = camyearTotalPricing; 
            eachCAMPeriod.TotalArea = 100;
        }

        camPricingJSON = JSON.serialize(camOrAirServiceObject);
        Decimal totalPrice = 0;
        Decimal totalSummary = 0;

        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
            if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_WITHMIN) {
                
                eachPricingPeriod.GPWithMinSection.SalesMin = 1000000;


                for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPWithMinSection.ReportingRuleList) {
                    eachReportingRule.ReportingRuleDescription = 'Test';
                    eachReportingRule.ReportingRule = 'Z010';
                    eachReportingRule.ReportingRuleLabel = 'Sales before VAT';

                    for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                        eachReportingRuleDetail.GPPercent = 10;
                    }

                }


                eachPricingPeriod.GPWithMinSection.PricingSection.MinType = 'Fixed';
                eachPricingPeriod.GPWithMinSection.PricingSection.FixedPricing.Price = 10000;
                eachPricingPeriod.GPWithMinSection.PricingSection.TotalPrice = 10000;
                // eachPricingPeriod.GPWithMinSection.PricingSection.TotalSummary =totalSummary;

            }
        }

        periodPricingJson = JSON.serialize(periodPricing);
        QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
        QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
        QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);

        Test.stopTest();
    }
    @isTest
    static void testSavePricingGPOnTop_MinTypeFixed(){
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1]; 

        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        createShortLeaseGPOpp(opp, Constant.CAL_METHOD_GP_ONTOP, building.Id);
        update opp;
    
        String oppDetailJSON = '';
        
        oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);

        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';
        String selectedRO = '';
        String periodPricingJson = '';

        System.debug('oppDetailJSON' + oppDetailJSON);
        oppDetail.totalMeasurmentArea = 100;
        oppDetail.totalLeasableArea = 100;
        oppDetailJSON = JSON.serialize(oppDetail);

        Test.startTest();
        selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        String rentServiceJson = QuotationPrepController.getRentServicePricingDetail(selectedRO, 5, opp.Id, true);
        periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,opp.Calculation_Method__c, 'Short-Term' , 3, 0, oppDetailJSON);

        System.debug('Test selectedRO' + selectedRO);
        Decimal camyearTotalPricing = 0;
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        for (QuotationComponentDataWrapper.CAMYearPeriodWrapper eachCAMPeriod : camOrAirServiceObject.CAMYearPeriod) {
            camyearTotalPricing = 0;
            
            for (QuotationComponentDataWrapper.MeasurmentWrapper eachCAMMeasurement : eachCAMPeriod.CAMMeasurmentList) {
                eachCAMMeasurement.Price.value = 100;
                eachCAMMeasurement.MeasurementArea = 50;
                camyearTotalPricing += eachCAMMeasurement.Price.value * eachCAMMeasurement.MeasurementArea;
            }

            eachCAMPeriod.TotalPrice = camyearTotalPricing; 
            eachCAMPeriod.TotalArea = 100;
        }

        camPricingJSON = JSON.serialize(camOrAirServiceObject);
        Decimal totalPrice = 0;
        Decimal totalSummary = 0;

        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        for ( QuotationComponentDataWrapper.PeriodPricing eachPricingPeriod : periodPricing){
            if (eachPricingPeriod.CalculationMethod == Constant.CAL_METHOD_GP_ONTOP) {


                for (QuotationComponentDataWrapper.ReportingRuleWrapper eachReportingRule : eachPricingPeriod.GPOnTopSection.ReportingRuleList) {
                    eachReportingRule.ReportingRuleDescription = 'Test';
                    eachReportingRule.ReportingRule = 'Z010';
                    eachReportingRule.ReportingRuleLabel = 'Sales before VAT';

                    for (QuotationComponentDataWrapper.ReportingRuleDetailWrapper eachReportingRuleDetail : eachReportingRule.ReportingRuleDetailList) {
                        eachReportingRuleDetail.GPPercent = 10;
                    }

                }

                eachPricingPeriod.GPOnTopSection.PricingSection.MinType = 'Fixed';
                eachPricingPeriod.GPOnTopSection.PricingSection.FixedPricing.Price = 10000;
                eachPricingPeriod.GPOnTopSection.PricingSection.TotalPrice = 10000;
                // eachPricingPeriod.GPOnTopSection.PricingSection.TotalSummary =totalSummary;

            }
        }

        System.debug('Test GPONTOP ' + periodPricing);
        periodPricingJson = JSON.serialize(periodPricing);
        QuotationPrepController.savePricingApex(camPricingJSON,rentServiceJson,periodPricingJson, oppDetailJSON, opp.Id);
        QuotationPrepController.getSavedPeriodPricingDetail(opp.Id, oppDetailJSON, selectedRO, oppDetail.rentServiceEscalationType, oppDetail.calculationMethod);
        QuotationPrepController.getSavedCAMPricingDetail(opp.Id, oppDetail.camOrAirEscalationType, 5, selectedRO, oppDetailJSON);

        Test.stopTest();
    }

    @isTest
    public static void test_getPicklistValueFromPageSettingFromRentType() {
        Test.startTest();
        Map<String,String> res = QuotationPrepController.getPicklistValueFromPageSettingFromRentType('Space_Rental', 'Expense and Fee', new List<String>{'Footprint Area'});
        Test.stopTest();
    }

    @isTest
    public static void test_getOtherExpenseSubtype() {
        Test.startTest();
        Map<String,String> res = QuotationPrepController.getOtherExpenseSubtype('Space_Rental');
        Test.stopTest();
    }

    @isTest
    public static void test_validateInstallmentPaymentMethod() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', null);
        update opp;
    
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String camDeposit = QuotationPrepController.getDepositObjectJson(Constant.CAL_METHOD_CAM,100,100,100,6,null,oppDetailJSON);
        QuotationComponentDataWrapper.DepositWrapper depositObject = (QuotationComponentDataWrapper.DepositWrapper) JSON.deserialize(camDeposit, QuotationComponentDataWrapper.DepositWrapper.class);
        Test.startTest();
        Boolean res = QuotationPrepController.validateInstallmentPaymentMethod(depositObject);
        Test.stopTest();
    }

    @isTest
    public static void test_validateCarriedDepositWhenRenewOpp_And_NoCAM() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', null);
        update opp;
    
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String camDeposit = QuotationPrepController.getDepositObjectJson(Constant.CAL_METHOD_CAM,100,100,100,6,null,oppDetailJSON);
        QuotationComponentDataWrapper.DepositWrapper depositObject = (QuotationComponentDataWrapper.DepositWrapper) JSON.deserialize(camDeposit, QuotationComponentDataWrapper.DepositWrapper.class);
        depositObject.DepositSummary = new QuotationComponentDataWrapper.DepositSummaryWrapper();
        depositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit = depositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit = 0;
        depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit = 0;
        Test.startTest();
        Boolean res = QuotationPrepController.validateCarriedDepositWhenRenewOpp_And_NoCAM(depositObject);
        Test.stopTest();
    }

    @isTest
    public static void test_validateExpenseTypeWhenContractTypeLongLease() {
        String expenseJSon = QuotationPrepController.getNewExpenseINstallmentJson();
        QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper expenseObject = (QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper) JSON.deserialize(expenseJSon, QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper.class);
        List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseList = new List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>();
        expenseList.add(expenseObject);
        expenseJSon = JSON.serialize(expenseList);
        List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper> expenseAndFeeList = (List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>) JSON.deserialize(expenseJSon, List<QuotationComponentDataWrapper.ExpenseAndDepositInstallmentWrapper>.class);
        Test.startTest();
        Boolean res = QuotationPrepController.validateExpenseTypeWhenContractTypeLongLease(expenseAndFeeList);
        Test.stopTest();
    }

    //OpportunityController
    @isTest
    public static void test_generateOppPeriodForFixedMeasurement() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);
        oppDetail.calculationMethod = Constant.CAL_METHOD_FIXED_MEAS;
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';

        String selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,Constant.CAL_METHOD_FIXED_MEAS, 'Short-Term' , 3, 0, oppDetailJSON);
        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        
        Test.startTest();
        OpportunityPeriod__c res = oppController.generateOppPeriodForFixedMeasurement(opp.Id,periodPricing[0],oppDetail);
        Test.stopTest();
    }

    @isTest
    public static void test_generateOppPeriodForFixedPrice() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);
        oppDetail.calculationMethod = Constant.CAL_METHOD_FIXED_PRICE;
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';

        String selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,Constant.CAL_METHOD_FIXED_PRICE, 'Short-Term' , 3, 0, oppDetailJSON);
        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        
        Test.startTest();
        OpportunityPeriod__c res = oppController.generateOppPeriodForFixedPrice(opp.Id,periodPricing[0],oppDetail);
        Test.stopTest();
    }
    
    @isTest
    public static void test_generateDepositMeasurement() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];   
        
        Test.startTest();
        DepositMeasurementModel.Data res = oppController.generateDepositMeasurement(opp.Id,'Test', 1, IDGenerator.generate(Schema.getGlobalDescribe().get('Measurement__c')));
        Test.stopTest();
    }

    @isTest
    public static void test_generateOppPriceForFixedPrice() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);
        oppDetail.calculationMethod = Constant.CAL_METHOD_FIXED_PRICE;
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';

        String selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,Constant.CAL_METHOD_FIXED_PRICE, 'Short-Term' , 3, 0, oppDetailJSON);
        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        Map<Integer, List<OpportunityController.IncludedCAMInfo>> periodWithCAMMap = OpportunityController.getPeriodMappingWithCAM(camOrAirServiceObject, periodPricing);
        Map<Integer, List<OpportunityController.SumIncludedCAM>> mapPeriodNumberWithCAMPricing = OpportunityController.getSumPriceByPeriodMappingWithCAM(periodPricing[0].PeriodNumber, periodWithCAMMap);

        Test.startTest();
        List<OpportunityPrice__c> res = oppController.generateOppPriceForFixedPrice(opp.Id,oppDetail,periodPricing[0],mapPeriodNumberWithCAMPricing,null,null,null);
        Test.stopTest();
    }

    @isTest
    public static void test_generateOppPriceForFixedMeasurement() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);
        oppDetail.calculationMethod = Constant.CAL_METHOD_FIXED_MEAS;
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';

        String selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        String periodPricingJson = QuotationPrepController.getPeriodPricingDetail(selectedRO,opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1) ,Constant.CAL_METHOD_FIXED_MEAS, 'Short-Term' , 3, 0, oppDetailJSON);
        List<QuotationComponentDataWrapper.PeriodPricing> periodPricing = (List<QuotationComponentDataWrapper.PeriodPricing>) JSON.deserialize(periodPricingJson, List<QuotationComponentDataWrapper.PeriodPricing>.class);
        String camPricingJSON = QuotationPrepController.getCAMPricingDetail(opp.Id, selectedRO, opp.Estimated_Contract_Start_Date__c, opp.Estimated_Contract_End_Date__c.addDays(-1), 'Short-Term',5 ,true,0,0,oppDetailJSON);
        QuotationComponentDataWrapper.CAMPricingWrapper camOrAirServiceObject = (QuotationComponentDataWrapper.CAMPricingWrapper) JSON.deserialize(camPricingJSON, QuotationComponentDataWrapper.CAMPricingWrapper.class);
        Map<Integer, List<OpportunityController.IncludedCAMInfo>> periodWithCAMMap = OpportunityController.getPeriodMappingWithCAM(camOrAirServiceObject, periodPricing);

        Test.startTest();
        List<OpportunityPrice__c> res = oppController.generateOppPriceForFixedMeasurement(opp.Id,oppDetail,periodPricing[0],periodWithCAMMap,null,null);
        Test.stopTest();
    }

    @isTest
    public static void test_processResetSecurityDeposit() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id, Deposit_Month__c FROM Opportunity LIMIT 1];   
        Opportunity opp2 = opp;
        opp2.Deposit_Month__c = 10;

        Test.startTest();
        oppController.processResetSecurityDeposit(new Map<Id, SObject>{opp.Id => opp}, new List<SObject>{opp2});
        Test.stopTest();
    }

    @isTest
    public static void test_getContractedROMap() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);
        oppDetail.calculationMethod = Constant.CAL_METHOD_FIXED_MEAS;
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';

        Units__c unit = [SELECT Id FROM Units__c LIMIT 1];

        Contract__c contract = new Contract__c();
        contract.Name = 'My Contract';
        contract.Contract_Start_Date__c = Date.today();
        contract.Contract_End_Date__c = Date.today();
        insert contract;

        ContractLineItem__c cli = new ContractLineItem__c();
        cli.Contract__c = contract.Id;
        cli.Unit__c = unit.Id;
        insert cli;

        Test.startTest();
        QuotationPrepController.getContractedROMap(new Map<Id, Contract__c>{contract.Id => contract}, new List<ContractLineItem__c>{cli}, Date.today(), Date.today());
        Test.stopTest();
    }

    @isTest
    public static void testSeachRentalObjectWithContract() {
        OpportunityController oppController = new OpportunityController();
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        QuotationComponentDataWrapper.OppUIWrapper oppDetail = (QuotationComponentDataWrapper.OppUIWrapper) JSON.deserialize(oppDetailJSON, QuotationComponentDataWrapper.OppUIWrapper.class);
        oppDetail.calculationMethod = Constant.CAL_METHOD_FIXED_MEAS;
        Building__c building = [SELECT Id FROM Building__c WHERE Building_Name_TH__c = 'buildingNameTH' LIMIT 1];
        String queryCondition = queryForSearchRO + '\''+building.Id+'\'';

        Units__c unit = [SELECT Id FROM Units__c LIMIT 1];

        Contract__c contract = new Contract__c();
        contract.Name = 'My Contract';
        contract.Contract_Start_Date__c = Date.today();
        contract.Contract_End_Date__c = Date.today();
        insert contract;

        ContractLineItem__c cli = new ContractLineItem__c();
        cli.Contract__c = contract.Id;
        cli.Unit__c = unit.Id;
        insert cli;

        Test.startTest();
        String selectedRO = QuotationPrepController.SearchRentalObject(queryCondition, false, String.valueOf(opp.Estimated_Contract_Start_Date__c), String.valueOf(opp.Estimated_Contract_End_Date__c));
        Test.stopTest();
    }

    @isTest
    static void testErrorSaveDepositObject() {
        Opportunity opp = [SELECT Id,
                                    Name,
                                    Usage_Type__c,
                                    CloseDate,
                                    RecordTypeId,
                                    StageName,
                                    AccountId,
                                    Building__c,
                                    Shop_Name__c,
                                    Rental_Period_Year__c,
                                    Contact_Name__c,
                                    Estimated_Contract_Start_Date__c,
                                    Estimated_Contract_End_Date__c FROM Opportunity LIMIT 1];   
        createShortLeaseFixOpp(opp, 'Fixed Rental Object', null);
        update opp;
    
        String oppDetailJSON = QuotationPrepController.getOppDetail(opp.Id);
        String camDeposit = QuotationPrepController.getDepositObjectJson(Constant.CAL_METHOD_CAM,100,100,100,6,null,oppDetailJSON);
        QuotationComponentDataWrapper.DepositWrapper depositObject = (QuotationComponentDataWrapper.DepositWrapper) JSON.deserialize(camDeposit, QuotationComponentDataWrapper.DepositWrapper.class);
        
        depositObject.DepositCalculationType = 'Advance';
        depositObject.DepositSummary.AdvanceDepositAmount = 999; // Error

        List<QuotationComponentDataWrapper.DepositOtherWrapper> otherDepositList = new List<QuotationComponentDataWrapper.DepositOtherWrapper>();
        QuotationComponentDataWrapper.DepositOtherWrapper newOtherDeposit = new QuotationComponentDataWrapper.DepositOtherWrapper();
        newOtherDeposit.Type = 'Furniture Deposit';
        newOtherDeposit.Remark = 'Test Remark' ;
        newOtherDeposit.TotalAmount = 1000;
        newOtherDeposit.TotalInstallment =  1000;
        newOtherDeposit.NumberOfInstallment = 1;
        newOtherDeposit.InstallmentList = new List<QuotationComponentDataWrapper.InstallmentWrapper>();

        QuotationComponentDataWrapper.InstallmentWrapper newInstallment = new QuotationComponentDataWrapper.InstallmentWrapper();
        newInstallment.InstallmentNumber = '1';
        newInstallment.InstallmentAmount = 1000;
        newInstallment.InstallmentAmountWithVat = 1070; 
        newInstallment.InstallmentVAT = 70;

        newOtherDeposit.InstallmentList.add(newInstallment);

        otherDepositList.add(newOtherDeposit);
        depositObject.OtherDepositList = otherDepositList;

        camDeposit  = JSON.serialize(depositObject);
        
        Test.startTest();
        QuotationPrepController.saveDepositApex(camDeposit, opp.Id, oppDetailJSON, false);

        newOtherDeposit.NumberOfInstallment = 0;
        newOtherDeposit.InstallmentList.add(newInstallment);
        otherDepositList.add(newOtherDeposit);
        camDeposit  = JSON.serialize(depositObject);
        QuotationPrepController.saveDepositApex(camDeposit, opp.Id, oppDetailJSON, false);
        Test.stopTest();           
    }

    //generateOppPeriodForFixedMeasurement
    //generateOppPeriodForFixedPrice
    //generateDepositMeasurement
    //generateOppPriceForFixedPrice
    //generateOppPriceForFixedMeasurement
    //processResetSecurityDeposit 
    //isDepositMonthChange
}