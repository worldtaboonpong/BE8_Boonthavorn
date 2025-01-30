({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
        //return Math.round((number) * 100) / 100;
    },
    resetInstallmentHelper : function(component, event){
        var depositObject = component.get("v.depositObject");
        var newInstallmentList = [...depositObject.DepositSummary.InstallmentList];

        newInstallmentList = newInstallmentList.map(function(rowData) {
            
            if (!rowData.isToDeleteRecord) {
                rowData.isToDeleteRecord = true;
            }
            return rowData;
        });

        this.addInstallmentHelper(component, event);

    },
    addInstallmentHelper : function(component, event) {
    	var depositObject = component.get("v.depositObject");
    	var newInstallmentList = [...depositObject.DepositSummary.InstallmentList];
        var oppDetail = component.get("v.oppObject");

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
                
                depositObject.DepositSummary.InstallmentList = newInstallmentList;
                depositObject.NumberOfInstallment = index;
                component.set("v.depositObject", depositObject);

                this.calculateInstallmentHelper(component, event);
                
            }
        });

        $A.enqueueAction(action);


        // var newInstallment = {
		      //                   InstallmentNumber: "",
		      //                   InstallmentAmount: 0,
		      //                   PaymentMethod: "cash",
		      //                   PaymentDueDate: ""

		      //               };


    },
    addOtherDepositHelper : function(component, event){
    	var depositObject = component.get("v.depositObject");
        var expenseDepositTypeOption = component.get("v.expenseDepositTypeOption");
    	var newOtherDepositList = [...depositObject.OtherDepositList];
    	var action = component.get("c.getNewOtherDepositJson");
     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedData = response.getReturnValue();
                console.log('Return Expense JSON', returnedData);
                debugger;

                var newOtherDeposit =  JSON.parse(returnedData);
                newOtherDeposit.Type = expenseDepositTypeOption[0].value;
                
				newOtherDepositList.push(newOtherDeposit);
				depositObject.OtherDepositList = newOtherDepositList;
				component.set("v.depositObject", depositObject);
            }
        });
 
        $A.enqueueAction(action);

    	// var newOtherDeposit = {
				 //                    Type : "furnitureDeposit",
				 //                    TotalAmount : 0,
				 //                    NumberOfInstallment: 0,
				 //                    Remark: "",
				 //                    InstllmentList: [
				 //                        {InstallmentNumber: "1", InstallmentAmount : 0, PaymentDueDate : ''},
				 //                        {InstallmentNumber: "2", InstallmentAmount : 0, PaymentDueDate : ''}
				 //                    ]
				 //                };

    },

    removeInstallmentHelper : function(component, event){
        var depositObject = component.get("v.depositObject");
        var newInstallmentList = [...depositObject.DepositSummary.InstallmentList];

        var indexPosition = event.target.name;
        console.log("Delete Row ",indexPosition);

        // newInstallmentList.splice(indexPosition, 1);
        newInstallmentList[indexPosition].isToDeleteRecord = true;

        var index = 0;
        newInstallmentList = newInstallmentList.map(function(rowData) {
            
            if (!rowData.isToDeleteRecord) {
                index++;
                rowData.InstallmentNumber = index;
            }

            return rowData;
        });

        depositObject.DepositSummary.InstallmentList = newInstallmentList
        depositObject.NumberOfInstallment = index;
        component.set("v.depositObject", depositObject);
        this.calculateInstallmentHelper(component, event);
    },

    removeOtherDepositHelper : function(component, event){
        var depositObject = component.get("v.depositObject");
        var newOtherDeposit = [...depositObject.OtherDepositList];

        var indexPosition = event.target.name;
        console.log("Delete Row ",indexPosition);

        // newOtherDeposit.splice(indexPosition, 1);
        newOtherDeposit[indexPosition].isToDeleteRecord = true;

        depositObject.OtherDepositList = newOtherDeposit
        component.set("v.depositObject", depositObject);
    },

    onblurchangeInstallmentHelper : function(component, event){
        var depositObject = component.get("v.depositObject");
        var oppDetail = component.get("v.oppObject");

        var indexPosition = event.getSource().get("v.name");
        console.log("Edit Row", indexPosition );
        var vatPercent = oppDetail.vatPercentValue;
        var newInstallmentList = [...depositObject.DepositSummary.InstallmentList];
        var totalInstallment = 0;
        var totalInstallment_WithVat = 0;
        var totalInstallment_Vat = 0;
        var totalRentPortion = 0;
        var totalServicePortion = 0;
        var totalCAMOrAirServicePortion = 0;


        debugger;
        var rentWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
        var serviceWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.service_Summary;
        var camOrAirServiceWithoutVat =  (!oppDetail.isNoCAM)?depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary:0;
        var depositTotalSummaryWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit;

        var rentPerent = (rentWithoutVat*100)/depositTotalSummaryWithoutVat;
        var servicePerent = (serviceWithoutVat*100)/depositTotalSummaryWithoutVat;
        var camOrAirservicePerent = (camOrAirServiceWithoutVat*100)/depositTotalSummaryWithoutVat;

        if (!newInstallmentList[indexPosition].InstallmentAmount) {
            newInstallmentList[indexPosition].InstallmentAmount = 0;
        }

        var installmentServiceProportion = parseFloat(newInstallmentList[indexPosition].InstallmentAmount) * (servicePerent/100);
        installmentServiceProportion = this.roundDecimal(installmentServiceProportion);

        var installmentCAMOrAirServiceProportion = parseFloat(newInstallmentList[indexPosition].InstallmentAmount) * (camOrAirservicePerent/100);
        installmentCAMOrAirServiceProportion = this.roundDecimal(installmentCAMOrAirServiceProportion);

        var installmentRentProportion = newInstallmentList[indexPosition].InstallmentAmount - (installmentServiceProportion + installmentCAMOrAirServiceProportion);
        installmentRentProportion = this.roundDecimal(installmentRentProportion);

        var installmentServiceProportionVat = this.roundDecimal(installmentServiceProportion * (vatPercent/100));
        var installmentRentProportionVat = (oppDetail.isWindowDisplay)?(this.roundDecimal(installmentRentProportion * (vatPercent/100))):0;
        var installmentCAMOrAirServiceProportionVat = this.roundDecimal(installmentCAMOrAirServiceProportion * (vatPercent/100));


        newInstallmentList[indexPosition].InstallmentAmountWithVat = installmentRentProportion + installmentServiceProportion + installmentCAMOrAirServiceProportion + installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
        newInstallmentList[indexPosition].InstallmentVAT = installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
        
        newInstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);
        newInstallmentList.forEach((rowData, index) => {
            debugger;
            
            if (!rowData.isToDeleteRecord) {
                
                if (parseFloat(rowData.InstallmentNumber) == depositObject.NumberOfInstallment){

                    installmentServiceProportion = depositObject.DepositSummary.DepositSummaryPricing.service_Summary - totalServicePortion;
                    installmentServiceProportion = this.roundDecimal(installmentServiceProportion);

                    installmentCAMOrAirServiceProportion = depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary - totalCAMOrAirServicePortion;
                    installmentCAMOrAirServiceProportion = this.roundDecimal(installmentCAMOrAirServiceProportion);

                    installmentRentProportion = depositObject.DepositSummary.DepositSummaryPricing.rent_Summary - totalRentPortion;
                    installmentRentProportion = this.roundDecimal(installmentRentProportion);
                    
                    rowData.InstallmentAmount = installmentServiceProportion + installmentCAMOrAirServiceProportion + installmentRentProportion;
                    rowData.InstallmentAmount = this.roundDecimal(rowData.InstallmentAmount);

                    installmentServiceProportionVat = this.roundDecimal(installmentServiceProportion * (vatPercent/100));
                    installmentRentProportionVat = (oppDetail.isWindowDisplay)?(this.roundDecimal(installmentRentProportion * (vatPercent/100))):0;
                    installmentCAMOrAirServiceProportionVat = this.roundDecimal(installmentCAMOrAirServiceProportion * (vatPercent/100));

                    rowData.InstallmentAmountWithVat = installmentRentProportion + installmentServiceProportion + installmentCAMOrAirServiceProportion +installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
                    rowData.InstallmentVAT = installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;

                    if (rowData.InstallmentAmount <= 0 && !oppDetail.isAllowChangeOptionToRenew) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "warning",
                            "title": "Warning!",
                            "message": "Last Installment should more than 0."
                        });
                        toastEvent.fire();
                    }
                }else{
                    totalRentPortion += rowData.InstallmentAmount - (this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (servicePerent/100)) + this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (camOrAirservicePerent/100)));
                    totalServicePortion += this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (servicePerent/100));
                    totalCAMOrAirServicePortion += this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (camOrAirservicePerent/100));
                }

                totalInstallment += (rowData.InstallmentAmount)?this.roundDecimal(parseFloat(rowData.InstallmentAmount)):0;
                totalInstallment_WithVat += (rowData.InstallmentAmountWithVat)?this.roundDecimal(parseFloat(rowData.InstallmentAmountWithVat)):0;
                totalInstallment_Vat += (rowData.InstallmentVAT)?this.roundDecimal(parseFloat(rowData.InstallmentVAT)):0;
            }
        });


        // newInstallmentList = newInstallmentList.map(function(rowData) {
        //     debugger;
        //     if (!rowData.isToDeleteRecord) {
        //         // if (parseFloat(rowData.InstallmentNumber) == parseFloat(depositObject.NumberOfInstallment)){
                    
        //         //     rowData.InstallmentAmountWithVat = parseFloat(depositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat) - totalInstallment_WithVat;
        //         //     rowData.InstallmentAmountWithVat = parseFloat(rowData.InstallmentAmountWithVat.toFixed(2));
                   
        //         //     totalInstallment_WithVat += (rowData.InstallmentAmountWithVat)?parseFloat(rowData.InstallmentAmountWithVat):0;
        //         // }else{
        //         // }
        //     }

        //     return rowData;
        // });


        depositObject.DepositSummary.TotalInstallment = this.roundDecimal(totalInstallment);
        depositObject.DepositSummary.TotalInstallment_WithVat = this.roundDecimal(totalInstallment_WithVat);
        depositObject.DepositSummary.TotalInstallment_VAT = this.roundDecimal(totalInstallment_Vat);
        component.set("v.depositObject",depositObject);
        component.set("v.totalInstallment", this.roundDecimal(totalInstallment));
    },

    changeInstallmentHelper : function(component, event){
        var depositObject = component.get("v.depositObject");
        var oppDetail = component.get("v.oppObject");

        var indexPosition = event.getSource().get("v.name");
        console.log("Edit Row", indexPosition );
        var vatPercent = oppDetail.vatPercentValue;
        var newInstallmentList = [...depositObject.DepositSummary.InstallmentList];
        var totalInstallment = 0;
        var totalInstallment_WithVat = 0;
        var totalInstallment_Vat = 0;
        var totalRentPortion = 0;
        var totalServicePortion = 0;
        var totalCAMOrAirServicePortion = 0;


        debugger;
        var rentWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
        var serviceWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.service_Summary;
        var camOrAirServiceWithoutVat =  (!oppDetail.isNoCAM)?depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary:0;
        var depositTotalSummaryWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit;

        var rentPerent = (rentWithoutVat*100)/depositTotalSummaryWithoutVat;
        var servicePerent = (serviceWithoutVat*100)/depositTotalSummaryWithoutVat;
        var camOrAirservicePerent = (camOrAirServiceWithoutVat*100)/depositTotalSummaryWithoutVat;

        var installmentServiceProportion = parseFloat(newInstallmentList[indexPosition].InstallmentAmount) * (servicePerent/100);
        installmentServiceProportion = this.roundDecimal(installmentServiceProportion);

        var installmentCAMOrAirServiceProportion = parseFloat(newInstallmentList[indexPosition].InstallmentAmount) * (camOrAirservicePerent/100);
        installmentCAMOrAirServiceProportion = this.roundDecimal(installmentCAMOrAirServiceProportion);

        // var installmentRentProportion = parseFloat(newInstallmentList[indexPosition].InstallmentAmount) * (rentPerent/100);
        var installmentRentProportion = newInstallmentList[indexPosition].InstallmentAmount - (installmentServiceProportion + installmentCAMOrAirServiceProportion);
        installmentRentProportion = this.roundDecimal(installmentRentProportion);

        var installmentServiceProportionVat = this.roundDecimal(installmentServiceProportion * (vatPercent/100));
        var installmentRentProportionVat = (oppDetail.isWindowDisplay)?(this.roundDecimal(installmentRentProportion * (vatPercent/100))):0;

        // var installmentServiceProportionWithVat = installmentServiceProportion + (installmentServiceProportion * (vatPercent/100));
        // installmentServiceProportionWithVat = this.roundDecimal(installmentServiceProportionWithVat);

        var installmentCAMOrAirServiceProportionVat = this.roundDecimal(installmentCAMOrAirServiceProportion * (vatPercent/100));
        // var installmentCAMOrAirServiceProportionWithVat = installmentCAMOrAirServiceProportion + (installmentCAMOrAirServiceProportion * (vatPercent/100));
        // installmentCAMOrAirServiceProportionWithVat = this.roundDecimal(installmentCAMOrAirServiceProportionWithVat);

        console.log('installmentServiceProportionVat' + installmentServiceProportionVat);
        console.log('installmentRentProportionVat' + installmentRentProportionVat);
        console.log('installmentCAMOrAirServiceProportionVat' + installmentCAMOrAirServiceProportionVat);


        newInstallmentList[indexPosition].InstallmentAmountWithVat = installmentRentProportion + installmentServiceProportion + installmentCAMOrAirServiceProportion + installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
        newInstallmentList[indexPosition].InstallmentVAT = installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
        
        newInstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);
        newInstallmentList.forEach((rowData, index) => {
            debugger;
            
            if (!rowData.isToDeleteRecord) {
                
                if (parseFloat(rowData.InstallmentNumber) == depositObject.NumberOfInstallment){

                    installmentServiceProportion = depositObject.DepositSummary.DepositSummaryPricing.service_Summary - totalServicePortion;
                    installmentServiceProportion = this.roundDecimal(installmentServiceProportion);

                    installmentCAMOrAirServiceProportion = depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary - totalCAMOrAirServicePortion;
                    installmentCAMOrAirServiceProportion = this.roundDecimal(installmentCAMOrAirServiceProportion);

                    installmentRentProportion = depositObject.DepositSummary.DepositSummaryPricing.rent_Summary - totalRentPortion;
                    installmentRentProportion = this.roundDecimal(installmentRentProportion);
                    
                    rowData.InstallmentAmount = installmentServiceProportion + installmentCAMOrAirServiceProportion + installmentRentProportion;
                    rowData.InstallmentAmount = this.roundDecimal(rowData.InstallmentAmount);

                    installmentServiceProportionVat = this.roundDecimal(installmentServiceProportion * (vatPercent/100));
                    installmentRentProportionVat = (oppDetail.isWindowDisplay)?(this.roundDecimal(installmentRentProportion * (vatPercent/100))):0;
                    installmentCAMOrAirServiceProportionVat = this.roundDecimal(installmentCAMOrAirServiceProportion * (vatPercent/100));

                    rowData.InstallmentAmountWithVat = installmentRentProportion + installmentServiceProportion + installmentCAMOrAirServiceProportion +installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
                    rowData.InstallmentVAT = installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;

                    // if (rowData.InstallmentAmount <= 0) {
                    //     var toastEvent = $A.get("e.force:showToast");
                    //     toastEvent.setParams({
                    //         "type": "warning",
                    //         "title": "Warning!",
                    //         "message": "Last Installment should more than 0."
                    //     });
                    //     toastEvent.fire();
                    // }
                }else{
                    totalRentPortion += rowData.InstallmentAmount - (this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (servicePerent/100)) + this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (camOrAirservicePerent/100)));
                    totalServicePortion += this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (servicePerent/100));
                    totalCAMOrAirServicePortion += this.roundDecimal(parseFloat(rowData.InstallmentAmount) * (camOrAirservicePerent/100));
                }

                totalInstallment += (rowData.InstallmentAmount)?this.roundDecimal(parseFloat(rowData.InstallmentAmount)):0;
                totalInstallment_WithVat += (rowData.InstallmentAmountWithVat)?this.roundDecimal(parseFloat(rowData.InstallmentAmountWithVat)):0;
                totalInstallment_Vat += (rowData.InstallmentVAT)?this.roundDecimal(parseFloat(rowData.InstallmentVAT)):0;
            }
        });


        // newInstallmentList = newInstallmentList.map(function(rowData) {
        //     debugger;
        //     if (!rowData.isToDeleteRecord) {
        //         // if (parseFloat(rowData.InstallmentNumber) == parseFloat(depositObject.NumberOfInstallment)){
                    
        //         //     rowData.InstallmentAmountWithVat = parseFloat(depositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat) - totalInstallment_WithVat;
        //         //     rowData.InstallmentAmountWithVat = parseFloat(rowData.InstallmentAmountWithVat.toFixed(2));
                   
        //         //     totalInstallment_WithVat += (rowData.InstallmentAmountWithVat)?parseFloat(rowData.InstallmentAmountWithVat):0;
        //         // }else{
        //         // }
        //     }

        //     return rowData;
        // });


        depositObject.DepositSummary.TotalInstallment = this.roundDecimal(totalInstallment);
        depositObject.DepositSummary.TotalInstallment_WithVat = this.roundDecimal(totalInstallment_WithVat);
        depositObject.DepositSummary.TotalInstallment_VAT = this.roundDecimal(totalInstallment_Vat);
        component.set("v.depositObject",depositObject);
        component.set("v.totalInstallment", this.roundDecimal(totalInstallment));
    },

    calculateInstallmentHelper : function(component, event){
        var depositObject = component.get("v.depositObject");
        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;
        var newInstallmentList = [...depositObject.DepositSummary.InstallmentList];

        var totalPrice = parseFloat(depositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
        var totalPrice_WithVat = parseFloat(depositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat);
        var totalInstallmentPrice = 0;
        var totalInstallmentPrice_WithVat = 0;
        var totalInstallment_Vat = 0;
        let installmentAmount = 0;
        let installmentAmount_WithVat = 0;

        
        var rentWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
        var serviceWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.service_Summary;
        var camOrAirServiceWithoutVat =  (!oppDetail.isNoCAM)?depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary:0;
        var depositTotalSummaryWithoutVat = depositObject.DepositSummary.DepositSummaryPricing.totalDeposit;

        var rentPerent = (rentWithoutVat*100)/depositTotalSummaryWithoutVat;
        rentPerent = (rentPerent)?rentPerent:0;
        var servicePerent = (serviceWithoutVat*100)/depositTotalSummaryWithoutVat;
        servicePerent = (servicePerent)?servicePerent:0;
        var camOrAirservicePerent = (camOrAirServiceWithoutVat*100)/depositTotalSummaryWithoutVat;
        camOrAirservicePerent = (camOrAirservicePerent)?camOrAirservicePerent:0;

        let divided_rent = 0;
        let divided_service = 0;
        let divided_camOrAirService = 0;

        let total_divided_rent = 0;
        let total_divided_service = 0;
        let total_divided_camOrAirService = 0;

        let lastInstallment_divided_rent = 0;
        let lastInstallment_divided_service = 0;
        let lastInstallment_divided_camOrAirService = 0;


        newInstallmentList.sort((a, b) => a.InstallmentNumber - b.InstallmentNumber);
        newInstallmentList.forEach((installmentRowData, index) => {


          if (!installmentRowData.isToDeleteRecord) {
              debugger;

              divided_rent = rentWithoutVat / parseFloat(depositObject.NumberOfInstallment);
              divided_rent = this.roundDecimal(divided_rent);

              divided_service = serviceWithoutVat / parseFloat(depositObject.NumberOfInstallment);
              divided_service = this.roundDecimal(divided_service);

              divided_camOrAirService = camOrAirServiceWithoutVat / parseFloat(depositObject.NumberOfInstallment);
              divided_camOrAirService = this.roundDecimal(divided_camOrAirService);
              
              installmentAmount = divided_rent + divided_service + divided_camOrAirService;

              

              if (parseFloat(installmentRowData.InstallmentNumber) == depositObject.NumberOfInstallment) {

                if ((installmentAmount%1)>0) {
                    
                    lastInstallment_divided_rent = rentWithoutVat - total_divided_rent;
                    lastInstallment_divided_service = serviceWithoutVat - total_divided_service;
                    lastInstallment_divided_camOrAirService = camOrAirServiceWithoutVat - total_divided_camOrAirService;

                    installmentAmount = lastInstallment_divided_rent + lastInstallment_divided_service + lastInstallment_divided_camOrAirService;
                    installmentRowData.InstallmentAmount = this.roundDecimal(installmentAmount);
                }else{
                    installmentRowData.InstallmentAmount = this.roundDecimal(installmentAmount);    
                }


              }else{
                installmentRowData.InstallmentAmount = this.roundDecimal(installmentAmount);
              }


              var installmentServiceProportion = parseFloat(installmentRowData.InstallmentAmount) * (servicePerent/100);
              installmentServiceProportion = this.roundDecimal(installmentServiceProportion);

              var installmentCAMOrAirServiceProportion = parseFloat(installmentRowData.InstallmentAmount) * (camOrAirservicePerent/100);
              installmentCAMOrAirServiceProportion = this.roundDecimal(installmentCAMOrAirServiceProportion);

              var installmentRentProportion = installmentRowData.InstallmentAmount - (installmentServiceProportion + installmentCAMOrAirServiceProportion);
              installmentRentProportion = this.roundDecimal(installmentRentProportion);
              // var installmentRentProportion = parseFloat(installmentRowData.InstallmentAmount) * (rentPerent/100);


              var installmentServiceProportionVat = this.roundDecimal(installmentServiceProportion * (vatPercent/100));
              var installmentRentProportionVat = (oppDetail.isWindowDisplay)?(this.roundDecimal(installmentRentProportion * (vatPercent/100))):0;
              var installmentCAMOrAirServiceProportionVat = this.roundDecimal(installmentCAMOrAirServiceProportion * (vatPercent/100));
              
              console.log('installmentServiceProportionVat' + installmentServiceProportionVat);
              console.log('installmentRentProportionVat' + installmentRentProportionVat);
              console.log('installmentCAMOrAirServiceProportionVat' + installmentCAMOrAirServiceProportionVat);
              // var installmentServiceProportionWithVat = installmentServiceProportion + (installmentServiceProportion * (vatPercent/100));
              // installmentServiceProportionWithVat = this.roundDecimal(installmentServiceProportionWithVat);

              // var installmentCAMOrAirServiceProportionWithVat = installmentCAMOrAirServiceProportion + (installmentCAMOrAirServiceProportion * (vatPercent/100));
              // installmentCAMOrAirServiceProportionWithVat = this.roundDecimal(installmentCAMOrAirServiceProportionWithVat);
              
              installmentAmount_WithVat = installmentRentProportion + installmentCAMOrAirServiceProportion + installmentServiceProportion + installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
              installmentRowData.InstallmentAmountWithVat = this.roundDecimal(installmentAmount_WithVat);
              installmentRowData.InstallmentVAT = installmentServiceProportionVat + installmentCAMOrAirServiceProportionVat + installmentRentProportionVat;
              installmentRowData.InstallmentVAT = this.roundDecimal(installmentRowData.InstallmentVAT);
              
              totalInstallmentPrice += parseFloat(installmentRowData.InstallmentAmount);
              totalInstallmentPrice_WithVat += parseFloat(installmentRowData.InstallmentAmountWithVat);
              totalInstallment_Vat += parseFloat(installmentRowData.InstallmentVAT);

              total_divided_rent += divided_rent;
              total_divided_service += divided_service;
              total_divided_camOrAirService += divided_camOrAirService;

              if(oppDetail.isAllowChangeOptionToRenew && installmentRowData.InstallmentAmount <= 0){
                    installmentRowData.PaymentMethod = null;
                    installmentRowData.PaymentDueDate = null;
                    installmentRowData.remark = "";
              }else if(oppDetail.isAllowChangeOptionToRenew && installmentRowData.InstallmentAmount > 0){
                    if (installmentRowData.PaymentMethod == null) {
                        installmentRowData.PaymentMethod = "Cash";
                    }
                    if (installmentRowData.PaymentDueDate == null) {
                        installmentRowData.PaymentDueDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                    }
              }
          }

        });

        depositObject.DepositSummary.InstallmentList = newInstallmentList;
        depositObject.DepositSummary.TotalInstallment = totalInstallmentPrice;
        depositObject.DepositSummary.TotalInstallment_WithVat = totalInstallmentPrice_WithVat;
        depositObject.DepositSummary.TotalInstallment_VAT = totalInstallment_Vat;
        console.log("newInstallmentList ", newInstallmentList)
        component.set("v.depositObject",depositObject);
        component.set("v.totalInstallment", totalInstallmentPrice);
        
    },

    getNewSystemCalculationDeposit : function(component, event){
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);
        
        var camPricing = component.get("v.camPricing");
        var pricing = component.get("v.periodPricing");
        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;

        let camOrAirService = oppDetail.camOrAirService;
        let depositMonth = oppDetail.depositMonth;
        let parentContract = oppDetail.parentContractId;

        var oppContractEnDate = oppDetail.contractEndate;
        var camLastIndex = camPricing.CAMYearPeriod.length-1;
        var periodLastIndex = pricing.length-1;

        camPricing.CAMYearPeriod.forEach((camPeriodRowData, camPeriodIndex) =>{
            if (!camPeriodRowData.isToDeleteRecord) {
                                
                let startPeriod = new Date(camPeriodRowData.DateFrom);
                let endPeriod = new Date(camPeriodRowData.DateTo);
                let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                if (targetDate >= startPeriod && targetDate <= endPeriod) {
                    camLastIndex = camPeriodIndex;
                }
            }
            
        });

        pricing.forEach((periodRowData, periodIndex) =>{
            if(!periodRowData.isToDeleteRecord){
                let startPeriod = new Date(periodRowData.PricingFrom);
                let endPeriod = new Date(periodRowData.PricingTo);
                let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                if (targetDate >= startPeriod && targetDate <= endPeriod) {
                    periodLastIndex = periodIndex;
                }
            }
        });

        let lastPeriodOfCAMORAirService = camPricing.CAMYearPeriod[camLastIndex];
        let lastPeriodOfPricing = pricing[periodLastIndex];

        let camOrAirServicePrice = lastPeriodOfCAMORAirService.TotalPrice;
        let rentPrice = 0;
        let rentPercent = lastPeriodOfPricing.Proportion.Rent;
        let servicePrice = 0;
        let servicePercent = lastPeriodOfPricing.Proportion.Service;
        let periodPrice = 0;
        let estimateRev = 0;
        let gpPercent = 0;

            switch (lastPeriodOfPricing.CalculationMethod) {
                case 'Fixed Price':
                    periodPrice = (oppDetail.isWindowDisplay)?lastPeriodOfPricing.FixedPriceSection.Price_withoutVat:lastPeriodOfPricing.FixedPriceSection.Price;

                    if (lastPeriodOfPricing.IsIncludeCAM) {
                        periodPrice = periodPrice - camOrAirServicePrice;                                
                    }
                    
                    rentPrice = (periodPrice * rentPercent) / 100;
                    servicePrice = (periodPrice * servicePercent) / 100;
                    break;
                case 'Fixed Rental Object':
                    periodPrice = (oppDetail.isWindowDisplay)?lastPeriodOfPricing.FixedRentalObjectSection.TotalPrice_withOutVat:lastPeriodOfPricing.FixedRentalObjectSection.TotalPrice;
                    
                    if (lastPeriodOfPricing.IsIncludeCAM) {
                        periodPrice = periodPrice - camOrAirServicePrice;                                
                    }

                    rentPrice = (periodPrice * rentPercent) / 100;
                    servicePrice = (periodPrice * servicePercent) / 100;
                    break;
                case 'Fixed Measurement':
                    periodPrice = (oppDetail.isWindowDisplay)?lastPeriodOfPricing.FixedMeasurementSection.TotalSummary_withoutVat:lastPeriodOfPricing.FixedMeasurementSection.TotalSummary;
                    
                    if (lastPeriodOfPricing.IsIncludeCAM) {
                        periodPrice = periodPrice - camOrAirServicePrice;                                
                    }

                    rentPrice = (periodPrice * rentPercent) / 100;
                    servicePrice = (periodPrice * servicePercent) / 100;
                    break;
                case 'GP no Min':
                    // estimateRev = lastPeriodOfPricing.EstimateRevernue;
                    // let gpTier = lastPeriodOfPricing.GPNoMinSection.ReportingRuleList[0].ReportingRuleDetailList;

                    // gpTier.forEach((gpRowData, gpIndex) =>{
                    //     if(!gpRowData.isToDeleteRecord){
                    //         let startPrice = gpRowData.rangTo;
                    //         let endPrice = gpRowData.rangFrom;
            
                    //         if ((estimateRev >= startPrice && estimateRev <= endPrice) || endPrice == 0) {
                    //             gpPercent = gpRowData.GPPercent;
                    //         }
                    //     }
                    // });
                    // periodPrice = estimateRev * gpPercent / 100;
                    
                    // rentPrice = (periodPrice * rentPercent) / 100;
                    // servicePrice = (periodPrice * servicePercent) / 100;
                    rentPrice = 0;
                    servicePrice = 0;
                    break;
                case 'GP with Min':
                    if (lastPeriodOfPricing.GPWithMinSection.PricingSection.MinType === "Measurement") {
                        periodPrice = (oppDetail.isWindowDisplay)? lastPeriodOfPricing.GPWithMinSection.PricingSection.TotalSummary_withoutVat :lastPeriodOfPricing.GPWithMinSection.PricingSection.TotalSummary;
                    } else if (lastPeriodOfPricing.GPWithMinSection.PricingSection.MinType === "Fixed") {
                        periodPrice = (oppDetail.isWindowDisplay)? lastPeriodOfPricing.GPWithMinSection.PricingSection.FixedPricing.Price_withoutVat :lastPeriodOfPricing.GPWithMinSection.PricingSection.FixedPricing.Price;
                    }

                    if (lastPeriodOfPricing.IsIncludeCAM) {
                        periodPrice = periodPrice - camOrAirServicePrice;                                
                    }
                    

                    rentPrice = (periodPrice * rentPercent) / 100;
                    servicePrice = (periodPrice * servicePercent) / 100;
                    break;
                case 'GP on Top':
                    if (lastPeriodOfPricing.GPOnTopSection.PricingSection.MinType === "Measurement") {
                        periodPrice = (oppDetail.isWindowDisplay)? lastPeriodOfPricing.GPOnTopSection.PricingSection.TotalSummary_withoutVat : lastPeriodOfPricing.GPOnTopSection.PricingSection.TotalSummary;
                    } else if (lastPeriodOfPricing.GPOnTopSection.PricingSection.MinType === "Fixed") {
                        periodPrice = (oppDetail.isWindowDisplay)? lastPeriodOfPricing.GPOnTopSection.PricingSection.FixedPricing.Price_withoutVat : lastPeriodOfPricing.GPOnTopSection.PricingSection.FixedPricing.Price;
                    }
                    
                    if (lastPeriodOfPricing.IsIncludeCAM) {
                        periodPrice = periodPrice - camOrAirServicePrice;                                
                    }

                    rentPrice = (periodPrice * rentPercent) / 100;
                    servicePrice = (periodPrice * servicePercent) / 100;
                    break;
                default:
                    break;

            }

            debugger;

            rentPrice = (typeof rentPrice == 'number')?this.roundDecimal(rentPrice):0;
            servicePrice = (typeof servicePrice == 'number')?this.roundDecimal(servicePrice):0;

            if (!oppDetail.isNoCAM) {

                if (oppDetail.camOrAirService === "Air Service") {
                    var service = (depositMonth>0)?servicePrice:0;
                    var airService = (depositMonth>0)?this.roundDecimal(camOrAirServicePrice):0;

                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = 0;
                    newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = (depositMonth>0)?this.roundDecimal(rentPrice):0;
                    newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = airService+service;
                }else{

                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = (depositMonth>0)?this.roundDecimal(camOrAirServicePrice):0;
                    newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = (depositMonth>0)?this.roundDecimal(rentPrice):0;
                    newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = (depositMonth>0)?this.roundDecimal(servicePrice):0;
                }
            }else{
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = 0;
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = (depositMonth>0)?this.roundDecimal(rentPrice):0;
                newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = (depositMonth>0)?this.roundDecimal(servicePrice):0;
            }



            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate * depositMonth;
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit);
            
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate * depositMonth;
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit);
            
            newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate * depositMonth;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit);



            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit);
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit);
            newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit);
            

            if (oppDetail.isAllowChangeOptionToRenew) {
                let rentTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)?this.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)):0;
                let serviceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)?this.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)):0;
                let camOrAirServiceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)?this.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)):0;

                let rentCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
                rentCarriedDeposit = this.roundDecimal(rentCarriedDeposit);

                let serviceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
                serviceCarriedDeposit = this.roundDecimal(serviceCarriedDeposit);

                let camOrAirServiceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;
                camOrAirServiceCarriedDeposit = this.roundDecimal(camOrAirServiceCarriedDeposit);

                if(newDepositObject.DepositOption === "คิดเงินประกันตามสัญญาใหม่"){

                    newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentTotalDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceTotalDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceTotalDeposit;

                }else if(newDepositObject.DepositOption === "คงเงินประกันเดิม"){
                    newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentCarriedDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceCarriedDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceCarriedDeposit;
                }
                let rentActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit;
                let serviceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit;
                let camOrAirServiceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit;

                var rentSummaryDeposit =  rentActualDDeposit - rentCarriedDeposit;
                var serviceSummaryDeposit =  serviceActualDDeposit - serviceCarriedDeposit;
                var camOrAirServiceSummaryDeposit =  camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit;

                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
            }else{

                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit;  
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary)
                
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit; 
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary);

                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary);

                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary;
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
            }
            
            var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
            camOrAirService_Summary_vat = this.roundDecimal(camOrAirService_Summary_vat);

            var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
            service_Summary_vat = this.roundDecimal(service_Summary_vat);
            
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat>0)?this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat):0;

            component.set("v.depositObject", newDepositObject);

            this.calculateInstallmentHelper(component, event);

    },
    getNewAdvanceCalculationDeposit : function(component, event){
        debugger;
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);
        var camPricing = component.get("v.camPricing");
        var pricing = component.get("v.periodPricing");
        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;

        let depositMonth = oppDetail.depositMonth;
        var oppContractEnDate = oppDetail.contractEndate;
        var camLastIndex = camPricing.CAMYearPeriod.length-1;
        var periodLastIndex = pricing.length-1;

        camPricing.CAMYearPeriod.forEach((camPeriodRowData, camPeriodIndex) =>{
            if (camPeriodRowData.DateTo === oppContractEnDate && !camPeriodRowData.isToDeleteRecord) {
                camLastIndex = camPeriodIndex;
            }
            
        });

        pricing.forEach((periodRowData, periodIndex) =>{
            if (periodRowData.PricingTo === oppContractEnDate && !periodRowData.isToDeleteRecord) {
                periodLastIndex = periodIndex;
            }
        });

        let depositAmount = newDepositObject.DepositSummary.AdvanceDepositAmount;
        let lastPeriodOfCAMORAirService = camPricing.CAMYearPeriod[camLastIndex];
        let lastPeriodOfPricing = pricing[periodLastIndex];

        let camOrAirServicePrice = lastPeriodOfCAMORAirService.TotalPrice;
        let rentPercent = lastPeriodOfPricing.Proportion.Rent;
        let servicePercent = lastPeriodOfPricing.Proportion.Service;

        let sumTotalDeposit = 0;

        let camOrAirService_TotalDeposit = 0;
        let rent_TotalDeposit = 0;
        let service_TotalDeposit = 0;

        debugger;

        if (!oppDetail.isNoCAM) {
            if (oppDetail.camOrAirService === "Air Service"){
                camOrAirService_TotalDeposit = 0;

                var airServieWithDepositMonth = this.roundDecimal((camOrAirServicePrice*depositMonth));
                rent_TotalDeposit = ((depositAmount - airServieWithDepositMonth)*(rentPercent/100));
                service_TotalDeposit = airServieWithDepositMonth + ((depositAmount - airServieWithDepositMonth)*(servicePercent/100));

            }else{
                camOrAirService_TotalDeposit = (camOrAirServicePrice)*depositMonth;
                camOrAirService_TotalDeposit = this.roundDecimal(camOrAirService_TotalDeposit);

                rent_TotalDeposit = (depositAmount - camOrAirService_TotalDeposit)* (rentPercent/100);
                service_TotalDeposit = (depositAmount - camOrAirService_TotalDeposit)* (servicePercent/100);
            }
        }else{
            camOrAirService_TotalDeposit = 0;
            rent_TotalDeposit = (depositAmount - camOrAirService_TotalDeposit)* (rentPercent/100);
            service_TotalDeposit = (depositAmount - camOrAirService_TotalDeposit)* (servicePercent/100);
        }


        if (depositAmount>camOrAirService_TotalDeposit) {
            sumTotalDeposit = rent_TotalDeposit + service_TotalDeposit + newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit;
        }else{
            sumTotalDeposit = depositAmount;
        }

        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = null;
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = null;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = null;


        if (!oppDetail.isNoCAM){
            if (oppDetail.camOrAirService === "Air Service"){
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = 0;
            }else{
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = (depositAmount>camOrAirService_TotalDeposit)?camOrAirService_TotalDeposit:sumTotalDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit);
            }
        }else{
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = 0;
        }
        
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = (rent_TotalDeposit>0)?rent_TotalDeposit:0;
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit);
        
        newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = (service_TotalDeposit>0)?service_TotalDeposit:0;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit);



        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit);
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit);
        newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit);


        if (oppDetail.isAllowChangeOptionToRenew) {
                let rentTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)?this.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)):0;
                let serviceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)?this.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)):0;
                let camOrAirServiceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)?this.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)):0;

                let rentCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
                rentCarriedDeposit = this.roundDecimal(rentCarriedDeposit);

                let serviceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
                serviceCarriedDeposit = this.roundDecimal(serviceCarriedDeposit);

                let camOrAirServiceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;
                camOrAirServiceCarriedDeposit = this.roundDecimal(camOrAirServiceCarriedDeposit);

                if(newDepositObject.DepositOption === "คิดเงินประกันตามสัญญาใหม่"){

                    newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentTotalDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceTotalDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceTotalDeposit;

                }else if(newDepositObject.DepositOption === "คงเงินประกันเดิม"){
                    newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentCarriedDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceCarriedDeposit;
                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceCarriedDeposit;
                }
                let rentActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit;
                let serviceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit;
                let camOrAirServiceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit;

                var rentSummaryDeposit =  rentActualDDeposit - rentCarriedDeposit;
                var serviceSummaryDeposit =  serviceActualDDeposit - serviceCarriedDeposit;
                var camOrAirServiceSummaryDeposit =  camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit;

                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
            }else{

                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit;  
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary)
                
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit; 
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary);

                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary);

                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary;
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
            }





        var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
        camOrAirService_Summary_vat = this.roundDecimal(camOrAirService_Summary_vat);

        var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
        service_Summary_vat = this.roundDecimal(service_Summary_vat);

        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat>0)?this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat):0;

        component.set("v.sumTotalDeposit",sumTotalDeposit);
        component.set("v.depositObject",newDepositObject);

        this.calculateInstallmentHelper(component, event);
    },

    roundToTwo: function(num) {
        var m = Number((Math.abs(num) * 100).toPrecision(15));
        return Math.round(m) / 100 * Math.sign(num);
    },

    calculateAdvanceDeposit : function(component, event){
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);
        var pricing = component.get("v.periodPricing");
        var camPricing = component.get("v.camPricing");
        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;
        let depositMonth = oppDetail.depositMonth;

        var oppContractEnDate = oppDetail.contractEndate;
        var camLastIndex = camPricing.CAMYearPeriod.length-1;
        var periodLastIndex = pricing.length-1;

        camPricing.CAMYearPeriod.forEach((camPeriodRowData, camPeriodIndex) =>{
            if (camPeriodRowData.DateTo === oppContractEnDate && !camPeriodRowData.isToDeleteRecord) {
                camLastIndex = camPeriodIndex;
            }
            
        });

        pricing.forEach((periodRowData, periodIndex) =>{
            if (periodRowData.PricingTo === oppContractEnDate && !periodRowData.isToDeleteRecord) {
                periodLastIndex = periodIndex;
            }
        });

        let lastPeriodOfCAMORAirService = camPricing.CAMYearPeriod[camLastIndex];
        let lastPeriodOfPricing = pricing[periodLastIndex];


        let rentPercent = this.roundDecimal(parseFloat(lastPeriodOfPricing.Proportion.Rent));
        let servicePercent = this.roundDecimal(parseFloat(lastPeriodOfPricing.Proportion.Service));
        let camOrAirServicePrice = this.roundDecimal(lastPeriodOfCAMORAirService.TotalPrice);

        let sumTotalDeposit = 0;
        let depositAmount = (newDepositObject.DepositSummary.AdvanceDepositAmount)?this.roundDecimal(parseFloat(newDepositObject.DepositSummary.AdvanceDepositAmount)):0;

        let camOrAirService_TotalDeposit = 0;
        let rent_TotalDeposit = 0;
        let service_TotalDeposit = 0;

        debugger;

        if (!oppDetail.isNoCAM) {
            if (oppDetail.camOrAirService === "Air Service"){
                camOrAirService_TotalDeposit = 0;

                var airServieWithDepositMonth = this.roundDecimal((camOrAirServicePrice*depositMonth));

                rent_TotalDeposit = ((depositAmount - airServieWithDepositMonth)*(rentPercent/100));
                service_TotalDeposit = airServieWithDepositMonth + ((depositAmount - airServieWithDepositMonth)*(servicePercent/100));

                rent_TotalDeposit = this.roundDecimal(rent_TotalDeposit);
                service_TotalDeposit = this.roundDecimal(service_TotalDeposit);

            }else{
                camOrAirService_TotalDeposit = (camOrAirServicePrice)*depositMonth;
                camOrAirService_TotalDeposit = this.roundDecimal(camOrAirService_TotalDeposit);

                rent_TotalDeposit =  (depositAmount - camOrAirService_TotalDeposit)* (rentPercent/100);
                rent_TotalDeposit = this.roundDecimal(rent_TotalDeposit);

                service_TotalDeposit = (depositAmount - camOrAirService_TotalDeposit)* (servicePercent/100);
                service_TotalDeposit = this.roundDecimal(service_TotalDeposit);
            }
        }else{
            camOrAirService_TotalDeposit = 0;

            rent_TotalDeposit =  (depositAmount - camOrAirService_TotalDeposit)* (rentPercent/100);
            rent_TotalDeposit = this.roundDecimal(rent_TotalDeposit);

            service_TotalDeposit = (depositAmount - camOrAirService_TotalDeposit)* (servicePercent/100);
            service_TotalDeposit = this.roundDecimal(service_TotalDeposit);
        }


        if(!oppDetail.isNoCAM){

            if (depositAmount>camOrAirService_TotalDeposit) {
                sumTotalDeposit = rent_TotalDeposit + service_TotalDeposit + camOrAirService_TotalDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = camOrAirService_TotalDeposit;
            }else{
                if (oppDetail.camOrAirService === "Air Service"){
                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = 0;
                }else{
                    newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = depositAmount;
                }
                    sumTotalDeposit = depositAmount;
            }
        }else{
            sumTotalDeposit = rent_TotalDeposit + service_TotalDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = 0;
        }

        newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = (rent_TotalDeposit>0)?rent_TotalDeposit:0;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = (service_TotalDeposit>0)?service_TotalDeposit:0;


        let rentCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
        rentCarriedDeposit = this.roundDecimal(rentCarriedDeposit);

        let serviceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
        serviceCarriedDeposit = this.roundDecimal(serviceCarriedDeposit);

        let camOrAirServiceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;
        camOrAirServiceCarriedDeposit = this.roundDecimal(camOrAirServiceCarriedDeposit);


        let rentActualDDeposit  = 0;
        let serviceActualDDeposit  = 0;
        let camOrAirServiceActualDDeposit  = 0;

        if (oppDetail.isAllowChangeOptionToRenew && newDepositObject.DepositOption == "คงเงินประกันเดิม") {
            rentActualDDeposit = rentCarriedDeposit;
            serviceActualDDeposit = serviceCarriedDeposit;
            camOrAirServiceActualDDeposit = camOrAirServiceCarriedDeposit;

        }else{
            rentActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit;
            serviceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit;
            camOrAirServiceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit;
        }
        
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentActualDDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceActualDDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceActualDDeposit;



        var rentSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( rentActualDDeposit - rentCarriedDeposit) : (newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit - rentCarriedDeposit);
        var serviceSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( serviceActualDDeposit - serviceCarriedDeposit) : (newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit - serviceCarriedDeposit);
        var camOrAirServiceSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit) : (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit - camOrAirServiceCarriedDeposit);

        newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);

        var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
        camOrAirService_Summary_vat = this.roundDecimal(camOrAirService_Summary_vat);

        var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
        service_Summary_vat =  this.roundDecimal(service_Summary_vat);

        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat>0)?this.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat):0;

        component.set("v.depositObject",newDepositObject);
        component.set("v.sumTotalDeposit",sumTotalDeposit);

        this.calculateInstallmentHelper(component, event);
    }
})