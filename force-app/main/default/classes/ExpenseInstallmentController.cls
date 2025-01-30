public class ExpenseInstallmentController {

    public Id contractId {get;set;}
    public Map<String, List<InstallmentWrapper>> getExpenseInstallments(){
        List<ContractPrice__c> conPriceList =  [SELECT id, Installment__c, DepositExpenseType__c, SubType__c, TotalPrice__c, PaymentDueDate__c, Remark__c
                                                FROM ContractPrice__c 
                                                WHERE Contract__c =: contractId AND TypeGroup__c = 'Expense' AND SubType__c = 'Installment' ORDER BY DepositExpenseType__c ASC];
        Map<String, List<InstallmentWrapper>> output = new Map<String, List<InstallmentWrapper>>();
        for(ContractPrice__c conPrice : conPriceList) {
            InstallmentWrapper install = new InstallmentWrapper();
            install.ExpenseName = conPrice.DepositExpenseType__c;
            install.InstallmentNumber = String.valueof(conPrice.Installment__c);
            install.InstallmentAmount = conPrice.TotalPrice__c;
            install.PaymentDueDate = conPrice.PaymentDueDate__c;
            install.remark = conPrice.Remark__c;
            
            if(output.containsKey(conPrice.DepositExpenseType__c)) {
                output.get(conPrice.DepositExpenseType__c).add(install);
            } else {
                output.put(conPrice.DepositExpenseType__c, new List<InstallmentWrapper>{install});
            }
            
        }
        return output;
    }

    public class InstallmentWrapper{
        public String ExpenseName {get;set;}
        public String InstallmentNumber {get;set;}
        public Decimal InstallmentAmount  {get;set;}
        public Date PaymentDueDate  {get;set;}
        public String remark  {get;set;}
    }
}