public with sharing class RecordTypeUtility {
    public static Id getRecordTypeId(String sObjectType, String developerName) {
        Map<String, Schema.RecordTypeInfo> recordTypeMap = DescribeSObjectUtility.getStaticDescribe(sObjectType).getRecordTypeInfosByDeveloperName();
        if(!recordTypeMap.containsKey(developerName)) {
            throw new CustomException('RecordType not found :' + developerName);
        }
        return recordTypeMap.get(developerName).getRecordTypeId();
    }

    public static String getRecordTypeDeveloperName(String sObjectType, Id recordTypeId) {
        Map<Id, Schema.RecordTypeInfo> recordTypeMap = DescribeSObjectUtility.getStaticDescribe(sObjectType).getRecordTypeInfosById();
        if(!recordTypeMap.containsKey(recordTypeId)) {
            throw new CustomException('RecordType not found :' + recordTypeId);
        }
        return recordTypeMap.get(recordTypeId).getDeveloperName();
    }

    public static List<RecordType> getRecordTypeByDeveloperName(String sObjectType, List<String> recordTypeNameList) {
        if (recordTypeNameList == null || recordTypeNameList.isEmpty()) { return null; }
        List<RecordType> recordTypeList = new List<RecordType>();
        recordTypeList = [SELECT Id, DeveloperName
                        FROM RecordType
                        WHERE SobjectType =: sObjectType AND DeveloperName IN: recordTypeNameList];
        return recordTypeList;
    }

    public static List<RecordType> getRecordTypeByObject(String sObjectType) {
        if (sObjectType == null) { return null; }
        List<RecordType> recordTypeList = new List<RecordType>();
        recordTypeList = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType =: sObjectType];
        return recordTypeList;
    }
}