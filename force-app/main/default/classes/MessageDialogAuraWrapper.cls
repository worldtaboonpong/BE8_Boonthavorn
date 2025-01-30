public with sharing class MessageDialogAuraWrapper {
    @AuraEnabled public String message;
    @AuraEnabled public Boolean isError;
    @AuraEnabled public Boolean isMissingRequireField;
    @AuraEnabled public Id recordId;
    @AuraEnabled public SObject recordObj;
    public MessageDialogAuraWrapper(String message, Boolean isError, Boolean isMissingRequireField) {
        this.message = message;
        this.isError = isError;
        this.isMissingRequireField = isMissingRequireField;
    }
    public MessageDialogAuraWrapper(String message, Boolean isError, Boolean isMissingRequireField, Id recordId) {
        this.message = message;
        this.isError = isError;
        this.isMissingRequireField = isMissingRequireField;
        this.recordId = recordId;
    }
    public MessageDialogAuraWrapper(String message, Boolean isError, Boolean isMissingRequireField, SObject recordObj) {
        this.message = message;
        this.isError = isError;
        this.isMissingRequireField = isMissingRequireField;
        this.recordId = recordObj.Id;
        this.recordObj = recordObj;
    }
}