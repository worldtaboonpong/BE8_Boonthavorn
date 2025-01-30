({
    onChangeExpense : function(component, event, helper){
        component.set("v.isChangeExpense",true);
    },
    addINstallment : function(component, event, helper) {
    	helper.addInstallmentHelper(component, event);
        component.set("v.isChangeExpense",true);
    },
    changeTotalPriceHandler : function(component, event, helper){
        helper.calculateInstallmentHelper(component, event);
        component.set("v.isChangeExpense",true);
    },
    handleChangeExenseObject : function(component, event, helper){
        var eachExpense = component.get("v.eachExpense");
        var newEachPeriod = Object.assign({}, eachExpense);

        if(!newEachPeriod.TotalAmount){
            newEachPeriod.TotalAmount = 0;
            component.set("v.eachExpense.TotalAmount",newEachPeriod.TotalAmount)
        }

        helper.handleChangeExenseObject(component, event);
        component.set("v.isChangeExpense",true);
    },
    handleChangeExpenseType : function(component, event, helper){
        var eachExpense = component.get("v.eachExpense");
        var newEachPeriod = Object.assign({}, eachExpense);

        helper.handleChangeExpenseType(component, event);
        component.set("v.isChangeExpense",true);
    },
    changeLeaseHoldPrice : function(component, event, helper){
        component.set("v.isChangeExpense",true);

        helper.changeLeaseHoldPriceHelper(component, event);
    },
    onBlurLeaseHoldPrice : function(component, event, helper){
        helper.onBlurLeaseHoldPriceHelper(component, event);
    }
    // removeInstallment : function(component, event, helper){
    // 	helper.removeInstallmentHelper(component, event);
    // },
    // changeInstallmentHandler : function(component, event, helper){
    // 	helper.changeInstallmentHelper(component, event);
    // }
})