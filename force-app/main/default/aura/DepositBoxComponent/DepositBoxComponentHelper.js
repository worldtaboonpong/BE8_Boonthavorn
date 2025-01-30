({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    addInstallmentHelper : function(component, event) {
        var eachOtherDeposit = component.get("v.eachOtherDeposit");
        var newInstallmentList = [...eachOtherDeposit.InstallmentList];

        var action = component.get("c.getNewInstallmentJson");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedData = response.getReturnValue();
                console.log('Return Installment', returnedData);

                var newInstallment =  JSON.parse(returnedData);
                newInstallmentList.push(newInstallment);   
                
                var index = 0;
                newInstallmentList = newInstallmentList.map(function(rowData) {
                    if (!rowData.isToDeleteRecord) {
                        index++;
                        rowData.InstallmentNumber = index;
                    }

                    return rowData;
                });
                
                eachOtherDeposit.InstallmentList = newInstallmentList;
                eachOtherDeposit.NumberOfInstallment = index;
                component.set("v.eachOtherDeposit", eachOtherDeposit);
                this.calculateInstallmentHelper(component, event);
                this.handleChangeOtherDepositObject(component, event);
                
            }
        });

        $A.enqueueAction(action);
        // var newInstallment = {InstallmentNumber: "", InstallmentAmount : 0, PaymentDueDate : ''};


    },

    calculateInstallmentHelper : function(component, event){
        var eachOtherDeposit = component.get("v.eachOtherDeposit");
        var newEachPeriod = Object.assign({}, eachOtherDeposit);

        var numberOfInstallment = (newEachPeriod.NumberOfInstallment)?parseFloat(newEachPeriod.NumberOfInstallment):0;
        var totalPrice =(newEachPeriod.TotalAmount)?parseFloat(newEachPeriod.TotalAmount):0;
        var totalInstallmentPrice = 0;
        let installmentAmount = 0;

        newEachPeriod.InstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);

        newEachPeriod.InstallmentList.forEach((installmentRowData, index) => {
              if (!installmentRowData.isToDeleteRecord) {
                installmentAmount = parseFloat(totalPrice) / parseFloat(numberOfInstallment);
                  
                  if (parseFloat(installmentRowData.InstallmentNumber) == numberOfInstallment) {

                    if ((installmentAmount%1)>0) {
                        installmentAmount = parseFloat(totalPrice) - parseFloat(totalInstallmentPrice);
                        installmentRowData.InstallmentAmount = this.roundDecimal(installmentAmount);
                    }else{
                        installmentRowData.InstallmentAmount = this.roundDecimal(installmentAmount);    
                    }

                  }else{
                    installmentRowData.InstallmentAmount = this.roundDecimal(installmentAmount);
                  }
              }

              totalInstallmentPrice += parseFloat(installmentRowData.InstallmentAmount);
        });

        newEachPeriod.TotalInstallment = this.roundDecimal(totalInstallmentPrice);   

        console.log("newEachPeriod ", newEachPeriod)
        component.set("v.eachOtherDeposit",newEachPeriod);
        component.set("v.totalInstallment", totalPrice);
        
    },

    handleChangeOtherDepositObject : function(component, event) {
        var compEvent = component.getEvent("otherDepositObjectEvent");
        compEvent.setParams({
            "eachOtherDeposit" : component.get("v.eachOtherDeposit"),
            "OtherDepositIndex" : component.get("v.OtherDepositIndex")
        });
        compEvent.fire();
    }
})