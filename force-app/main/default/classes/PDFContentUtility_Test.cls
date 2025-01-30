@isTest
public class PDFContentUtility_Test
{
    public static Id recordTypeIdForPDFMaster = RecordTypeUtility.getRecordTypeId('PDF_Content__c','Master_Template');

    @TestSetup
    static void makeData(){
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

        OpportunityLineItem__c oppLine = new OpportunityLineItem__c();
        oppLine.Opportunity__c = oppSpace.Id;
        oppLine.Unit__c = testUnit.Id;
        insert(oppLine);

        

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
    static void test_generatePDFContent() {
        createPDFContentMaster();
        PDFContentUtility pdfUtil = new PDFContentUtility();
        Opportunity newOpp = [SELECT Id FROM Opportunity Limit 1];
        pdfUtil.removeRecordByCondition('Opportunity__c = \'' + newOpp.Id + '\'');
        pdfUtil.generatePDFContent(newOpp.Id, 'Thai', 'Opportunity__c','Space_Rental');
    }



    @isTest
    static void test_updatePDFContent() {
        TriggerActivation__c triggerFieldValueSetting = new TriggerActivation__c();
        triggerFieldValueSetting.PDFContentTrigger__c = true;
        insert triggerFieldValueSetting;

        createPDFContentMaster();
        PDFContentUtility pdfUtil = new PDFContentUtility();
        Opportunity newOpp = [SELECT Id FROM Opportunity Limit 1];
        pdfUtil.removeRecordByCondition('Opportunity__c = \'' + newOpp.Id + '\'');
        pdfUtil.generatePDFContent(newOpp.Id, 'Thai', 'Opportunity__c','Space_Rental');
        PDF_Content__c pdfContent = [SELECT Id, Content__c FROM PDF_Content__c WHERE RecordType.DeveloperName = 'Content' LIMIT 1];
        pdfContent.Content__c = pdfContent.Content__c + ' Test';
        update pdfContent;
    }


    public static void createPDFContentMaster(){
        PDF_Content__c pdfContentMaster = new PDF_Content__c(
            Sequence__c = 0,
            Content__c = '<p>ทดสอบการใส่ sequence</p><p> </p><p>{VF:PDFSpace_OPQuotationtable}</p><p> </p><p style="text-align: center;">{LOOPRELATEDOBJ:OpportunityLineItem__c;LOOKUPFIELD:Opportunity__c;FIELDS:Unit__r.Building__r.Building_Abbreviated__c, Unit__r.Floor__r.Floor_Short_Name__c, Unit__r.Name} </p><p style="text-align: center;">[SOURCE:ROImage_{FIELDS:Unit__r.Building__r.Building_Abbreviated__c}_{FIELDS:Unit__r.Floor__r.Floor_Short_Name__c}_{FIELDS:Unit__r.Name}.jpg]</p><p style="text-align: center;">{ENDLOOPRELATEDOBJ} </p><p> </p><p> </p><p><span style="color: rgb(0,0,0);">{FIELD:Building__r.Name}</span></p><p><span style="color: rgb(0,0,0);">{FIELD:Name}</span></p><p> </p><p> </p><p> </p><p> </p>',
            Is_Active__c = true,
            Is_Show_Sequence__c = true,
            Is_Optional__c = true,
            Object__c = 'Opportunity',
            Language__c = 'Thai',
            Continue_From_Above__c = true,
            RecordTypeId = recordTypeIdForPDFMaster,
            Rental_Type__c = 'Space_Rental'
        );
        insert pdfContentMaster;
    }
}