@isTest 
public class Util_Test {
    @isTest 
    static void Test_toGMT7TextUserUpdate(){
        Test.startTest();
        String data = Util.toGMT7TextUserUpdate(System.now()); 
        Test.stopTest();
    }
    
    @isTest
    public static void Test_getErrorMessage() {
        try {
            Lead myLead = new Lead();
          insert(myLead);
        } Catch(Exception ex) {
            Test.startTest();
            String data = Util.getErrorMessage(ex); 
            Test.stopTest();
        }
    }
    
    @isTest 
    static void Test_getDatabaseErrorMessage(){
        Lead myLead = new Lead();
        Database.SaveResult sr = Database.insert(myLead, false);
      if (!sr.isSuccess()) {
            Test.startTest();
            for(Database.Error err : sr.getErrors()) {
              String data = Util.getDatabaseErrorMessage(err); 
            }
            Test.stopTest();
        }
    }
    
    @isTest 
    static void Test_getResponseResultItemErrorMessage(){
        Lead myLead = new Lead();
        Database.UpsertResult sr = Database.upsert(myLead, false);
        Test.startTest();
        String data = Util.getResponseResultItemErrorMessage(sr); 
        Test.stopTest();
    }
    
    @isTest 
    static void Test_getResponseResultItemErrorMessageDelete(){
        Lead myLead = new Lead(LastName='Test',Company='Test',Email='test@gmail.com', Phone='0623134422', MobilePhone='0623134422');
        insert(myLead);
        Database.DeleteResult sr = Database.delete(myLead, false);
        Test.startTest();
        String data = Util.getResponseResultItemErrorMessage(sr); 
        Test.stopTest();
    }
    
    @isTest 
    static void Test_getResponseResultItemErrorMessageinsert(){
        Lead myLead = new Lead(LastName='Test',Company='Test');
        Database.SaveResult sr = Database.insert(myLead, false);
        Test.startTest();
        String data = Util.getResponseResultItemErrorMessage(sr); 
        Test.stopTest();
    }
    
    @isTest 
    static void Test_getStdPricebookId(){
        Test.startTest();
        ID output = Util.getStdPricebookId(); 
        Test.stopTest();
    }
    
    @isTest 
    static void Test_getStdPriceBook(){
    Pricebook2 stdPB = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        Update(stdPB);
            
        Test.startTest();
        Pricebook2 output = Util.getStdPriceBook(); 
        Test.stopTest();
    }
    
    @isTest 
    static void Test_updateLeadsType(){
        
        Lead myLead = new Lead(LastName='Test',Company='Test',Email='test@gmail.com', Phone='0623134422', MobilePhone='0623134422');
        insert(myLead);
        ID typeID = [Select Id From RecordType where sobjecttype = 'Lead' LIMIT 1].Id;
        
        Test.startTest();
        Util.updateLeadsType(myLead.Id, typeID); 
        Test.stopTest();
    }
    
    @isTest 
    static void Test_findObjectNameFromRecordIdPrefix(){
        
        Lead myLead = new Lead(LastName='Test',Company='Test',Email='test@gmail.com', Phone='0623134422', MobilePhone='0623134422');
        insert(myLead);
        
        Test.startTest();
        String data = Util.findObjectNameFromRecordIdPrefix(myLead.Id); 
        Test.stopTest();
    }
}