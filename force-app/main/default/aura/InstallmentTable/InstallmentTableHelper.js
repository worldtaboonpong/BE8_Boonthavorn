({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    removeInstallmentHelper : function(component, event){
    	var installmentList = component.get("v.installmentList");
        var newInstallmentList = [...installmentList];

    	var indexPosition = event.target.name;
        console.log("Delete Row ",indexPosition);

        // newInstallmentList.splice(indexPosition, 1);
        newInstallmentList[indexPosition].isToDeleteRecord = true;

        var index = 0;
        newInstallmentList = newInstallmentList.map(function(rowData) {
            
            if (rowData.isToDeleteRecord != true) {
                index++;
                rowData.InstallmentNumber = index;
            }

            return rowData;
        });

        installmentList = newInstallmentList
        component.set("v.NumberOfInstallment", index);            
        component.set("v.installmentList", installmentList);
        this.calculateInstallmentHelper(component, event);
    },

    changeInstallmentHelper : function(component, event){
    	var installmentList = component.get("v.installmentList");
        var newInstallmentList = [...installmentList];
        var numberOfInstallment = component.get("v.NumberOfInstallment");
        var totalPrice = parseFloat(component.get("v.TotalPrice"));
        var totalInstallment = 0;

        newInstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);
        newInstallmentList.forEach((rowData, index) => {
            debugger;
            
            if (!rowData.isToDeleteRecord) {

                if (parseFloat(rowData.InstallmentNumber) == numberOfInstallment){
                    rowData.InstallmentAmount = totalPrice - totalInstallment;
                    rowData.InstallmentAmount = this.roundDecimal(rowData.InstallmentAmount);

                    if (rowData.InstallmentAmount <= 0) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "warning",
                            "title": "Warning!",
                            "message": "Last Installment should more than 0."
                        });
                        toastEvent.fire();
                    }
                }

                totalInstallment += (rowData.InstallmentAmount)?this.roundDecimal(parseFloat(rowData.InstallmentAmount)):0;
            }
        });

        component.set("v.installmentList",newInstallmentList);
        component.set("v.totalInstallment", this.roundDecimal(totalInstallment));
    },
    onblurChangeInstallmentHelper : function(component, event){
        var installmentList = component.get("v.installmentList");
        var newInstallmentList = [...installmentList];
        var numberOfInstallment = component.get("v.NumberOfInstallment");
        var totalPrice = parseFloat(component.get("v.TotalPrice"));
        var totalInstallment = 0;

        newInstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);
        newInstallmentList.forEach((rowData, index) => {
            debugger;
            
            if (!rowData.isToDeleteRecord) {

                if(!rowData.InstallmentAmount){
                    rowData.InstallmentAmount = 0;
                }

                if (parseFloat(rowData.InstallmentNumber) == numberOfInstallment){
                    rowData.InstallmentAmount = totalPrice - totalInstallment;
                    rowData.InstallmentAmount = this.roundDecimal(rowData.InstallmentAmount);
                }

                totalInstallment += (rowData.InstallmentAmount)?this.roundDecimal(parseFloat(rowData.InstallmentAmount)):0;
            }
        });

        component.set("v.installmentList",newInstallmentList);
        component.set("v.totalInstallment", this.roundDecimal(totalInstallment));
        this.onBlurForInstallmentAmountEventHelper(component, event);
    },

    calculateInstallmentHelper : function(component, event){
        var installmentList = component.get("v.installmentList");
        var numberOfInstallment = component.get("v.NumberOfInstallment");
        var newInstallmentList = [...installmentList];

        var totalPrice = parseFloat(component.get("v.TotalPrice"));
        var totalInstallmentPrice = 0;
        var installmentAmount = 0;
        debugger;

        if (newInstallmentList) {

            newInstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);

            newInstallmentList.forEach((installmentRowData, index) => {

                if (!installmentRowData.isToDeleteRecord) {

                  installmentAmount =  parseFloat(totalPrice) / parseFloat(numberOfInstallment);

                  if (parseFloat(installmentRowData.InstallmentNumber) == numberOfInstallment) {

                    if ((installmentAmount%1)>0) {
                        installmentAmount = parseFloat(totalPrice) - parseFloat(totalInstallmentPrice);
                        installmentRowData.InstallmentAmount = (this.roundDecimal(installmentAmount));
                    }else{
                        installmentRowData.InstallmentAmount = (this.roundDecimal(installmentAmount));    
                    }
                    
                  }else{
                    installmentRowData.InstallmentAmount = (this.roundDecimal(installmentAmount));
                  }

                  totalInstallmentPrice += parseFloat(installmentRowData.InstallmentAmount);
                }
            });

            console.log("newInstallmentList ", JSON.stringify(newInstallmentList))
            component.set("v.installmentList",newInstallmentList);
            component.set("v.totalInstallment", this.roundDecimal(totalInstallmentPrice));
        }

        
    },
    onBlurForInstallmentBoxEventHelper: function(component, event){
        debugger;
        var installmentList = component.get("v.installmentList");
        var installmentIndex = event.getSource().get("v.name");

        var isLeaseHold = component.get('v.isLeaseHold');
        var installmentForEvent = Object.assign({}, installmentList[installmentIndex]);

        if (isLeaseHold) {
            var compEvent = component.getEvent("leaseHoldInstallmentEvent");
            compEvent.setParams({
                "installmentIndex" : installmentForEvent.InstallmentNumber,
                "installmentObjet" : installmentForEvent,
                "isEditInstallment" : true,
                "isDeleteInstallment" : false
            });
            compEvent.fire();
        }

    },
    onBlurForInstallmentAmountEventHelper: function(component, event){
        var installmentList = component.get("v.installmentList");
        var installmentIndex = event.getSource().get("v.name");

        var isLeaseHold = component.get('v.isLeaseHold');
        var installmentForEvent = Object.assign({}, installmentList[installmentIndex]);

        if (isLeaseHold) {
            var compEvent = component.getEvent("leaseHoldInstallmentAmountEvent");
            compEvent.setParams({
                "installmentIndex" : installmentForEvent.InstallmentNumber,
                "installmentObjet" : installmentForEvent,
                "isEditInstallment" : true,
                "isDeleteInstallment" : false
            });
            compEvent.fire();
        }

    },
    onRemoveForInstallmentBoxEventHelper: function(component, event){
        var installmentList = component.get("v.installmentList");
        var installmentIndex = event.target.name;

        var isLeaseHold = component.get('v.isLeaseHold');
        var installmentForEvent = Object.assign({}, installmentList[installmentIndex]);

        if (isLeaseHold) {
            var compEvent = component.getEvent("leaseHoldInstallmentEvent");
            compEvent.setParams({
                "installmentIndex" : installmentForEvent.InstallmentNumber,
                "installmentObjet" : installmentForEvent,
                "isEditInstallment" : false,
                "isDeleteInstallment" : true
            });
            compEvent.fire();
        }

    }
})