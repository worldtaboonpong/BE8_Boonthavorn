global class ContractDepositMeasurementModel {
    public static List<ContractDepositMeasurementModel.Data> parse(String json) {
        return (List<ContractDepositMeasurementModel.Data>)System.JSON.deserialize(json, List<ContractDepositMeasurementModel.Data>.class);
    }

    public static String toString(List<ContractDepositMeasurementModel.Data> data) {
        return System.JSON.serialize(data);
    }

    global class Data {
        public String Id {get; set;}
        public String Name {get; set;}
        public String ContractId {get; set;}
        public String Measurement {get; set;}
        public String SubType {get; set;}
        public Decimal Price {get; set;}
    }
}