@isTest
public class MasterPlanControllerTest {
    @TestSetup
    static void setupData(){
        // tms_MockUpDataForTest.insertIntegrationCustomSetting();

        // tms_Company__c componany = tms_MockUpDataForTest.createCustomCompany('Some Company Full Name EN',
        //                                                                         'Some Company Full Name',
        //                                                                         'code',
        //                                                                         'abbr');
        // insert componany;

        // tms_CompanyBranch__c companyBranch = tms_MockUpDataForTest.createDefaultCompanyBranch(componany,null,null,null,null);
        // insert companyBranch;

        // tms_Building__c building = tms_MockUpDataForTest.createBuilding(componany,
        //                                                                     companyBranch,
        //                                                                     'buildingName',
        //                                                                     'buildingNameTH',
        //                                                                     'abbr',
        //                                                                     'smCode',false);
        // insert building;

        Opportunity myOpp = new Opportunity(
            Name = 'My Opp',
            CloseDate = DATE.TODAY() + 2,
            StageName = 'Quotation Sent'
        );
        insert myOpp;

        Contract__c cont = new Contract__c(
            Name = 'my Cont'
        );
        insert cont;
        
        Branch__c branch = new Branch__c(
        	Name = 'Branch',
            Branch_Code__c = 'b001'
        );
        insert branch;

        Building__c building = new Building__c(
            Name = 'buildingName',
            Building_Name_TH__c = 'Building Name TH',
            Building_Abbreviated__c = 'Abbr',
            Active__c = false,
            Branch__c = branch.Id
        );
        insert building;

        // Floor__c myFloor = tMockUpDataForTest.createBuildingFloor(building, 'Fl0', 'Fl000', 'Test Floor Name');
        // insert buildingFloor;

        Floor__c myFloor = new Floor__c(
            Building__c = building.Id,
            Name = 'Test Floor Name',
            Floor_Code__c = 'F1000',
            Floor_Short_Name__c = 'F10'
        );
        insert myFloor;

//         tms_RentalObject__c rentalObject = tms_MockUpDataForTest.createRentalObject(building, buildingFloor, '10');
//         insert rentalObject;

        Units__c units = new Units__c(
            Building__c = building.Id,
            Floor__c = myFloor.Id,
            Usage_Type__c = 'Office Rental',
            CurrentContract__c = cont.Id
        ); 
        insert units;

        Units__c units2 = new Units__c(
            Building__c = building.Id,
            Floor__c = myFloor.Id,
            Usage_Type__c = 'Office Rental'
        ); 
        insert units2;

        OpportunityLineItem__c oppLine = new OpportunityLineItem__c(
            Unit__c = units.Id,
            Opportunity__c = myOpp.Id
        );
        insert oppLine;        

//         tms_Measurement__c measurement = tms_MockUpDataForTest.createDefaultMeasurement();
//         insert measurement;

        Measurement__c measurement = new Measurement__c();
        insert measurement;

    }

    // private static Map<String, SObject> InitialAllObject() {
    //     Map<String, Sobject> resultValue = new Map<String, Sobject>();
    //     List<Contract__c> contractList = MockUpDataForTest.getContractList(1);
    //     insert(contractList);
    //     resultValue.put('targetContact', contractList.get(0));
    //     return resultValue;
    // }

    @isTest static void test_searchProject() {
        String searchTerm = 'buildingName';
        List<String> selectedIds = new List<String>();
        List<LookupSearchResult> lookupSearchResultList = new List<LookupSearchResult>();
        Test.startTest();
            lookupSearchResultList = MasterPlanController.searchProject(searchTerm, selectedIds);
        Test.stopTest();
        System.assertEquals(false, lookupSearchResultList.isEmpty());
    }


    @isTest static void test_getFloorList() {
        Building__c targetBuilding = [SELECT Id, Name FROM Building__c WHERE Name = 'buildingName' LIMIT 1];
        System.debug(targetBuilding);
        List<Object> targetResultList;
        Test.startTest();
            targetResultList = MasterPlanController.getFloorList(targetBuilding.Id);
        Test.stopTest();
        System.debug(targetResultList);
        System.assertNotEquals(null, targetResultList);
    }

    @isTest static void test_saveUnitList() {
        Units__c targetRentalObj = [SELECT Id, Name FROM Units__c LIMIT 1];
        String jsonObject = '[{"unitType":"10","unitNumber":"Test Frequency 01","unitKey":"Test Frequency 01","UNIT_STATUS_MAPPING":{},"status":"Available for Sales","numberOfOpportunities":0,"id":"'+targetRentalObj.Id+'","floor":"Fl. 1","pointerSize":30}]';
        Boolean targetResultBoolean = true;
        Boolean resultBoolean = true;
        Test.startTest();
            resultBoolean = MasterPlanController.saveUnitList(jsonObject);
        Test.stopTest();
        System.assertEquals(targetResultBoolean, resultBoolean);
    }

    @isTest static void test_getStatusColorMapping() {
        Map<String, String> resutlMapping = new Map<String, String>();
        List<Object> unitObjList = new List<Object>();
        Test.startTest();
            resutlMapping = MasterPlanController.getStatusColorMapping(unitObjList);
        Test.stopTest();
        System.assertNotEquals(null, resutlMapping);
    }
    
    @isTest static void test_getRentalObjectDetailByRentalObjId() {
        Units__c u = [SELECT Id FROM Units__c limit 1];
        Test.startTest();
            Units__c myunit = MasterPlanController.getRentalObjectDetailByRentalObjId(u.Id);
        Test.stopTest();
    }
    
    @isTest static void test_getContactByRentalObjId() {
        Units__c u = [SELECT Id FROM Units__c limit 1];
        Test.startTest();
            List<ContractLineItem__c> conItems = MasterPlanController.getContactByRentalObjId(u.Id);
        Test.stopTest();
    }
}