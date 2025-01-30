({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    addInstallmentHelper : function(component, event) {
    	var eachExpense = component.get("v.eachExpense");
        var newEachPeriod = Object.assign({}, eachExpense);


        var action = component.get("c.getNewInstallmentJson");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedData = response.getReturnValue();

                var newInstallment =  JSON.parse(returnedData);
                var newInstallmentForLeaseHold = Object.assign({}, newInstallment);
                newEachPeriod.InstallmentList.push(newInstallment);   
                
                var index = 0;
                newEachPeriod.InstallmentList = newEachPeriod.InstallmentList.map(function(rowData) {
                    if(!rowData.isToDeleteRecord){
                        index++;
                        rowData.InstallmentNumber = index;
                    }

                    return rowData;
                });
                newEachPeriod.NumberOfInstallment = index;
                console.log('Return Installment', returnedData);
                console.log('Return eachExpense', JSON.stringify(newEachPeriod));
                component.set("v.eachExpense", newEachPeriod);
                this.calculateInstallmentHelper(component, event);
                this.handleChangeExenseInstallment(component, event, returnedData);
                
            }
        });

        $A.enqueueAction(action);

        // var newInstallment = {InstallmentNumber: "", InstallmentAmount : 0, PaymentDueDate : ''};


    },

    calculateInstallmentHelper : function(component, event){
        var eachExpense = component.get("v.eachExpense");
        var newEachPeriod = Object.assign({}, eachExpense);

        var numberOfInstallment = (newEachPeriod.NumberOfInstallment)?parseFloat(newEachPeriod.NumberOfInstallment):0;
        var totalPrice =(newEachPeriod.TotalAmount)?parseFloat(newEachPeriod.TotalAmount):0;
        var totalInstallmentPrice = 0;
        var installmentAmount = 0;

        // InstallmentNumber
        debugger;
        if (newEachPeriod.InstallmentList) {

            newEachPeriod.InstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);
            
            newEachPeriod.InstallmentList.forEach((installmentRowData, index) =>  {
                debugger;
                if (!installmentRowData.isToDeleteRecord) {
                      installmentAmount = parseFloat(totalPrice) / parseFloat(numberOfInstallment);

                      if (parseFloat(installmentRowData.InstallmentNumber) == newEachPeriod.NumberOfInstallment) {

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

            newEachPeriod.TotalInstallment = (this.roundDecimal(totalInstallmentPrice));

            console.log("newEachPeriod ", JSON.stringify(newEachPeriod))
            component.set("v.eachExpense",newEachPeriod);
            component.set("v.totalInstallment", totalPrice);
        }

        
    },
    handleChangeExenseInstallment : function(component, event, newInstallment){
        var compEvent = component.getEvent("expenseObjectInstallmentEvent");
        compEvent.setParams({
            "eachExpense" : component.get("v.eachExpense"),
            "expenseIndex" : component.get("v.expenseIndex"),
            "InstallmentObject" : newInstallment
        });
        compEvent.fire();
    },

    handleChangeExenseObject : function(component, event) {
        var compEvent = component.getEvent("expenseObjectEvent");
        compEvent.setParams({
            "eachExpense" : component.get("v.eachExpense"),
            "expenseIndex" : component.get("v.expenseIndex")
        });
        compEvent.fire();
    },

    handleChangeExpenseType : function(component, event) {
        var compEvent = component.getEvent("expenseObjectTypeEvent");
        compEvent.setParams({
            "eachExpense" : component.get("v.eachExpense"),
            "expenseIndex" : component.get("v.expenseIndex"),
        });
        compEvent.fire();
    },

    handleChangeLeaseFloorPrice : function(component, event, newExpense) {
        var compEvent = component.getEvent("expenseObjectLeaseFloorEvent");
        compEvent.setParams({
            "eachExpense" : JSON.parse(JSON.stringify(newExpense)),
            "expenseIndex" : component.get("v.expenseIndex"),
        });
        compEvent.fire();
    },
    changeLeaseHoldPriceHelper : function(component, event){

        var eachExpense = component.get("v.eachExpense");
        var newEachExpense = Object.assign({}, eachExpense);
        var leaseHoldFloorIndex = event.getSource().get("v.name");

        if(newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].price){
            newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].totalAmount = this.roundDecimal(parseFloat(newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].price) * parseFloat(newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].area));
        }

        var totalPrice = 0;
        var summaryTotalPrice = 0;
        newEachExpense.leaseHoldInfo.forEach((eachLeaseHold, index) => {
            totalPrice += parseFloat(eachLeaseHold.price);
            summaryTotalPrice += eachLeaseHold.totalAmount;
        });

        newEachExpense.leaseHoldTotalPrice = totalPrice;
        newEachExpense.TotalAmount = summaryTotalPrice;

        component.set("v.eachExpense",newEachExpense);
        this.calculateInstallmentHelper(component, event);
        this.handleChangeLeaseFloorPrice(component, event, newEachExpense);
    },
    onBlurLeaseHoldPriceHelper : function(component, event, helper){
        var eachExpense = component.get("v.eachExpense");
        var newEachExpense = Object.assign({}, eachExpense);
        var leaseHoldFloorIndex = event.getSource().get("v.name");

        if(newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].price){
            newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].totalAmount = this.roundDecimal(parseFloat(newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].price) * parseFloat(newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].area));
        }else{
            newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].totalAmount = 0;
            newEachExpense.leaseHoldInfo[leaseHoldFloorIndex].price = 0;
        }

        var totalPrice = 0;
        var summaryTotalPrice = 0;
        newEachExpense.leaseHoldInfo.forEach((eachLeaseHold, index) => {
            totalPrice += parseFloat(eachLeaseHold.price);
            summaryTotalPrice += eachLeaseHold.totalAmount;
        });

        newEachExpense.leaseHoldTotalPrice = totalPrice;
        newEachExpense.TotalAmount = summaryTotalPrice;

        component.set("v.eachExpense",newEachExpense);
        this.calculateInstallmentHelper(component, event);
        this.handleChangeLeaseFloorPrice(component, event, newEachExpense);
    }
    // removeInstallmentHelper : function(component, event){
    // 	var eachExpense = component.get("v.eachExpense");
    //     var newInstallmentList = [...eachExpense.InstallmentList];

    // 	var indexPosition = event.target.name;
    //     console.log("Delete Row ",indexPosition);

    //     newInstallmentList.splice(indexPosition, 1);

    //     var index = 1;
    //     newInstallmentList = newInstallmentList.map(function(rowData) {
            
    //         rowData.InstallmentNumber = index;
    //         index++;

    //         return rowData;
    //     });

    //     eachExpense.InstallmentList = newInstallmentList
    //     eachExpense.NumberOfInstallment = newInstallmentList.length;
    //     component.set("v.eachExpense", eachExpense);
    // },

    // changeInstallmentHelper : function(component, event){
    // 	var eachExpense = component.get("v.eachExpense");
    //     var newInstallmentList = [...eachExpense.InstallmentList];
    //     var totalInstallment = 0;

    //     newInstallmentList = newInstallmentList.map(function(rowData) {
            
    //         totalInstallment += (rowData.InstallmentAmount)?parseFloat(rowData.InstallmentAmount):0;

    //         return rowData;
    //     });

    //     component.set("v.totalInstallment", totalInstallment);
    // }


})