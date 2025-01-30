({
    init : function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        console.log('eachPeriod : ',eachPeriod);
        if (eachPeriod.OptionToRenew) {
            component.set("v.isDisableIncludeCAM",true);

        }else{
            component.set("v.isDisableIncludeCAM",false);            
        }
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
    onBlurFixPricingSQM: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var totalPice = 0;
        
        if (!eachPeriod.FixedPriceSection.PriceSQM) {
            eachPeriod.FixedPriceSection.PriceSQM = 0;
        }

        let priceSQM = parseFloat(eachPeriod.FixedPriceSection.PriceSQM);
        totalPice = priceSQM * parseFloat(eachPeriod.FixedPriceSection.TotalArea);
        eachPeriod.FixedPriceSection.Price = helper.roundDecimal(totalPice);

        component.set("v.eachPeriod",eachPeriod);
    },
    onChangeFixPricingSQM: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var totalPice = 0;
        
        let priceSQM = (eachPeriod.FixedPriceSection.PriceSQM)?parseFloat(eachPeriod.FixedPriceSection.PriceSQM):0;
        totalPice = priceSQM * parseFloat(eachPeriod.FixedPriceSection.TotalArea);
        eachPeriod.FixedPriceSection.Price = helper.roundDecimal(totalPice);

        component.set("v.eachPeriod",eachPeriod);
    },
    onBlurFixPricing: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        if (!eachPeriod.FixedPriceSection.Price) {
            eachPeriod.FixedPriceSection.Price =0;
        }else{
            eachPeriod.FixedPriceSection.Price = parseFloat(eachPeriod.FixedPriceSection.Price);
        }
        component.set("v.eachPeriod",eachPeriod);
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