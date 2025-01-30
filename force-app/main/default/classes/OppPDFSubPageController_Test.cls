@isTest
public with sharing class OppPDFSubPageController_Test {
    
    private static String OPP_NAME = 'test PDF Content';
    private String emptyOppId;

    @TestSetup
    static void makeData(){
        insert new OpportunitySetting__c(Tax__c = 0.07);

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
        Opportunity emptyOpp = new Opportunity(
                                                Name = 'empty Opp',
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
                                            CloseDate = System.today()
        );
        insert emptyOpp;

        Contract__c emptyContract = new Contract__c(
            Account_Name__c = account.Id,
            Opportunity_Name__c = emptyOpp.Id
        );
        insert emptyContract;

        // Test 4 type of Opp (Space , OP , Event, BillBoard)
        // Opp + Contract for Space Rental
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
                                                                    RentPercent__c = 40,
                                                                    ServicePercent__c = 60,
                                                                    // ServiceSqmMonth__c = 12,
                                                                    Total__c = 24000,
                                                                    TotalArea__c = 20
                                                                    );
        insert spacePeriod;

        OpportunityPrice__c spacePrice = new OpportunityPrice__c(Opportunity__c = oppSpace.Id,
                                                                OpportunityPeriod__c = spacePeriod.Id,
                                                                CalculationMethod__c = oppSpace.Calculation_Method__c,
                                                                From__c = spacePeriod.PeriodFrom__c,
                                                                To__c = spacePeriod.PeriodTo__c,
                                                                Price__c = 150,
                                                                TotalPrice__c = 24000,
                                                                MeasurementAmount__c = 20,
                                                                Unit__c = testUnit.Id                                             
                                                                );
        insert spacePrice;

        OpportunityDepositExpense__c additionalDepositExpense = new OpportunityDepositExpense__c(
                                                                                        Opportunity__c = oppSpace.Id,
                                                                                        Type__c = 'Additional Request',
                                                                                        Price__c = 1000,
                                                                                        Remark__c = 'Remark Test',
                                                                                        TypeGroup__c = 'Other'
                                                                                        );
        insert additionalDepositExpense;

        OpportunityDepositExpense__c exhaustDepositExpense = new OpportunityDepositExpense__c(
                                                                                        Opportunity__c = oppSpace.Id,
                                                                                        Type__c = 'Exhaust System',
                                                                                        Price__c = 1000,
                                                                                        TypeGroup__c = 'Other'
                                                                                    );
        insert exhaustDepositExpense;

        OpportunityDepositExpense__c otherDepositExpense = new OpportunityDepositExpense__c(
                                                                                        Opportunity__c = oppSpace.Id,
                                                                                        Type__c = 'อื่นๆ (เหมาจ่าย)',
                                                                                        Remark__c = 'others',
                                                                                        Price__c = 2000,
                                                                                        TypeGroup__c = 'Expense'
                                                                                        );
        insert otherDepositExpense;

        OpportunityDepositExpense__c parkingDepositExpense = new OpportunityDepositExpense__c(
                                                                                        Opportunity__c = oppSpace.Id,
                                                                                        Type__c = 'ค่าที่จอดรถ',
                                                                                        Price__c = 5000,
                                                                                        TypeGroup__c = 'Expense'
        );
        insert parkingDepositExpense;

        //Contract
        Contract__c spaceContract = new Contract__c(Account_Name__c = account.Id,
                                                    Opportunity_Name__c = oppSpace.Id                                      
                                                    );
        insert spaceContract;

        // OP opp and Contract
        // Opp GP
        Opportunity oppOp = new Opportunity(Name = 'OppOP',
                                            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId(),
                                            Rental_Type__c = 'OP_Rental',
                                            StageName = 'Quotation Preparation',
                                            AccountId = account.Id,
                                            Branch__c = 'Design Village Ratchapruek',
                                            Building__c = testBuilding.Id,
                                            Calculation_Method__c = 'GP no Min',
                                            ContactId = testContact.Id,
                                            // Decoration_Insurance_Amount__c = 1000,
                                            Decoration_Insurance_Discount__c = 100,
                                            Contract_Type__c = 'Long-Term GP Rent',
                                            Rental_Period_Year__c = 1,
                                            CloseDate = System.today(),
                                            Revenue_Collected_By__c = 'BTA เก็บเงิน	'
                                            );
        insert oppOp;

//        OpportunityGrading__c = '[{"ToR":0,"SalesDescription":"","ReportingRule":"null","OpportunityPeriodId":"a0EN000000KKGBOMA5","OpportunityId":"006N000000JydHjIAJ","Name":null,"IsIncludeCAM":false,"IsGrading":false,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"2025-11-30","GradingPeriodForm":"2024-12-01","GPRangeNo":"0","GP":20,"FromR":0}]'

        OpportunityPeriod__c OPPeriod = new OpportunityPeriod__c(Opportunity__c = oppOP.Id,
                                            CalculationMethod__c = oppOP.Calculation_Method__c,
                                            LeasableArea__c = 20,
                                            MinType__c = 'Measurement',
                                            PeriodFrom__c = System.today(),
                                            PeriodTo__c = System.today()+1,
                                            RentMonth__c = 14000,
                                            // RentSqmMonth__c = 8,
                                            ServiceMonth__c = 21000,
                                            RentPercent__c = 0,
                                            ServicePercent__c = 100,
                                            // ServiceSqmMonth__c = 12,
                                            Total__c = 35000,
                                            TotalArea__c = 20
                                            );
        insert OPPeriod;

        oppOp.OpportunityGrading__c = '[{"ToR":0,"SalesDescription":"","ReportingRule":"null","OpportunityPeriodId":"'+OPPeriod.Id+'","OpportunityId":"'+oppOp.Id+'","Name":null,"IsIncludeCAM":false,"IsGrading":false,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"2025-11-30","GradingPeriodForm":"2024-12-01","GPRangeNo":"0","GP":20,"FromR":0}]';

        update oppOp;

        OpportunityPrice__c OPPrice = new OpportunityPrice__c(Opportunity__c = oppSpace.Id,
                                                            OpportunityPeriod__c = spacePeriod.Id,
                                                            CalculationMethod__c = oppSpace.Calculation_Method__c,
                                                            From__c = spacePeriod.PeriodFrom__c,
                                                            To__c = spacePeriod.PeriodTo__c,
                                                            Price__c = 150,
                                                            TotalPrice__c = 24000,
                                                            MeasurementAmount__c = 20,
                                                            Unit__c = testUnit.Id                                             
                                                            );

        insert OPPrice;

        //test opp contract and opp with Fixed mintype
        Opportunity fixedOpp = new Opportunity(Name = 'FixedOpp',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId(),
            Rental_Type__c = 'Space_Rental',
            StageName = 'Quotation Preparation',
            Branch__c = 'Design Village Ratchapruek',
            Calculation_Method__c = 'Fixed Rental Object',
            Decoration_Insurance_Discount__c = 100,
            Contract_Type__c = 'Short-Term Fixed Rent',
            Rental_Period_Year__c = 1,
            CloseDate = System.today(),
            RoomNumber__c = 'Test00,Test01',
            AccountId = account.Id,
            Building__c = testBuilding.Id);
            insert fixedOpp;

            OpportunityPeriod__c fixedPeriod = new OpportunityPeriod__c(Opportunity__c = fixedOpp.Id,
                                            CalculationMethod__c = fixedOpp.Calculation_Method__c,
                                            LeasableArea__c = 20,
                                            MinType__c = 'Fixed',
                                            PeriodFrom__c = System.today(),
                                            PeriodTo__c = System.today()+1,
                                            RentMonth__c = 14000,
                                            // RentSqmMonth__c = 8,
                                            ServiceMonth__c = 21000,
                                            // ServiceSqmMonth__c = 12,
                                            Total__c = 35000,
                                            TotalArea__c = 20
                                            );
        insert fixedPeriod;
        OpportunityPeriod__c fixedPeriod2 = new OpportunityPeriod__c(Opportunity__c = fixedOpp.Id,
                                            CalculationMethod__c = fixedOpp.Calculation_Method__c,
                                            LeasableArea__c = 20,
                                            MinType__c = 'Fixed',
                                            PeriodFrom__c = System.today()+1,
                                            PeriodTo__c = System.today()+2,
                                            RentMonth__c = 14000,
                                            // RentSqmMonth__c = 8,
                                            ServiceMonth__c = 21000,
                                            // ServiceSqmMonth__c = 12,
                                            Total__c = 35000,
                                            TotalArea__c = 20
                                            );
        insert fixedPeriod2;

        OpportunityPrice__c fixedPrice = new OpportunityPrice__c(Opportunity__c = fixedOpp.Id,
                                                            OpportunityPeriod__c = fixedPeriod.Id,
                                                            CalculationMethod__c = fixedOpp.Calculation_Method__c,
                                                            From__c = fixedPeriod.PeriodFrom__c,
                                                            To__c = fixedPeriod.PeriodTo__c,
                                                            Price__c = 150,
                                                            TotalPrice__c = 24000,
                                                            MeasurementAmount__c = 20                                            
                                                            );
        insert fixedPrice;
        OpportunityPrice__c fixedPrice2 = new OpportunityPrice__c(Opportunity__c = fixedOpp.Id,
                                                            OpportunityPeriod__c = fixedPeriod2.Id,
                                                            CalculationMethod__c = fixedOpp.Calculation_Method__c,
                                                            From__c = fixedPeriod2.PeriodFrom__c,
                                                            To__c = fixedPeriod2.PeriodTo__c,
                                                            Price__c = 150,
                                                            TotalPrice__c = 24000,
                                                            MeasurementAmount__c = 20                                            
                                                            );
        insert fixedPrice2;

        Contract__c contract = new Contract__c(
            Account_Name__c = account.Id,
            Opportunity_Name__c = fixedOpp.Id
        );
        insert contract;

        //Event type
        Opportunity eventOpp = new Opportunity(Name = 'EventOpp',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_Event').getRecordTypeId(),
            Rental_Type__c = 'Event_Rental	',
            StageName = 'Quotation Preparation',
            Branch__c = 'Design Village Ratchapruek',
            Calculation_Method__c = 'GP no Min',
            Decoration_Insurance_Discount__c = 100,
            Contract_Type__c = 'Short-Term GP Rent',
            Rental_Period_Year__c = 1,
            CloseDate = System.today(),
            RoomNumber__c = 'Test02',
            AccountId = account.Id,
            Building__c = testBuilding.Id,
            Revenue_Collected_By__c = 'BTA เก็บเงิน',
            TotalOpportunityQuantity = 1);
            insert eventOpp;

            OpportunityPeriod__c eventPeriod = new OpportunityPeriod__c(Opportunity__c = eventOpp.Id,
            CalculationMethod__c = eventOpp.Calculation_Method__c,
            LeasableArea__c = 20,
            // MinType__c = 'Fixed',
            PeriodFrom__c = System.today(),
            PeriodTo__c = System.today()+1,
            // RentMonth__c = 14000,
            // RentSqmMonth__c = 8,
            // ServiceMonth__c = 21000,
            // ServiceSqmMonth__c = 12,
            Total__c = 35000,
            TotalArea__c = 20
            );
            insert eventPeriod;
            OpportunityPeriod__c eventPeriod2 = new OpportunityPeriod__c(Opportunity__c = eventOpp.Id,
            CalculationMethod__c = eventOpp.Calculation_Method__c,
            LeasableArea__c = 20,
            // MinType__c = 'Fixed',
            PeriodFrom__c = System.today()+1,
            PeriodTo__c = System.today()+2,
            // RentMonth__c = 14000,
            // RentSqmMonth__c = 8,
            // ServiceMonth__c = 21000,
            // ServiceSqmMonth__c = 12,
            Total__c = 35000,
            TotalArea__c = 20
            );
            insert eventPeriod2;

            eventOpp.OpportunityGrading__c = '[{"ToR":10000,"SalesDescription":"","ReportingRule":"null","OpportunityPeriodId":"'+eventPeriod.Id+'","OpportunityId":"'+oppOp.Id+'","Name":null,"IsIncludeCAM":false,"IsGrading":false,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"2025-11-30","GradingPeriodForm":"2024-12-01","GPRangeNo":"0","GP":20,"FromR":0},{"ToR":0,"SalesDescription":"","ReportingRule":"null","OpportunityPeriodId":"'+eventPeriod2.Id+'","OpportunityId":"'+oppOp.Id+'","Name":null,"IsIncludeCAM":false,"IsGrading":false,"Id":null,"GroupNo":0,"GradingTierOption":"Monthly คำนวณ GP ทุกเดือน","GradingPeriodTo":"2025-11-30","GradingPeriodForm":"2024-12-01","GPRangeNo":"0","GP":30,"FromR":10001}]';
            update eventOpp;

            OpportunityPrice__c eventPrice = new OpportunityPrice__c(Opportunity__c = eventOpp.Id,
                                                            OpportunityPeriod__c = eventPeriod.Id,
                                                            CalculationMethod__c = eventOpp.Calculation_Method__c,
                                                            From__c = eventPeriod.PeriodFrom__c,
                                                            To__c = eventPeriod.PeriodTo__c,
                                                            Price__c = 150,
                                                            TotalPrice__c = 24000,
                                                            MeasurementAmount__c = 20                                            
                                                            );
        insert eventPrice;
        OpportunityPrice__c eventPrice2 = new OpportunityPrice__c(Opportunity__c = eventOpp.Id,
                                                            OpportunityPeriod__c = eventPeriod2.Id,
                                                            CalculationMethod__c = eventOpp.Calculation_Method__c,
                                                            From__c = eventPeriod2.PeriodFrom__c,
                                                            To__c = eventPeriod2.PeriodTo__c,
                                                            Price__c = 150,
                                                            TotalPrice__c = 24000,
                                                            MeasurementAmount__c = 20                                            
                                                            );
        insert eventPrice2;

        Opportunity eventOpp2 = new Opportunity(Name = 'EventOpp2',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_Event').getRecordTypeId(),
            Rental_Type__c = 'Event_Rental	',
            StageName = 'Quotation Preparation',
            Branch__c = 'Design Village Ratchapruek',
            Calculation_Method__c = 'GP no Min',
            Decoration_Insurance_Discount__c = 100,
            Contract_Type__c = 'Short-Term GP Rent',
            Rental_Period_Year__c = 1,
            CloseDate = System.today(),
            RoomNumber__c = 'Test02',
            AccountId = account.Id,
            Building__c = testBuilding.Id,
            Revenue_Collected_By__c = 'BTA เก็บเงิน',
            TotalOpportunityQuantity = 1);
            insert eventOpp2;

            OpportunityPeriod__c eventPeriod3 = new OpportunityPeriod__c(Opportunity__c = eventOpp.Id,
            CalculationMethod__c = eventOpp.Calculation_Method__c,
            LeasableArea__c = 20,
            // MinType__c = 'Fixed',
            PeriodFrom__c = System.today(),
            PeriodTo__c = System.today()+1,
            // RentMonth__c = 14000,
            // RentSqmMonth__c = 8,
            // ServiceMonth__c = 21000,
            // ServiceSqmMonth__c = 12,
            Total__c = 35000,
            TotalArea__c = 20
            );
            insert eventPeriod3;

        //BillBoard
        Opportunity bbOpp = new Opportunity(
                                            Name = 'bbOpp',
                                            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_a_Billboard').getRecordTypeId(),
                                            Rental_Type__c = 'Billboard_Rental',
                                            StageName = 'Quotation Preparation',
                                            Branch__c = 'Design Village Ratchapruek',
                                            Calculation_Method__c = 'Fixed Rental Object',
                                            ContactId = testContact.Id,
                                            Decoration_Insurance_Discount__c = 100,
                                            Contract_Type__c = 'Short-Term Fixed Rent',
                                            Rental_Period_Year__c = 1,
                                            CloseDate = System.today(),
                                            RoomNumber__c = 'Test02',
                                            AccountId = account.Id,
                                            Building__c = testBuilding.Id,
                                            TotalOpportunityQuantity = 1,
                                            No_CAM__c = true
                                            );
        insert bbOpp;
        OpportunityPeriod__c bbPeriod = new OpportunityPeriod__c(
                                                Opportunity__c = bbOpp.Id,
                                                CalculationMethod__c = bbOpp.Calculation_Method__c,
                                                LeasableArea__c = 20,
                                                MinType__c = 'Fixed',
                                                PeriodFrom__c = System.today(),
                                                PeriodTo__c = System.today()+1,
                                                RentMonth__c = 14000,
                                                // RentSqmMonth__c = 8,
                                                ServiceMonth__c = 21000,
                                                // ServiceSqmMonth__c = 12,
                                                Total__c = 35000,
                                                TotalArea__c = 20
                                                                );
        insert bbPeriod;
        OpportunityPrice__c bbPrice = new OpportunityPrice__c(
                                                                Opportunity__c = bbOpp.Id,
                                                                OpportunityPeriod__c = bbPeriod.Id,
                                                                CalculationMethod__c = bbOpp.Calculation_Method__c,
                                                                From__c = bbPeriod.PeriodFrom__c,
                                                                To__c = bbPeriod.PeriodTo__c,
                                                                Price__c = 150,
                                                                TotalPrice__c = 24000,
                                                                MeasurementAmount__c = 20,
                                                                Unit__c = testUnit2.Id,
                                                                TotalPriceVAT__c = 1
        );
        insert bbPrice;
        Contract__c bbContract = new Contract__c(
            Account_Name__c = account.Id,
            Opportunity_Name__c = bbOpp.Id
        );
        insert bbContract;

        Opportunity bbOpp2 = new Opportunity(
            Name = 'bbOpp2',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_a_Billboard').getRecordTypeId(),
            Rental_Type__c = 'Billboard_Rental',
            StageName = 'Quotation Preparation',
            Branch__c = 'Design Village Ratchapruek',
            Calculation_Method__c = 'Fixed Rental Object',
            ContactId = testContact.Id,
            Decoration_Insurance_Discount__c = 100,
            Contract_Type__c = 'Short-Term Fixed Rent',
            Rental_Period_Year__c = 1,
            CloseDate = System.today(),
            RoomNumber__c = 'Test02',
            AccountId = account.Id,
            Building__c = testBuilding.Id,
            TotalOpportunityQuantity = 1,
            No_CAM__c = true
            );
insert bbOpp2;
OpportunityPeriod__c bbPeriod2 = new OpportunityPeriod__c(
                Opportunity__c = bbOpp.Id,
                CalculationMethod__c = bbOpp.Calculation_Method__c,
                LeasableArea__c = 20,
                MinType__c = 'Fixed',
                PeriodFrom__c = System.today(),
                PeriodTo__c = System.today()+1,
                RentMonth__c = 14000,
                // RentSqmMonth__c = 8,
                ServiceMonth__c = 21000,
                // ServiceSqmMonth__c = 12,
                Total__c = 35000,
                TotalArea__c = 20
                                );
insert bbPeriod2;
    }

    //additionalFee
        @isTest
        static void getQuotationAdditionalFee_Test(){
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Space Opp' LIMIT 1];
            // System.debug(opp.Rental_Type__c);
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(opp);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getQuotationAdditionalFee();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }
        @isTest
        static void getQuotationAdditionalFeeOP_Test(){
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'OppOP' LIMIT 1];
            // System.debug(opp.Rental_Type__c);
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(opp);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getQuotationAdditionalFee();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }

        @isTest
        static void emptyQuotationAdditionalFee_Test(){
            Opportunity opp = new Opportunity(Name = OPP_NAME,
            // RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_Space').getRecordTypeId(),
            Rental_Type__c = 'Space_Rental',
            StageName = 'Quotation Preparation',
            // AccountId = account.Id,
            Branch__c = 'Design Village Ratchapruek',
            // Building__c = testBuilding.Id,
            Calculation_Method__c = 'Fixed Rental Object',
            // ContactId = testContact.Id,
            // Decoration_Insurance_Amount__c = 1000,
            Decoration_Insurance_Discount__c = 100,
            Contract_Type__c = 'Short-Term Fixed Rent',
            Rental_Period_Year__c = 1,
            CloseDate = System.today());
            insert opp;

            Boolean hasError = false;
            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(opp);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getQuotationAdditionalFee();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }

    //Contract
        //empty
        @isTest
        static void emptygetContractFeePeriod_Space_Test(){
            
            Contract__c contract = [SELECT ID FROM Contract__c WHERE Opportunity_Name__r.Name = 'empty Opp' LIMIT 1];
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(contract);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getContractFeePeriod_Space();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }
    
        @isTest
        static void getContractFeePeriod_Space_Test(){
            Contract__c contract = [SELECT ID FROM Contract__c  WHERE Opportunity_Name__r.Name = 'Space Opp' LIMIT 1];
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(contract);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getContractFeePeriod_Space();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }
        // test เหมาจ่าย
        @isTest
        static void fixed_getContractFeePeriod_Space_Test(){
        Contract__c contract = [SELECT Id FROM Contract__c Where Opportunity_Name__r.Name = 'FixedOpp' LIMIT 1];
        Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(contract);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getContractFeePeriod_Space();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }

        //Event test
        @isTest
        static void getEventOppData_Test(){
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'EventOpp' LIMIT 1];
            // System.debug(opp.Rental_Type__c);
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(opp);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getEventOppData();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }

        @isTest
        static void empty_GetEventOppData_Test(){
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'EventOpp2' LIMIT 1];
            
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(opp);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getEventOppData();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }

        //billboard
        @isTest
        static void getBillBoardQuotationData(){
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'bbOpp' LIMIT 1];
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(opp);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getBillBoardQuotationData();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }

        @isTest
        static void empty_getBillBoardQuotationData(){
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'bbOpp2' LIMIT 1];
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(opp);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getBillBoardQuotationData();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);

            Test.stopTest();
        }

        @isTest
        static void getBillBoardContractData(){
            Contract__c contract = [SELECT Id FROM Contract__c Where Opportunity_Name__r.Name = 'bbOpp' LIMIT 1];
            Boolean hasError = false;

            Test.startTest();
            try{
                ApexPages.StandardController sc = new ApexPages.StandardController(contract);
                OppPDFSubPageController controller = new OppPDFSubPageController(sc);
                controller.getBillBoardContractData();
            }catch(Exception e){
                hasError = true;
                System.debug('Test Error '+ e.getMessage());
                System.debug('Test Error '+ e.getLineNumber());
            }
            System.assertEquals(false, hasError);
            Test.stopTest();
        }
}