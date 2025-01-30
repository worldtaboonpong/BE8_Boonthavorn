({
    init : function(component, event, helper) {
    },

    removeSelectedPeriod : function(component, event, helper) {
       var oppDetail = component.get("v.oppObject");

       if(oppDetail.popupSetting["การลบ Pricing Period"].tms_Enable__c){

           var modalBody;
           var modalFooter;
            $A.createComponents([
                ["c:ConfirmPopup",{}],
                ["c:ConfirmPopupFooter",{isConfirmRemove : component.getReference("v.isConfirmRemove")}]
            ],
            function(content, status){
                if (status === "SUCCESS") {
                    modalBody = content[0];
                    modalFooter = content[1];
                    component.find('confirmOverlay').showCustomModal({
                        cssClass: "confirmModal",
                        header: "Do you want to delete record?",
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true,
                        
                        closeCallback: function() {
                            console.log('You closed the alert!');
                            var isConfirm = component.get("v.isConfirmRemove");

                            if (isConfirm) {
                                component.set("v.isChangePricing",true);
                                helper.removeSelectedPeriod(component, event);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
            component.set("v.isChangePricing",true);
            helper.removeSelectedPeriod(component, event);
       }
    },

    addPeriod : function(component, event, helper){
      component.set("v.isChangePricing",true);
    	helper.addPeriodHelper(component, event);
    },
    changePeriodEvent : function(component, event, helper){
        debugger;
        var periodPricing = component.get("v.periodPricing");

        var periodIndex = event.getParam("periodIndex");
        var periodStartDate = event.getParam("periodStartDate");
        var periodEndDate = event.getParam("periodEndDate");
        var isOptionToReNew = event.getParam("isOptionToReNew");
        var isIncludedCAM = event.getParam("isIncludedCAM");

        if(periodStartDate) periodPricing[periodIndex].PricingFrom = periodStartDate;
        if(periodEndDate) periodPricing[periodIndex].PricingTo =  periodEndDate;
        if(isOptionToReNew) periodPricing[periodIndex].OptionToRenew = isOptionToReNew;
        if(isIncludedCAM) periodPricing[periodIndex].IsIncludeCAM = isIncludedCAM;
        component.set("v.periodPricing",periodPricing);
    }
})