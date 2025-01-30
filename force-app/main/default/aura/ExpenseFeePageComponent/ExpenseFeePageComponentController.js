({
    onChangeExpense : function(component, event, helper){
        component.set("v.isChangeExpense",true);
    },
    addExpense : function(component, event, helper) {
    	helper.addExpenseHelper(component, event);
        component.set("v.isChangeExpense",true);
    },
    removePeriod : function(component, event, helper){
        var oppDetail = component.get("v.oppObject");

        if(oppDetail.popupSetting["การลบ Other"].Enable__c){

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
                                helper.removePeriodHelper(component, event);
                                component.set("v.isChangeExpense",true);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
        	helper.removePeriodHelper(component, event);
            component.set("v.isChangeExpense",true);
       }

    },

    handleComponentEvent: function(component, event, helper){
        var eachExpense = event.getParam("eachExpense");
        var expenseIndex = event.getParam("expenseIndex");

        var expenseList = component.get("v.expenseList");
        var newExpenseList = [...expenseList];

        if(eachExpense.isLEASEHOLD){
            newExpenseList.forEach((eachLeaseHoldExpense, index) => {
                if (eachLeaseHoldExpense.isLeaseHoldDisableINstallment && !eachLeaseHoldExpense.isToDeleteRecord) {
                   eachLeaseHoldExpense.Remark = eachExpense.Remark;
                }
            });
        }

        component.set("v.isChangeExpense",true);

        newExpenseList[parseInt(expenseIndex)] = eachExpense;
        component.set("v.expenseList", newExpenseList);
    },

    handleExpenseTypeEvent : function(component, event, helper){
        var eachExpense = event.getParam("eachExpense");
        var expenseIndex = event.getParam("expenseIndex");
        var oppObject = component.get("v.oppObject");
        var selectedRoom = component.get("v.selectedRoom");
        var expenseList = component.get("v.expenseList");
        var newExpenseList = [...expenseList];
        var isIncludeSummary = true;
        var isDoubleType = false;
        var isDoubleLeaseHoldType = false;
        var leaseHoldSummaryIndex;
        var leaseHoldSummaryNumberOfInstallment = 1;
        component.set("v.isChangeExpense",true);



        if (eachExpense.Type == "ค่าสิทธิการเช่า") {
            
            // if (eachExpense.isLEASEHOLD){
            //     isDoubleLeaseHoldType = true;
            // }else{
            //     newExpenseList.forEach((eachOldExpense, index) => {
                     
            //         if(eachOldExpense.Type == eachExpense.Type && index != expenseIndex && !eachOldExpense.isToDeleteRecord){
            //             isDoubleType = true;
            //         }

            //     });
            // }


            // if (isDoubleType) {
            //     eachExpense.Type = "";
            //     newExpenseList[parseInt(expenseIndex)] = eachExpense;
            //     component.set("v.expenseList", newExpenseList);

            //     let toastEvent = $A.get("e.force:showToast");
            //     toastEvent.setParams({
            //         "title": "Error!",
            //         "type": "error",
            //         "message": "Type is already exist"
            //     });
            //     toastEvent.fire();

            // }else if(isDoubleLeaseHoldType){

            //     let toastEvent = $A.get("e.force:showToast");
            //     toastEvent.setParams({
            //         "title": "Error!",
            //         "type": "error",
            //         "message": "Type is already exist"
            //     });
            //     toastEvent.fire();

            // }else{

                newExpenseList.forEach((eachExpense, index) => {
                    if (eachExpense.isLEASEHOLDSUMMARY && !eachExpense.isToDeleteRecord) {
                        isIncludeSummary = false;
                        leaseHoldSummaryIndex = index;
                        leaseHoldSummaryNumberOfInstallment = eachExpense.NumberOfInstallment; 
                    }
                });

                var action = component.get("c.getNewExpenseINstallmentJsonForLeaseHold");
                action.setParams({ selectedRoomJson: JSON.stringify(selectedRoom) ,
                                   oppUiWrapper: JSON.stringify(oppObject),  
                                   includSummary : isIncludeSummary, 
                                   initNumberInstallment: leaseHoldSummaryNumberOfInstallment});
         
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var returnedData = response.getReturnValue();
                        console.log('Return Expense JSON', returnedData);
                        var leaseHoldExpenseSet = JSON.parse(returnedData);

                        if (isIncludeSummary) {
                            if (newExpenseList[parseInt(expenseIndex)].Id) {
                                newExpenseList[parseInt(expenseIndex)].isToDeleteRecord = true;

                                leaseHoldExpenseSet.forEach((eachLeaseHold, index) => {
                                    newExpenseList.splice(parseInt(expenseIndex)+index,0, eachLeaseHold);
                                });

                            }else{
                                leaseHoldExpenseSet.forEach((eachLeaseHold, index) => {
                                    newExpenseList.splice(parseInt(expenseIndex)+index, index, eachLeaseHold);
                                });
                            }
                        }else{
                            
                            newExpenseList[parseInt(expenseIndex)].isToDeleteRecord = true;

                            leaseHoldExpenseSet.forEach((eachLeaseHold, index) => {
                                newExpenseList.splice(leaseHoldSummaryIndex,0, eachLeaseHold);
                            });                        
                        }

                        component.set("v.expenseList", newExpenseList);
                        console.log("new expense List ", JSON.stringify(newExpenseList));
                        // newExpenseList[parseInt(expenseIndex)] = leaseHoldExpenseSet;
                    }
                });
         
                $A.enqueueAction(action);
            // }
        }else{

            newExpenseList[parseInt(expenseIndex)] = eachExpense;
            component.set("v.expenseList", newExpenseList);
        }

    },
    handleExpenseInstallmentEvent : function(component, event, helper){
        var eachExpense = event.getParam("eachExpense");
        var expenseIndex = event.getParam("expenseIndex");
        var newINstallmentObject = event.getParam("InstallmentObject");


        var oppObject = component.get("v.oppObject");
        var expenseList = component.get("v.expenseList");
        var newExpenseList = [...expenseList];

        if (oppObject.spetialOtherTypePicklist.includes(eachExpense.Type) && eachExpense.isLEASEHOLD && !eachExpense.isLeaseHoldDisableINstallment){
            newExpenseList[parseInt(expenseIndex)] = eachExpense;
            newExpenseList.forEach((eachNewExpense, index) => {
                     
                if(!eachNewExpense.isToDeleteRecord){
                    if ((eachNewExpense.isLEASEHOLD || eachNewExpense.isLEASEHOLDSUMMARY) && eachNewExpense.isLeaseHoldDisableINstallment) {

                        var newInstallmentJson =  JSON.parse(newINstallmentObject);
                        eachNewExpense.InstallmentList.push(newInstallmentJson);   
                        var installmentindex = 0;

                        eachNewExpense.InstallmentList.forEach((rowData) =>{

                            if(!rowData.isToDeleteRecord){
                                installmentindex++;
                                rowData.InstallmentNumber = installmentindex;
                            }
                        });

                        eachNewExpense.NumberOfInstallment = installmentindex;
                        helper.calculateInstallmentHelper(component, event, eachNewExpense);
                    }

                }

            });


            var totalINstallmentAmount = new Map();
            newExpenseList.forEach((eachNewExpense, exIndex) => {
                if(!eachNewExpense.isToDeleteRecord && (eachNewExpense.isLEASEHOLD)){
                    
                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        if (!eachInstallment.isToDeleteRecord){
                            if (totalINstallmentAmount.has(eachInstallment.InstallmentNumber)) {
                                let installmentAmount = totalINstallmentAmount.get(eachInstallment.InstallmentNumber);
                                installmentAmount += parseFloat(eachInstallment.InstallmentAmount); 
                                totalINstallmentAmount.set(eachInstallment.InstallmentNumber,parseFloat(installmentAmount));    
                            }else{
                                totalINstallmentAmount.set(eachInstallment.InstallmentNumber,parseFloat(eachInstallment.InstallmentAmount));    
                            }
                        }
                        
                    });
                }
            });

            newExpenseList.forEach((eachNewExpense, exIndex) => {
                if(!eachNewExpense.isToDeleteRecord && (eachNewExpense.isLEASEHOLDSUMMARY)){
                    var totalInstallment = 0;

                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        if (!eachInstallment.isToDeleteRecord){
                            eachInstallment.InstallmentAmount = totalINstallmentAmount.get(eachInstallment.InstallmentNumber); 
                            totalInstallment += parseFloat(eachInstallment.InstallmentAmount);
                        }
                    });   

                    eachNewExpense.TotalInstallment = totalInstallment;
                }
            });

            component.set("v.expenseList", newExpenseList);

        }else{
            newExpenseList[parseInt(expenseIndex)] = eachExpense;
            component.set("v.expenseList", newExpenseList);
        }
    },

    handleExpenseLeaseHoldFloorEvent : function(component, event, helper){
        var eachExpense = event.getParam("eachExpense");
        var expenseIndex = event.getParam("expenseIndex");

        var oppObject = component.get("v.oppObject");
        var expenseList = component.get("v.expenseList");
        var newExpenseList = [...expenseList];

        
            newExpenseList[parseInt(expenseIndex)].TotalAmount = eachExpense.TotalAmount;

            var summaryLeaseHoldTotalAmount = 0;
            newExpenseList.forEach((eachNewExpense, index) => {
                
                
                if(!eachNewExpense.isToDeleteRecord){
                    if (eachNewExpense.isLEASEHOLD) {
                        summaryLeaseHoldTotalAmount += eachNewExpense.TotalAmount;
                    }
                }

            });


            
            newExpenseList.forEach((eachNewExpense, index) => {
                
                if(!eachNewExpense.isToDeleteRecord){
                    if (eachNewExpense.isLEASEHOLDSUMMARY) {
                        eachNewExpense.TotalAmount = summaryLeaseHoldTotalAmount;
                        helper.calculateInstallmentHelper(component, event, eachNewExpense);
                    }
                }

            });

            component.set("v.expenseList", newExpenseList);


    },
    handleInstallmentBoxEvent : function(component, event, helper){
        
        var installmentIndex = event.getParam("installmentIndex");

        var installmentObjet = event.getParam("installmentObjet");
        // var installmentJson = JSON.parse(JSON.stringify(installmentObjet));
        var installmentJson = Object.assign({}, installmentObjet);
        
        var isEditInstallment = event.getParam("isEditInstallment");
        var isDeleteInstallment = event.getParam("isDeleteInstallment");

        var expenseList = component.get("v.expenseList");
        // var newExpenseList = JSON.parse(JSON.stringify(expenseList));
        var newExpenseList = expenseList;
        debugger;


        if (isEditInstallment) {

            newExpenseList.forEach((eachNewExpense, exIndex) => {
                
                if(!eachNewExpense.isToDeleteRecord && eachNewExpense.isLeaseHoldDisableINstallment && (eachNewExpense.isLEASEHOLDSUMMARY || eachNewExpense.isLEASEHOLD)){
                    
                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        if (!eachInstallment.isToDeleteRecord && parseFloat(eachInstallment.InstallmentNumber) == parseFloat(installmentIndex)) {
                            eachInstallment.PaymentDueDate = installmentJson.PaymentDueDate;
                            eachInstallment.remark = installmentJson.remark;
                        }
                    });   
                }
            });

            component.set("v.expenseList",newExpenseList);

        }else if (isDeleteInstallment) {
            debugger;
            newExpenseList.forEach((eachNewExpense, exIndex) => {
                debugger;
                if(!eachNewExpense.isToDeleteRecord && eachNewExpense.isLeaseHoldDisableINstallment && (eachNewExpense.isLEASEHOLDSUMMARY || eachNewExpense.isLEASEHOLD)){
                    
                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        debugger;
                        if (!eachInstallment.isToDeleteRecord && parseFloat(eachInstallment.InstallmentNumber) == parseFloat(installmentIndex)) {
                            eachInstallment.isToDeleteRecord = true;
                            eachNewExpense.NumberOfInstallment =  parseFloat(eachNewExpense.NumberOfInstallment) -1;
                        }else if(!eachInstallment.isToDeleteRecord && parseFloat(eachInstallment.InstallmentNumber) > parseFloat(installmentIndex)){
                            let oldInstallmentNumber = parseFloat(eachInstallment.InstallmentNumber);
                            oldInstallmentNumber--; 
                            eachInstallment.InstallmentNumber = oldInstallmentNumber;
                        }
                    });

                    helper.calculateInstallmentHelper(component, event, eachNewExpense);   
                }
            });

            debugger;
            var totalINstallmentAmount = new Map();
            newExpenseList.forEach((eachNewExpense, exIndex) => {
                debugger;
                if(!eachNewExpense.isToDeleteRecord && (eachNewExpense.isLEASEHOLD)){
                    
                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        if (!eachInstallment.isToDeleteRecord){
                            if (totalINstallmentAmount.has(parseFloat(eachInstallment.InstallmentNumber))) {
                                let installmentAmount = totalINstallmentAmount.get(parseFloat(eachInstallment.InstallmentNumber));
                                installmentAmount += helper.roundDecimal(parseFloat(eachInstallment.InstallmentAmount)); 
                                totalINstallmentAmount.set(parseFloat(eachInstallment.InstallmentNumber),parseFloat(installmentAmount));    
                            }else{
                                totalINstallmentAmount.set(parseFloat(eachInstallment.InstallmentNumber),helper.roundDecimal(parseFloat(eachInstallment.InstallmentAmount)));    
                            }
                        }
                        
                    });
                }
            });

            debugger;

            newExpenseList.forEach((eachNewExpense, exIndex) => {
                if(!eachNewExpense.isToDeleteRecord && (eachNewExpense.isLEASEHOLDSUMMARY)){
                    var totalInstallment = 0;

                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        if (!eachInstallment.isToDeleteRecord){
                            eachInstallment.InstallmentAmount = helper.roundDecimal(totalINstallmentAmount.get(parseFloat(eachInstallment.InstallmentNumber))); 
                            totalInstallment += helper.roundDecimal(parseFloat(eachInstallment.InstallmentAmount));
                        }
                    });   

                    eachNewExpense.TotalInstallment = totalInstallment;
                }
            });

            component.set("v.expenseList",newExpenseList);
        }
    },
    handleInstallmentAmountEvent : function(component, event, helper){
        var installmentIndex = event.getParam("installmentIndex");

        var installmentObjet = event.getParam("installmentObjet");
        var installmentJson = JSON.parse(JSON.stringify(installmentObjet));
        
        var isEditInstallment = event.getParam("isEditInstallment");
        var isDeleteInstallment = event.getParam("isDeleteInstallment");

        var expenseList = component.get("v.expenseList");
        var newExpenseList = JSON.parse(JSON.stringify(expenseList));
        

        debugger;
        if (isEditInstallment) {
            var totalINstallmentAmount = new Map();
            newExpenseList.forEach((eachNewExpense, exIndex) => {

                if(!eachNewExpense.isToDeleteRecord && (eachNewExpense.isLEASEHOLD)){

                    var totalInstallment = 0;
                    
                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        if(!eachInstallment.isToDeleteRecord){

                            if (totalINstallmentAmount.has(parseFloat(eachInstallment.InstallmentNumber))) {
                                let installmentAmount = totalINstallmentAmount.get(parseFloat(eachInstallment.InstallmentNumber));
                                installmentAmount += parseFloat(eachInstallment.InstallmentAmount); 
                                totalINstallmentAmount.set(parseFloat(eachInstallment.InstallmentNumber),parseFloat(installmentAmount));    
                            }else{
                                totalINstallmentAmount.set(parseFloat(eachInstallment.InstallmentNumber),parseFloat(eachInstallment.InstallmentAmount));    
                            }

                            totalInstallment+= parseFloat(eachInstallment.InstallmentAmount);
                        }
                        
                    });

                    eachNewExpense.TotalInstallment = totalInstallment;

                    var totalPrice = 0;
                    var totalsummary = 0;
                    eachNewExpense.leaseHoldInfo.forEach((eachLeaseHoldFloor, lshFloorIndex) => {
                        eachLeaseHoldFloor.totalAmount = helper.roundDecimal(parseFloat(eachLeaseHoldFloor.area) * parseFloat(eachLeaseHoldFloor.price)); 
                        totalPrice += eachLeaseHoldFloor.price;
                        totalsummary += eachLeaseHoldFloor.totalAmount;
                    });

                    eachNewExpense.leaseHoldTotalPrice = totalPrice;
                    eachNewExpense.TotalAmount = totalsummary;
                }
            });

            newExpenseList.forEach((eachNewExpense, exIndex) => {
                if(!eachNewExpense.isToDeleteRecord && (eachNewExpense.isLEASEHOLDSUMMARY)){
                    var totalInstallment = 0;

                    eachNewExpense.InstallmentList.forEach((eachInstallment, instIndex) => {
                        if(!eachInstallment.isToDeleteRecord){
                            eachInstallment.InstallmentAmount = totalINstallmentAmount.get(parseFloat(eachInstallment.InstallmentNumber)); 
                            totalInstallment += parseFloat(eachInstallment.InstallmentAmount);
                        }
                    });   

                    eachNewExpense.TotalInstallment = totalInstallment;
                }
            });

            component.set("v.expenseList",newExpenseList);

        }
    }

})