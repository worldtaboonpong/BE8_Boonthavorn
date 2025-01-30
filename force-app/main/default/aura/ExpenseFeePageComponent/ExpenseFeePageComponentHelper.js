({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    addExpenseHelper : function(component, event) {
        debugger;
    	var expenseList = component.get("v.expenseList");
        var newExpenseList = [];
        if (expenseList) {
            newExpenseList = [...expenseList];
        }
        var optionList = component.get('v.expenseDepositTypeOption');

        var action = component.get("c.getNewExpenseINstallmentJson");
     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                var returnedData = response.getReturnValue();
                console.log('Return Expense JSON', returnedData);

                var newExpense =  JSON.parse(returnedData);
                
                newExpenseList.push(newExpense);   
                
                expenseList = newExpenseList;
                component.set("v.expenseList", expenseList);
                
                console.log("expenseList" + JSON.stringify(expenseList));
            }
        });
 
        $A.enqueueAction(action);

        // var newExpense = {
        //         Type: "constructionFee",
        //         TotalAmount: 0,
        //         NumberOfInstallment : 0,
        //         Remark : "",
        //         InstallmentList : []
        //     };

    },
    removePeriodHelper : function(component, event){
    	var expenseList = component.get("v.expenseList");
        var oppObject = component.get("v.oppObject");
        var newExpenseList = [...expenseList];

    	var indexPosition = event.target.name;
        indexPosition = parseInt(indexPosition);
        console.log("Delete Row ",indexPosition);

        newExpenseList = JSON.parse(JSON.stringify(newExpenseList));

        if (oppObject.spetialOtherTypePicklist.includes(newExpenseList[indexPosition].Type) && newExpenseList[indexPosition].isLEASEHOLD){

            // var numberOfLeaseHoldExpense = 0;

            newExpenseList.forEach((eachOldExpense, index) => {
                if(!eachOldExpense.isToDeleteRecord && (eachOldExpense.isLEASEHOLD || eachOldExpense.isLEASEHOLDSUMMARY)){
                    eachOldExpense.isToDeleteRecord = true; 
                }
            });

            expenseList = newExpenseList;
            
            component.set("v.expenseList", expenseList);

            // if (numberOfLeaseHoldExpense > 1) {
                
            //     if(!newExpenseList[indexPosition].isLeaseHoldDisableINstallment){
            //         newExpenseList[indexPosition].isToDeleteRecord = true;

            //         var skipLoop = false;
            //         newExpenseList.forEach((eachNewExpense, index) => {
                    
            //             if(!eachNewExpense.isToDeleteRecord && index > indexPosition && !skipLoop){
            //                 eachNewExpense.isLeaseHoldDisableINstallment = false;
            //                 skipLoop = true;
            //             }

            //         });

            //     }else{
            //         newExpenseList[indexPosition].isToDeleteRecord = true;
            //     }

            //     var summaryLeaseHoldTotalAmount = 0;
            //     newExpenseList.forEach((eachNewExpense, index) => {
                    
            //         if(!eachNewExpense.isToDeleteRecord){
            //             if (eachNewExpense.isLEASEHOLD) {
            //                 summaryLeaseHoldTotalAmount += eachNewExpense.TotalAmount;
            //             }
            //         }

            //     });

            //     newExpenseList.forEach((eachNewExpense, index) => {
            //         if(!eachNewExpense.isToDeleteRecord){
            //             if (eachNewExpense.isLEASEHOLDSUMMARY) {
            //                 eachNewExpense.TotalAmount = summaryLeaseHoldTotalAmount;
            //                 this.calculateInstallmentHelper(component, event, eachNewExpense);
            //             }
            //         }

            //     });

            //     // expenseList = newExpenseList;
            //     component.set("v.expenseList", newExpenseList);
                
            // }else{
            //     newExpenseList[indexPosition].isToDeleteRecord = true;
            //     newExpenseList.forEach((eachOldExpense, index) => {
            //         if(!eachOldExpense.isToDeleteRecord && eachOldExpense.isLEASEHOLDSUMMARY){
            //             eachOldExpense.isToDeleteRecord = true;
            //         }
            //     });
            //     expenseList = newExpenseList;
            //     debugger;
            //     component.set("v.expenseList", newExpenseList);
            // }

        }else{
            newExpenseList[indexPosition].isToDeleteRecord = true;
            expenseList = newExpenseList;
            
            component.set("v.expenseList", expenseList);
        }

        // newExpenseList.splice(indexPosition, 1);
    },
    calculateInstallmentHelper : function(component, event, newEachPeriod){

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

                      if (parseFloat(installmentRowData.InstallmentNumber) == parseFloat(newEachPeriod.NumberOfInstallment)) {

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


        }
        
    },
})