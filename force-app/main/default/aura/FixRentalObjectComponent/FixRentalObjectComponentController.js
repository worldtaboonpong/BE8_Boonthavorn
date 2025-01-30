({
    init : function(component, event, helper) {

        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        if (component.get("v.isReadOnly")) {

            newEachPeriod.FixedRentalObjectSection.rentalObjectList = newEachPeriod.FixedRentalObjectSection.rentalObjectList.map(function(rowData) {

                rowData.Price.IsDisabled = true;
                return rowData;
            });
            component.set("v.eachPeriod", newEachPeriod);
        }

        if (eachPeriod.OptionToRenew) {
            component.set("v.isDisableIncludeCAM",true);

        }else{
            component.set("v.isDisableIncludeCAM",false);            
        }
    },
    changeRentalObjectPriceSQM : function(component, event, helper){
        debugger;
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        var totalRentalObjectPrice = 0;
        var totalRentalObjectPriceSQM = 0;

        let priceSQM = 0;

        newEachPeriod.FixedRentalObjectSection.rentalObjectList.forEach((rowData, index) => {
            debugger;
            if (!rowData.isToDeleteRecord) {

                priceSQM = (rowData.PriceSQM.value)?helper.roundDecimal(parseFloat(rowData.PriceSQM.value)):0;
                
                rowData.Price.value = priceSQM * parseFloat(rowData.LeasableArea);
                rowData.Price.value = helper.roundDecimal(rowData.Price.value);              

                totalRentalObjectPrice += (rowData.Price.value)?parseFloat(rowData.Price.value):0;
                totalRentalObjectPrice = helper.roundDecimal(totalRentalObjectPrice); 


            }
        });
        
        totalRentalObjectPriceSQM = totalRentalObjectPrice / parseFloat(newEachPeriod.FixedRentalObjectSection.TotalLeasableArea);
        totalRentalObjectPriceSQM = helper.roundDecimal(totalRentalObjectPriceSQM); 

        newEachPeriod.FixedRentalObjectSection.TotalPrice = totalRentalObjectPrice;
        newEachPeriod.FixedRentalObjectSection.TotalPriceSQm = totalRentalObjectPriceSQM;

        component.set("v.eachPeriod", newEachPeriod);
    },
    onBlurchangeRentalObjectPriceSQM : function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        var totalRentalObjectPrice = 0;
        var totalRentalObjectPriceSQM = 0;

        debugger;

        newEachPeriod.FixedRentalObjectSection.rentalObjectList.forEach((rowData, index) => {

            debugger;
            
            if (!rowData.isToDeleteRecord) {

                if (!rowData.PriceSQM.value) {
                    rowData.PriceSQM.value = 0;
                }
                rowData.PriceSQM.value = helper.roundDecimal(parseFloat(rowData.PriceSQM.value));
                
                rowData.Price.value = rowData.PriceSQM.value * parseFloat(rowData.LeasableArea);
                rowData.Price.value = helper.roundDecimal(rowData.Price.value);              

                totalRentalObjectPrice += (rowData.Price.value)?parseFloat(rowData.Price.value):0;
                totalRentalObjectPrice = helper.roundDecimal(totalRentalObjectPrice); 


            }
        });

        totalRentalObjectPriceSQM = totalRentalObjectPrice / parseFloat(newEachPeriod.FixedRentalObjectSection.TotalLeasableArea);;
        totalRentalObjectPriceSQM = helper.roundDecimal(totalRentalObjectPriceSQM);

        newEachPeriod.FixedRentalObjectSection.TotalPrice = totalRentalObjectPrice;
        newEachPeriod.FixedRentalObjectSection.TotalPriceSQm = totalRentalObjectPriceSQM;
        
        component.set("v.eachPeriod", newEachPeriod);
    },
    changeRentalObjectPrice : function(component, event, helper) {
        component.set("v.isChangePricing",true);
    	var eachPeriod = component.get("v.eachPeriod");
    	var newEachPeriod = Object.assign({}, eachPeriod);
    	var totalRentalObjectPrice = 0;

    	newEachPeriod.FixedRentalObjectSection.rentalObjectList.forEach((rowData, index) => {
            
            if (!rowData.isToDeleteRecord) {

                totalRentalObjectPrice += (rowData.Price.value)?parseFloat(rowData.Price.value):0;
                totalRentalObjectPrice = helper.roundDecimal(totalRentalObjectPrice); 
            }
        });

    	newEachPeriod.FixedRentalObjectSection.TotalPrice = totalRentalObjectPrice;
    	component.set("v.eachPeriod", newEachPeriod);

    },
    onBlurchangeRentalObjectPrice : function(component, event, helper) {
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        var totalRentalObjectPrice = 0;

        newEachPeriod.FixedRentalObjectSection.rentalObjectList.forEach((rowData, index) => {
            
            if (!rowData.isToDeleteRecord) {

                if(!rowData.Price.value){
                    rowData.Price.value = 0;
                }
            }
        });
        component.set("v.eachPeriod", newEachPeriod);

    },
    onChangePricing: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var compEvent = component.getEvent("PeriodChangeEvent");
            compEvent.setParams({
                "periodIndex" : component.get("v.periodIndex"),
                "isIncludedCAM" : component.get("v.eachPeriod.IsIncludeCAM")
            });
            compEvent.fire();
    },
    onChangeDatePeriod: function(component, event, helper){
       var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        component.set("v.eachPeriod.isEditRecord", true);
        component.set("v.isChangePricing",true);
        component.set("v.isRenewChangeDate",true);

        var compEvent = component.getEvent("PeriodChangeEvent");
            compEvent.setParams({
                "periodIndex" : component.get("v.periodIndex"),
                "periodStartDate" : newEachPeriod.PricingFrom,
                "periodEndDate" : newEachPeriod.PricingTo
            });
            compEvent.fire();
    },
    onChangeOptionToRenew: function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        component.set("v.isChangePricing",true);

        if (newEachPeriod.OptionToRenew) {
            newEachPeriod.IsIncludeCAM = false;
            component.set("v.isDisableIncludeCAM",true);
            component.set("v.eachPeriod.IsIncludeCAM",newEachPeriod.IsIncludeCAM);

        }else{
            component.set("v.isDisableIncludeCAM",false);            
        }

        var compEvent = component.getEvent("PeriodChangeEvent");
            compEvent.setParams({
                "periodIndex" : component.get("v.periodIndex"),
                "periodStartDate" : null,
                "periodEndDate" : null,
                "isOptionToReNew" : newEachPeriod.OptionToRenew
            });
            compEvent.fire();
    },
    onBlurProportion: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        if (!eachPeriod.Proportion.Rent) {
            eachPeriod.Proportion.Rent =0;
        }else{
            eachPeriod.Proportion.Rent = parseFloat(eachPeriod.Proportion.Rent);
        }

        if (!eachPeriod.Proportion.Service) {
            eachPeriod.Proportion.Service =0;
        }else{
            eachPeriod.Proportion.Service = parseFloat(eachPeriod.Proportion.Service);
        }
        
        component.set("v.eachPeriod",eachPeriod);
    },
})