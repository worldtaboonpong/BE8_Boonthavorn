public class SObjectUtils {
    public static String getMockUpSObjectId(String sObjectAPI, String suffix){
        String keyPrefix = Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().getKeyPrefix();
        String suffix_15digits = suffix.leftPad(15, '0');
        return keyPrefix+suffix_15digits;
    }

    public static string getSobjectPrefix(Schema.SObjectType sobjectType) {
        Schema.DescribeSObjectResult r = sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }
    public static Id generate(Schema.SObjectType sobjectType) {
        return IDGenerator.generate(sobjectType);
    }
    public static List<System.selectOption> getPickValues(Schema.sObjectType sobject_type, String field_name, Map<string, string> exceptionValue) {
        // New Option to Caller
        List<System.selectOption> options = new List<System.selectOption> (); //new list for holding all of the picklist options        
        List<Schema.PicklistEntry> pick_list_values = PickListDescriber.getPicklistEntry(sobject_type, field_name);
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            if (!exceptionValue.containsKey(a.getValue())) {
                options.add(new System.selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
            }
        }
        return options; //return the List
    }

    public static List<System.selectOption> getPickValues(Schema.sObjectType sobject_type, String field_name, String first_val) {
        // New Option to Caller
        List<System.selectOption> options = new List<System.selectOption> (); //new list for holding all of the picklist options
        if (first_val != null && first_val != '') { //if there is a first value being provided
            options.add(new System.selectOption(first_val, first_val)); //add the first option
        }
        List<Schema.PicklistEntry> pick_list_values = PickListDescriber.getPicklistEntry(sobject_type, field_name);
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            options.add(new System.selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list
        }
        return options; //return the List
    }
    public static List<SObjectUtils.SelectOption> getPickValues(String sObjectType,String fieldAPI){
        List<Schema.PicklistEntry> picklistVal = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap().get(fieldAPI).getDescribe().getPicklistValues();
        List<SObjectUtils.SelectOption> options = new List<SObjectUtils.SelectOption>();
        for(Schema.PicklistEntry picklistObj :picklistVal){
            options.add( new SObjectUtils.SelectOption(picklistObj.getValue(), picklistObj.getLabel() ) );
        }
        return options;
    }
    public static String getValue(SObject record, String field){
        String recordFieldValue = '';
        SObject rec = record;
        List<String> listRelationField = getListRelationField(field);
        for(Integer i=0;i<listRelationField.size();i++){
            if(rec!=null){
                Boolean isLastTime = i == listRelationField.size()-1;
                if(!isLastTime){
                    rec = (SObject)rec.getSObject(listRelationField.get(i) );
                }else{
                    recordFieldValue = String.valueOf(rec.get(listRelationField.get(i)) );
                }
            }
        }
        return recordFieldValue;
    }
    public static List<String> getListRelationField(String field){
        List<String> listRelationField = field.split('\\.');
        return listRelationField;
    }
    public static SObject instantOf(String sObjectType) {
        System.debug('SW Debug :get instant of :'+sObjectType);
        return  Schema.getGlobalDescribe().get(sObjectType).newSObject();
    }

    public static String getSObjectPrefixId(String sObjectAPI){
        if(isValidSObjectType(sObjectAPI)){
            return Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().getKeyPrefix();
        }
        return MessageLabel.SOBJECTUTIL_NOTFOUNDOBJECT+sObjectAPI;
    }
    public static List<String> getAllFieldInObject(String sObjectAPI){
        List<String> listOfFieldSetApiNames = new List<String>();
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectAPI);
        if( sObjType != NULL ) {
            Map<String, Schema.SObjectField> fieldSetNameToItsRecord = sObjType.getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> accessableField = new Map<String, Schema.SObjectField>();
            for(String fieldName:fieldSetNameToItsRecord.keySet()){
                //if(fieldSetNameToItsRecord.get(fieldName).getDescribe().isPermissionable()){
                    accessableField.put(fieldName,fieldSetNameToItsRecord.get(fieldName));
                //}
            }
            listOfFieldSetApiNames.addAll( accessableField.keySet() );
        }
        return listOfFieldSetApiNames;
    }
    public static String getQueryAllField(String sObjectAPI){
        List<String> allFields = SObjectUtils.getAllFieldInObject(sObjectAPI);
        String soql = 'Select ';
        if(!allFields.isEmpty()){
            soql += String.join(allFields, ', ')+' From '+sObjectAPI;
        }
        return soql;
    }

    public static Schema.DescribeFieldResult getSchemaFieldDescribe(String sObjectAPI, String fieldName){
        return getSchemaField(sObjectAPI,fieldName).getDescribe();
    }
    public static Schema.SObjectField getSchemaField(String sObjectAPI, String fieldName){
        if(isValidSObjectType(sObjectAPI)&&isValidSObjectField(sObjectAPI,fieldName)){
            return Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().fields.getMap().get(fieldName);
        }
        return null;
    }


    public static Map<String, Schema.FieldSet> getMapFieldSetsBySObjectAPI(String sObjectAPI){
        return Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().fieldSets.getMap();
    }

    public static Set<String> getAllFieldInFieldSet(Schema.FieldSet fieldSet){
        List<Schema.FieldSetMember> fieldMember = fieldSet.getFields();
        Set<String> fieldAPIs = new Set<String>();
        for(Schema.FieldSetMember eachMember :fieldMember){
            fieldAPIs.add(eachMember.getFieldPath());
        }
        return fieldAPIs;
    }



    /**
     * [Private Zone ] 
     * 
     **/
    private static Boolean isValidSObjectType(String sObjectAPI){
        if(Schema.getGlobalDescribe().containsKey(sObjectAPI)){
            return true;
        } 
        throw new SObjectUtilException(MessageLabel.SOBJECTUTIL_NOTFOUNDOBJECT+sObjectAPI);
    }
    private static Boolean isValidSObjectField(String sObjectAPI, String fieldName){
        if(Schema.getGlobalDescribe().get(sObjectAPI).getDescribe().fields.getMap().containsKey(fieldName)){
            return true;
        } 
        throw new SObjectUtilException(MessageLabel.SOBJECTUTIL_NOTFOUNDFIELD+fieldName+' : on object : '+sObjectAPI);
    }
    public class SelectOption{
        public String value;
        public String label;
        public SelectOption(String val, String lab){
            this.value = val;
            this.label = lab;
        }
    }
    public class SObjectUtilException extends Exception {}
}