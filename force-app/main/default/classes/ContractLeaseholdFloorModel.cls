global class ContractLeaseholdFloorModel {

    public static List<ContractLeaseholdFloorModel.Data> parse(String json) {
        return (List<ContractLeaseholdFloorModel.Data>)System.JSON.deserialize(json, List<ContractLeaseholdFloorModel.Data>.class);
    }

    public static String toString(List<ContractLeaseholdFloorModel.Data> data) {
        return System.JSON.serialize(data);
    }

    global class Data {
        public String Id {get; set;}
        public String Name {get; set;}
        public String Floor {get; set;}
        public Decimal TotalPrice {get; set;}
        public String ContractDepositExpense {get; set;}
        public Decimal PricePerSqm {get; set;}
        public Decimal Area {get; set;}
        public String Measurement {get; set;}
        public String BuildingFloor {get; set;}
        public String Contract {get; set;}
    }
}