@isTest
public with sharing class OpportunityTrigger_Test {
    
    @TestSetup
    static void makeData(){
        insert new OpportunitySetting__c(Tax__c = 0.07);
        TriggerActivation__c triggerFieldValueSetting = new TriggerActivation__c();
        triggerFieldValueSetting.OpportunityTrigger__c = true;
        insert triggerFieldValueSetting;
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
                                            RoomNumber__c = testUnit.Name,
                                            Approve_Status__c = 'Approved',
                                            Total_Area_sq_m__c = 0,
                                            Total_Other_Expense_Amount_THB__c = 0,
                                            TotalDeposit__c = 0,
                                            Total_Rent_billboard__c = 0,
                                            Generate_Billboard_Amount__c = 0,
                                            Install_Billboard_Amount__c = 0,
                                            Monthly_Rent_Billboard__c = 0,
                                            TotalRentGP__c = 0);
        insert oppSpace;
         
        Profile prof = [SELECT id FROM profile WHERE name = 'Manager'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2';
        user.profileId = prof.id;
        user.Username = 'BTATestUser@test.com';
        user.email = 'BTATestUser@test.com';
        user.Alias = 'tester';
        user.TimeZoneSidKey = 'Asia/Bangkok';
        user.LocaleSidKey = 'en_GB';
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.IsActive = true;
        insert user;
    }

    @isTest
    public static void testInsertOpportunity(){

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'Manager' AND IsActive = TRUE LIMIT 1];

        Opportunity oppSpace = new Opportunity(
                                            Name = 'Space Opp',
                                            Rental_Type__c = 'Space_Rental',
                                            StageName = 'Quotation Preparation',
                                            Branch__c = 'Design Village Ratchapruek',
                                            Calculation_Method__c = 'Fixed Rental Object',
                                            // Decoration_Insurance_Amount__c = 1000,
                                            Decoration_Insurance_Discount__c = 100,
                                            Contract_Type__c = 'Short-Term Fixed Rent',
                                            AccountId = acc.Id,
                                            Building__c = building.id,
                                            Approve_Status__c = 'Approved',
                                            Rental_Period_Year__c = 1,
                                            CloseDate = System.today(),
                                            Shop_Name__c = 'Test Shop',
                                            OwnerId = usr.Id,
                                            Total_Area_sq_m__c = 0,
                                            Total_Other_Expense_Amount_THB__c = 0,
                                            TotalDeposit__c = 0,
                                            Total_Rent_billboard__c = 0,
                                            Generate_Billboard_Amount__c = 0,
                                            Install_Billboard_Amount__c = 0,
                                            Monthly_Rent_Billboard__c = 0,
                                            TotalRentGP__c = 0);
        insert oppSpace;
    }

    @isTest
    public static void testInsertOpportunityOP(){

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'Manager' LIMIT 1];

        Opportunity opp = new Opportunity(
            Name = 'OP Opp',
            StageName = 'Quotation Preparation',
            Rental_Type__c = 'OP_Rental',
            CloseDate = System.today(),
            AccountId = acc.Id,
            Building__c = building.id,
            Rental_Period_Year__c = 1
        );
        insert opp;

    }
    @isTest
    public static void testTiggerOpportunityBillBoard(){

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'Manager' LIMIT 1];

        Opportunity BBOpp = new Opportunity(
            Name = 'BillBoard Opp',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_a_Billboard').getRecordTypeId(),
            StageName = 'Quotation Preparation',
            Rental_Type__c = 'Billboard_Rental',
            CloseDate = System.today(),
            AccountId = acc.Id,
            Building__c = building.id,
            Rental_Period_Year__c = 1,
            No_CAM__c = true
        );
        insert BBOpp;

    }
    @isTest
    public static void testTiggerOpportunityEvent(){

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Building__c building = [SELECT Id FROM Building__c LIMIT 1];
        User usr = [SELECT Id FROM User WHERE Profile.Name = 'Manager' LIMIT 1];

        Opportunity eventOpp = new Opportunity(
            Name = 'Event Opp',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Rent_Event').getRecordTypeId(),
            StageName = 'Quotation Preparation',
            Rental_Type__c = 'Event_Rental',
            CloseDate = System.today(),
            AccountId = acc.Id,
            Building__c = building.id,
            Rental_Period_Month__c = 5,
            TotalOpportunityQuantity = 1
        );
        insert eventOpp;

    }

    @isTest
    public static void testUpdateTrigger(){

        Opportunity updateOpp = [SELECT Id FROM Opportunity LIMIT 1];

        
        // Opportunity updateOpp = new Opportunity(Id = opp.Id);
        updateOpp.Total_Area_sq_m__c = 1;
        updateOpp.Total_Other_Expense_Amount_THB__c = 10;
        updateOpp.TotalDeposit__c = 10;
        updateOpp.Total_Rent_billboard__c = 10;
        updateOpp.Generate_Billboard_Amount__c = 200;
        updateOpp.Install_Billboard_Amount__c = 40;
        updateOpp.Monthly_Rent_Billboard__c = 10;
        updateOpp.TotalRentGP__c = 20;
        update updateOpp;
    }


}