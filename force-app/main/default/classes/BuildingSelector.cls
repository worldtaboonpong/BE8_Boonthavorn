public class BuildingSelector {
    public static List<Building__c> getBuildingInfoById(Set<Id> buildingIdSet) {
        if (buildingIdSet == null || buildingIdSet.isEmpty()) { return null; }
        List<Building__c> buildingInfoList = new List<Building__c>();
        buildingInfoList = [SELECT Id, Name, Building_Abbreviated__c
                            FROM Building__c
                            WHERE Id IN: buildingIdSet];
        return buildingInfoList;
    }
}