({
    changeStep: function (component, event, targetStep) {
        console.log("targetStep", targetStep);
        component.set("v.progresStep", targetStep);
    },

    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },

    saveData: function (component, event) {
        var progressStep = component.get("v.progresStep");
        component.set("v.toggleSpinner", true);
        if (progressStep === "1") {
            this.validateBeforeSaveSelectedRO(component, event, '1', true);
        }
        else if (progressStep === "2") {
            if (this.validateProportionNull(component, event)) {
                var camPricing = component.get("v.camPricing");
                var rentService = component.get("v.rentServicePricing");
                var oppId = component.get("v.recordId");
                var pricing = component.get("v.periodPricing");
                var oppDetail = component.get("v.oppObject");
                var camOrAirService = camPricing.CAMOrAirService;
                var depositMonth = oppDetail.depositMonth;
                var parentContract = oppDetail.parentContractId;
                var selectedRoom = component.get("v.seletedRoom");

                console.log("camPricing ", JSON.stringify(camPricing));
                console.log("pricing ", JSON.stringify(pricing));

                if (component.get("v.isChangePricing")) {
                    oppDetail.camOrAirEscalationType = camPricing.CAMCondition;
                    oppDetail.camOrAirEscalationRate = camPricing.CAMEscationRate.value;
                    oppDetail.rentServiceEscalationType =  rentService.RentCondition;
                    oppDetail.rentServiiceEscalationRate =  rentService.RentServiceEscalationRate.value;
                    component.set("v.oppObject", oppDetail);

                    component.lax.enqueueAll([{
                        name: "c.savePricingApex",
                        params: {
                            "camorAirServiceJson": JSON.stringify(camPricing),
                            "rentServiceJson": JSON.stringify(rentService),
                            "periodPricingJson": JSON.stringify(pricing),
                            "oppUiWrapper": JSON.stringify(oppDetail),
                            "oppId": oppId
                        },
                        options: { background: true },
                    }
                    ]).then(result => {
                        var savePricingResult = result[0];
                        // debugger;
                        if (!savePricingResult.messageAura.isError) {
                            var action = component.get("c.getSavedPeriodPricingDetail");
                            action.setParams({ oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail), selectedRoomJson: JSON.stringify(selectedRoom), rentServiceEscalationType: oppDetail.rentServiceEscalationType,
                                calculationMethod: oppDetail.calculationMethod });
                            action.setCallback(this, function (response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    let ret = response.getReturnValue();
                                    if (ret) {
                                        var savedPricing = JSON.parse(ret);
                                        var oppContractEnDate = oppDetail.contractEndate;
                                        var periodLastIndex = 0;

                                        savedPricing.forEach((periodRowData, periodIndex) =>{
                                            if(!periodRowData.isToDeleteRecord){
                                                let startPeriod = new Date(periodRowData.PricingFrom);
                                                let endPeriod = new Date(periodRowData.PricingTo);
                                                let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                                if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                                    periodLastIndex = periodIndex;
                                                }
                                            }
                                        });

                                        var camOrAirServicePrice = 0;
                                        if (!oppDetail.isNoCAM) {
                                            var camLastIndex = camPricing.CAMYearPeriod.length - 1;
                                            camPricing.CAMYearPeriod.forEach((camPeriodRowData, camPeriodIndex) => {
                                                if (!camPeriodRowData.isToDeleteRecord) {
                                                    let startPeriod = new Date(camPeriodRowData.DateFrom);
                                                    let endPeriod = new Date(camPeriodRowData.DateTo);
                                                    let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                                    if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                                        camLastIndex = camPeriodIndex;
                                                    }
                                                }
                                            });
                                            var lastPeriodOfCAMORAirService = camPricing.CAMYearPeriod[camLastIndex];
                                            camOrAirServicePrice = lastPeriodOfCAMORAirService.TotalPrice;
                                        }

                                        var lastPeriodOfPricing = savedPricing[periodLastIndex];
                                        var rentPrice = 0;
                                        var rentPercent = lastPeriodOfPricing.Proportion.Rent;
                                        var servicePrice = 0;
                                        var servicePercent = lastPeriodOfPricing.Proportion.Service;

                                        let price = this.calculateRentAndService(lastPeriodOfPricing, oppDetail, rentPercent, servicePercent, camOrAirServicePrice);
                                        rentPrice = price.rentPrice;
                                        servicePrice = price.servicePrice;
                                        rentPrice = (typeof rentPrice == 'number')?this.roundDecimal(rentPrice):0;
                                        servicePrice = (typeof servicePrice == 'number')?this.roundDecimal(servicePrice):0;



                                        var action = component.get("c.getDepositObjectJson");
                                        action.setParams({ camORAirServiceCondition: camOrAirService,
                                                            camPrice: camOrAirServicePrice,
                                                            rentPrice: rentPrice,
                                                            servicePrice: servicePrice,
                                                            depositMonth: depositMonth,
                                                            parentContract: parentContract,
                                                            oppUiWrapper: JSON.stringify(oppDetail)});

                                        action.setCallback(this, function (response) {
                                            var state = response.getState();
                                            if (state === "SUCCESS") {
                                                var returnedDeposit = response.getReturnValue();
                                                var depositObject = JSON.parse(returnedDeposit);
                                                component.set("v.depositObject", depositObject);

                                                var action = component.get("c.saveDepositApex");
                                                action.setParams({ depositJson: JSON.stringify(depositObject), oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail), isInitialDeposit: true });

                                                action.setCallback(this, function (response) {
                                                    var state = response.getState();
                                                    if (state === "SUCCESS") {

                                                        let ret = response.getReturnValue();
                                                        component.set("v.toggleSpinner", false);

                                                        if (!ret.messageAura.isError) {

                                                            $A.get('e.force:refreshView').fire();

                                                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                                            dismissActionPanel.fire();
                                                        } else {
                                                            let toastEvent = $A.get("e.force:showToast");
                                                            toastEvent.setParams({
                                                                "title": "Error!",
                                                                "type": "error",
                                                                "message": ret.messageAura.message
                                                            });
                                                            toastEvent.fire();
                                                        }
                                                    }
                                                });
                                                $A.enqueueAction(action);
                                            }
                                        });
                                        $A.enqueueAction(action);
                                    }
                                }
                            });
                            $A.enqueueAction(action);
                        } else {
                            component.set("v.toggleSpinner", false);
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": savePricingResult.messageAura.message
                            });
                            toastEvent.fire();
                        }
                    });
                }else if(component.get("v.isChangeGrading")){
                    component.lax.enqueueAll([
                    {
                        name: "c.savePricingApex",
                        params: {
                            "camorAirServiceJson": JSON.stringify(camPricing),
                            "rentServiceJson": JSON.stringify(rentService),
                            "periodPricingJson": JSON.stringify(pricing),
                            "oppUiWrapper": JSON.stringify(oppDetail),
                            "oppId": oppId
                        },
                        options: { background: true },
                    }
                    ]).then(result => {

                        var savePricingResult = result[0];
                        component.set("v.toggleSpinner", false);

                        // debugger;
                        if (!savePricingResult.messageAura.isError) {
                            $A.get('e.force:refreshView').fire();

                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();
                        } else {
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": savePricingResult.messageAura.message
                            });
                            toastEvent.fire();
                        }


                    });

                }else {
                    component.set("v.toggleSpinner", false);

                    $A.get('e.force:refreshView').fire();

                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            } else {
                if (!this.validateProportionNull(component, event)) {
                    component.set("v.toggleSpinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "error!",
                        "message": "Proportion cannot blank"
                    });
                    toastEvent.fire();
                }
            }
        } else if (progressStep === "3") {

            if (this.validateSaveDeposit(component, event)) {
                var depositObject = component.get("v.depositObject");
                var oppId = component.get("v.recordId");
                var oppDetail = component.get("v.oppObject");
                oppDetail.depositMonth = depositObject.DepositMonth;
                component.set("v.oppObject", oppDetail);

                // if (component.get("v.isChangeDeposit")) {

                var action = component.get("c.saveDepositApex");
                action.setParams({ depositJson: JSON.stringify(depositObject), oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail), isInitialDeposit : false });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {

                        let ret = response.getReturnValue();
                        component.set("v.toggleSpinner", false);

                        if (!ret.messageAura.isError) {

                            $A.get('e.force:refreshView').fire();

                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();
                        } else {
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": ret.messageAura.message
                            });
                            toastEvent.fire();
                        }

                    }
                });
                $A.enqueueAction(action);
            } else {
                if (!this.validateSaveDeposit(component, event)) {

                    component.set("v.toggleSpinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "error!",
                        "message": "Total summary should not less than 0"
                    });
                    toastEvent.fire();
                }
            }
            // }else{
            //     component.set("v.toggleSpinner", false);
            //     var dismissActionPanel = $A.get("e.force:closeQuickAction");
            //     dismissActionPanel.fire();
            // }
        } else if (progressStep === "4") {
            let oppId = component.get("v.recordId");
            var otherExpense = component.get("v.otherPageObject");
            var oppDetail = component.get("v.oppObject");
            // let hasError = false;

            // if(oppDetail.isOwnCashier){
            //     otherExpense.fixedFormatList.forEach(element => {
            //         if(element.Type == 'Cashier' && (!element.Monthly || element.Monthly <= 0)){
            //             hasError = true;
            //             let toastEvent = $A.get("e.force:showToast");
            //             toastEvent.setParams({
            //                 "title": "Error!",
            //                 "type": "error",
            //                 "message": 'Cashier Monthly (Baht) ต้องมีค่ามากกว่า 0'
            //             });
            //             toastEvent.fire();
            //             return;
            //         }
            //     });
            // }
            // if(hasError){
            //     component.set("v.toggleSpinner", false);
            //     return;
            // }

            console.log('Save Other Expense', otherExpense);

            // if (component.get("v.isChangeOtherExpense")) {
            var action = component.get("c.saveOtherExpense");
            action.setParams({ expenseJson: JSON.stringify(otherExpense), oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    let ret = response.getReturnValue();
                    component.set("v.toggleSpinner", false);

                    if (!ret.messageAura.isError) {

                        $A.get('e.force:refreshView').fire();

                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    } else {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": ret.messageAura.message
                        });
                        toastEvent.fire();
                    }

                }
            });

            $A.enqueueAction(action);
            // }else{
            //     component.set("v.toggleSpinner", false);
            //     var dismissActionPanel = $A.get("e.force:closeQuickAction");
            //     dismissActionPanel.fire();
            // }
        } else if (progressStep === "5") {
            var expenseList = component.get("v.expenseList");
            var expenseListStringJson = JSON.stringify(expenseList);
            var oppId = component.get("v.recordId");
            var oppDetail = component.get("v.oppObject");

            // if (component.get("v.isChangeExpense")) {
            console.log('expenseListStringJson To Save', expenseListStringJson);

            var action = component.get("c.saveExpenseInstallment");
            action.setParams({ installmentJson: expenseListStringJson, oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    let ret = response.getReturnValue();
                    component.set("v.toggleSpinner", false);

                    if (!ret.messageAura.isError) {

                        $A.get('e.force:refreshView').fire();

                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    } else {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": ret.messageAura.message
                        });
                        toastEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);

            // }else {
            //     component.set("v.toggleSpinner", false);
            //     var dismissActionPanel = $A.get("e.force:closeQuickAction");
            //     dismissActionPanel.fire();
            // }
        }

        console.log("Pricing Period", component.get("v.periodPricing"));
        console.log("New Selected Room", component.get('v.seletedRoom'));

    },

    validateGPPricingReportingRule: function (component, event) {
        var periodPricing = component.get("v.periodPricing");
        let isPassValidate = true;

        periodPricing.forEach((periodRowData, periodIndex) => {
            if (periodRowData.CalculationMethod === "GPWithMin" && periodRowData.GPWithMinSection && periodRowData.GPWithMinSection.ReportingRuleList) {

                periodRowData.GPWithMinSection.ReportingRuleList.forEach((periodReportingRuleRowData, periodReportingRuleIndex) => {

                    if (periodRowData.GPWithMinSection.ReportingRuleList.length > 1 && !periodReportingRuleRowData.ReportingRuleDescription) {
                        isPassValidate = false;
                    }

                });
            }
            else if (periodRowData.CalculationMethod === "GPNoMin" && periodRowData.GPNoMinSection && periodRowData.GPNoMinSection.ReportingRuleList) {
                periodRowData.GPNoMinSection.ReportingRuleList.forEach((periodReportingRuleRowData, periodReportingRuleIndex) => {

                    if (periodRowData.GPNoMinSection.ReportingRuleList.length > 1 && !periodReportingRuleRowData.ReportingRuleDescription) {
                        isPassValidate = false;
                    }

                });
            }
            else if (periodRowData.CalculationMethod === "GPOnTop" && periodRowData.GPOnTopSection && periodRowData.GPOnTopSection.ReportingRuleList) {

                periodRowData.GPOnTopSection.ReportingRuleList.forEach((periodReportingRuleRowData, periodReportingRuleIndex) => {

                    if (periodRowData.GPOnTopSection.ReportingRuleList.length > 1 && !periodReportingRuleRowData.ReportingRuleDescription) {
                        isPassValidate = false;
                    }

                });
            }
        });

        return isPassValidate;
    },
    validateProportionPricing: function (component, event) {
        var periodPricing = component.get("v.periodPricing");
        var oppDetail = component.get("v.oppObject");

        let isPassValidate = true;

        if (oppDetail.leaseType === "Long-Term" && oppDetail.longleaseType == 'ระบุราคาปีปฏิทินแรก') {
            periodPricing.forEach((periodRowData, periodIndex) => {
                if (periodRowData.Proportion.Rent == "" || periodRowData.Proportion.Service == "" || parseFloat(periodRowData.Proportion.Rent) === 0 || parseFloat(periodRowData.Proportion.Service) === 0) {
                    isPassValidate = false;
                }
            });
        }

        return isPassValidate;
    },

    validateProportionNull: function (component, event) {
        var periodPricing = component.get("v.periodPricing");
        var oppDetail = component.get("v.oppObject");

        let isPassValidate = true;


        periodPricing.forEach((periodRowData, periodIndex) => {
            if (periodRowData.Proportion.Rent === "" || periodRowData.Proportion.Service === "") {
                isPassValidate = false;
            }
        });


        return isPassValidate;
    },

    validateProportionValue: function (component, event) {
        var periodPricing = component.get("v.periodPricing");
        let isPassValidate = false;
        if (periodPricing) {
            periodPricing.forEach((periodRowData, periodIndex) => {
                if (periodRowData.Proportion.Rent != "" && periodRowData.Proportion.Service != "") {
                    if (parseFloat(periodRowData.Proportion.Rent) + parseFloat(periodRowData.Proportion.Service) == 100) {
                        isPassValidate = true;
                    }
                }
            });
        }


        return isPassValidate;
    },

    validateExpenseAndFeeInstallment: function (component, event) {
        var expenseList = component.get("v.expenseList");
        let isPassValidate = true;
        let expenseTotalAmount = 0;
        let sumInstalment = 0;
        let isDeletedExpenseDepositList = [];
        let isDeletedExpenseInstallmentList = [];


        if (expenseList) {
            expenseList.forEach((eachExpense, expenseIndex) => {

                if (!eachExpense.isToDeleteRecord) {

                    expenseTotalAmount = 0;
                    sumInstalment = 0;
                    if (eachExpense.TotalAmount && eachExpense.TotalAmount != "") {
                        expenseTotalAmount = parseFloat(eachExpense.TotalAmount);
                    }

                    if (eachExpense.InstallmentList) {

                        eachExpense.InstallmentList.forEach((eachInstallment, installmentIndex) => {

                            if (!eachInstallment.isToDeleteRecord) {
                                if (eachInstallment.InstallmentAmount != "") {
                                    sumInstalment += parseFloat(eachInstallment.InstallmentAmount);
                                } else {
                                    isPassValidate = false;
                                }
                            } else {
                                isDeletedExpenseInstallmentList.push(eachInstallment);
                            }
                        });

                        if (sumInstalment != expenseTotalAmount) {
                            isPassValidate = false;
                        }

                        if (isDeletedExpenseInstallmentList.length == eachExpense.InstallmentList.length) {
                            isPassValidate = false;
                        }
                    }
                } else {
                    isDeletedExpenseDepositList.push(eachExpense);
                }

            });

            if (isDeletedExpenseDepositList.length == expenseList.length) {
                isPassValidate = true;
            }
        }

        return true;
    },

    isSameDay: function (d1, d2) {
        return d1.getFullYear() === d2.getFullYear() && d1.getMonth() === d2.getMonth() && d1.getDate() === d2.getDate();
    },

    validatePeriodPricing: function (component, event) {

        var periodPricing = component.get("v.periodPricing");
        var camPricing = component.get("v.camPricing");
        var oppDetail = component.get("v.oppObject");

        var contractStartDate = new Date(oppDetail.contractStartDate);
        var contractEndDate = new Date(oppDetail.contractEndate);

        let isPassValidate = false;

        var tomorrow;

        var camMinDate;
        var camMaxDate;
        var camPeriodFromList = [];
        var camPeriodToList = [];

        var periodMinDate;
        var periodMaxDate;
        var periodPeriodFromList = [];
        var periodPeriodToList = [];
        // debugger;

        if (camPricing) {
            if (camPricing.CAMYearPeriod.length > 0) {

                // debugger;
                camMinDate = new Date(camPricing.CAMYearPeriod[0].DateFrom);
                camMaxDate = new Date(camPricing.CAMYearPeriod[0].DateTo);

                camPricing.CAMYearPeriod.forEach((eachDate, Index) => {
                    // debugger;
                    if (!eachDate.isToDeleteRecord) {
                        if (new Date(eachDate.DateFrom) < camMinDate) {
                            camMinDate = new Date(eachDate.DateFrom);
                        }
                        if (new Date(eachDate.DateTo) > camMaxDate) {
                            camMaxDate = new Date(eachDate.DateTo);
                        }

                        camPeriodFromList.push(new Date(eachDate.DateFrom));
                        camPeriodToList.push(new Date(eachDate.DateTo));
                    }

                });

                camPeriodFromList.sort((a, b) => a - b);
                camPeriodToList.sort((a, b) => a - b);
                // debugger;

                if (camPeriodFromList.length > 0 && camPeriodToList.length > 0) {
                    // debugger;

                    for (var i = 0; i < camPeriodToList.length; i++) {

                        // debugger;
                        tomorrow = new Date(camPeriodToList[i]);
                        tomorrow.setDate(camPeriodToList[i].getDate() + 1);

                        if (!camPeriodFromList.includes(tomorrow)) {

                            if (this.isSameDay(camPeriodToList[i], contractEndDate)) {
                                isPassValidate = true;
                            } else {
                                isPassValidate = false;
                                break;
                            }
                        }
                    }
                }

                // debugger;
                if (!this.isSameDay(camMinDate, contractStartDate)) {
                    isPassValidate = false;
                }
                if (!this.isSameDay(camMaxDate, contractEndDate)) {
                    isPassValidate = false;
                }
            } else {
                isPassValidate = false;
            }
        }

        if (periodPricing) {
            if (periodPricing.length > 0) {
                periodMinDate = new Date(periodPricing[0].PricingFrom);
                periodMaxDate = new Date(periodPricing[0].PricingTo);

                periodPricing.forEach((eachDate, Index) => {
                    if (!eachDate.isToDeleteRecord) {
                        if (new Date(eachDate.PricingFrom) < periodMinDate) {
                            periodMinDate = new Date(eachDate.PricingFrom);
                        }
                        if (new Date(eachDate.PricingTo) > periodMaxDate) {
                            periodMaxDate = new Date(eachDate.PricingTo);
                        }

                        periodPeriodFromList.push(new Date(eachDate.PricingFrom));
                        periodPeriodToList.push(new Date(eachDate.PricingTo));
                    }

                });
                periodPeriodFromList.sort((a, b) => a - b);
                periodPeriodToList.sort((a, b) => a - b);

                if (periodPeriodFromList.length > 0 && periodPeriodToList.length > 0) {

                    for (var i = 0; i < periodPeriodToList.length; i++) {

                        tomorrow = new Date(periodPeriodToList[i]);
                        tomorrow.setDate(periodPeriodToList[i].getDate() + 1);

                        if (!periodPeriodFromList.includes(tomorrow)) {

                            if (this.isSameDay(periodPeriodToList[i], contractEndDate)) {
                                isPassValidate = true;
                            } else {
                                isPassValidate = false;
                                break;
                            }
                        }
                    }
                }

                if (!this.isSameDay(periodMinDate, contractStartDate)) {
                    isPassValidate = false;
                }
                if (!this.isSameDay(periodMaxDate, contractEndDate)) {
                    isPassValidate = false;
                }
            } else {
                isPassValidate = false;
            }
        }

        return true;
    },
    getOppRecordType: function (component, event) {
        let oppId = component.get("v.recordId");
        // component.set("v.toggleSpinner", true);

        var action = component.get("c.getRecordTypeName");
        action.setParams({ recordId: oppId, sObjectName: "Opportunity" });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedData = response.getReturnValue();
                component.set("v.recordTypeName", returnedData)
                // component.set("v.toggleSpinner", false);

            }
        });

        $A.enqueueAction(action);


    },
    getPageData: function (component, event, oppDetail) {
        console.log("-----getPageData------");
        var oppId = component.get("v.recordId");
        var isMeasurementAreaChange = false;

        component.set("v.toggleSpinner", true);
        // debugger;
        var action = component.get("c.getSavedSelectedRO");
        action.setParams({
            recordId: oppId,
            opp_ContractStartDate: oppDetail.contractStartDate,
            opp_ContractEndDate: oppDetail.contractEndDateFrom
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedData = response.getReturnValue();
                console.log(returnedData);

                var measurementIdList = null;
                var selectedRoom = JSON.parse(returnedData);
                console.log('Test Init Selected Room', selectedRoom);
                if (selectedRoom && selectedRoom.length > 0) {
                    component.set("v.toggleSpinner", true);
                    component.set("v.seletedRoom", selectedRoom);
                    component.set("v.isDisabledSaveButton", false);
                    component.set("v.isInitialPageWithRO", true);



                    measurementIdList =[];
                    var oppLeasableArea = 0;
                    var oppTotalArea = 0;

                    selectedRoom.forEach((eachSelectedRoom, selesctedRoomIndex) => {
                       // debugger;
                       oppLeasableArea += eachSelectedRoom.leasableArea;
                       oppTotalArea += eachSelectedRoom.totalArea;
                       if (eachSelectedRoom.roMeasurmentList && eachSelectedRoom.roMeasurmentList.length > 0) {

                            eachSelectedRoom.roMeasurmentList.forEach((eachROMeasurement, roMeasurmentIndex) => {
                                // debugger;
                                if (eachROMeasurement.measurementId) {

                                    if (!measurementIdList.includes(eachROMeasurement.measurementId)) {
                                        measurementIdList.push(eachROMeasurement.measurementId);
                                    }
                                }
                            });
                       }
                    });

                    if (oppDetail.oppStageName == "Quotation Preparation") {
                        oppDetail.totalMeasurmentArea = oppTotalArea;
                        oppDetail.new_totalMeasurmentArea = oppTotalArea;
                        oppDetail.totalLeasableArea = oppLeasableArea;
                        oppDetail.new_totalLeasableArea = oppLeasableArea;

                        let isROMeasurementValid =  selectedRoom.filter(eachSelectedRoom => eachSelectedRoom.roMeasurmentList.length > 0);

                        if((oppDetail.new_totalMeasurmentArea != oppDetail.old_totalMeasurmentArea || oppDetail.new_totalLeasableArea != oppDetail.old_totalLeasableArea)
                            && isROMeasurementValid.length){
                            component.set("v.isMeasurementAreaChange", true);
                            isMeasurementAreaChange = true;
                        }

                        component.set("v.oppObject",oppDetail);
                        console.log("OppDetai After getPageData", oppDetail);
                    }



                    var camPrincg = {};
                    var rentService = {};
                    var periodPricing = {};
                    var expenseInstallment = {};
                    var otherExpense = {};
                    var deposit = {};
                    var expenseOptionValue = [];
                    component.lax.enqueueAll([
                        {
                            name: "c.getSavedCAMPricingDetail",
                            params: {
                                "recordId": oppId,
                                "escalationType": oppDetail.camOrAirEscalationType,
                                "escalationRate": oppDetail.camOrAirEscalationRate,
                                "selectedRoomJson" : JSON.stringify(selectedRoom),
                                "oppUiWrapper": JSON.stringify(oppDetail)
                            },
                            options: { background: true },
                        },
                        {
                            name: "c.getSavedRentServicePricingDetail",
                            params: {
                                "oppId": oppId,
                                "selectedRoomJson": JSON.stringify(selectedRoom),
                                "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                                "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                                "oppUiWrapper" : JSON.stringify(oppDetail)
                            },
                            options: { background: true },
                        },
                        {
                            name: "c.getSavedPeriodPricingDetail",
                            params: {
                                "oppId": oppId,
                                "oppUiWrapper": JSON.stringify(oppDetail),
                                "selectedRoomJson": JSON.stringify(selectedRoom),
                                "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                                "calculationMethod": oppDetail.calculationMethod
                            },
                            options: { background: true },
                        },
                        {
                            name: "c.getSavedExpenseINstallmentJson",
                            params: {
                                "oppId": oppId,
                            },
                            options: { background: true },
                        },
                        {
                            name: "c.getSavedOtherExpenseJson",
                            params: {
                                "oppId": oppId,
                                "rentType": oppDetail.rentType
                            },
                            options: { background: true },
                        },
                        {
                            name: "c.getSavedDepositObjectJson",
                            params: {
                                "oppId": oppId,
                                "camOrAirServiceCondition": oppDetail.camOrAirService,
                                "oppUiWrapper": JSON.stringify(oppDetail)
                            },
                            options: { background: true },
                        },
                        {
                            name: "c.getPicklistValueFromPageSettingFromRentType",
                            params: {
                                "rentType": oppDetail.rentType,
                                "screenToDisplay": "Other",
                                "mesurementListId" : measurementIdList
                            },
                            options: { background: true },
                        },{
                            name: "c.getCAMPricingDetail",
                            params: {
                                "oppId": oppId,
                                "selectedRoomJson": JSON.stringify(selectedRoom),
                                "contractStartDate": oppDetail.contractStartDateForm,
                                "contractEndDate": oppDetail.contractEndDateFrom,
                                "leaseType": oppDetail.leaseType,
                                "escalationRate": oppDetail.camOrAirEscalationRate,
                                "isUpdateOpp": false,
                                "optionToRenewYear" : oppDetail.optionToRenewYear,
                                "optionToRenewMonth": oppDetail.optionToRenewMonth,
                                "oppUiWrapper": JSON.stringify(oppDetail)
                            },
                            options: { background: true },
                        }
                    ]).then(result => {

                        console.log('init camPricing', result[0])
                        console.log('init RentAndService', result[1]);
                        console.log('init periodPricing', result[2]);
                        console.log('init expesefee', result[3]);
                        let expenseOptionMap = result[6];
                        // debugger;


                        if (result[1]) {
                            component.set("v.rentServicePricing", JSON.parse(result[1]));
                            component.set("v.isInitialPageWithRentService", true);
                        }
                        if (result[2]) {
                            component.set("v.periodPricing", JSON.parse(result[2]));
                            component.set("v.isInitialPageWithPeriod", true);
                        }
                        if (result[3]) {
                            component.set("v.expenseList", JSON.parse(result[3]));
                        }
                        if (result[4]) {
                            component.set("v.otherPageObject", JSON.parse(result[4]));
                        }

                        if (expenseOptionMap) {
                            console.log("expenseOptionMap: " + JSON.stringify(expenseOptionMap));
                            var isSkip = false;
                            var actualLeaseHold = [];
                            for (var key in expenseOptionMap) {
                                if (oppDetail.spetialOtherTypePicklist.includes(key)) {
                                    if (!isSkip) {
                                        expenseOptionValue.push({ value: "ค่าสิทธิการเช่า", label: "ค่าสิทธิการเช่า" });
                                        isSkip = true;
                                    }
                                }else{
                                    expenseOptionValue.push({ value: key, label: expenseOptionMap[key] });
                                }
                            }
                            console.log("option Expense Option" + JSON.stringify(expenseOptionValue));
                            component.set('v.expenseTypeOption', expenseOptionValue);

                            for (var key in expenseOptionMap){
                                if (oppDetail.spetialOtherTypePicklist.includes(key)) {
                                    actualLeaseHold.push(key);
                                }
                            }

                            oppDetail.spetialOtherTypePicklist = actualLeaseHold;
                            component.set("v.oppObject.spetialOtherTypePicklist",oppDetail.spetialOtherTypePicklist);
                        }

                        if (!oppDetail.isNoCAM) {
                            if (result[0]) {
                                // if (Object.keys(JSON.parse(result[0])).length !== 0) {
                                component.set("v.camPricing", JSON.parse(result[0]));
                                component.set("v.isInitialPageWithCAM", true);
                                // }
                            }else{
                                if (result[7]) {
                                    // if (Object.keys(JSON.parse(result[0])).length !== 0) {
                                    component.set("v.camPricing", JSON.parse(result[7]));
                                    // }
                                }
                            }

                        }else{
                            if (result[7]) {
                                // if (Object.keys(JSON.parse(result[0])).length !== 0) {
                                component.set("v.camPricing", JSON.parse(result[7]));
                                // }
                            }
                        }

                        if (result[5]) {
                            // if (Object.keys(JSON.parse(result[5])).length !== 0) {

                            var savedDepositJson  = JSON.parse(result[5]);

                            if ((savedDepositJson.DepositCalculationType == null && savedDepositJson.NumberOfInstallment == null) || isMeasurementAreaChange) {

                                var savedPricing = JSON.parse(result[2]);
                                var oppContractEnDate = oppDetail.contractEndate;
                                var periodLastIndex = savedPricing.length - 1;


                                savedPricing.forEach((periodRowData, periodIndex) => {
                                    if(!periodRowData.isToDeleteRecord){
                                        let startPeriod = new Date(periodRowData.PricingFrom);
                                        let endPeriod = new Date(periodRowData.PricingTo);
                                        let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                        if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                            periodLastIndex = periodIndex;
                                        }
                                    }
                                });


                                var camOrAirServicePrice = 0;
                                var camPricing = component.get("v.camPricing");
                                if (!oppDetail.isNoCAM) {
                                    var camLastIndex = camPricing.CAMYearPeriod.length - 1;
                                    camPricing.CAMYearPeriod.forEach((camPeriodRowData, camPeriodIndex) => {
                                        if (!camPeriodRowData.isToDeleteRecord) {

                                            let startPeriod = new Date(camPeriodRowData.DateFrom);
                                            let endPeriod = new Date(camPeriodRowData.DateTo);
                                            let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                            if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                                camLastIndex = camPeriodIndex;
                                            }
                                        }

                                    });
                                    var lastPeriodOfCAMORAirService = camPricing.CAMYearPeriod[camLastIndex];
                                    camOrAirServicePrice = lastPeriodOfCAMORAirService.TotalPrice;
                                }

                                var lastPeriodOfPricing = savedPricing[periodLastIndex];
                                var rentPrice = 0;
                                var rentPercent = lastPeriodOfPricing.Proportion.Rent;
                                var servicePrice = 0;
                                var servicePercent = lastPeriodOfPricing.Proportion.Service;

                                let price = this.calculateRentAndService(lastPeriodOfPricing, oppDetail, rentPercent, servicePercent, camOrAirServicePrice);
                                rentPrice = price.rentPrice;
                                servicePrice = price.servicePrice;
                                rentPrice = (typeof rentPrice == 'number')?this.roundDecimal(rentPrice):0;
                                servicePrice = (typeof servicePrice == 'number')?this.roundDecimal(servicePrice):0;

                                var action = component.get("c.getDepositObjectJson");
                                action.setParams({ camORAirServiceCondition: camPricing.camOrAirService,
                                                    camPrice: camOrAirServicePrice,
                                                    rentPrice: rentPrice,
                                                    servicePrice: servicePrice,
                                                    depositMonth: oppDetail.depositMonth,
                                                    parentContract: oppDetail.parentContract,
                                                    oppUiWrapper: JSON.stringify(oppDetail)});

                                action.setCallback(this, function (response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var returnedDeposit = response.getReturnValue();
                                        var depositObject = JSON.parse(returnedDeposit);
                                        depositObject.OtherDepositList = savedDepositJson.OtherDepositList;
                                        console.log('init New Security Deposit', result[5]);
                                        component.set("v.depositObject", depositObject);

                                        if (isMeasurementAreaChange) {
                                            this.processSetNewDataWhenMeasurementAreaChanged(component, event, oppId, JSON.stringify(camPricing), result[1], result[2], returnedDeposit, oppDetail, selectedRoom, result[3]);
                                        }


                                    }
                                });
                                $A.enqueueAction(action);

                            }else{

                                console.log('init Deposit', result[5]);
                                component.set("v.depositObject", JSON.parse(result[5]));
                            }

                            // }
                        }
                        component.set("v.toggleSpinner", false);


                    });
                } else {
                    //console.log('No Select Unit');
                    component.set("v.isDisabledSaveButton", true);
                    component.set("v.toggleSpinner", false);
                    // debugger;
                }
            }
        });

        $A.enqueueAction(action);

    },

    processSetNewDataWhenMeasurementAreaChanged: function (component, event, oppId, camObjectJson, rentAndServiceObjectJson, pricingObjectJson, depositObjectJson, oppDetail, selectedRoom, expenseAndFee){

        component.set("v.toggleSpinner", true);
        component.lax.enqueueAll([
        {
            name: "c.updateOppLineItem",
            params: {
                "selectedRoomJson": JSON.stringify(selectedRoom)
            },
            options: { background: true },
        },
        {
            name: "c.savePricingApex",
            params: {
                "camorAirServiceJson": camObjectJson,
                "rentServiceJson": rentAndServiceObjectJson,
                "periodPricingJson": pricingObjectJson,
                "oppUiWrapper": JSON.stringify(oppDetail),
                "oppId": oppId
            },
            options: { background: true },
        },
        {
            name: "c.saveDepositApex",
            params: {
                "depositJson": depositObjectJson,
                "oppId": oppId,
                "oppUiWrapper": JSON.stringify(oppDetail),
                "isInitialDeposit": true
            },
            options: { background: true },
        },
        {
            name: "c.editExpenseAndFeeWhenMeasurementChanged",
            params: {
                "oppId": oppId,
                "expenseAndFeeObjectJson":expenseAndFee,
                "selectedRoomJson": JSON.stringify(selectedRoom),
                "oppUiWrapper": JSON.stringify(oppDetail)
            },
            options: { background: true },
        }
        ]).then(result => {
            var newSelectedRoom = result[0];
            var savePricingResult = result[1];
            var saveDepositResult = result[2];
            var newExpenseList = result[3];

            component.set("v.seletedRoom", JSON.parse(newSelectedRoom));
            component.set("v.expenseList", JSON.parse(result[3]));

            // debugger;
            if (!savePricingResult.messageAura.isError) {
                component.lax.enqueueAll([
                    {
                        name: "c.getSavedCAMPricingDetail",
                        params: {
                            "recordId": oppId,
                            "escalationType": oppDetail.camOrAirEscalationType,
                            "escalationRate": oppDetail.camOrAirEscalationRate,
                            "selectedRoomJson" : newSelectedRoom,
                            "oppUiWrapper": JSON.stringify(oppDetail)
                        },
                        options: { background: true },
                    },
                    {
                        name: "c.getSavedRentServicePricingDetail",
                        params: {
                            "oppId": oppId,
                            "selectedRoomJson": newSelectedRoom,
                            "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                            "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                            "oppUiWrapper" : JSON.stringify(oppDetail)
                        },
                        options: { background: true },
                    },
                    {
                        name: "c.getSavedPeriodPricingDetail",
                        params: {
                            "oppId": oppId,
                            "oppUiWrapper": JSON.stringify(oppDetail),
                            "selectedRoomJson": newSelectedRoom,
                            "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                            "calculationMethod": oppDetail.calculationMethod
                        },
                        options: { background: true },
                    }
                ]).then(getSavedresult => {


                    if (getSavedresult[0]) {
                        // if (Object.keys(JSON.parse(getSavedresult[0])).length !== 0) {
                        component.set("v.camPricing", JSON.parse(getSavedresult[0]));
                        component.set("v.isInitialPageWithCAM", true);
                        // }
                    }

                    if (getSavedresult[1]) {
                        // if (Object.keys(JSON.parse(getSavedresult[1])).length !== 0) {

                        component.set("v.rentServicePricing", JSON.parse(getSavedresult[1]));
                        component.set("v.isInitialPageWithRentService", true);
                        // }
                    }

                    if (getSavedresult[2]) {
                        // if (Object.keys(JSON.parse(getSavedresult[2])).length !== 0) {

                        component.set("v.periodPricing", JSON.parse(getSavedresult[2]));
                        component.set("v.isInitialPageWithPeriod", true);
                        // }
                    }

                });
            } else {
                component.set("v.toggleSpinner", false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": savePricingResult.messageAura.message
                });
                toastEvent.fire();
            }


            if (!saveDepositResult.messageAura.isError) {
                    var action = component.get("c.getSavedDepositObjectJson");
                    action.setParams({ oppId: oppId, camOrAirServiceCondition: oppDetail.camOrAirService, oppUiWrapper: JSON.stringify(oppDetail) });

                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            // debugger;

                            var returnedData = response.getReturnValue();

                            if (returnedData) {
                                component.set("v.depositObject", JSON.parse(returnedData));
                                component.set("v.toggleSpinner", false);
                            }

                        }
                    });
                    $A.enqueueAction(action);
            }else {
                component.set("v.toggleSpinner", false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": saveDepositResult.messageAura.message
                });
                toastEvent.fire();
            }


        });
    },

    getOppDetail: function (component, event) {
        component.set("v.toggleSpinner", true);
        let oppId = component.get("v.recordId");

        var action = component.get("c.getOppDetail");
        action.setParams({ recordId: oppId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnedData = response.getReturnValue();

                var jsonData = JSON.parse(returnedData);
                console.log(returnedData);

                component.set("v.oppObject", jsonData);
                // debugger;
                if (jsonData.usageType) {
                    component.set("v.selectedUsageType", jsonData.usageType);
                } else {
                    component.set("v.selectedUsageType", 'Retail Shop');
                }

                if (jsonData.leaseType === 'Long-Term' && jsonData.longleaseType == 'ระบุราคาปีปฏิทินแรก') {
                    component.set("v.rentServiceType", "Advance");
                }

                var pricingType = jsonData.pricingType;
                this.getComponentOptionHelper(component, event, pricingType);
                //console.log("=====================Check 1===================");
                if (pricingType === "GP") {
                    this.getGPPricingComponentOptionHelper(component, event, pricingType);
                }
                //console.log("=====================Check 2===================");
                this.getPageData(component, event, jsonData);
            }
        });

        $A.enqueueAction(action);

    },

    getComponentOptionHelper: function (component, event, pricingType) {

        var usageTypeOptionValue = [];
        var calculationReportingOptionValue = [];
        var calculationMethodOptionValue = [];
        var reportingRuleOptioValue = [];
        // var expenseOptionValue = [];
        var otherDepositOptionValue = [];
        var expenseDepositSupTypeOptionValue = [];
        var depositInputMethodOptionValue = [];
        var depositOptionValue = [];
        var paymenyTypeOptionValue = [];
        var minTypeOptioValue = [];
        var otherExpenseOptioValue = [];
        var yearlyTierValue = [];
        var oppDetail = component.get("v.oppObject");

        var recordType = component.get("v.recordTypeName");

        component.lax.enqueueAll([
            {
                name: "c.getPicklistOption",
                params: {
                    "objectName": "Units__c",
                    "picklistField": "Usage_Type__c"
                },
                options: { background: true },
            },
            // {
            //     name: "c.getPicklistOption",
            //     params: {
            //         "objectName": "Opportunity",
            //         "picklistField": "tms_CalculationAndReporting__c"
            //     },
            //     options: { background: true },
            // },
            {
                name: "c.getPicklistOption",
                params: {
                    "objectName": "Opportunity",
                    "picklistField": "Calculation_Method__c"
                },
                options: { background: true },
            },
            {
                name: "c.getPicklistValueFromPageSetting",
                params: {
                    "conditionField": "ScreentoDisplay__c",
                    "conditionValue": "Other Deposit",
                    "contractType": oppDetail.contractTypeValue,
                },
                options: { background: true },
            },
            {
                name: "c.getOtherExpenseSubtype",
                params: {
                    "rentType": oppDetail.rentType
                },
                options: { background: true },
            },
            {
                name: "c.getPicklistOption",
                params: {
                    "objectName": "OpportunityDepositExpense__c",
                    "picklistField": "DepositInputMethod__c"
                },
                options: { background: true },
            },
            {
                name: "c.getPicklistOption",
                params: {
                    "objectName": "OpportunityPrice__c",
                    "picklistField": "PaymentType__c"
                },
                options: { background: true },
            },
            {
                name: "c.getPicklistOption",
                params: {
                    "objectName": "OpportunityPeriod__c",
                    "picklistField": "MinType__c"
                },
                options: { background: true },
            },
            {
                name: "c.getOtherExpenseOption",
                params: {
                    "rentType": oppDetail.rentType
                },
                options: { background: true },
            },
            {
                name: "c.getPicklistOption",
                params: {
                    "objectName": "OpportunityDepositExpense__c",
                    "picklistField": "DepositOption__c"
                },
                options: { background: true },
            },
            // {
            //     name: "c.getPicklistOption",
            //     params: {
            //         "objectName": "OpportunityGrading__c",
            //         "picklistField": "GradingTierOption__c"
            //     },
            //     options: { background: true },
            // }
        ]).then(result => {

            let usageTypeOptionMap = result[0];
            //let calculationReportingOptionMap = result[1];
            let calculationReportingOptionMap = {};
            let calculationMethodOptionMap = result[1];
            let otherDepositOptionMap = result[2];
            let expenseDepositSubTypeOptionMap = result[3];
            let depositInputMethodOptionMap = result[4];
            let paymentTypeOptionMap = result[5];
            let minTypeOptionMap = result[6];
            let otherExpenseOptionMap = result[7];
            let depositOptionMap = result[8];
            //let yearlyTierOptionMap = result[10];
            let yearlyTierOptionMap = {"Monthly คำนวณ GP ทุกเดือน":"Monthly คำนวณ GP ทุกเดือน"};


            if (usageTypeOptionMap) {

                for (var key in usageTypeOptionMap) {
                    usageTypeOptionValue.push({ value: key, label: usageTypeOptionMap[key] });
                }
                console.log("usageTypeOptionValue" + JSON.stringify(usageTypeOptionValue));
                component.set('v.usageTypeOption', usageTypeOptionValue);

                var rawValueUsageType = component.get("v.selectedUsageType");
                component.set("v.outputUsageType", usageTypeOptionMap[rawValueUsageType]);
            }

            if (calculationReportingOptionMap) {
                for (var key in calculationReportingOptionMap) {
                    calculationReportingOptionValue.push({ value: key, label: calculationReportingOptionMap[key] });
                }
                console.log("option Calcutaion Repoting" + calculationReportingOptionValue);
                component.set('v.calcultationAndReporting', calculationReportingOptionValue);
            }

            if (calculationMethodOptionMap) {
                //console.log(JSON.stringify(calculationMethodOptionMap));
                for (var key in calculationMethodOptionMap) {
                    // debugger;
                    //if (pricingType === "Fixed" && calculationMethodOptionMap[key].includes("Fix")) {
                    if (pricingType === "Fixed" && calculationMethodOptionMap[key].includes("Fixed Unit")) {
                        calculationMethodOptionValue.push({ value: key, label: calculationMethodOptionMap[key] });
                    }

                    if (pricingType === "GP" && calculationMethodOptionMap[key].includes("GP")) {
                        calculationMethodOptionValue.push({ value: key, label: calculationMethodOptionMap[key] });
                    }
                }
                console.log("calculation Method Option" + calculationMethodOptionValue);
                component.set('v.calculationMethodOption', calculationMethodOptionValue);
            }
            //console.log("option Other Deposit Option" + otherDepositOptionMap);
            if (otherDepositOptionMap) {
                for (var key in otherDepositOptionMap) {
                    otherDepositOptionValue.push({ value: key, label: otherDepositOptionMap[key] });
                }
                component.set('v.otherDepositTypeOption', otherDepositOptionValue);
            }else{
                component.set("v.disabledAddDeposit",true);
            }

            if (expenseDepositSubTypeOptionMap) {
                for (var key in expenseDepositSubTypeOptionMap) {
                    expenseDepositSupTypeOptionValue.push({ value: key, label: expenseDepositSubTypeOptionMap[key] });
                }
                console.log("option Expense Deposit" + JSON.stringify(expenseDepositSupTypeOptionValue));
                component.set('v.expenseDepositSubTypeOption', expenseDepositSupTypeOptionValue);
            }

            if (depositInputMethodOptionMap) {
                for (var key in depositInputMethodOptionMap) {
                    depositInputMethodOptionValue.push({ value: key, label: depositInputMethodOptionMap[key] });
                }
                console.log("option Deposit Input Method" + depositInputMethodOptionValue);
                component.set('v.depositInputMethodOption', depositInputMethodOptionValue);
            }

            if (depositOptionMap) {
                for (var key in depositOptionMap) {
                    depositOptionValue.push({ value: key, label: depositOptionMap[key] });
                }
                component.set('v.depositOption', depositOptionValue);
            }

            if (paymentTypeOptionMap) {
                for (var key in paymentTypeOptionMap) {
                    paymenyTypeOptionValue.push({ value: key, label: paymentTypeOptionMap[key] });
                }
                console.log("option paymentType Input Method" + paymenyTypeOptionValue);
                component.set('v.paymentTypeOption', paymenyTypeOptionValue);
            }

            if (minTypeOptionMap) {
                for (var key in minTypeOptionMap) {
                    if(oppDetail.rentType == 'Billboard_Rental' && key == 'Measurement') {
                        //minTypeOptioValue.push({ value: key, label: minTypeOptionMap[key] });
                    } else {
                        minTypeOptioValue.push({ value: key, label: minTypeOptionMap[key] });
                    }
                }
                component.set("v.minTypeOption", minTypeOptioValue);
            }

            if (otherExpenseOptionMap) {
                var isOwnCashier = component.get("v.oppObject.isOwnCashier");
                for (var key in otherExpenseOptionMap) {
                    if (!isOwnCashier) {
                        if (otherExpenseOptionMap[key] != 'Cashier') {
                            otherExpenseOptioValue.push({ value: key, label: otherExpenseOptionMap[key] });
                        }
                    }else{
                        otherExpenseOptioValue.push({ value: key, label: otherExpenseOptionMap[key] });
                    }
                }
                component.set("v.otherExpenseOption", otherExpenseOptioValue);
            }

            if (yearlyTierOptionMap) {
                for (var key in yearlyTierOptionMap) {
                    yearlyTierValue.push({ value: key, label: yearlyTierOptionMap[key] });
                }
                component.set("v.yearlyTierOption", yearlyTierValue);
            }

        });
    },

    getGPPricingComponentOptionHelper: function (component, event, pricingType) {
        var reportingRuleOptioValue = [];

        // component.lax.enqueueAll([
        //     {
        //         name: "c.getPicklistOption",
        //         params: {
        //             "objectName": "OpportunityGrading__c",
        //             "picklistField": "ReportingRule__c"
        //         },
        //         options: { background: true },
        //     }
        // ]).then(result => {
        //     let reportingRuleOptionMap = result[0];
        //     if (reportingRuleOptionMap) {
        //         for (var key in reportingRuleOptionMap) {
        //             reportingRuleOptioValue.push({ value: key, label: reportingRuleOptionMap[key] });
        //         }
        //         component.set('v.reportingRuleOption', reportingRuleOptioValue);
        //         component.set('v.reportingRuleMap', reportingRuleOptionMap);
        //         console.log("reportingRuleOptioValue" + component.get("v.reportingRuleOption"));

        //     }
        // });
        let reportingRuleOptionMap = {'Sales before VAT': 'Sales before VAT'};
            for (var key in reportingRuleOptionMap) {
                reportingRuleOptioValue.push({ value: key, label: reportingRuleOptionMap[key] });
            }
            component.set('v.reportingRuleOption', reportingRuleOptioValue);
            component.set('v.reportingRuleMap', reportingRuleOptionMap);
            console.log("reportingRuleOptioValue" + component.get("v.reportingRuleOption"));
    },
    processDeleteOldRecordToSave: function (component, event) {
        component.set("v.camPricing", null);
        component.set("v.rentServicePricing", null);
        component.set("v.periodPricing", null);
        component.set("v.expenseList", null);
        component.set("v.depositObject", null);
        component.set("v.otherPageObject", null);
    },

    saveSelectedRentalObject: function (component, event, stepNumber) {
        var isInitialPageWithRO = component.get("v.isInitialPageWithRO");
        var selectedroom = component.get("v.seletedRoom");
        var selectedRoomJsonString = JSON.stringify(selectedroom);
        var oppId = component.get("v.recordId");
        var oppDetail = component.get("v.oppObject");
        var contractStartDate_DateForm = oppDetail.contractStartDateForm;
        var contractEndDate_DateForm = oppDetail.contractEndDateFrom;
        var calculationMethod = oppDetail.calculationMethod;
        var camOrAirEscalationType = oppDetail.camOrAirEscalationType;
        var leaseType = oppDetail.leaseType;
        var opptionToRenewYear = oppDetail.optionToRenewYear;
        var opptionToRenewMonth = oppDetail.optionToRenewMonth;
        var periodPricing = component.get("v.periodPricing");
        console.log("periodPricing: "+JSON.stringify(periodPricing));
        console.log("selectedRoomJsonString: "+selectedRoomJsonString);


        if (component.get("v.isChangeSelectedRO")) {
            // debugger;
            //console.log("=====================Check 1===================");
            if (isInitialPageWithRO) {
                this.processDeleteOldRecordToSave(component, event);
            }
            var action = component.get("c.saveSelectedRentalObject");
            action.setParams({ selectedRoomJson: selectedRoomJsonString, oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Success");
                    // debugger;
                    //console.log("=====================Check 2===================");
                    var returnedData = response.getReturnValue();
                    var newSelectedRoom = JSON.parse(returnedData);
                    component.set("v.seletedRoom", newSelectedRoom);


                    var action = component.get("c.getOtherExpenseJson");
                    action.setParams({ rentType: oppDetail.rentType });

                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var returnedData = response.getReturnValue();
                            // returnedData.rateAndAreaFormatList.sort((a, b) => a.Sequence - b.Sequence);
                            // returnedData.fixedFormatList.sort((a, b) => a.Sequence - b.Sequence);
                            //console.log("=====================Check 3===================");
                            var jsonData = JSON.parse(returnedData);
                            console.log("Other ExpeseDetail", returnedData);

                            component.set("v.otherPageObject", jsonData);
                            this.getPricingDaetail(component, event, stepNumber, selectedRoomJsonString, contractStartDate_DateForm, contractEndDate_DateForm, calculationMethod, leaseType, camOrAirEscalationType, opptionToRenewYear, opptionToRenewMonth);

                        }
                    });

                    $A.enqueueAction(action);
                }
            });

            $A.enqueueAction(action);
        } else {
            if(!oppDetail.isReadOnly){
                //console.log("=====================Check 1===================");
                var action = component.get("c.updateOppArea");
                action.setParams({ selectedRoomJson: selectedRoomJsonString, oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("Success");
                        //console.log("=====================Check 2===================");
                        var returnedData = response.getReturnValue();

                        component.set("v.toggleSpinner", false);
                        if (returnedData) {
                            if (periodPricing.length == 0) {
                                // debugger;
                                this.getPricingDaetail(component, event, stepNumber, selectedRoomJsonString, contractStartDate_DateForm, contractEndDate_DateForm, calculationMethod, leaseType, camOrAirEscalationType, opptionToRenewYear, opptionToRenewMonth);
                            } else {
                                // debugger;
                                this.changeStep(component, event, stepNumber);
                                component.set("v.toggleSpinner", false);
                            }
                        }else{
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message":"Somthing went wrong while updating Opportunity."
                            });
                            toastEvent.fire();
                        }

                    }
                });

                $A.enqueueAction(action);
            }else{
                if (periodPricing.length == 0) {
                    // debugger;
                    this.getPricingDaetail(component, event, stepNumber, selectedRoomJsonString, contractStartDate_DateForm, contractEndDate_DateForm, calculationMethod, leaseType, camOrAirEscalationType, opptionToRenewYear, opptionToRenewMonth);
                } else {
                    // debugger;
                    this.changeStep(component, event, stepNumber);
                    component.set("v.toggleSpinner", false);
                }
            }

        }

    },

    savePricing: function (component, event, stepNumber) {
        if (this.validateProportionNull(component, event)) {
            //debugger;
            component.set("v.toggleSpinner", true);
            var camPricing = component.get("v.camPricing");
            var rentService = component.get("v.rentServicePricing");
            var oppId = component.get("v.recordId");
            var pricing = component.get("v.periodPricing");
            var oppDetail = component.get("v.oppObject");
            var camOrAirService = camPricing.CAMOrAirService;
            var depositMonth = oppDetail.depositMonth;
            var parentContract = oppDetail.parentContractId;
            var selectedRoom = component.get("v.seletedRoom");
            console.log('camPricing: '+JSON.stringify(camPricing));
            console.log("pricing ", JSON.stringify(pricing));
            console.log('selectedRoom: '+JSON.stringify(selectedRoom));

            let depositObject = component.get("v.depositObject");
            //debugger;

            if (component.get("v.isChangePricing")) {
                console.log('change pricing = true');
                component.lax.enqueueAll([
                {
                    name: "c.savePricingApex",
                    params: {
                        "camorAirServiceJson": JSON.stringify(camPricing),
                        "rentServiceJson": JSON.stringify(rentService),
                        "periodPricingJson": JSON.stringify(pricing),
                        "oppUiWrapper": JSON.stringify(oppDetail),
                        "oppId": oppId
                    },
                    options: { background: true },
                }
                ]).then(result => {

                    var savePricingResult = result[0];

                    oppDetail.camOrAirEscalationType = camPricing.CAMCondition;
                    oppDetail.camOrAirEscalationRate = camPricing.CAMEscationRate.value;
                    oppDetail.rentServiceEscalationType = rentService.RentCondition;
                    oppDetail.rentServiiceEscalationRate = rentService.RentServiceEscalationRate.value;

                    component.set("v.oppObject", oppDetail);

                    //debugger;
                    if (!savePricingResult.messageAura.isError) {


                        component.lax.enqueueAll([
                            {
                                name: "c.getSavedCAMPricingDetail",
                                params: {
                                    "recordId": oppId,
                                    "escalationType": oppDetail.camOrAirEscalationType,
                                    "escalationRate": oppDetail.camOrAirEscalationRate,
                                    "selectedRoomJson" : JSON.stringify(selectedRoom),
                                    "oppUiWrapper": JSON.stringify(oppDetail)
                                },
                                options: { background: true },
                            },
                            {
                                name: "c.getSavedRentServicePricingDetail",
                                params: {
                                    "oppId": oppId,
                                    "selectedRoomJson": JSON.stringify(selectedRoom),
                                    "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                                    "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                                    "oppUiWrapper" : JSON.stringify(oppDetail)
                                },
                                options: { background: true },
                            },
                            {
                                name: "c.getSavedPeriodPricingDetail",
                                params: {
                                    "oppId": oppId,
                                    "oppUiWrapper": JSON.stringify(oppDetail),
                                    "selectedRoomJson": JSON.stringify(selectedRoom),
                                    "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                                    "calculationMethod": oppDetail.calculationMethod
                                },
                                options: { background: true },
                            }
                        ]).then(result => {

                            var returnedDeposit = result[0];
                            var depositObject = JSON.parse(returnedDeposit);
                            console.log('getSavedCAMPricingDetail: '+returnedDeposit);
                            component.set("v.depositObject", depositObject);
                            component.set("v.isChangeDeposit", true);



                            if (result[0]) {
                                // if (Object.keys(JSON.parse(result[0])).length !== 0) {
                                component.set("v.camPricing", JSON.parse(result[0]));
                                component.set("v.isInitialPageWithCAM", true);
                                // }
                            }

                            if (result[1]) {
                                // if (Object.keys(JSON.parse(result[1])).length !== 0) {

                                component.set("v.rentServicePricing", JSON.parse(result[1]));
                                component.set("v.isInitialPageWithRentService", true);
                                // }
                            }

                            if (result[2]) {
                                // if (Object.keys(JSON.parse(result[2])).length !== 0) {

                                component.set("v.periodPricing", JSON.parse(result[2]));
                                component.set("v.isInitialPageWithPeriod", true);
                                // }
                                var savedPeriodPricing = JSON.parse(result[2]);
                                var oppContractEnDate = oppDetail.contractEndate;
                                var periodLastIndex = savedPeriodPricing.length - 1;

                                console.log("savePricng", JSON.stringify(savedPeriodPricing));

                                var camOrAirServicePrice = 0;
                                if (!oppDetail.isNoCAM) {
                                    var camLastIndex = camPricing.CAMYearPeriod.length - 1;
                                    camPricing.CAMYearPeriod.forEach((camPeriodRowData, camPeriodIndex) => {
                                        if (!camPeriodRowData.isToDeleteRecord) {

                                            let startPeriod = new Date(camPeriodRowData.DateFrom);
                                            let endPeriod = new Date(camPeriodRowData.DateTo);
                                            let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                            if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                                camLastIndex = camPeriodIndex;
                                            }
                                        }

                                    });
                                    var lastPeriodOfCAMORAirService = camPricing.CAMYearPeriod[camLastIndex];
                                    camOrAirServicePrice = lastPeriodOfCAMORAirService.TotalPrice;
                                }

                                savedPeriodPricing.forEach((periodRowData, periodIndex) => {
                                    if(!periodRowData.isToDeleteRecord){
                                        let startPeriod = new Date(periodRowData.PricingFrom);
                                        let endPeriod = new Date(periodRowData.PricingTo);
                                        let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                        if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                            periodLastIndex = periodIndex;
                                        }
                                    }
                                });

                                var lastPeriodOfPricing = savedPeriodPricing[periodLastIndex];
                                var rentPrice = 0;
                                var rentPercent = lastPeriodOfPricing.Proportion.Rent;
                                var servicePrice = 0;
                                var servicePercent = lastPeriodOfPricing.Proportion.Service;

                                let price = this.calculateRentAndService(lastPeriodOfPricing, oppDetail, rentPercent, servicePercent, camOrAirServicePrice);
                                rentPrice = price.rentPrice;
                                servicePrice = price.servicePrice;
                                rentPrice = (typeof rentPrice == 'number')?this.roundDecimal(rentPrice):0;
                                servicePrice = (typeof servicePrice == 'number')?this.roundDecimal(servicePrice):0;

                                var action = component.get("c.getDepositObjectJson");
                                action.setParams({ camORAirServiceCondition: camOrAirService,
                                                    camPrice: camOrAirServicePrice,
                                                    rentPrice: rentPrice,
                                                    servicePrice: servicePrice,
                                                    depositMonth: depositMonth,
                                                    parentContract: parentContract,
                                                    oppUiWrapper: JSON.stringify(oppDetail)});

                                action.setCallback(this, function (response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var returnedDeposit = response.getReturnValue();
                                        var depositObject = JSON.parse(returnedDeposit);
                                        console.log('getDepositObjectJson: '+returnedDeposit);
                                        component.set("v.depositObject", depositObject);


                                        var action = component.get("c.saveDepositApex");
                                        action.setParams({ depositJson: JSON.stringify(depositObject), oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail), isInitialDeposit:true });

                                        action.setCallback(this, function (response) {
                                            var state = response.getState();
                                            if (state === "SUCCESS") {

                                                let ret = response.getReturnValue();
                                                component.set("v.toggleSpinner", false);

                                                if (!ret.messageAura.isError) {

                                                    this.changeStep(component, event, stepNumber);

                                                } else {
                                                    let toastEvent = $A.get("e.force:showToast");
                                                    toastEvent.setParams({
                                                        "title": "Error!",
                                                        "type": "error",
                                                        "message": ret.messageAura.message
                                                    });
                                                    toastEvent.fire();
                                                }

                                            }
                                        });
                                        $A.enqueueAction(action);


                                    }
                                });
                                $A.enqueueAction(action);
                            }
                        });
                    } else {
                        component.set("v.toggleSpinner", false);
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": savePricingResult.messageAura.message
                        });
                        toastEvent.fire();
                    }


                });
            }
            else {
                // debugger;
                console.log('change pricing = false');
                if (component.get("v.isChangeGrading")) {
                    component.lax.enqueueAll([
                    {
                        name: "c.savePricingApex",
                        params: {
                            "camorAirServiceJson": JSON.stringify(camPricing),
                            "rentServiceJson": JSON.stringify(rentService),
                            "periodPricingJson": JSON.stringify(pricing),
                            "oppUiWrapper": JSON.stringify(oppDetail),
                            "oppId": oppId
                        },
                        options: { background: true },
                    }
                    ]).then(result => {

                        var savePricingResult = result[0];

                        oppDetail.camOrAirEscalationType = camPricing.CAMCondition;
                        oppDetail.camOrAirEscalationRate = camPricing.CAMEscationRate.value;
                        oppDetail.rentServiceEscalationType = rentService.RentCondition;
                        oppDetail.rentServiiceEscalationRate = rentService.RentServiceEscalationRate.value;

                        component.set("v.oppObject", oppDetail);

                        // debugger;
                        if (!savePricingResult.messageAura.isError) {
                            component.lax.enqueueAll([
                                {
                                    name: "c.getSavedCAMPricingDetail",
                                    params: {
                                        "recordId": oppId,
                                        "escalationType": oppDetail.camOrAirEscalationType,
                                        "escalationRate": oppDetail.camOrAirEscalationRate,
                                        "selectedRoomJson" : JSON.stringify(selectedRoom),
                                        "oppUiWrapper": JSON.stringify(oppDetail)
                                    },
                                    options: { background: true },
                                },
                                {
                                    name: "c.getSavedRentServicePricingDetail",
                                    params: {
                                        "oppId": oppId,
                                        "selectedRoomJson": JSON.stringify(selectedRoom),
                                        "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                                        "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                                        "oppUiWrapper" : JSON.stringify(oppDetail)
                                    },
                                    options: { background: true },
                                },
                                {
                                    name: "c.getSavedPeriodPricingDetail",
                                    params: {
                                        "oppId": oppId,
                                        "oppUiWrapper": JSON.stringify(oppDetail),
                                        "selectedRoomJson": JSON.stringify(selectedRoom),
                                        "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                                        "calculationMethod": oppDetail.calculationMethod
                                    },
                                    options: { background: true },
                                }
                            ]).then(result => {


                                if (result[0]) {
                                    // if (Object.keys(JSON.parse(result[0])).length !== 0) {
                                    component.set("v.camPricing", JSON.parse(result[0]));
                                    component.set("v.isInitialPageWithCAM", true);
                                    // }
                                }

                                if (result[1]) {
                                    // if (Object.keys(JSON.parse(result[1])).length !== 0) {

                                    component.set("v.rentServicePricing", JSON.parse(result[1]));
                                    component.set("v.isInitialPageWithRentService", true);
                                    // }
                                }

                                if (result[2]) {
                                    // if (Object.keys(JSON.parse(result[2])).length !== 0) {

                                    component.set("v.periodPricing", JSON.parse(result[2]));
                                    component.set("v.isInitialPageWithPeriod", true);
                                    // }
                                }

                                this.changeStep(component, event, stepNumber);
                                component.set("v.toggleSpinner", false);
                            });
                        } else {
                            component.set("v.toggleSpinner", false);
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": savePricingResult.messageAura.message
                            });
                            toastEvent.fire();
                        }


                    });
                }else{

                    if (!depositObject && camOrAirService) {

                        var action = component.get("c.getSavedPeriodPricingDetail");
                            action.setParams({ oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail), selectedRoomJson: JSON.stringify(selectedRoom), rentServiceEscalationType: oppDetail.rentServiceEscalationType,
                                calculationMethod: oppDetail.calculationMethod });

                            action.setCallback(this, function (response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {

                                    let ret = response.getReturnValue();
                                    if (ret) {
                                        var savedPricing = JSON.parse(ret);
                                        var oppContractEnDate = oppDetail.contractEndate;
                                        var periodLastIndex = savedPricing.length - 1;


                                        savedPricing.forEach((periodRowData, periodIndex) => {
                                            if(!periodRowData.isToDeleteRecord){
                                                let startPeriod = new Date(periodRowData.PricingFrom);
                                                let endPeriod = new Date(periodRowData.PricingTo);
                                                let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                                if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                                    periodLastIndex = periodIndex;
                                                }
                                            }
                                        });


                                        var camOrAirServicePrice = 0;
                                        if (!oppDetail.isNoCAM) {
                                            var camLastIndex = camPricing.CAMYearPeriod.length - 1;
                                            camPricing.CAMYearPeriod.forEach((camPeriodRowData, camPeriodIndex) => {
                                                if (!camPeriodRowData.isToDeleteRecord) {

                                                    let startPeriod = new Date(camPeriodRowData.DateFrom);
                                                    let endPeriod = new Date(camPeriodRowData.DateTo);
                                                    let targetDate = new Date(oppDetail.thirdYearOfPeriod);

                                                    if (targetDate >= startPeriod && targetDate <= endPeriod) {
                                                        camLastIndex = camPeriodIndex;
                                                    }
                                                }

                                            });
                                            var lastPeriodOfCAMORAirService = camPricing.CAMYearPeriod[camLastIndex];
                                            camOrAirServicePrice = lastPeriodOfCAMORAirService.TotalPrice;
                                        }

                                        var lastPeriodOfPricing = savedPricing[periodLastIndex];
                                        var rentPrice = 0;
                                        var rentPercent = lastPeriodOfPricing.Proportion.Rent;
                                        var servicePrice = 0;
                                        var servicePercent = lastPeriodOfPricing.Proportion.Service;

                                        let price = this.calculateRentAndService(lastPeriodOfPricing, oppDetail, rentPercent, servicePercent, camOrAirServicePrice);
                                        rentPrice = price.rentPrice;
                                        servicePrice = price.servicePrice;
                                        rentPrice = (typeof rentPrice == 'number')?this.roundDecimal(rentPrice):0;
                                        servicePrice = (typeof servicePrice == 'number')?this.roundDecimal(servicePrice):0;


                                        var action = component.get("c.getDepositObjectJson");
                                        action.setParams({ camORAirServiceCondition: camOrAirService,
                                                            camPrice: camOrAirServicePrice,
                                                            rentPrice: rentPrice,
                                                            servicePrice: servicePrice,
                                                            depositMonth: depositMonth,
                                                            parentContract: parentContract,
                                                            oppUiWrapper: JSON.stringify(oppDetail)});

                                        action.setCallback(this, function (response) {
                                            var state = response.getState();
                                            if (state === "SUCCESS") {
                                                var returnedDeposit = response.getReturnValue();
                                                var depositObject = JSON.parse(returnedDeposit);
                                                component.set("v.depositObject", depositObject);
                                                component.set("v.isChangeDeposit", true);

                                                this.changeStep(component, event, stepNumber);
                                                component.set("v.toggleSpinner", false);



                                            }
                                        });
                                        $A.enqueueAction(action);


                                    }
                                }
                            });
                            $A.enqueueAction(action);
                    } else {
                        this.changeStep(component, event, stepNumber);
                        component.set("v.toggleSpinner", false);
                    }
                }
            }



        } else {
            if (!this.validateProportionNull(component, event)) {
                component.set("v.toggleSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "error!",
                    "message": "Proportion cannot blank"
                });
                toastEvent.fire();
            }
        }
    },

    saveExpenseList: function (component, event, stepNumber){
        component.set("v.toggleSpinner", true);
        let oppId = component.get("v.recordId");
        var otherExpense = component.get("v.otherPageObject");
        var oppDetail = component.get("v.oppObject");
        console.log('Save Other Expense', otherExpense);

        if(!oppDetail.isReadOnly){

            var action = component.get("c.saveOtherExpense");
            action.setParams({ expenseJson: JSON.stringify(otherExpense), oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    let ret = response.getReturnValue();
                    if (!ret.messageAura.isError) {

                        var action = component.get("c.getSavedOtherExpenseJson");
                        action.setParams({ oppId: oppId, rentType: oppDetail.rentType });

                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {

                                var returnedData = response.getReturnValue();

                                if (returnedData) {
                                    component.set("v.otherPageObject", JSON.parse(returnedData));
                                }
                                this.changeStep(component, event, stepNumber);
                                component.set("v.toggleSpinner", false);

                            }
                        });
                        $A.enqueueAction(action);

                    } else {
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": ret.messageAura.message
                        });
                        toastEvent.fire();
                    }

                }
            });

            $A.enqueueAction(action);
        }else{
             var action = component.get("c.getSavedOtherExpenseJson");
            action.setParams({ oppId: oppId, rentType: oppDetail.rentType });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {

                    var returnedData = response.getReturnValue();

                    if (returnedData) {
                        component.set("v.otherPageObject", JSON.parse(returnedData));
                    }
                    this.changeStep(component, event, stepNumber);
                    component.set("v.toggleSpinner", false);

                }
            });
            $A.enqueueAction(action);
        }
    },

    saveInstallment: function (component, event, stepNumber) {


        var expenseList = component.get("v.expenseList");
        var expenseListStringJson = JSON.stringify(expenseList);
        console.log('expenseListStringJson To Save ', expenseListStringJson);
        var oppId = component.get("v.recordId");
        component.set("v.toggleSpinner", true);
        var oppDetail = component.get("v.oppObject");

        // debugger;
        if (component.get("v.isChangeExpense")) {
            var action = component.get("c.saveExpenseInstallment");
            action.setParams({ installmentJson: expenseListStringJson, oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let ret = response.getReturnValue();
                    component.set("v.toggleSpinner", false);

                    if (!ret.messageAura.isError) {

                        var action = component.get("c.getSavedExpenseINstallmentJson");
                        action.setParams({ oppId: oppId });

                        action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {

                                var returnedData = response.getReturnValue();

                                if (returnedData) {
                                    component.set("v.expenseList", JSON.parse(returnedData));
                                }
                                this.changeStep(component, event, stepNumber);
                                component.set("v.toggleSpinner", false);

                            }
                        });
                        $A.enqueueAction(action);

                    } else {
                        component.set("v.toggleSpinner", false);
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": ret.messageAura.message
                        });
                        toastEvent.fire();
                    }


                }
            });
            $A.enqueueAction(action);
        } else {
            this.changeStep(component, event, stepNumber);
            component.set("v.toggleSpinner", false);
        }
    },

    validateSaveDeposit: function (component, event) {
        var res = true;
        var depositObject = component.get("v.depositObject");
        var oppDetail = component.get("v.oppObject");

        if (!oppDetail.isAllowChangeOptionToRenew) {
            let camOrAirService_Summary = depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary;
            let rent_Summary = depositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
            let service_Summary = depositObject.DepositSummary.DepositSummaryPricing.service_Summary;
            if(oppDetail.isMigration){
                return true;
            }
            else if((camOrAirService_Summary < 0 || rent_Summary < 0 || service_Summary < 0)) {
                res = false;
            }
        }

        return res;
    },

    saveDeposit: function (component, event, stepNumber) {
        component.set("v.toggleSpinner", true);
        var depositObject = component.get("v.depositObject");
        var oppId = component.get("v.recordId");
        var oppDetail = component.get("v.oppObject");
        oppDetail.depositMonth = depositObject.DepositMonth;
        component.set("v.oppObject", oppDetail);

        // debugger;
        console.log('Save Deposit ', JSON.stringify(depositObject));
        if(!oppDetail.isReadOnly){
            if (component.get("v.isChangeDeposit")) {
                if (this.validateSaveDeposit(component, event)) {
                    var action = component.get("c.saveDepositApex");
                    action.setParams({ depositJson: JSON.stringify(depositObject), oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail), isInitialDeposit : false});
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            let ret = response.getReturnValue();
                            //console.log("saveDepositApex ret: "+JSON.stringify(ret));
                            component.set("v.toggleSpinner", false);

                            if (!ret.messageAura.isError) {
                                var action = component.get("c.getSavedDepositObjectJson");
                                action.setParams({ oppId: oppId, camOrAirServiceCondition: oppDetail.camOrAirService, oppUiWrapper: JSON.stringify(oppDetail) });
                                action.setCallback(this, function (response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        // debugger;
                                        var returnedData = response.getReturnValue();
                                        //console.log("getSavedDepositObjectJson returnedData: "+returnedData);
                                        if (returnedData) {
                                            component.set("v.depositObject", JSON.parse(returnedData));
                                            this.changeStep(component, event, stepNumber);
                                            component.set("v.toggleSpinner", false);
                                        }
                                    }
                                });
                                $A.enqueueAction(action);
                            } else {
                                component.set("v.toggleSpinner", false);
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "type": "error",
                                    "message": ret.messageAura.message
                                });
                                toastEvent.fire();
                            }
                        }
                    });
                    $A.enqueueAction(action);
                } else {
                    if (!this.validateSaveDeposit(component, event)) {
                        component.set("v.toggleSpinner", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "error!",
                            "message": "Total summary should not less than 0"
                        });
                        toastEvent.fire();
                    }
                }
            } else {
                this.changeStep(component, event, stepNumber);
                component.set("v.toggleSpinner", false);
            }
        }else {
            this.changeStep(component, event, stepNumber);
            component.set("v.toggleSpinner", false);
        }

    },

    getPricingDaetail: function (component, event, stepNumber, selectedRoom, contractStartDate, contractEndDate, calculationMethod, leaseType, camOrAirEscalationType, opptionToRenewYear, opptionToRenewMonth) {

        var oppDetail = component.get("v.oppObject");
        var oppId = component.get("v.recordId");

        var measurementIdList =[];
        var expenseOptionValue = [];

        var selectedRommObject = JSON.parse(selectedRoom);

        selectedRommObject.forEach((eachSelectedRoom, selesctedRoomIndex) => {

           if (eachSelectedRoom.roMeasurmentList && eachSelectedRoom.roMeasurmentList.length > 0) {

                eachSelectedRoom.roMeasurmentList.forEach((eachROMeasurement, roMeasurmentIndex) => {

                    if (eachROMeasurement.measurementId) {

                        if (!measurementIdList.includes(eachROMeasurement.measurementId)) {
                            measurementIdList.push(eachROMeasurement.measurementId);
                        }
                    }
                });
           }
        });

        // debugger;
        console.log("selectedRoom ", JSON.stringify(selectedRoom));

        component.lax.enqueueAll([{
			//[0]
            name: "c.getCAMPricingDetail",
            params: {
                "oppId": oppId,
                "selectedRoomJson": selectedRoom,
                "contractStartDate": contractStartDate,
                "contractEndDate": contractEndDate,
                "leaseType": leaseType,
                "escalationRate": oppDetail.camOrAirEscalationRate,
                "isUpdateOpp": true,
                "optionToRenewYear" : oppDetail.optionToRenewYear,
                "optionToRenewMonth": oppDetail.optionToRenewMonth,
                "oppUiWrapper": JSON.stringify(oppDetail)
            },
            options: { background: true },
        },
        {
			//[1]
            name: "c.getRentServicePricingDetail",
            params: {
                "selectedRoomJson": selectedRoom,
                "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                "oppId": oppDetail.oppId,
                "isUpdateOpp": true
            },
            options: { background: true },
        },
        {
			//[2]
            name: "c.getPeriodPricingDetail",
            params: {
                "selectedRoomJson": selectedRoom,
                "contractStartDate": contractStartDate,
                "contractEndDate": contractEndDate,
                "calCulationMethod": calculationMethod,
                "leaseType": leaseType,
                "optionToRenewYear": opptionToRenewYear,
                "optionToRenewMonth": opptionToRenewMonth,
                "oppUiWrapper" : JSON.stringify(oppDetail)
            },
            options: { background: true },
        },
        {
			//[3]
            name: "c.getPicklistValueFromPageSettingFromRentType",
            params: {
                "rentType": oppDetail.rentType,
                "screenToDisplay": "Other",
                "mesurementListId" : measurementIdList
            },
            options: { background: true },
        }

        ]).then(result => {
            // debugger;

            console.log("CAM Pricing", result[0]);
            console.log("RentService Pricing", result[1]);
            console.log("Period Pricing", result[2]);
            let expenseOptionMap = result[3];

            var jsonCAMDetail = result[0];
            var camDetailData = JSON.parse(jsonCAMDetail);

            var jsonRentServiceDetail = result[1];
            var rentServiceDetailData = JSON.parse(jsonRentServiceDetail);

            var jsonPeriodPricing = result[2];
            var periodPricingData = JSON.parse(jsonPeriodPricing);

            if (expenseOptionMap) {
                var isSkip = false;
                var actualLeaseHold = [];
                for (var key in expenseOptionMap) {
                    if (oppDetail.spetialOtherTypePicklist.includes(key)) {
                        if (!isSkip) {
                            expenseOptionValue.push({ value: "ค่าสิทธิการเช่า", label: "ค่าสิทธิการเช่า" });
                            isSkip = true;
                        }
                    }else{
                        expenseOptionValue.push({ value: key, label: expenseOptionMap[key] });
                    }
                }
                console.log("option Expense Option" + JSON.stringify(expenseOptionValue));
                component.set('v.expenseTypeOption', expenseOptionValue);
                for (var key in expenseOptionMap){
                    if (oppDetail.spetialOtherTypePicklist.includes(key)) {
                        actualLeaseHold.push(key);
                    }
                }
                oppDetail.spetialOtherTypePicklist = actualLeaseHold;
                component.set("v.oppObject.spetialOtherTypePicklist",oppDetail.spetialOtherTypePicklist);
            }

            if(periodPricingData){
                component.set("v.oppObject.totalQuotationPeriod", periodPricingData.length);
                component.set("v.oppObject.isRenewChangeOppPeriod", true);
            }



            component.set("v.camPricing", camDetailData);
            component.set("v.rentServicePricing", rentServiceDetailData);
            component.set("v.periodPricing", periodPricingData);
            component.set("v.isChangePricing", true);


            this.changeStep(component, event, stepNumber);
            component.set("v.toggleSpinner", false);

        });
    },

    regenerateAdvanceRentService: function (component, event) {
        var oppDetail = component.get("v.oppObject");
        var selectedRoom = component.get("v.seletedRoom");
        var oppId = component.get("v.recordId");


        component.lax.enqueueAll([

            {
                name: "c.getSavedRentServicePricingDetail",
                params: {
                    "oppId": oppId,
                    "selectedRoomJson": JSON.stringify(selectedRoom),
                    "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                    "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                    "oppUiWrapper" : JSON.stringify(oppDetail)
                },
                options: { background: true },
            },
            {
                name: "c.getSavedPeriodPricingDetail",
                params: {
                    "oppId": oppId,
                    "oppUiWrapper": JSON.stringify(oppDetail),
                    "selectedRoomJson": JSON.stringify(selectedRoom),
                    "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                    "calculationMethod": oppDetail.calculationMethod
                },
                options: { background: true },
            }
        ]).then(result => {


            if (result[0]) {
                component.set("v.rentServicePricing", JSON.parse(result[0]));
            }

            if (result[1]) {
                component.set("v.periodPricing", JSON.parse(result[1]));
            }

            component.set("v.toggleSpinner", false);

        });

    },
    regenerateEscalatonRentService: function (component, event) {
        var oppDetail = component.get("v.oppObject");
        var selectedRoom = component.get("v.seletedRoom");
        var oppId = component.get("v.recordId");

        var isInitialPageWithRentService = component.get('v.isInitialPageWithRentService');
        var isInitialPageWithPeriod = component.get('v.isInitialPageWithPeriod');
        component.set("v.toggleSpinner", true);

        // debugger;

        if (isInitialPageWithRentService && isInitialPageWithPeriod) {

            if (oppDetail.rentServiceEscalationType == 'Advance') {
                component.lax.enqueueAll([
                    {
                        name: "c.getRentServicePricingDetail",
                        params: {
                            "selectedRoomJson": JSON.stringify(selectedRoom),
                            "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                            "oppId": oppDetail.oppId,
                            "isUpdateOpp": false
                        },
                        options: { background: true },
                    },
                    {
                        name: "c.getPeriodPricingDetail",
                        params: {
                            "selectedRoomJson": JSON.stringify(selectedRoom),
                            "contractStartDate": oppDetail.contractStartDateForm,
                            "contractEndDate": oppDetail.contractEndDateFrom,
                            "calCulationMethod": oppDetail.calculationMethod,
                            "leaseType": oppDetail.leaseType,
                            "optionToRenewYear": oppDetail.optionToRenewYear,
                            "optionToRenewMonth": oppDetail.optionToRenewMonth,
                            "oppUiWrapper" : JSON.stringify(oppDetail)
                        },
                        options: { background: true },
                    }

                ]).then(result => {


                    var oldRentServicePricing = component.get("v.rentServicePricing");
                    var oldPeriodPricing = component.get("v.periodPricing");


                    var jsonRentServiceDetail = result[0];
                    var jsonPeriodPricing = result[1];

                    if (jsonRentServiceDetail) {

                        var newRentService = JSON.parse(jsonRentServiceDetail);

                        oldRentServicePricing.RentServiceMeasurment = oldRentServicePricing.RentServiceMeasurment.map(function (measurmentRowData) {
                            measurmentRowData.isToDeleteRecord = true;
                            return measurmentRowData;
                        });

                        newRentService.RentServiceMeasurment = newRentService.RentServiceMeasurment.map(function (measurmentRowData) {
                            oldRentServicePricing.RentServiceMeasurment.push(measurmentRowData);
                            return measurmentRowData;
                        });

                        oldRentServicePricing.RentCondition = "% Escalation";
                        oldRentServicePricing.RentServiceEscalationRate.IsDisabled = false;

                        component.set("v.rentServicePricing", oldRentServicePricing);
                    }


                    if (jsonPeriodPricing) {

                        var newPeriodPricing = JSON.parse(jsonPeriodPricing);

                        oldPeriodPricing = oldPeriodPricing.map(function (periodRowData) {
                            periodRowData.isToDeleteRecord = true;
                            return periodRowData;
                        });

                        newPeriodPricing = newPeriodPricing.map(function (periodRowData) {
                            oldPeriodPricing.push(periodRowData);
                            return periodRowData;
                        });


                        component.set("v.oppObject.totalQuotationPeriod", oldPeriodPricing.length);
                        component.set("v.periodPricing", oldPeriodPricing);
                    }

                    component.set("v.toggleSpinner", false);

                });
            } else {

                component.lax.enqueueAll([

                    {
                        name: "c.getSavedRentServicePricingDetail",
                        params: {
                            "oppId": oppId,
                            "selectedRoomJson": JSON.stringify(selectedRoom),
                            "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                            "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                            "oppUiWrapper" : JSON.stringify(oppDetail)
                        },
                        options: { background: true },
                    },
                    {
                        name: "c.getSavedPeriodPricingDetail",
                        params: {
                            "oppId": oppId,
                            "oppUiWrapper": JSON.stringify(oppDetail),
                            "selectedRoomJson": JSON.stringify(selectedRoom),
                            "rentServiceEscalationType": oppDetail.rentServiceEscalationType,
                            "calculationMethod": oppDetail.calculationMethod
                        },
                        options: { background: true },
                    }
                ]).then(result => {


                    if (result[0]) {
                        component.set("v.rentServicePricing", JSON.parse(result[0]));
                    }

                    if (result[1]) {
                        component.set("v.periodPricing", JSON.parse(result[1]));
                    }

                    component.set("v.toggleSpinner", false);

                });
            }


        } else {

            component.lax.enqueueAll([
                {
                    name: "c.getRentServicePricingDetail",
                    params: {
                        "selectedRoomJson": JSON.stringify(selectedRoom),
                        "rentServiceEscalationRate": oppDetail.rentServiiceEscalationRate,
                        "oppId": oppDetail.oppId,
                        "isUpdateOpp": false
                    },
                    options: { background: true },
                },
                {
                    name: "c.getPeriodPricingDetail",
                    params: {
                        "selectedRoomJson": JSON.stringify(selectedRoom),
                        "contractStartDate": oppDetail.contractStartDateForm,
                        "contractEndDate": oppDetail.contractEndDateFrom,
                        "calCulationMethod": oppDetail.calculationMethod,
                        "leaseType": oppDetail.leaseType,
                        "optionToRenewYear": oppDetail.optionToRenewYear,
                        "optionToRenewMonth": oppDetail.optionToRenewMonth,
                        "oppUiWrapper" : JSON.stringify(oppDetail)
                    },
                    options: { background: true },
                }

            ]).then(result => {


                var jsonRentServiceDetail = result[0];
                var jsonPeriodPricing = result[1];

                if (jsonRentServiceDetail) {
                    component.set("v.rentServicePricing", JSON.parse(jsonRentServiceDetail));
                }

                if (jsonPeriodPricing) {

                    var periodPricingData = JSON.parse(jsonPeriodPricing);

                    if(periodPricingData){
                        component.set("v.oppObject.totalQuotationPeriod", periodPricingData.length);
                    }
                    component.set("v.periodPricing", JSON.parse(jsonPeriodPricing));
                }

                component.set("v.toggleSpinner", false);

            });
        }

    },

    validateBeforeSaveSelectedRO: function (component, event, stepNumber, isSaveAndClose) {
        component.set("v.toggleSpinner", true);
        const selectedroom = component.get("v.seletedRoom");
        var oppDetail = component.get("v.oppObject");
        let roIdList = [];
        selectedroom.map(x => {
            if (!x.isToDeleteRecord) {
                roIdList.push(x.id);
            }
        });
        //debugger

        const action = component.get("c.validateBeforeSaveSelectedRO");
        action.setParams({ roIdList: roIdList, selectedRoomJson : JSON.stringify(selectedroom), oppUiWrapper : JSON.stringify(oppDetail)});

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const returnedData = response.getReturnValue();
                // debugger;
                if (!returnedData) {
                    if (isSaveAndClose) {
                        this.saveDataProgressStep1(component, event);
                    }
                    else {
                        this.saveSelectedRentalObject(component, event, stepNumber);
                    }
                }
                else {
                    component.set("v.toggleSpinner", false);
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": returnedData
                    });
                    toastEvent.fire();
                }
            }
        });

        $A.enqueueAction(action);
    },
    saveDataProgressStep1: function (component, event){
        var selectedroom = component.get("v.seletedRoom");
        var selectedRoomJsonString = JSON.stringify(selectedroom);
        var oppId = component.get("v.recordId");
        var oppDetail = component.get("v.oppObject");

        if (component.get("v.isChangeSelectedRO")) {

            var action = component.get("c.saveSelectedRentalObject");
            action.setParams({ selectedRoomJson: selectedRoomJsonString, oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Success");

                    var returnedData = response.getReturnValue();
                    var newSelectedRoom = JSON.parse(returnedData);
                    component.set("v.seletedRoom", newSelectedRoom);
                    component.set("v.toggleSpinner", false);

                    $A.get('e.force:refreshView').fire();

                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            });

            $A.enqueueAction(action);
        } else {
            if(!oppDetail.isReadOnly){

                var action = component.get("c.updateOppArea");
                action.setParams({ selectedRoomJson: selectedRoomJsonString, oppId: oppId, oppUiWrapper: JSON.stringify(oppDetail) });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("Success");

                        var returnedData = response.getReturnValue();

                        component.set("v.toggleSpinner", false);
                        if (returnedData) {
                            $A.get('e.force:refreshView').fire();

                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();
                        }else{
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message":"Somthing went wrong while updating Opportunity."
                            });
                            toastEvent.fire();
                        }

                    }
                });

                $A.enqueueAction(action);
            }else{
                component.set("v.toggleSpinner", false);
                $A.get('e.force:refreshView').fire();

                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }

        }
    },

    calculateRentAndService: function (lastPeriodOfPricing, oppDetail, rentPercent, servicePercent, camOrAirServicePrice){
        var periodPrice = 0;
        let rentPrice = 0;
        let servicePrice = 0;
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
        return {rentPrice, servicePrice};
    }
})