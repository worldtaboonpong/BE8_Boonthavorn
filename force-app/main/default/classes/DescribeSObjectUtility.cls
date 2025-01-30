public without sharing class DescribeSObjectUtility {
    private static DescribeSObjectUtility instance;
    
    Map<String, Schema.DescribeSObjectResult> describeSObjectMap = new Map<String, Schema.DescribeSObjectResult>();

    public static Schema.DescribeSObjectResult getStaticDescribe(String sObjectType) {
        return getInstance().getDescribe(sObjectType);
    }

    public Schema.DescribeSObjectResult getDescribe(String sObjectType) {
        if(describeSObjectMap.containsKey(sObjectType)) {
            return describeSObjectMap.get(sObjectType);
        }
        Schema.DescribeSObjectResult thisDescribe = Schema.getGlobalDescribe().get(sObjectType).getDescribe();

        describeSObjectMap.put(sObjectType, thisDescribe);
        return thisDescribe;
    }

    public static DescribeSObjectUtility getInstance() {
        if(instance == null) {
            instance = new DescribeSObjectUtility();
        }
        return instance;
    }
}