global abstract class Abstract_RestResponseModel {
    @AuraEnabled
    global Boolean isSuccess;
    @AuraEnabled
    global String message;
    @AuraEnabled
    global final Datetime SystemDate = Datetime.now();
    @AuraEnabled
    global final Datetime timeStamp {
        get;
        set {
            timeStamp = Datetime.valueOf(value);
        }
    } 
}