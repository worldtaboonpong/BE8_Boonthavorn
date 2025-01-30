({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    addOtherExpenseHelper : function(component, event){
        debugger;
        var modalBody;
        var selectedOtherExpense;
        $A.createComponent("c:AddOtherExpenseCpmponent", {optionToparent : component.getReference("v.addedOtherExpenseType"), options : component.get("v.otherExpenseOption")},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('addOtherExpenseOverLey').showCustomModal({
                       header: "Add Other Expense",
                       body: modalBody,
                       showCloseButton: false,
                       cssClass: "slds-modal_medium",
                       closeCallback: function() {
                           // alert('You closed the alert!');
                           console.log(component.get("v.addedOtherExpenseType"));
                           selectedOtherExpense = component.get("v.addedOtherExpenseType");
                           if (selectedOtherExpense) {
                            debugger;
                                
                            var addOtherExpenseTypeDeleted = false;

                            var validateDuplicateExpenseType = function(){
                                var res = true;
                                debugger;
                                
                                var otherExpenseObject = component.get("v.otherPageObject");
                                otherExpenseObject.rateAndAreaFormatList.forEach((rowData, index) => {
                                    if(rowData.Type === selectedOtherExpense){
                                        addOtherExpenseTypeDeleted = true;
                                        if (!rowData.isToDeleteRecord){
                                            res = false;
                                        }
                                    }
                                });

                                otherExpenseObject.fixedFormatList.forEach((rowData, index) => {
                                    if(rowData.Type === selectedOtherExpense){
                                        addOtherExpenseTypeDeleted = true;
                                        if (!rowData.isToDeleteRecord){
                                            res = false;
                                        }
                                    }
                                });

                                return res;
                            }
                            
                            var otherExpenseObject = component.get("v.otherPageObject");
                            var newOtherDepsit = Object.assign({}, otherExpenseObject);
                            var oppDetail = component.get("v.oppObject");
                            var disabledPriceKey = component.get("v.disabledPriceKey");
                            var disabledTotalKey = component.get("v.disabledTotaleKey");
                            var disabledRemarkKey = component.get("v.disabledRemarkKey");

                            if (validateDuplicateExpenseType()) {
                                var action = component.get("c.getNewOtherExpenseJson");
                                action.setParams({rentType : oppDetail.rentType, targetType: selectedOtherExpense});
                            
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var returnedData = response.getReturnValue();
                                        var newotherExpenseObject = JSON.parse(returnedData);

                                        console.log("Return new Period",JSON.parse(returnedData));
                                        
                                        if (newotherExpenseObject) {

                                            if (disabledPriceKey.includes(newotherExpenseObject.SubType)) {
                                                newotherExpenseObject.isDisabledRateAndArea = true;
                                            }
                                            if (disabledTotalKey.includes(newotherExpenseObject.SubType)) {
                                                newotherExpenseObject.isDisabledTotal = true;
                                            }
                                            if (disabledRemarkKey.includes(newotherExpenseObject.SubType)) {
                                                newotherExpenseObject.isDisabledRemark = true;
                                            }

                                            debugger;

                                            let alreadyAdd = false;

                                            if (newotherExpenseObject.ExpenseOtherType === "Rate and Area") {
                                                if(newotherExpenseObject.Sequence != null){
                                                    let newArray = [...newOtherDepsit.rateAndAreaFormatList];
                                                    if(newArray.length > 0){
                                                        newOtherDepsit.rateAndAreaFormatList.forEach((eachOtherObject, index) => {
                                                            if(!alreadyAdd){
                                                                if(addOtherExpenseTypeDeleted){
                                                                    if (newotherExpenseObject.Type === eachOtherObject.Type) {
                                                                        eachOtherObject.isToDeleteRecord = false;
                                                                        alreadyAdd = true;
                                                                    }
                                                                }
                                                                else{
                                                                    if (newotherExpenseObject.Sequence < eachOtherObject.Sequence) {
                                                                        alreadyAdd = true;
                                                                        newArray.splice(index, 0, newotherExpenseObject);
                                                                    }
                                                                    else if(index == newOtherDepsit.rateAndAreaFormatList.length - 1){
                                                                        alreadyAdd = true;
                                                                        newArray.push(newotherExpenseObject);
                                                                    }
                                                                }
                                                            }
                                                        });
                                                    }
                                                    else{
                                                        newArray.push(newotherExpenseObject);
                                                    }

                                                    debugger;

                                                    newOtherDepsit.rateAndAreaFormatList = newArray;

                                                }else{
                                                    alreadyAdd = true;
                                                    if(addOtherExpenseTypeDeleted){
                                                        newOtherDepsit.rateAndAreaFormatList.forEach((eachOtherObject, index) => {
                                                            if (newotherExpenseObject.Type === eachOtherObject.Type) {
                                                                eachOtherObject.isToDeleteRecord = false;
                                                            }
                                                        });
                                                    }
                                                    else{
                                                        newOtherDepsit.rateAndAreaFormatList.push(newotherExpenseObject);
                                                    }
                                                }
                                                // newOtherDepsit.rateAndAreaFormatList.sort((a, b) => a.Sequence - b.Sequence);
                                                component.set("v.otherPageObject.rateAndAreaFormatList", newOtherDepsit.rateAndAreaFormatList);
                                            }else if(newotherExpenseObject.ExpenseOtherType === "Fixed"){

                                                if(newotherExpenseObject.Sequence != null){
                                                    let newArray = [...newOtherDepsit.fixedFormatList];
                                                    
                                                    if(newArray.length > 0){
                                                        newOtherDepsit.fixedFormatList.forEach((eachOtherObject, index) => {
                                                            if(!alreadyAdd){
                                                                if(addOtherExpenseTypeDeleted){
                                                                    if (newotherExpenseObject.Type === eachOtherObject.Type) {
                                                                        eachOtherObject.isToDeleteRecord = false;
                                                                        alreadyAdd = true;
                                                                    }
                                                                }
                                                                else{
                                                                    if (newotherExpenseObject.Sequence < eachOtherObject.Sequence) {
                                                                        alreadyAdd = true;
                                                                        newArray.splice(index, 0, newotherExpenseObject);
                                                                    }
                                                                    else if(index == newOtherDepsit.fixedFormatList.length - 1){
                                                                        alreadyAdd = true;
                                                                        newArray.push(newotherExpenseObject);
                                                                    }
                                                                }
                                                            }
                                                        }); 
                                                    }
                                                    else{
                                                        newArray.push(newotherExpenseObject);
                                                    }

                                                    newOtherDepsit.fixedFormatList = newArray;
                                                    
                                                }else{
                                                    alreadyAdd = true;
                                                    if(addOtherExpenseTypeDeleted){
                                                        newOtherDepsit.fixedFormatList.forEach((eachOtherObject, index) => {
                                                            if (newotherExpenseObject.Type === eachOtherObject.Type) {
                                                                eachOtherObject.isToDeleteRecord = false;
                                                            }
                                                        });
                                                    }
                                                    else{
                                                        newOtherDepsit.fixedFormatList.push(newotherExpenseObject);
                                                    }
                                                }
                                                // newOtherDepsit.fixedFormatList.sort((a, b) => a.Sequence - b.Sequence);
                                                component.set("v.otherPageObject.fixedFormatList", newOtherDepsit.fixedFormatList);
                                            }
                                        }

                                        // var newPeriod = JSON.parse(returnedData);
                                        // newPeriodList.push(newPeriod);
                                        // periodPricing = newPeriodList;
                                        component.set("v.addedOtherExpenseType", null);
                                        
                                    }
                                });
                            
                                $A.enqueueAction(action);
                            }else{
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "type": "error",
                                    "message": "Duplicate Other Expense Type"
                                });
                                toastEvent.fire();
                            }

                           }
                       },
                   })
               }
           });
    },
})