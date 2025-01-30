global class OpportunityLeaseholdFloorModel {

    public static List<OpportunityLeaseholdFloorModel.Data> parse(String json) {
        return (List<OpportunityLeaseholdFloorModel.Data>)System.JSON.deserialize(json, List<OpportunityLeaseholdFloorModel.Data>.class);
    }

    public static String toString(List<OpportunityLeaseholdFloorModel.Data> data) {
        return System.JSON.serialize(data);
    }

    public static List<OpportunityLeaseholdFloorModel.Data> getData(String oppId) {
        String dataJson = [SELECT OpportunityLeaseholdFloor__c FROM Opportunity WHERE Id =: oppId].OpportunityLeaseholdFloor__c;
        if(dataJson != null) return parse(dataJson);
        else return new List<OpportunityLeaseholdFloorModel.Data>();
    }

    global class Data {
        public String Id {get; set;}
        public String Name {get; set;}
        public String Floor {get; set;}
        public Decimal TotalPrice {get; set;}
        public String OpportunityDepositExpense {get; set;}
        public Decimal PricePerSqm {get; set;}
        public Decimal Area {get; set;}
        public String Measurement {get; set;}
        public String BuildingFloor {get; set;}
        public String Opportunity {get; set;}
    }
}