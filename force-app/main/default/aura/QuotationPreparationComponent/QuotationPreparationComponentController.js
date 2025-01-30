({
    init : function(component, event, helper) {

    // helper.getUsageTypeOption(component, event);
    // helper.getCalculationReportingOption(component, event);
    component.set("v.isDisabledSaveButton", true);
    component.set("v.toggleSpinner", true);
    let oppId = component.get("v.recordId");

    var action = component.get("c.getRecordTypeName");
    action.setParams({ recordId: oppId });

    action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var returnedData = response.getReturnValue();
            //console.log(returnedData);
            component.set("v.recordTypeName", returnedData)
            helper.getOppDetail(component, event);

        }
    });

    $A.enqueueAction(action);
    // helper.getOppRecordType(component, event);
    
    },
    oppDetailEventController : function(component, event, helper){
        var newOppObject = event.getParam("oppObject");
        component.set("v.oppObject",newOppObject);
        console.log('newOppObject',JSON.stringify(newOppObject));
    },
    saveAndClose : function(component, event, helper) {
        var oppDetail = component.get("v.oppObject");
        var isRenew = oppDetail.isRenew;
        var isOppRenewAlreadyChangePeriod = oppDetail.isRenewChangeOppPeriod;
        var isRenewChangeDate = component.get("v.isRenewChangeDate");
        var isRenewCAMChangeDate = component.get("v.isRenewCAMChangeDate");
        var isNoCAM = oppDetail.isNoCAM;

        //debugger;

        if(!oppDetail.isReadOnly){

            // if (isRenew) {
            //     if (isOppRenewAlreadyChangePeriod) {
            //         helper.saveData(component, event);
            //     }else{
            //         if (isNoCAM) {
            //             if(isRenewChangeDate){
            //                 component.set("v.oppObject.isRenewChangeOppPeriod",true);
            //                 helper.saveData(component, event);
            //             }else{
            //                 let toastEvent = $A.get("e.force:showToast");
            //                 toastEvent.setParams({
            //                     "title": "Error!",
            //                     "type": "error",
            //                     "message": $A.get("$Label.c.ChangePeriodDateRenew")
            //                 });
            //                 toastEvent.fire();
            //             }
            //         }else{
            //             if(isRenewChangeDate && isRenewCAMChangeDate){
            //                 component.set("v.oppObject.isRenewChangeOppPeriod",true);
            //                 helper.saveData(component, event);
            //             }else{
            //                 let toastEvent = $A.get("e.force:showToast");
            //                 toastEvent.setParams({
            //                     "title": "Error!",
            //                     "type": "error",
            //                     "message": $A.get("$Label.c.ChangePeriodDateRenew")
            //                 });
            //                 toastEvent.fire();
            //             }
            //         }

            //         // if(isRenewChangeDate){
            //         //     helper.saveData(component, event);
            //         //     component.set("v.oppObject.isRenewChangeOppPeriod",true);
            //         // }else{
            //         //     let toastEvent = $A.get("e.force:showToast");
            //         //     toastEvent.setParams({
            //         //         "title": "Error!",
            //         //         "type": "error",
            //         //         "message": $A.get("$Label.c.ChangePeriodDateRenew")
            //         //     });
            //         //     toastEvent.fire();
            //         // }
            //     }
            // }else{
                helper.saveData(component, event);
            // }
        }else{
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }

    },
    clickStep1 : function(component, event, helper) {
    	component.set("v.progresStep", "1");
    },
    clickStep2 : function(component, event, helper) {
		component.set("v.progresStep", "2");    	
    },
    clickStep3 : function(component, event, helper) {
		component.set("v.progresStep", "3");    
    },
    clickStep4 : function(component, event, helper) {
		component.set("v.progresStep", "4");    
    },
    clickStep5 : function(component, event, helper) {
		component.set("v.progresStep", "5");    
    },

    clickNextStep : function(component, event, helper){
        var currentStep = component.get("v.progresStep");
        var oppDetail = component.get("v.oppObject");
        var isRenew = oppDetail.isRenew;
        var isOppRenewAlreadyChangePeriod = oppDetail.isRenewChangeOppPeriod;
        var isRenewChangeDate = component.get("v.isRenewChangeDate");
        var isRenewCAMChangeDate = component.get("v.isRenewCAMChangeDate");
        var isNoCAM = oppDetail.isNoCAM;

        //debugger;
        
        switch (currentStep) {
            case '1':               
                // helper.saveSelectedRentalObject(component, event, '2');
                helper.validateBeforeSaveSelectedRO(component, event, '2', false);
                break;
            case '2':
                var nextStep = '3';
                if(oppDetail.rentType == 'Billboard_Rental' || oppDetail.rentType == 'Event_Rental') nextStep = '4';

                if(!oppDetail.isReadOnly){
                    // if (isRenew) {
                    //     if (isOppRenewAlreadyChangePeriod) {
                    //         helper.savePricing(component, event, nextStep);
                    //     }else{
                    //         if (isNoCAM) {
                    //             if(isRenewChangeDate){
                    //                 component.set("v.oppObject.isRenewChangeOppPeriod",true);
                    //                 helper.savePricing(component, event, nextStep);
                    //             }else{
                    //                 let toastEvent = $A.get("e.force:showToast");
                    //                 toastEvent.setParams({
                    //                     "title": "Error!",
                    //                     "type": "error",
                    //                     "message": $A.get("$Label.c.ChangePeriodDateRenew")
                    //                 });
                    //                 toastEvent.fire();
                    //             }
                    //         }else{
                    //             if(isRenewChangeDate && isRenewCAMChangeDate){
                    //                 component.set("v.oppObject.isRenewChangeOppPeriod",true);
                    //                 helper.savePricing(component, event, nextStep);
                    //             }else{
                    //                 let toastEvent = $A.get("e.force:showToast");
                    //                 toastEvent.setParams({
                    //                     "title": "Error!",
                    //                     "type": "error",
                    //                     "message": $A.get("$Label.c.ChangePeriodDateRenew")
                    //                 });
                    //                 toastEvent.fire();
                    //             }
                    //         }

                    //     }
                    // }else{
                        helper.savePricing(component, event, nextStep);
                    // }
                }else{
                    helper.savePricing(component, event, nextStep);
                }
                break;
            case '3':
                helper.saveDeposit(component, event, '4');
                break;
            case '4':
                debugger;
                helper.saveExpenseList(component, event, '5');
                break;
            default:
                break;
        }

    },
    clickBackStep : function(component, event, helper){
        var currentStep = component.get("v.progresStep");
        
        switch (currentStep) {
            case '2':
                helper.changeStep(component, event, '1');
                component.set("v.isChangeSelectedRO",false);
                break;
            case '3':
                helper.changeStep(component, event, '2');
                component.set("v.isChangePricing",false);
                break;
            case '4':
                var oppDetail = component.get("v.oppObject");
                if(oppDetail.rentType == 'Billboard_Rental' || oppDetail.rentType == 'Event_Rental') {
                    helper.changeStep(component, event, '2');
                } else {
                    helper.changeStep(component, event, '3');
                }
                component.set("v.isChangeExpense",false);
                break;
            case '5':
                helper.changeStep(component, event, '4');
                component.set("v.isChangeDeposit",false);
                break;
            default:
                break;
        }

    },
    regenerateRenserviceController : function(component, event, helper){
        console.log('Regenerate RentService');
        if (event.getParam("isSelectRenServiceEscalation")) {
            helper.regenerateEscalatonRentService(component,event);
        }
        if (event.getParam("isSelectRenServiceAdvance")) {
            helper.regenerateAdvanceRentService(component,event);
        }
    },
    selectedROEventController : function(component, event, helper){
        component.set("v.isDisabledSaveButton",event.getParam("isDisabledSaveButton"));
    },
    // changePeriodEvent : function(component, event, helper){
    //     debugger;
    //     var periodIndex = event.getParam("periodIndex");
    //     var periodStartDate = event.getParam("periodStartDate");
    //     var periodEndDate = event.getParam("periodEndDate");
    // }

})