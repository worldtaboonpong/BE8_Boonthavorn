global class DepositMeasurementModel {
    public static List<DepositMeasurementModel.Data> parse(String json) {
        return (List<DepositMeasurementModel.Data>)System.JSON.deserialize(json, List<DepositMeasurementModel.Data>.class);
    }

    public static String toString(List<DepositMeasurementModel.Data> data) {
        return System.JSON.serialize(data);
    }

    global class Data {
        public String Id {get; set;}
        public String Name {get; set;}
        public String OpportunityId {get; set;}
        public String Measurement {get; set;}
        public String SubType {get; set;}
        public Decimal Price {get; set;}
    }
}