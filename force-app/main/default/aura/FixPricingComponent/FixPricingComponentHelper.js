({
    setCAMOrAirserviceHelper: function(component, event){
    	var camOrAirServiceType = component.get("v.oppDetail_CAMOrAirService");
    	var camPricing = component.get("v.camPricing");
    	var newCamPricing = Object.assign({}, camPricing);

    	if (camOrAirServiceType) {

	    	if (camOrAirServiceType === "CAM") {
	    		component.set("v.isSelectedCAMType", true);
                component.set("v.isSelectedAirServiceType", false);
                newCamPricing.CAMOrAirService = "CAM";
	    	}
	    	else if(camOrAirServiceType === "Air Service"){
	    		component.set("v.isSelectedAirServiceType", true);
                component.set("v.isSelectedCAMType", false);
                newCamPricing.CAMOrAirService = "Air Service";
	    	}
    	}else{
    		component.set("v.isSelectedCAMType", true);
            component.set("v.isSelectedAirServiceType", false);
            newCamPricing.CAMOrAirService = "CAM";
    	}

    	component.set("v.camPricing",newCamPricing);

    },

    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    }
})