({
    removeSelectedPeriod : function(component, event){

        var periodPricing = component.get("v.periodPricing");
        // var newPeriodList = [...periodPricing];

        debugger;
    	var indexPosition = parseInt(event.target.name);
        console.log("Delete Row ",indexPosition);

        // newPeriodList.splice(indexPosition, 1);
        periodPricing[indexPosition].isToDeleteRecord = true;

        var eachPeriod = periodPricing[indexPosition];
        var newEachPeriod = Object.assign({}, eachPeriod);
        newEachPeriod.isToDeleteRecord = true;
        let deletedPeriodNummber = newEachPeriod.PeriodNumber;
        periodPricing[indexPosition] = newEachPeriod;


        periodPricing = periodPricing.map(function(rowData) {
            if (rowData.PeriodNumber > deletedPeriodNummber && !rowData.isToDeleteRecord) {
                rowData.PeriodNumber -= 1;
            }
            return rowData;
        });

        // periodPricing = newPeriodList;
        component.set("v.periodPricing", periodPricing);
    },

    addPeriodHelper : function(component, event){

        var modalBody;
        var selectedPeriodType;
        $A.createComponent("c:PricingAddPeriodComponent", {optionToparent : component.getReference("v.addedPeriodType"), options : component.get("v.calculationMethodOption")},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('addPeriodOverLey').showCustomModal({
                       header: "AddPeriod",
                       body: modalBody,
                       showCloseButton: false,
                       cssClass: "slds-modal_medium",
                       closeCallback: function() {
                           // alert('You closed the alert!');
                           console.log(component.get("v.addedPeriodType"));
                           selectedPeriodType = component.get("v.addedPeriodType");
                           if (selectedPeriodType) {
                            	var periodPricing = component.get("v.periodPricing");
                            	var newPeriodList = [...periodPricing];
                            	
                                let periodNumber = 1;
                                newPeriodList = newPeriodList.map(function(rowData) {
                                    if (!rowData.isToDeleteRecord) {
                                        periodNumber++;
                                    }
                                    return rowData;
                                });

                                let selectedRoom = component.get("v.seletedRoom");
                                var oppObject = component.get("v.oppObject");

                                var action = component.get("c.getNewPeriodJSON");
                                action.setParams({periodType : selectedPeriodType, periodNUmber: periodNumber, selectedRoomJson:JSON.stringify(selectedRoom), oppUiWrapper :JSON.stringify(oppObject)});
                         
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var returnedData = response.getReturnValue();

                                        console.log("Return new Period",JSON.parse(returnedData));

                                    	var newPeriod = JSON.parse(returnedData);
                                    	newPeriodList.push(newPeriod);
                                    	periodPricing = newPeriodList;
                                    	component.set("v.periodPricing", periodPricing);
                                        component.set("v.addedPeriodType", null);
                                        component.set("v.oppObject.totalQuotationPeriod", newPeriodList.length);
                                        
                                    }
                                });
                         
                                $A.enqueueAction(action);

                           }
                       }
                   })
               }
           });
    },
})