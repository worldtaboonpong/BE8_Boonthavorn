global class ContractGradingModel {
    public static List<ContractGradingModel.Data> parse(String json) {
        return (List<ContractGradingModel.Data>)System.JSON.deserialize(json, List<ContractGradingModel.Data>.class);
    }

    public static String toString(List<ContractGradingModel.Data> data) {
        return System.JSON.serialize(data);
    }

    global class Data {
        public String Id {get; set;}
        public String Name {get; set;}
        public String ContractId {get; set;}
        public String ContractPeriodId {get; set;}
        public Date GradingPeriodTo {get; set;}
        public Date GradingPeriodForm {get; set;}
        public String GPRangeNo {get; set;}
        public Integer GroupNo {get; set;}
        public Decimal FromR {get; set;}
        public Decimal ToR {get; set;}
        public Decimal GP {get; set;}
        public Boolean IsIncludeCAM {get; set;}
        public Boolean IsGrading {get; set;}
        public String SalesDescription {get; set;}
        public String ReportingRule {get; set;}
        public String GradingTierOption {get; set;}
    }
}