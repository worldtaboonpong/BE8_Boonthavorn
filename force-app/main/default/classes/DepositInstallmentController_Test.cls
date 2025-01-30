@isTest
public class DepositInstallmentController_Test {
    @isTest
    public static void test_getDepositInstallment() {
        Contract__c con = new Contract__c(Name = 'Test');
        insert(con);

        ContractDepositExpense__c conEx = new ContractDepositExpense__c();
        conEx.TypeGroup__c = 'Deposit';
        conEx.Type__c = 'Security Deposit';
        insert(conEx);

        List<ContractPrice__c> conPrice = new List<ContractPrice__c>();
        ContractPrice__c conP = new ContractPrice__c();
        conP.Contract__c = con.Id;
        conP.ContractDepositExpense__c = conEx.Id;
        conP.Installment__c = conP.Price__c = conP.InstallmentPriceWithVAT__c = 1;
        conPrice.add(conP);

        ContractPrice__c conP2 = new ContractPrice__c();
        conP2.Contract__c = con.Id;
        conP2.ContractDepositExpense__c = conEx.Id;
        conP2.Installment__c = conP2.Price__c = conP2.InstallmentPriceWithVAT__c = 1;
        conPrice.add(conP2);

        insert(conPrice);

        DepositInstallmentController controller = new DepositInstallmentController();
        controller.contractId = con.Id;
        Test.startTest();
        List<DepositInstallmentController.InstallmentWrapper> res = controller.getDepositInstallments();
        Test.stopTest();
    }
}