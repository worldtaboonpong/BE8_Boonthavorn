@isTest
public with sharing class ContractGradingModel_Test {
    @isTest
    public static void test_parse() {
        Test.startTest();
        List<ContractGradingModel.Data> res = ContractGradingModel.parse('[{}]');
        Test.stopTest();
    }

    @isTest
    public static void test_toString() {
        List<ContractGradingModel.Data> data = new List<ContractGradingModel.Data>();
        Test.startTest();
        ContractGradingModel.Data temp = new ContractGradingModel.Data();
        temp.Id = temp.Name = temp.ContractId = temp.ContractPeriodId = temp.GPRangeNo = temp.SalesDescription = temp.ReportingRule = temp.GradingTierOption = 'x';
        temp.GradingPeriodTo = temp.GradingPeriodForm = System.today();
        temp.GroupNo = 1;
        temp.FromR = temp.ToR = temp.GP = 0;
        temp.IsIncludeCAM = temp.IsGrading = true;
        data.add(temp);
        String res = ContractGradingModel.toString(data);
        Test.stopTest();
    }
}