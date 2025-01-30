@isTest
public with sharing class PDFController_Test {

    @TestSetup
    static void setupData() {

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
        Contract__c spaceContract = new Contract__c(Account_Name__c = account.Id,
                                                    Opportunity_Name__c = oppSpace.Id                                      
                                                    );
        insert spaceContract;

        // Id managerId = [SELECT Id FROM Profile WHERE Name = 'Manager' LIMIT 1].Id;
        // Id managerUser = [SELECT Id FROM User WHERE ProfileId =: managerId LIMIT 1].Id;
        Profile prof = [SELECT id FROM profile WHERE name = 'Manager'];
        User managerUser = new User();
        managerUser.firstName = 'test1';
        managerUser.lastName = 'test2';
        managerUser.profileId = prof.id;
        managerUser.Username = 'BTATestUser@test.com';
        managerUser.email = 'BTATestUser@test.com';
        managerUser.Alias = 'tester';
        managerUser.TimeZoneSidKey = 'Asia/Bangkok';
        managerUser.LocaleSidKey = 'en_GB';
        managerUser.EmailEncodingKey = 'UTF-8';
        managerUser.LanguageLocaleKey = 'en_US';
        insert managerUser;

        Opportunity oppSpace2 = new Opportunity(
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
                                            OwnerId = managerUser.Id,
                                            Approve_Status__c = 'Approved');
        insert oppSpace2;
        // Id managerUserId2 = [SELECT Id FROM User WHERE ProfileId !=: managerId LIMIT 1].Id;
        Profile prof2 = [SELECT id FROM profile WHERE name = 'Tenant and Building'];
        User managerUser2 = new User();
        managerUser2.firstName = 'test1';
        managerUser2.lastName = 'test2';
        managerUser2.profileId = prof2.id;
        managerUser2.Username = 'BTATestUser1@test.com';
        managerUser2.email = 'BTATestUser1@test.com';
        managerUser2.Alias = 'tester';
        managerUser2.TimeZoneSidKey = 'Asia/Bangkok';
        managerUser2.LocaleSidKey = 'en_GB';
        managerUser2.EmailEncodingKey = 'UTF-8';
        managerUser2.LanguageLocaleKey = 'en_US';
        insert managerUser2;
        Contract__c spaceContract2 = new Contract__c(Account_Name__c = account.Id,
                                                    Opportunity_Name__c = oppSpace.Id,
                                                    OwnerId =  managerUser2.Id,
                                                    Approve_Status__c = 'Approved'                           
                                                    );
        insert spaceContract2;

        PDF_Content__c tester = new PDF_Content__c(
            Sequence__c = 1,
            Content__c = '000000',
            Expression_Criteria__c = 'Approve_Status__c != "Approved"',
            Is_Active__c = true,
            Is_Show_Sequence__c = false,
            Is_Optional__c = false,
            Opportunity__c = oppSpace2.Id,
            Master_Content__c = null,
            Content_Description__c = null,
            Object__c = null,
            Language__c = 'Thai',
            Continue_From_Above__c = false

        );
        insert tester;
    }

    @isTest
    public static void testPDFController() {
        PageReference pageRef = Page.PDFSpace_OPQuotationtable;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('FieldSetDevName','Test');
        ApexPages.currentPage().getParameters().put('ObjectAPIName', 'Opportunity');
        ApexPages.currentPage().getParameters().put('Id',null);

        PDFController pdfController = new PDFController();

    }

    @isTest
    public static void testSaveQuotation() {
        Profile profileAdmin = [SELECT id FROM profile WHERE name = 'System Administrator'];
        User integrationUser = new User();
        integrationUser.firstName = 'Integration';
        integrationUser.lastName = 'Integration';
        integrationUser.profileId = profileAdmin.id;
        integrationUser.Username = 'Integration_Test@test.com';
        integrationUser.email = 'BTATestUser1@test.com';
        integrationUser.Alias = 'intetest';
        integrationUser.TimeZoneSidKey = 'Asia/Bangkok';
        integrationUser.LocaleSidKey = 'en_GB';
        integrationUser.EmailEncodingKey = 'UTF-8';
        integrationUser.LanguageLocaleKey = 'en_US';
        insert integrationUser;

        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        PDFController.SaveQuotation((String)opportunity.Id);
    }

    @isTest
    public static void testGenerateQuotation() {
        TriggerActivation__c triggerFieldValueSetting = new TriggerActivation__c();
        triggerFieldValueSetting.PDFContentTrigger__c = true;
        insert triggerFieldValueSetting;

        Id managerId = [SELECT Id FROM User WHERE Profile.Name = 'Manager' LIMIT 1].Id;
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Owner.Profile.Name != 'Manager' LIMIT 1];
        PDFController.GeneratePDFContent((String)opportunity.Id);
    }

    @isTest
    public static void testGenerateContract() {
        TriggerActivation__c triggerFieldValueSetting = new TriggerActivation__c();
        triggerFieldValueSetting.PDFContentTrigger__c = true;
        insert triggerFieldValueSetting;

        Contract__c contract = [SELECT Id FROM Contract__c  LIMIT 1];
        PDFController.GeneratePDFContent((String)contract.Id);
    }

    @isTest
    public static void testGenerateQuotationApproved(){
        TriggerActivation__c triggerFieldValueSetting = new TriggerActivation__c();
        triggerFieldValueSetting.PDFContentTrigger__c = true;
        insert triggerFieldValueSetting;

        Id managerId = [SELECT Id FROM User WHERE Profile.Name = 'Manager' LIMIT 1].Id;
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Owner.Profile.Name = 'Manager' LIMIT 1];
        PDFController.GeneratePDFContent((String)opp.Id);
    }

    @isTest
    public static void testGenerateApprovedContract() {
        TriggerActivation__c triggerFieldValueSetting = new TriggerActivation__c();
        triggerFieldValueSetting.PDFContentTrigger__c = true;
        insert triggerFieldValueSetting;

        Contract__c contract = [SELECT Id FROM Contract__c WHERE Approve_Status__c = 'Approved' LIMIT 1];
        PDFController.GeneratePDFContent((String)contract.Id);
    }
}