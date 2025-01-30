({
    doInit : function(component, event, helper) {
    	component.set("v.toggleSpinner", true);
    	var quoatRecord = component.get("v.recordId");;  
    	var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	        "url":"/apex/PDFMakeContract?oppId="+quoatRecord+"&renderredDraft=T"
	    });
	    urlEvent.fire();
	    component.set("v.toggleSpinner", false);
               

    }
})