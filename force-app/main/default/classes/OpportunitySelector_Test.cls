@isTest
public with sharing class OpportunitySelector_Test {
    
    @TestSetup
    static void makeData(){
        Branch__c testBranch = new Branch__c(Name = 'test Branch',Branch_Code__c = '0000');
        insert testBranch;

        Building__c testBuilding = new Building__c(Name = 'test Building', Branch_Code__c = '0000' ,Branch__c = testBranch.Id, Building_Abbreviated__c = 'A',Building_Name_TH__c= 'THName',Company_Address__c = 'Address',Bank_Account_Name__c = 'Test Name', Bank_Account_Number__c='012345678912');
        insert testBuilding;

        Floor__c testFloor = new Floor__c(Name = '0st Floor', Floor_Code__c = 'Fl0', Building__c = testBuilding.Id, Floor_Short_Name__c = 'Fl0');
        insert testFloor;

        Units__c testUnit = new Units__c(Name = 'Test00', 
                                        Building__c = testBuilding.Id, 
                                        Category__c='Common Area',
                                        Floor__c = testFloor.Id,
                                        TotalArea__c = 20,
                                        Units_Code__c = 'T00',
                                        UnitType__c = 'Rental Unit',
                                        LeasableArea__c = 20,
                                        ValidFrom__c = System.today(),
                                        ValidTo__c = System.today()
                                        );
        insert testUnit;
        Units__c testUnit2 = new Units__c(Name = 'Test01', 
                                        Building__c = testBuilding.Id, 
                                        Category__c='Common Area',
                                        Floor__c = testFloor.Id,
                                        TotalArea__c = 20,
                                        Units_Code__c = 'T01',
                                        UnitType__c = 'Rental Unit',
                                        LeasableArea__c = 20,
                                        ValidFrom__c = System.today(),
                                        ValidTo__c = System.today()
                                        );
        insert testUnit2;
        Units__c testUnit3 = new Units__c(Name = 'Test02', 
                                        Building__c = testBuilding.Id, 
                                        Category__c='Common Area',
                                        Floor__c = testFloor.Id,
                                        TotalArea__c = 20,
                                        Units_Code__c = 'T01',
                                        UnitType__c = 'Rental Unit',
                                        LeasableArea__c = 20,
                                        ValidFrom__c = System.today(),
                                        ValidTo__c = System.today()
                                        );
        insert testUnit3;
        Units__c testUnit4 = new Units__c(Name = 'Test03', 
                                        Building__c = testBuilding.Id, 
                                        Category__c='Common Area',
                                        Floor__c = testFloor.Id,
                                        TotalArea__c = 20,
                                        Units_Code__c = 'T01',
                                        UnitType__c = 'Rental Unit',
                                        LeasableArea__c = 20,
                                        ValidFrom__c = System.today(),
                                        ValidTo__c = System.today()
                                        );
        insert testUnit4;

        Measurement__c testMeasurement = new Measurement__c(
                                                            // Building__c = testBuilding.Id,
                                                            // Floor__c = testFloor.Id,
                                                            Measurement_Area_Sqm__c = 20,
                                                            Type__c = 'Common Area',
                                                            Unit_No__c = testUnit.Id,
                                                            Valid_From_Date__c = System.today(),
                                                            Valid_To_Date__c = System.today()
                                                            );
        insert testMeasurement;

        Account account = new Account();
        account.Name = 'Test Account';
        account.Phone = '0200000000';
        // account.Email = 'Test@Gmail.com';
        account.Company__c = 'TestCompany';
        account.Company_Code__c = 'Company1';
        insert account;


        Contact testContact = new Contact(
                                        // Name = 'Test Tester',
                                        LastName = 'Chi',
                                        title__c = 'Business owner',
                                        AccountId = account.Id,
                                        Email = 'contact@gmail.com',
                                        MobilePhone = '0200000001'
                                        );
        insert testContact;

        //empty Opp & Contract
        Opportunity oppSpace = new Opportunity(
                                            Name = 'Space Opp',
                                            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId(),
                                            Rental_Type__c = 'Space_Rental',
                                            StageName = 'Quotation Preparation',
                                            AccountId = account.Id,
                                            Branch__c = 'Design Village Ratchapruek',
                                            Building__c = testBuilding.Id,
                                            Calculation_Method__c = 'Fixed Rental Object',
                                            ContactId = testContact.Id,
                                            // Decoration_Insurance_Amount__c = 1000,
                                            Decoration_Insurance_Discount__c = 100,
                                            Contract_Type__c = 'Short-Term Fixed Rent',
                                            Rental_Period_Year__c = 1,
                                            CloseDate = System.today(),
                                            Shop_Name__c = 'Test Shop',
                                            RoomNumber__c = testUnit.Name);
        insert oppSpace;

        OpportunityPeriod__c spacePeriod = new OpportunityPeriod__c(Opportunity__c = oppSpace.Id,
                                                                    CalculationMethod__c = oppSpace.Calculation_Method__c,
                                                                    LeasableArea__c = 20,
                                                                    MinType__c = 'Measurement',
                                                                    PeriodFrom__c = System.today(),
                                                                    PeriodTo__c = System.today()+1,
                                                                    RentMonth__c = 9600,
                                                                    // RentSqmMonth__c = 8,
                                                                    ServiceMonth__c = 14400,
                                                                    // ServiceSqmMonth__c = 12,
                                                                    Total__c = 24000,
                                                                    TotalArea__c = 20
                                                                    );
        insert spacePeriod;

        OpportunityDepositExpense__c additionalDepositExpense = new OpportunityDepositExpense__c(
                                                                                        Opportunity__c = oppSpace.Id,
                                                                                        Type__c = 'Security Deposit	',
                                                                                        Price__c = 1000,
                                                                                        Remark__c = 'Remark Test',
                                                                                        TypeGroup__c = 'Expense'
                                                                                        );
        insert additionalDepositExpense;

        OpportunityPrice__c spacePrice = new OpportunityPrice__c(Opportunity__c = oppSpace.Id,
                                                                OpportunityPeriod__c = spacePeriod.Id,
                                                                CalculationMethod__c = oppSpace.Calculation_Method__c,
                                                                From__c = spacePeriod.PeriodFrom__c,
                                                                To__c = spacePeriod.PeriodTo__c,
                                                                Price__c = 150,
                                                                TotalPrice__c = 24000,
                                                                MeasurementAmount__c = 20,
                                                                Unit__c = testUnit.Id ,
                                                                OpportunityDepositExpense__c = additionalDepositExpense.Id                                          
                                                                );
        insert spacePrice;


        OpportunityLineItem__c newOppLine = new OpportunityLineItem__c(
            Unit__c = testUnit.Id,
            Opportunity__c = oppSpace.Id
                                                                        );
    }

    @isTest
    static void getCurrentVersion_Test(){
        Opportunity opp = [SELECT Id, CurrentVersion__c FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        Test.startTest();
        List<Opportunity> res = OpportunitySelector.getCurrentVersion(idSet);

        System.assertEquals(new List<Opportunity>{opp}, res);
        Test.stopTest();
    }

    @isTest
    static void insertOpportunity_Test(){
        Opportunity opp  = new Opportunity(
                                    Name = 'empty Opp',
                                    StageName = 'Quotation Preparation',
                                    CloseDate = System.today()
        );
        List<Opportunity> oppList = new List<Opportunity>{opp};
        Boolean hasError = false;

        Test.startTest();
        try{
        OpportunitySelector.insertOpportunity(oppList);
        }catch(Exception e){
            hasError = true;
        }
        System.assertEquals(false, hasError);
        Test.stopTest();
    }

    @isTest
    static void updateOpportunity_Test(){
        Opportunity opp = [SELECT Id, CurrentVersion__c FROM Opportunity LIMIT 1];
        List<Opportunity> oppList = new List<Opportunity>{opp};

        Boolean hasError = false;

        Test.startTest();
        try{
        OpportunitySelector.updateOpportunity(oppList);
        }catch(Exception e){
            hasError = true;
        }
        System.assertEquals(false, hasError);
        Test.stopTest();
    }

    @isTest
    static void upsertOpportunity_Test(){
        Opportunity opp = [SELECT Id, CurrentVersion__c FROM Opportunity LIMIT 1];
        Opportunity opp2  = new Opportunity(
                                    Name = 'empty Opp',
                                    StageName = 'Quotation Preparation',
                                    CloseDate = System.today()
        );
        List<Opportunity> oppList = new List<Opportunity>{opp,opp2};

        Boolean hasError = false;

        Test.startTest();
        try{
        OpportunitySelector.upsertOpportunity(oppList);
        }catch(Exception e){
            hasError = true;
        }
        System.assertEquals(false, hasError);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityApproverCriteriaInfo_Test(){
        Opportunity opp = [SELECT Id, Shop_Name__c FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        Test.startTest();
        List<Opportunity> res = OpportunitySelector.getOpportunityApproverCriteriaInfo(idSet);

        System.assertEquals(new List<Opportunity>{opp}, res);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityOwner_Test(){
        Opportunity opp = [SELECT Id, OwnerId, Owner.Name FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        Test.startTest();
        List<Opportunity> res = OpportunitySelector.getOpportunityOwner(idSet);

        System.assertEquals(new List<Opportunity>{opp}, res);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityInfoByOppId_Test(){
        DescribeSObjectResult describeResult = Opportunity.getSObjectType().getDescribe();
        Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
        String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
        //String addOnField = ',Parent_Contract__r.RoomNumber__c,Parent_Contract__r.Total_Area_sq_m__c,Contact_Name__r.Name';
        String addOnField = ',Parent_Contract__r.Unit_No__c,Parent_Contract__r.Agreement_Total_Area__c';
        String queryString = 'SELECT ' + queryFieldString + addOnField + ' FROM Opportunity LIMIT 1';
        Opportunity opp = Database.query(queryString);
        Set<Id> idSet = new Set<Id>{opp.Id};

        Test.startTest();
        List<Opportunity> res = OpportunitySelector.getOpportunityInfoByOppId(idSet);

        System.assertEquals(new List<Opportunity>{opp}, res);
        Test.stopTest();
    }

    @isTest
    static void getRelatedOpportunityInfoByOppId_Test(){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('OpportunityPeriod__c').getDescribe();
        Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
        String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
        String queryString = 'SELECT ' + queryFieldString + ' FROM ' + ' OpportunityPeriod__c' + ' LIMIT 1';
        List<SObject> relatedOppInfoList = Database.query(queryString);

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        Test.startTest();
        List<SObject> res = OpportunitySelector.getRelatedOpportunityInfoByOppId('OpportunityPeriod__c',idSet);

        System.assertEquals(relatedOppInfoList, res);
        Test.stopTest();
    }

    @isTest
    static void getRelatedOpportunityInfoByOppIdMultiParam_Test(){
        String addedFieldName = 'Unit__r.Name';
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('OpportunityPrice__c').getDescribe();
        Set<String> queryFieldSet = describeResult.fields.getMap().keySet();
        String queryFieldString = String.join(new List<String>(queryFieldSet), ',');
        String queryString = 'SELECT '+ addedFieldName + ', ' +queryFieldString  + ' FROM ' + ' OpportunityPrice__c' + ' LIMIT 1';
        List<SObject> relatedOppInfoList = Database.query(queryString);

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        Test.startTest();
        List<SObject> res = OpportunitySelector.getRelatedOpportunityInfoByOppId(addedFieldName,'OpportunityPrice__c',idSet);

        System.assertEquals(relatedOppInfoList, res);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityLineInfoByOppId_Test(){
        List<OpportunityLineItem__c> oppLine = [SELECT Id, Unit__c, Opportunity__r.Estimated_Contract_Start_Date__c, Opportunity__r.Estimated_Contract_End_Date__c
        FROM OpportunityLineItem__c LIMIT 1];

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        Test.startTest();
        List<OpportunityLineItem__c> res = OpportunitySelector.getOpportunityLineInfoByOppId(idSet);

        System.assertEquals(oppLine, res);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityListView_Test(){
        String devName = 'RecentlyViewedOpportunities';
        List<ListView> listviews = [SELECT Id, Name, DeveloperName 
        FROM ListView 
        WHERE SobjectType = 'Opportunity' AND 
            DeveloperName =: devName];

        Test.startTest();
        List<ListView> res = OpportunitySelector.getOpportunityListView(devName);

        System.assertEquals(listviews, res);
        Test.stopTest();
    }

    @isTest
    static void getOpportunityPriceByOppPeriodId_Test(){

        OpportunityPeriod__c oppPeriod = [SELECT Id FROM OpportunityPeriod__c LIMIT 1];
        Set<Id> idSet = new Set<Id>{oppPeriod.Id};

        List<OpportunityPrice__c> oppPrice = [SELECT Id FROM OpportunityPrice__c LIMIT 1];

        Test.startTest();
        List<OpportunityPrice__c> res = OpportunitySelector.getOpportunityPriceByOppPeriodId(idSet);

        System.assertEquals(oppPrice, res);
        Test.stopTest();
    }

    @isTest
    static void getSecurityDepositHeaderByOppId_Test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        List<OpportunityDepositExpense__c> oppDeposit = [SELECT Id FROM OpportunityDepositExpense__c LIMIT 1];

        Test.startTest();
        List<OpportunityDepositExpense__c> res = OpportunitySelector.getSecurityDepositHeaderByOppId(idSet);

        System.assertEquals(oppDeposit, res);
        Test.stopTest();
    }

    @isTest
    static void getSecurityDepositPriceByOppId_Test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        List<OpportunityPrice__c> oppPrice = [SELECT Id FROM OpportunityPrice__c LIMIT 1];

        Test.startTest();
        List<OpportunityPrice__c> res = OpportunitySelector.getSecurityDepositPriceByOppId(idSet);

        System.assertEquals(oppPrice, res);
        Test.stopTest();
    }

    @isTest
    static void getFullAndAmortizedPriceByOppId_Test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<Id> idSet = new Set<Id>{opp.Id};

        List<OpportunityPrice__c> oppPrice = [SELECT Id FROM OpportunityPrice__c LIMIT 1];

        Test.startTest();
        List<OpportunityPrice__c> res = OpportunitySelector.getFullAndAmortizedPriceByOppId(idSet);

        System.assertEquals(oppPrice, res);
        Test.stopTest();
    }
}