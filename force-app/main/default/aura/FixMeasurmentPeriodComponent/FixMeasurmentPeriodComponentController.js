({
    init : function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        if (eachPeriod.OptionToRenew) {
            component.set("v.isDisableIncludeCAM",true);

        }else{
            component.set("v.isDisableIncludeCAM",false);            
        }
    },
    onMeasurmentPricingBlur : function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);


        var totalMeasurmentPrice =0;
        var totalSummaryPrice =0;
        var measurmentSummary;

        newEachPeriod.FixedMeasurementSection.pricingList = newEachPeriod.FixedMeasurementSection.pricingList.map(function(rowData) {
            measurmentSummary = 0; 

            if (!rowData.isToDeleteRecord) {

                if(!rowData.Price.value){
                    rowData.Price.value = 0;
                }
                measurmentSummary = parseFloat(rowData.Area) *parseFloat(rowData.Price.value);
                measurmentSummary = helper.roundDecimal(measurmentSummary);
                
                totalMeasurmentPrice += parseFloat(rowData.Price.value);
                totalSummaryPrice += measurmentSummary;

                totalSummaryPrice = helper.roundDecimal(totalSummaryPrice);
            }

            rowData.Summary = measurmentSummary;


            return rowData;
        });

        newEachPeriod.FixedMeasurementSection.TotalPrice = totalMeasurmentPrice;
        newEachPeriod.FixedMeasurementSection.TotalSummary = totalSummaryPrice;
        console.log('check new eachPeriod : ', newEachPeriod);

        component.set("v.eachPeriod", newEachPeriod);
    },
    onMeasurmentPricingChange : function(component, event, helper) {
        debugger
        component.set("v.isChangePricing",true);
    	var eachPeriod = component.get("v.eachPeriod");
    	var newEachPeriod = Object.assign({}, eachPeriod);


    	var totalMeasurmentPrice =0;
    	var totalSummaryPrice =0;
    	var measurmentSummary;

    	newEachPeriod.FixedMeasurementSection.pricingList = newEachPeriod.FixedMeasurementSection.pricingList.map(function(rowData) {
            measurmentSummary = 0; 

            if (!rowData.isToDeleteRecord) {


                measurmentSummary = (rowData.Price.value)?parseFloat(rowData.Area) *parseFloat(rowData.Price.value): parseFloat(rowData.Area) *0;
                measurmentSummary = helper.roundDecimal(measurmentSummary);
                
                totalMeasurmentPrice += (rowData.Price.value)?parseFloat(rowData.Price.value):0;
                totalSummaryPrice += measurmentSummary;

                totalSummaryPrice = helper.roundDecimal(totalSummaryPrice);
            }

            rowData.Summary = measurmentSummary;


            return rowData;
        });

    	newEachPeriod.FixedMeasurementSection.TotalPrice = totalMeasurmentPrice;
    	newEachPeriod.FixedMeasurementSection.TotalSummary = totalSummaryPrice;
        console.log('check new eachPeriod : ', newEachPeriod);

    	component.set("v.eachPeriod", newEachPeriod);
    },
    onChangePricing: function(component, event, helper){
        debugger;
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var compEvent = component.getEvent("PeriodChangeEvent");
            compEvent.setParams({
                "periodIndex" : component.get("v.periodIndex"),
                "isIncludedCAM" : component.get("v.eachPeriod.IsIncludeCAM")
            });
            compEvent.fire();
    },
    onChangeOptionToRenew: function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        component.set("v.isChangePricing",true);
        debugger;

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