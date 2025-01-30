({
    addOtherExpense : function(component, event, helper) {
        var optionValue = component.get("v.optionValue");
        if (optionValue) {
            component.set("v.optionToparent", optionValue);
            component.find("addOtherExpenseOverLey").notifyClose();
        }
    },

    changeOption : function(component, event, helper) {
        component.set("v.disabledButtom", false);
    },

    cancelAddOtherExpense : function(component, event, helper) {
        component.set("v.optionToparent", null);
        component.find("addOtherExpenseOverLey").notifyClose();
    }

})