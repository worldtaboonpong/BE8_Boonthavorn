public class PickListDescriber {
    private static Map<Schema.sObjectType /*SObject*/, Map<String /*field_name*/, Schema.SObjectField>> mapPicklistValues { get; Set; }

    public static void buildMapOfPicklistValues(Schema.sObjectType objectType) {
        Schema.DescribeSObjectResult sobject_describe = objectType.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        mapPicklistValues.put(objectType, field_map);
    }
    // Get All By Sobject
    public static Map<String, Schema.SObjectField> getPicklistEntry(Schema.sObjectType objectType) {
        if (null == mapPicklistValues) {
            //LoggerManager.FrameworkLog('BE8 Framework :=> Create mapPicklistValues');
            mapPicklistValues = new Map<Schema.sObjectType /*SObject*/, Map<String /*field_name*/, Schema.SObjectField>> ();
        }
        if (!mapPicklistValues.containsKey(objectType)) {
            //LoggerManager.FrameworkLog('BE8 Framework :=> Create Map For ' + objectType.getDescribe().getName());
            buildMapOfPicklistValues(objectType);
        }

        return mapPicklistValues.get(objectType);

    }

    public static List<Schema.PicklistEntry> getPicklistEntry(Schema.sObjectType objectType, string fieldName) {
        if (null == mapPicklistValues) {
            //LoggerManager.FrameworkLog('BE8 Framework :=> Create mapPicklistValues');
            mapPicklistValues = new Map<Schema.sObjectType /*SObject*/, Map<String /*field_name*/, Schema.SObjectField>> ();
        }
        if (!mapPicklistValues.containsKey(objectType)) {
            //LoggerManager.FrameworkLog('BE8 Framework :=> Create Map For ' + objectType.getDescribe().getName());
            buildMapOfPicklistValues(objectType);
        }

        return mapPicklistValues.get(objectType).get(fieldName).getDescribe().getPickListValues();

    }

}