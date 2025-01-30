({
    removeInstallment : function(component, event, helper){

        var oppDetail = component.get("v.oppObject");

        if(oppDetail.popupSetting["การลบ Installment"].Enable__c){

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
                                helper.removeInstallmentHelper(component, event);
                                component.set("v.isChangeExpense",true);
                                component.set("v.isChangeDeposit",true);

                                helper.onRemoveForInstallmentBoxEventHelper(component, event);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
        	helper.removeInstallmentHelper(component, event);
            component.set("v.isChangeExpense",true);
            component.set("v.isChangeDeposit",true);

            helper.onRemoveForInstallmentBoxEventHelper(component, event);
       }


    },
    changeInstallmentHandler : function(component, event, helper){
    	helper.changeInstallmentHelper(component, event);
        component.set("v.isChangeExpense",true);
        component.set("v.isChangeDeposit",true);
    },
    onblurchangeInstallmentHandler : function(component, event, helper){
        helper.onblurChangeInstallmentHelper(component, event);
    },
    onChangeExpense : function(component, event, helper){
        component.set("v.isChangeExpense",true);
        component.set("v.isChangeDeposit",true);

        helper.onBlurForInstallmentBoxEventHelper(component, event);
    },
    onChangeDatePeriod: function(component, event, helper){
        
        var installmentList = component.get("v.installmentList");
        var installmentIndex = event.getSource().get("v.name");

        installmentList[installmentIndex].isEditRecord = true;


        component.set("v.installmentList",installmentList);
        component.set("v.isChangeExpense",true);
        component.set("v.isChangeDeposit",true);



    },
    onBlurForInstallmentBoxEvent: function(component, event, helper){
        helper.onBlurForInstallmentBoxEventHelper(component, event);
    }
})