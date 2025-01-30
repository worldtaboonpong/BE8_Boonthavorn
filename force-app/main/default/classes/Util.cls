public without sharing class Util {

    public static String toGMT7TextUserUpdate(DateTime dt) {
        String dateTimeString = dt.format('yyyy-MM-dd HH:mm:ss+07:00', 'GMT+7');
        dateTimeString = dateTimeString.replaceAll('\\s+', 'T');
        return dateTimeString;
    }

    public static String getErrorMessage(Exception e){
        return e.getTypeName()+', '+e.getMessage()+', '+e.getStackTraceString();
    }

    public static String getDatabaseErrorMessage(Database.Error e){
        return e.getStatusCode()+', '+e.getMessage()+', '+e.getFields();
    }

    public static String getResponseResultItemErrorMessage(Database.UpsertResult res){
        return getResponseResultItemErrorMessage(res.getErrors());
    }

    public static String getResponseResultItemErrorMessage(Database.DeleteResult res){
        return getResponseResultItemErrorMessage(res.getErrors());
    }

    public static String getResponseResultItemErrorMessage(Database.SaveResult res){
        return getResponseResultItemErrorMessage(res.getErrors());
    }

    public static String getResponseResultItemErrorMessage(List<Database.Error> errorList){
        List<String> errorStringList = new List<String>();
        for (Database.Error eachErr:errorList){
            errorStringList.add(Util.getDatabaseErrorMessage(eachErr));
        }
        String errorMessages = String.join(errorStringList,'; ');
        return errorMessages;
    }

    public static ID getStdPricebookId(){
        if (Test.isRunningTest())   return Test.getStandardPricebookId();
        return getStdPricebook().id;
    }

    public static Pricebook2 getStdPriceBook() {
        Pricebook2 stdPriceBook = [select id, name from Pricebook2 where isStandard = true limit 1];
        return stdPriceBook;    
    }
    // public static String generateUniqueKey(){
    //     Blob keyBlob = Crypto.generateAesKey(128);
    //     String keyString = EncodingUtil.base64Encode(keyBlob);
    //     System.debug('keyString: '+keyString);
    //     return keyString;
    // }

    @future
    public static void updateLeadsType(String leadIds, Id recordTypeId)
    {
        List<String> listLeadIds = leadIds.split(',');
        List<Lead> toUpdateLead = new List<Lead>();
        for(String leadId : listLeadIds) {
            Lead temp = new Lead(Id = leadId, RecordTypeId = recordTypeId);
            toUpdateLead.add(temp);
        }
        update toUpdateLead;
    }
    
    public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){

                //if (!sObj.contains('__')) to exclude managed package objects

                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }

}