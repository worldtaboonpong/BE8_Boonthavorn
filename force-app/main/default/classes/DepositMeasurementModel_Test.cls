@isTest
public  class DepositMeasurementModel_Test {
    @isTest
    public static void test_parse() {
        Test.startTest();
        List<DepositMeasurementModel.Data> res = DepositMeasurementModel.parse('[{}]');
        Test.stopTest();
    }

    @isTest
    public static void test_toString() {
        List<DepositMeasurementModel.Data> data = new List<DepositMeasurementModel.Data>();
        Test.startTest();
        DepositMeasurementModel.Data temp = new DepositMeasurementModel.Data();
        temp.Id = temp.Name = temp.OpportunityId = temp.Measurement = temp.SubType = 'x';
        temp.Price = 1;
        data.add(temp);
        String res = DepositMeasurementModel.toString(data);
        Test.stopTest();
    }
}