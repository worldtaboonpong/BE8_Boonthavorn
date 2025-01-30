({
    
    addINstallment : function(component, event, helper) {
        helper.addInstallmentHelper(component, event);
        component.set("v.isChangeDeposit",true);
    },
    changeTotalPriceHandler : function(component, event, helper){
        helper.calculateInstallmentHelper(component, event);
        component.set("v.isChangeDeposit",true);
    },
    handleChangeOtherDepositObject : function(component, event, helper){
        var eachOtherDeposit = component.get("v.eachOtherDeposit");
        var newEachPeriod = Object.assign({}, eachOtherDeposit);

        if (!newEachPeriod.TotalAmount) {
            newEachPeriod.TotalAmount = 0;
            component.set("v.eachOtherDeposit.TotalAmount",newEachPeriod.TotalAmount);
        }

        helper.handleChangeOtherDepositObject(component, event);
        component.set("v.isChangeDeposit",true);
    },
    onChangeDeposit : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
    },
})