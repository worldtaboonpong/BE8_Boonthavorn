({
    init : function(component, event, helper) {
  		helper.isSetReadOnly(component,event);
    	helper.initEscalationType(component,event);
  		console.log("init Rent service");
    },
    onChangePricing: function(component, event, helper){
        component.set("v.isChangePricing",true);
    },

    oncChangeRentServiceTypeGroup: function(component, event, helper) {
    	component.set("v.isChangePricing",true);
	 	var rentServicePricing = component.get("v.rentServicePricing");
	 	var new_rentServicePricing = Object.assign({}, rentServicePricing);
		var selected = event.getSource().getLocalId();
		var oppDetail = component.get("v.oppObject");

		var isInitialPageWithRentService = component.get("v.isInitialPageWithRentService");
		var isInitialPageWithPeriod = component.get("v.isInitialPageWithPeriod");

		new_rentServicePricing.RentCondition = selected;

		// 	Select Advance  
		if (selected === "Advance"){

			component.set("v.isSelectRenServiceAdvance", true);
			debugger;
			if (isInitialPageWithRentService && isInitialPageWithPeriod && oppDetail.rentServiceEscalationType == 'Advance') {
				var compEvent = component.getEvent("RegenerateRentServiceEvent");
		        compEvent.setParams({
		            "isSelectRenServiceAdvance" : true,
		            "isSelectRenServiceEscalation" : false
		        });
		        compEvent.fire();
			}else{
				new_rentServicePricing.RentServiceEscalationRate.IsDisabled = true;
				new_rentServicePricing.RentServiceMeasurment = new_rentServicePricing.RentServiceMeasurment.map(function(rentedMeasurment){

					if (!rentedMeasurment.isFOC) {
						rentedMeasurment.Price.IsDisabled = true;
						rentedMeasurment.Price.value = 0;
					} 	

			    	return rentedMeasurment;
			    });
				component.set("v.rentServicePricing", new_rentServicePricing);
			}
		}else{

			// Select Escalate
			var compEvent = component.getEvent("RegenerateRentServiceEvent");
	        compEvent.setParams({
	            "isSelectRenServiceAdvance" : false,
	            "isSelectRenServiceEscalation" : true
	        });
	        compEvent.fire();
			component.set("v.isSelectRentServiceEscalation", true);
		}

		console.log(selected);
		component.set("v.rentServiceType", selected);
	 },

	 onChangeMeasurementPrice: function(component, event, helper){
	 	debugger;
	 	console.log("Trigger Event");
	 	component.set("v.isChangePricing",true);
	 	var rentServicePricing = component.get("v.rentServicePricing");

	 	var appEvent = $A.get("e.c:RentServiceFixMeasurementCustomeEvent");
        appEvent.setParams({"rentServicePricingMessage" : rentServicePricing });
        appEvent.fire();
	 },

})