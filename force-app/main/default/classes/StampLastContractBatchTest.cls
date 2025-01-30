@isTest
private class StampLastContractBatchTest {
    @TestSetup
    static void mockData(){

    }

    @isTest
    static void expiredTest() {

        Contract__c newCont = new Contract__c(
            Name = 'Cont1',
            Termination_Date__c = Date.TODAY() - 1,
            Status__c = 'Terminated',
            Contract_Start_Date__c = Date.TODAY()
        );
        insert newCont;

        ContractLineItem__c contLine1 = new ContractLineItem__c(
            Contract__c = newCont.Id,
            TotalArea__c = 50.00,
            LeasableArea__c = 35.00
        );
        insert contLine1;

         // Create Unit
         Units__c unit1 = new Units__c(
            Name = 'DS1',
            TotalArea__c = 0.00,
            CurrentContract__c = newCont.Id
        );
        insert unit1;

        contLine1.Unit__c = unit1.Id;
        update contLine1;

        // StampLastContractBatch uca = new StampLastContractBatch();
        // Id batchId = Database.executeBatch(uca);

        Contract__c newCont2 = new Contract__c(
            Name = 'Cont2',
            Contract_End_Date__c = Date.TODAY() + 10,
            Status__c = 'Activated',
            Contract_Start_Date__c = Date.TODAY(),
            Actual_of_Billing_Rent_Service__c = Date.TODAY(),
            Actual_of_Billing_Insurance__c = Date.TODAY(),
            Actual_of_Decorate_the_Space__c = Date.TODAY(),
            Actual_of_Delivery_the_Area__c = Date.TODAY(),
            Actual_of_Design_Guideline__c  = Date.TODAY(),
            Actual_of_Signed_Contract__c  = Date.TODAY(),
            Actual_of_Shop_Open__c   = Date.TODAY()
        );
        insert newCont2;
        System.debug('con2: '+ newCont2.CreatedDate);

        Units__c queryUnit1 = [SELECT Name, TotalArea__c, CurrentContract__r.Name, LastContract__r.Name, Id FROM Units__c LIMIT 1];
        System.debug(queryUnit1);

        ContractLineItem__c contLine2 = new ContractLineItem__c(
            Contract__c = newCont2.Id,
            TotalArea__c = 50.00,
            LeasableArea__c = 35.00,
            Unit__c = queryUnit1.Id
        );
        insert contLine2;
        
        queryUnit1.CurrentContract__c = newCont2.Id;
        update queryUnit1;

        Test.setCreatedDate(newCont.Id, Date.TODAY()-10);
        Test.setCreatedDate(newCont2.Id, Date.TODAY());
        Test.startTest();
        
        UpdateCurrentContractBatch ucaa = new UpdateCurrentContractBatch();
        Id batchId3 = Database.executeBatch(ucaa);

        StampLastContractBatch uca2 = new StampLastContractBatch();
        Id batchId2 = Database.executeBatch(uca2);

        Test.stopTest();

        Units__c queryUnit2 = [SELECT Name, TotalArea__c, CurrentContract__r.Name, LastContract__r.Name, Id FROM Units__c LIMIT 1];
        System.debug(queryUnit2.CurrentContract__r.Name);
        System.debug(queryUnit2.LastContract__r.Name);

        System.assertEquals( 'Cont2',queryUnit2.CurrentContract__r.Name);
        System.assertEquals('Cont1', queryUnit2.LastContract__r.Name);
    }
}