@isTest
public class ContractLeaseholdFloorModel_Test {
    @isTest
    public static void test_parse() {
        Test.startTest();
        List<ContractLeaseholdFloorModel.Data> res = ContractLeaseholdFloorModel.parse('[{}]');
        Test.stopTest();
    }

    @isTest
    public static void test_toString() {
        List<ContractLeaseholdFloorModel.Data> data = new List<ContractLeaseholdFloorModel.Data>();
        Test.startTest();
        ContractLeaseholdFloorModel.Data temp = new ContractLeaseholdFloorModel.Data();
        temp.Id = temp.Name = temp.Floor = temp.ContractDepositExpense = temp.Measurement = temp.BuildingFloor = temp.Contract = 'x';
        temp.TotalPrice = temp.PricePerSqm = temp.Area = 0;
        data.add(temp);
        String res = ContractLeaseholdFloorModel.toString(data);
        Test.stopTest();
    }
}