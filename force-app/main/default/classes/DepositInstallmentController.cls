public class DepositInstallmentController {

    public Id contractId {get;set;}
    public List<InstallmentWrapper> getDepositInstallments(){
        List<ContractPrice__c> conPriceList =  [SELECT id, Installment__c, From__c, To__c, SubType__c, Price__c, InstallmentPriceWithVAT__c, TotalPrice__c, PaymentDueDate__c, PaymentType__c, Remark__c
                                                FROM ContractPrice__c 
                                                WHERE Contract__c =: contractId AND TypeGroup__c = 'Deposit' AND DepositExpenseType__c = 'Security Deposit' ORDER BY Installment__c ASC];
        Map<Decimal, InstallmentWrapper> output = new Map<Decimal, InstallmentWrapper>();
        for(ContractPrice__c conPrice : conPriceList) {
            InstallmentWrapper install ;
            if(output.containsKey(conPrice.Installment__c)) {
                install = output.get(conPrice.Installment__c);
                install.InstallmentAmount += conPrice.Price__c;
                install.InstallmentAmountWithVat += conPrice.InstallmentPriceWithVAT__c;
            } else {
                install = new InstallmentWrapper();
                install.InstallmentNumber = String.valueof(conPrice.Installment__c);
                install.InstallmentAmount = conPrice.Price__c;
                install.InstallmentAmountWithVat = conPrice.InstallmentPriceWithVAT__c;
                install.PaymentDueDate = conPrice.PaymentDueDate__c;
                install.PaymentMethod = conPrice.PaymentType__c;
                install.remark = conPrice.Remark__c;
            }
            install.InstallmentVAT = install.InstallmentAmountWithVat - install.InstallmentAmount;
            output.put(conPrice.Installment__c, install);
        }
        return output.values();
    }

    public class InstallmentWrapper{
        public String InstallmentNumber {get;set;}
        public Decimal InstallmentAmount  {get;set;}
        public Decimal InstallmentTopUpValue  {get;set;}
        public Decimal InstallmentAmountWithVat  {get;set;}
        public Decimal InstallmentVAT  {get;set;}
        public Date PaymentDueDate  {get;set;}
        public String PaymentMethod  {get;set;}
        public String remark  {get;set;}
    }
}