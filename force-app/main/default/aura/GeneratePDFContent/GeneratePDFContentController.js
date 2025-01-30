({
	doInit : function(component, event, helper) {
		component.set("v.toggleSpinner", true);
		var opportunityRecord = component.get("v.recordId");;  
		var urlEvent = $A.get("e.force:navigateToURL");
		var action = component.get("c.GeneratePDFContent");
		action.setParams({
			recordId : opportunityRecord
		});

		action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            console.log('response : ', response);
            if (state === "SUCCESS") {
            	if(response == ''){
            		$A.get("e.force:closeQuickAction").fire();
					window.location.reload();
            	}
            	else{
            		var toastEventError = $A.get("e.force:showToast");
					toastEventError.setParams({
						"type": "error",
						"title": "Failed !",
						"message":response,
						"mode":"dismissible"
					});
					toastEventError.fire();
					$A.get("e.force:closeQuickAction").fire();
            	}
                
            } else if (state === "ERROR") {
                var toastEventError = $A.get("e.force:showToast");
				toastEventError.setParams({
					"type": "error",
					"title": "Failed !",
					"message":response,
					"mode":"dismissible"
				});
				toastEventError.fire();
            }
        });
		
		$A.enqueueAction(action);
		
	}
})