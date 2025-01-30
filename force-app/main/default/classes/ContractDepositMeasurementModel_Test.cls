@isTest
public with sharing class ContractDepositMeasurementModel_Test {
    @isTest
    public static void test_parse() {
        Test.startTest();
        List<ContractDepositMeasurementModel.Data> res = ContractDepositMeasurementModel.parse('[{}]');
        Test.stopTest();
    }

    @isTest
    public static void test_toString() {
        List<ContractDepositMeasurementModel.Data> data = new List<ContractDepositMeasurementModel.Data>();
        Test.startTest();
        ContractDepositMeasurementModel.Data temp = new ContractDepositMeasurementModel.Data();
        temp.Id = temp.Name = temp.ContractId = temp.Measurement = temp.SubType = 'xx';
        temp.price = 0;
        data.add(temp);
        String res = ContractDepositMeasurementModel.toString(data);
        Test.stopTest();
    }
}