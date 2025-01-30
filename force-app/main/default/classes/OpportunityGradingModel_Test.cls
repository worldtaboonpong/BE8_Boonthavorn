@isTest
public with sharing class OpportunityGradingModel_Test {
    @isTest
    public static void test_parse() {
        Test.startTest();
        List<OpportunityGradingModel.Data> res = OpportunityGradingModel.parse('[{}]');
        Test.stopTest();
    }

    @isTest
    public static void test_toString() {
        List<OpportunityGradingModel.Data> data = new List<OpportunityGradingModel.Data>();
        Test.startTest();
        OpportunityGradingModel.Data temp = new OpportunityGradingModel.Data();
        temp.Id = temp.Name = temp.OpportunityId = temp.OpportunityPeriodId = temp.GPRangeNo = temp.SalesDescription = temp.ReportingRule = temp.GradingTierOption = 'x';
        temp.GradingPeriodTo = temp.GradingPeriodForm = System.today();
        temp.GroupNo = 1;
        temp.FromR = temp.ToR = temp.GP = 0;
        temp.IsIncludeCAM = temp.IsGrading = true;
        data.add(temp);
        String res = OpportunityGradingModel.toString(data);
        Test.stopTest();
    }
}