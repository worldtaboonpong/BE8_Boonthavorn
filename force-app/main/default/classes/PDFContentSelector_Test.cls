@isTest
public with sharing class PDFContentSelector_Test {    
    public static Id recordTypeIdForPDFMaster = RecordTypeUtility.getRecordTypeId('PDF_Content__c','Master_Template');

    @TestSetup
    static void makeData(){
        PDF_Content__c content = new PDF_Content__c(
            Content__c = '<p>ผู้ให้เช่ามีความยินดีจะเสนอพื้นที่เช่า โดยมีรายละเอียดและเงื่อนไขดังนี้:</p>',
            Is_Active__c = true,
            Object__c = 'Opportunity',
            Language__c = 'Thai',
            RecordTypeId = recordTypeIdForPDFMaster,
            Rental_Type__C = 'Space_Rental');
        insert content;
        Branch__c testBranch = new Branch__c(Name = 'test Branch',Branch_Code__c = '0000');
        insert testBranch;

        Building__c testBuilding = new Building__c(Name = 'test', Branch_Code__c = '0000' ,Branch__c = testBranch.Id, Building_Abbreviated__c = 'A',Building_Name_TH__c= 'THName',Company_Address__c = 'Address',Bank_Account_Name__c = 'Test Name', Bank_Account_Number__c='012345678912');
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
                                            RoomNumber__c = testUnit.Name);
        insert oppSpace;

        ContentVersion version = new ContentVersion(
            Title='ROImage_test_Fl0_Test00',
            PathOnClient='ROImage_test_Fl0_Test00.jpg',
            VersionData=EncodingUtil.base64Decode('AA=='),
            Origin='H'
            );
insert version;


        ContentDocumentLink linkedDoc = new ContentDocumentLink(
            LinkedEntityId = testUnit.Id,
            contentdocumentid = [select contentdocumentid from contentversion where id =: version.id].contentdocumentid
        );
        insert linkedDoc;
    }

    @isTest
    static void testGetPDFContentMasterByObject(){
        List<PDF_Content__c> content = [SELECT Id, Sequence__c, Is_Show_Sequence__c, Content__c, Expression_Criteria__c, Language__c, Continue_From_Above__c, Rental_Type__c
        FROM PDF_Content__c
        WHERE Is_Active__c =: true AND Object__c = 'Opportunity' AND Language__c ='Thai' AND RecordTypeId =: recordTypeIdForPDFMaster AND Rental_Type__C = 'Space_Rental'
        ORDER BY Sequence__c ASC];
        Set<Decimal> existedSequence = new Set<Decimal>();
        Test.startTest();
        List<PDF_Content__c> res = PDFContentSelector.getPDFContentMasterByObject('Opportunity',recordTypeIdForPDFMaster,'Thai','Space_Rental',existedSequence);
        System.assertEquals(content, res);
        Test.stopTest();
    }

    @isTest
    static void testGetPDFContentMasterByObjectApproved(){
        List<PDF_Content__c> content = [SELECT Id, Sequence__c, Is_Show_Sequence__c, Content__c, Expression_Criteria__c, Language__c, Continue_From_Above__c, Rental_Type__c
        FROM PDF_Content__c
        WHERE Is_Active__c =: true AND Object__c = 'Opportunity' AND Language__c ='Thai' AND RecordTypeId =: recordTypeIdForPDFMaster AND Rental_Type__C = 'Space_Rental'
        ORDER BY Sequence__c ASC];
        Set<Decimal> existedSequence = new Set<Decimal>();
        for(PDF_Content__c record: content){
            existedSequence.add(record.Sequence__c);
        }
        
        Test.startTest();
        List<PDF_Content__c> res = PDFContentSelector.getPDFContentMasterByObject('Opportunity',recordTypeIdForPDFMaster,'Thai','Space_Rental',existedSequence);
        System.assertEquals(content, res);
        Test.stopTest();
    }

    @isTest
    static void testGetPDFContentIdByCondition(){
        Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        String condition = 'Opportunity__c = \'' + newOpp.Id + '\'';
        List<PDF_Content__c> contentList = null;
        String query = 'SELECT Id FROM PDF_Content__c WHERE ' + condition;
        contentList = Database.query(query);
        Test.startTest();
        List<PDF_Content__c> res = PDFContentSelector.getPDFContentIdByCondition(condition);
        System.assertEquals(contentList, res);
        Test.stopTest();
    }

    @isTest
    static void testGetContentVersionByObject(){
        // ROImage_test_Fl0_Test00
        Set<String> fileNameSet = new Set<String> {'ROImage_test_Fl0_Test00.jpg'};
        Id contentDocId = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in (SELECT Id FROM Units__c)].ContentDocumentId;
        List<ContentVersion> contentVer = [SELECT Id, ContentBodyId, PathOnClient, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId =: contentDocId];

        Test.startTest();
        List<ContentVersion> res = PDFContentSelector.getContentVersionByObject('Units__c', fileNameSet);
        System.assertEquals(contentVer,res);
        Test.stopTest();
    }

    @isTest
    static void testGetRecordValue(){
        String opp = 'Opportunity';
        String oppId = 'Id = \'' + [SELECT Id FROM Opportunity LIMIT 1].Id + '\''; 
        Set<String> fieldAPISet = new Set<String>{'name'};
        String query = 'SELECT name'  + ' FROM ' + opp + ' WHERE ' + oppId;
        List<SObject> listObject = Database.query(query);

        Test.startTest();
        List<SObject> res = PDFContentSelector.getRecordValue(fieldAPISet, opp, oppId);
        System.assertEquals(listObject, res);
        Test.stopTest();
    }
}