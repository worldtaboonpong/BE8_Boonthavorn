({
    init : function(component, event, helper) {
        var otherExpenseObject = component.get("v.otherPageObject");
        debugger;
        var newOtherDepsit = Object.assign({}, otherExpenseObject);
        var picklistOption = component.get("v.expenseDepositSubTypeOption");
        var disabledPriceKey = component.get("v.disabledPriceKey");
        var disabledTotalKey = component.get("v.disabledTotaleKey");
        var oppDetail = component.get("v.oppObject");
        component.set("v.isChangeOtherExpense", true);

        newOtherDepsit.rateAndAreaFormatList = newOtherDepsit.rateAndAreaFormatList.map(function(rowData) {
            if (disabledPriceKey.includes(rowData.SubType)) {
                rowData.isDisabledRateAndArea = true;
            }
            if (disabledTotalKey.includes(rowData.SubType)) {
                rowData.isDisabledTotal = true;
            }
            if(rowData.SubType == "Actual" || rowData.SubType == "Additional") {
                if(rowData.Type == "Electric") {
                    rowData.Rate = oppDetail.defaultElectricity;
                } else if(rowData.Type == "Water") {
                    rowData.Rate = oppDetail.defaultWater;
                } else if(rowData.Type == "Gas") {
                    rowData.Rate = oppDetail.defaultGas;
                }
            }
            return rowData;
        });
        component.set("v.otherPageObject", newOtherDepsit);
    },
    addOtherExpense : function(component, event, helper){
      component.set("v.isChangeOtherExpense",true);
        helper.addOtherExpenseHelper(component, event);
    },
    removeRateAndArea : function(component, event, helper) {
       var oppDetail = component.get("v.oppObject");

       if(oppDetail.popupSetting["การลบ Expense and Fee"].Enable__c){

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
                                component.set("v.isChangeOtherExpense",true);

                               var otherExpenseObject = component.get("v.otherPageObject");
                               var newOtherDepsit = Object.assign({}, otherExpenseObject);
                               var indexPosition = parseInt(event.target.name);
                               console.log("Delete Row ",indexPosition);

                               newOtherDepsit.rateAndAreaFormatList[indexPosition].isToDeleteRecord = true;
                               component.set("v.otherPageObject.rateAndAreaFormatList", newOtherDepsit.rateAndAreaFormatList);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
           component.set("v.isChangeOtherExpense",true);

           var otherExpenseObject = component.get("v.otherPageObject");
           var newOtherDepsit = Object.assign({}, otherExpenseObject);
           var indexPosition = parseInt(event.target.name);
           console.log("Delete Row ",indexPosition);

           newOtherDepsit.rateAndAreaFormatList[indexPosition].isToDeleteRecord = true;
           component.set("v.otherPageObject.rateAndAreaFormatList", newOtherDepsit.rateAndAreaFormatList);
       }


    },
    removeFixedFormat : function(component, event, helper) {
       var oppDetail = component.get("v.oppObject");
       if(oppDetail.popupSetting["การลบ Expense and Fee"].Enable__c){

           var modalBody;
           var modalFooter;
            $A.createComponents([
                ["c:ConfirmPopup",{}],
                ["c:onfirmPopupFooter",{isConfirmRemove : component.getReference("v.isConfirmRemove")}]
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
                                component.set("v.isChangeOtherExpense",true);
                               var otherExpenseObject = component.get("v.otherPageObject");
                               var newOtherDepsit = Object.assign({}, otherExpenseObject);
                               var indexPosition = parseInt(event.target.name);
                               console.log("Delete Row ",indexPosition);

                               debugger;

                               newOtherDepsit.fixedFormatList[indexPosition].isToDeleteRecord = true;
                               component.set("v.otherPageObject.fixedFormatList", newOtherDepsit.fixedFormatList);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
           component.set("v.isChangeOtherExpense",true);
           var otherExpenseObject = component.get("v.otherPageObject");
           var newOtherDepsit = Object.assign({}, otherExpenseObject);
           var indexPosition = parseInt(event.target.name);
           console.log("Delete Row ",indexPosition);

           debugger;

           newOtherDepsit.fixedFormatList[indexPosition].isToDeleteRecord = true;
           component.set("v.otherPageObject.fixedFormatList", newOtherDepsit.fixedFormatList);
       }

    },
    calculatePrice : function(component, event, helper) {
        var otherExpenseObject = component.get("v.otherPageObject");
        var newOtherDepsit = Object.assign({}, otherExpenseObject);
        component.set("v.isChangeOtherExpense", true);
        var inputSection = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));

        var totalPrice = 0;
        if (newOtherDepsit.rateAndAreaFormatList[inputSection].SubType === "Additional"){
            totalPrice = parseFloat(newOtherDepsit.rateAndAreaFormatList[inputSection].Area) * parseFloat(newOtherDepsit.rateAndAreaFormatList[inputSection].Rate);
            newOtherDepsit.rateAndAreaFormatList[inputSection].Total = (totalPrice)?helper.roundDecimal(totalPrice):0;
        }
        console.log(newOtherDepsit);
        component.set("v.otherPageObject", newOtherDepsit);

    },

    OnblurRate : function(component, event, helper){
        var otherExpenseObject = component.get("v.otherPageObject");
        var newOtherDepsit = Object.assign({}, otherExpenseObject);
        component.set("v.isChangeOtherExpense", true);
        var inputSection = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));

        newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = (newOtherDepsit.rateAndAreaFormatList[inputSection].Rate)?newOtherDepsit.rateAndAreaFormatList[inputSection].Rate:0;
        component.set("v.otherPageObject", newOtherDepsit);
    },

    OnblurArea : function(component, event, helper){
        var otherExpenseObject = component.get("v.otherPageObject");
        var newOtherDepsit = Object.assign({}, otherExpenseObject);
        component.set("v.isChangeOtherExpense", true);
        var inputSection = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));

        newOtherDepsit.rateAndAreaFormatList[inputSection].Area = (newOtherDepsit.rateAndAreaFormatList[inputSection].Area)?newOtherDepsit.rateAndAreaFormatList[inputSection].Area:0;
        component.set("v.otherPageObject", newOtherDepsit);
    },

    OnblurFixedMonthly : function(component, event, helper){
        var otherExpenseObject = component.get("v.otherPageObject");
        var newOtherDepsit = Object.assign({}, otherExpenseObject);
        component.set("v.isChangeOtherExpense", true);
        var inputSection = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));

        newOtherDepsit.fixedFormatList[inputSection].Monthly = (newOtherDepsit.fixedFormatList[inputSection].Monthly)?newOtherDepsit.fixedFormatList[inputSection].Monthly:0;
        component.set("v.otherPageObject", newOtherDepsit);
    },

    OnblurTotal : function(component, event, helper){
        var otherExpenseObject = component.get("v.otherPageObject");
        var newOtherDepsit = Object.assign({}, otherExpenseObject);
        component.set("v.isChangeOtherExpense", true);
        var inputSection = event.getSource().get("v.name");
        console.log(event.getSource().get("v.name"));

        newOtherDepsit.rateAndAreaFormatList[inputSection].Total = (newOtherDepsit.rateAndAreaFormatList[inputSection].Total)?newOtherDepsit.rateAndAreaFormatList[inputSection].Total:0;
        component.set("v.otherPageObject", newOtherDepsit);
    },

    handleChangeSubType: function(component, event, helper){
        var otherExpenseObject = component.get("v.otherPageObject");
        var newOtherDepsit = Object.assign({}, otherExpenseObject);
        component.set("v.isChangeOtherExpense", true);
        var disabledPriceKey = component.get("v.disabledPriceKey");
        var disabledRemarkKey = component.get("v.disabledRemarkKey");
        var disabledTotalKey = component.get("v.disabledTotaleKey");
        var inputSection = event.getSource().get("v.name");
        var oppDetail = component.get("v.oppObject");
        console.log(event.getSource().get("v.name"));

        if (disabledPriceKey.includes(newOtherDepsit.rateAndAreaFormatList[inputSection].SubType)) {
            newOtherDepsit.rateAndAreaFormatList[inputSection].isDisabledRateAndArea = true;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Area = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Total = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = 0;
        }else{
            newOtherDepsit.rateAndAreaFormatList[inputSection].isDisabledRateAndArea = false;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Area = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Total = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = 0;
        }

        if (disabledTotalKey.includes(newOtherDepsit.rateAndAreaFormatList[inputSection].SubType)) {
            newOtherDepsit.rateAndAreaFormatList[inputSection].isDisabledTotal = true;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Area = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Total = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = 0;
        }else{
            newOtherDepsit.rateAndAreaFormatList[inputSection].isDisabledTotal = false;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Area = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Total = 0;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = 0;
        }

        if(newOtherDepsit.rateAndAreaFormatList[inputSection].SubType == "Actual" || 
        newOtherDepsit.rateAndAreaFormatList[inputSection].SubType == "Additional") {
            if(newOtherDepsit.rateAndAreaFormatList[inputSection].Type == "Electric") {
                newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = oppDetail.defaultElectricity;
            } else if(newOtherDepsit.rateAndAreaFormatList[inputSection].Type == "Water") {
                newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = oppDetail.defaultWater;
            } else if(newOtherDepsit.rateAndAreaFormatList[inputSection].Type == "Gas") {
                newOtherDepsit.rateAndAreaFormatList[inputSection].Rate = oppDetail.defaultGas;
            }
        }

        if (disabledRemarkKey.includes(newOtherDepsit.rateAndAreaFormatList[inputSection].SubType)) {
            newOtherDepsit.rateAndAreaFormatList[inputSection].isDisabledRemark = true;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Remark = "";
        }else{
            newOtherDepsit.rateAndAreaFormatList[inputSection].isDisabledRemark = false;
            newOtherDepsit.rateAndAreaFormatList[inputSection].Remark = "";
        }

        console.log(newOtherDepsit);
        component.set("v.otherPageObject", newOtherDepsit);

    },
    onChangeInput : function(component, event, helper){
        component.set("v.isChangeOtherExpense", true);
    }
})