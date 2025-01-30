({
    addPaeriod : function(component, event, helper) {
    	var optionValue = component.get("v.optionValue");
    	if (optionValue) {
    		component.set("v.optionToparent", optionValue);
    		component.find("addPeriodOverLey").notifyClose();
    	}
    },

    changeOption : function(component, event, helper) {
    	component.set("v.disabledButtom", false);
    },

    cancelAddPeriod : function(component, event, helper) {
    	component.set("v.optionToparent", null);
    	component.find("addPeriodOverLey").notifyClose();
    }

})