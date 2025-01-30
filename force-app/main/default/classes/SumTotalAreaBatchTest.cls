@isTest
private class SumTotalAreaBatchTest {
    @TestSetup
    static void mockData(){
        // Create Unit
        Units__c unit1 = new Units__c(
            Name = 'DS1',
            TotalArea__c = 0.00
        );
        insert unit1;

        Measurement__c mm1 = new Measurement__c(
            Unit_No__c = unit1.Id,
            Measurement_Area_Sqm__c = 20.00,
            Valid_From_Date__c = DATE.TODAY() - 2,
            Valid_To_Date__c = DATE.TODAY() + 2
        );
        insert mm1;

        Measurement__c mm2 = new Measurement__c(
            Unit_No__c = unit1.Id,
            Measurement_Area_Sqm__c = 30.00,
            Valid_From_Date__c = DATE.TODAY() - 2,
            Valid_To_Date__c = DATE.TODAY() + 2
        );
        insert mm2;

        Units__c unit2 = new Units__c(
            Name = 'DS1',
            TotalArea__c = 0.00,
            LeasableArea__c = 0.00
        );
        insert unit2;

        Measurement__c mm3 = new Measurement__c(
            Unit_No__c = unit2.Id,
            Measurement_Area_Sqm__c = 50.50,
            Valid_From_Date__c = DATE.TODAY() - 2,
            Valid_To_Date__c = DATE.TODAY() + 2
        );
        insert mm3;

        Measurement__c mm4 = new Measurement__c(
            Unit_No__c = unit2.Id,
            Measurement_Area_Sqm__c = 90.00,
            Valid_From_Date__c = DATE.TODAY() - 2,
            Valid_To_Date__c = DATE.TODAY() + 2
        );
        insert mm4;

        Measurement__c mm5 = new Measurement__c(
            Unit_No__c = unit2.Id,
            Measurement_Area_Sqm__c = 90.00,
            Valid_From_Date__c = DATE.TODAY() - 2,
            Valid_To_Date__c = DATE.TODAY() + 2,
            Type__c = 'Free of Charge'
        );
        insert mm5;

    }

    @isTest 
    static void addUnit_Test() {
        Test.startTest();
        SumTotalAreaBatch uca = new SumTotalAreaBatch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        List<Units__c> unitList = [SELECT Name, TotalArea__c, LeasableArea__c FROM Units__c ];
        System.assertEquals(unitList.size(), 2);
        System.debug(unitList);
        // System.assertEquals(unitList, 50.00);
    }
}