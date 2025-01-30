({
    init : function(component, event, helper) {
        var eachPeriod = component.get("v.eachPeriod");
        if (eachPeriod.GPWithMinSection.ReportingRuleList.length > 1) {
            component.set("v.isDisabledAllSales",false);
        }else{
            component.set("v.isDisabledAllSales",true);
        }

        if (eachPeriod.OptionToRenew) {
            component.set("v.isDisableIncludeCAM",true);

        }else{
            component.set("v.isDisableIncludeCAM",false);            
        }
    },

    onChangePricing: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var compEvent = component.getEvent("PeriodChangeEvent");
            compEvent.setParams({
                "periodIndex" : component.get("v.periodIndex"),
                "isIncludedCAM" : component.get("v.eachPeriod.IsIncludeCAM")
            });
            compEvent.fire();
    },
    onChangeGrading: function(component, event, helper){
        component.set("v.isChangeGrading",true);
    },
    onblurNUmberField: function(component, event, helper){
        var indexPosition = event.getSource().get("v.name");
        var res = indexPosition.split("_");

        debugger;
        
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);

        if (!newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangFrom) {
            newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangFrom = 0;
        }
        if(!newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangTo){
            newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangTo = 0;
        }
        if(!newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].GPPercent){
            newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].GPPercent = 0;
        }

        component.set("v.eachPeriod.GPWithMinSection", newEachPeriod.GPWithMinSection);

    },
    onChangePeriodIncludeCAM: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);

        if (newEachPeriod.IsIncludeCAM) {
            newEachPeriod.GPWithMinSection.ReportingRuleList.forEach((eachReportingRule, reportingRuleIndex) =>{
               
               eachReportingRule.ReportingRuleDetailList.forEach((eachReportingRuleDetail, reportingRuleDetailIndex) =>{
                    
                    eachReportingRuleDetail.IsIncludeCam = false;
                }); 
            });

            component.set("v.eachPeriod.GPWithMinSection", eachPeriod.GPWithMinSection);
        }

    },
    onChangeDatePeriod: function(component, event, helper){
        debugger;

        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        component.set("v.eachPeriod.isEditRecord", true);
        component.set("v.isChangePricing",true);
        component.set("v.isRenewChangeDate",true);

        var compEvent = component.getEvent("PeriodChangeEvent");
            compEvent.setParams({
                "periodIndex" : component.get("v.periodIndex"),
                "periodStartDate" : newEachPeriod.PricingFrom,
                "periodEndDate" : newEachPeriod.PricingTo
            });
            compEvent.fire();
            
    },
    onChangeOptionToRenew: function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        component.set("v.isChangePricing",true);

        if (newEachPeriod.OptionToRenew) {
            newEachPeriod.IsIncludeCAM = false;
            component.set("v.isDisableIncludeCAM",true);
            component.set("v.eachPeriod.IsIncludeCAM",newEachPeriod.IsIncludeCAM);

        }else{
            component.set("v.isDisableIncludeCAM",false);            
        }

        var compEvent = component.getEvent("PeriodChangeEvent");
            compEvent.setParams({
                "periodIndex" : component.get("v.periodIndex"),
                "periodStartDate" : null,
                "periodEndDate" : null,
                "isOptionToReNew" : newEachPeriod.OptionToRenew
            });
            compEvent.fire();
    },
    removeReportingRule : function(component, event, helper) {
        var oppDetail = component.get("v.oppObject");

        if(oppDetail.popupSetting["การลบ GP ใน Period"].tms_Enable__c){

           var modalBody;
           var modalFooter;
            $A.createComponents([
                ["c:tms_ConfirmPopup",{}],
                ["c:tms_ConfirmPopupFooter",{isConfirmRemove : component.getReference("v.isConfirmRemove")}]
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
                                debugger;
                                component.set("v.isChangeGrading",true);
                                var eachPeriod = component.get("v.eachPeriod");
                                var newEachPeriodReportingRuleList = [...eachPeriod.GPWithMinSection.ReportingRuleList];
                                let numberActiveReportingRule = 0;

                                var indexPosition = event.target.name;
                                console.log("Delete Row ",indexPosition);

                                // newEachPeriodReportingRuleList.splice(indexPosition, 1);
                                newEachPeriodReportingRuleList[indexPosition].isToDeleteRecord = true;

                                eachPeriod.GPWithMinSection.ReportingRuleList = newEachPeriodReportingRuleList;

                                let groupLength = 0;

                                eachPeriod.GPWithMinSection.ReportingRuleList.sort((a, b) => a.GroupNumber - b.GroupNumber);
                                eachPeriod.GPWithMinSection.ReportingRuleList.forEach((rowData, index) =>{   
                                    if (!rowData.isToDeleteRecord) {
                                        numberActiveReportingRule ++;
                                        rowData.GroupNumber = groupLength;
                                        groupLength++;
                                    }
                                });

                                component.set("v.eachPeriod", eachPeriod);


                                if (numberActiveReportingRule<=1) {
                                    component.set("v.isDisabledAllSales",true);
                                    component.set("v.eachPeriod.IsAllSales", false);
                                }
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
            component.set("v.isChangeGrading",true);
        	var eachPeriod = component.get("v.eachPeriod");
            var newEachPeriodReportingRuleList = [...eachPeriod.GPWithMinSection.ReportingRuleList];
            let numberActiveReportingRule = 0;

        	var indexPosition = event.target.name;
            console.log("Delete Row ",indexPosition);

            // newEachPeriodReportingRuleList.splice(indexPosition, 1);
            newEachPeriodReportingRuleList[indexPosition].isToDeleteRecord = true;

            eachPeriod.GPWithMinSection.ReportingRuleList = newEachPeriodReportingRuleList;

            let groupLength = 0;

            eachPeriod.GPWithMinSection.ReportingRuleList.sort((a, b) => a.GroupNumber - b.GroupNumber);
            eachPeriod.GPWithMinSection.ReportingRuleList.forEach((rowData, index) =>{   
                if (!rowData.isToDeleteRecord) {
                    numberActiveReportingRule ++;
                    rowData.GroupNumber = groupLength;
                    groupLength++;
                }
            });

            component.set("v.eachPeriod", eachPeriod);


            if (numberActiveReportingRule<=1) {
                component.set("v.isDisabledAllSales",true);
                component.set("v.eachPeriod.IsAllSales", false);
            }
       }


    },

    removeReportingRuleDetail : function(component, event, helper){
        var oppDetail = component.get("v.oppObject");

        if(oppDetail.popupSetting["การลบ Tier ของ GP"].tms_Enable__c){

           var modalBody;
           var modalFooter;
            $A.createComponents([
                ["c:tms_ConfirmPopup",{}],
                ["c:tms_ConfirmPopupFooter",{isConfirmRemove : component.getReference("v.isConfirmRemove")}]
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
                                component.set("v.isChangeGrading",true);
                                var indexPosition = event.target.name;
                                var res = indexPosition.split("_");
                                console.log("Delete Row ",indexPosition[0]);
                                console.log("Delete Row Detail",indexPosition[2]);
                                debugger;

                                var eachPeriod = component.get("v.eachPeriod");
                                var newEachPeriodReportingRuleDetailList = [...eachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList];

                                // newEachPeriodReportingRuleDetailList.splice(indexPosition[1], 1);
                                newEachPeriodReportingRuleDetailList[indexPosition[2]].isToDeleteRecord = true;
                                eachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList = newEachPeriodReportingRuleDetailList;


                                var newEachPeriod = Object.assign({}, eachPeriod); 
                                var salesmin = helper.calculateSalesMinHelper(component, event, newEachPeriod);
                                component.set("v.eachPeriod.GPWithMinSection.ReportingRuleList", eachPeriod.GPWithMinSection.ReportingRuleList);
                                component.set("v.eachPeriod.GPWithMinSection.SalesMin", salesmin);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
            component.set("v.isChangeGrading",true);
        	var indexPosition = event.target.name;
        	var res = indexPosition.split("_");
            console.log("Delete Row ",indexPosition[0]);
            console.log("Delete Row Detail",indexPosition[2]);
            debugger;

            var eachPeriod = component.get("v.eachPeriod");
            var newEachPeriodReportingRuleDetailList = [...eachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList];

            // newEachPeriodReportingRuleDetailList.splice(indexPosition[1], 1);
            newEachPeriodReportingRuleDetailList[indexPosition[2]].isToDeleteRecord = true;
            eachPeriod.GPWithMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList = newEachPeriodReportingRuleDetailList;


            var newEachPeriod = Object.assign({}, eachPeriod); 
            var salesmin = helper.calculateSalesMinHelper(component, event, newEachPeriod);
            component.set("v.eachPeriod.GPWithMinSection.ReportingRuleList", eachPeriod.GPWithMinSection.ReportingRuleList);
            component.set("v.eachPeriod.GPWithMinSection.SalesMin", salesmin);
       }


    },

    addReportingRule :function(component, event, helper){
        component.set("v.isChangeGrading",true);
        var modalBody;
        var selectedRangeReportingRule;
        var selectedRangeReportingRuleLabel;
        $A.createComponent("c:tms_AddRangReportingRuleComponent", {
                                                                optionToparent : component.getReference("v.addedRangReportingRule"), 
                                                                optionLabelToparent: component.getReference("v.addedRangReportingRuleLabel"), 
                                                                options: component.get("v.reportingRuleOption"),
                                                                reportingRuleMap: component.get("v.reportingRuleMap")},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('addRangReportingRule').showCustomModal({
                    
                       header: "Add Range",
                       body: modalBody,
                       showCloseButton: false,
                       cssClass: "slds-modal_medium",

                       closeCallback: function() {

                            console.log(component.get("v.addedRangReportingRule"));
                            selectedRangeReportingRule = component.get("v.addedRangReportingRule");
                            selectedRangeReportingRuleLabel = component.get("v.addedRangReportingRuleLabel");

                           if (selectedRangeReportingRule){


                                var action = component.get("c.getNewReportingRuleJson");
                                action.setParams({reportingRule: selectedRangeReportingRule, reportingRuleLabel:selectedRangeReportingRuleLabel});
     
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        debugger;
                                        var eachPeriod = component.get("v.eachPeriod");
                                        var newEachPeriod = Object.assign({}, eachPeriod);
                                        var newEachPeriodReportingRuleList = newEachPeriod.GPWithMinSection.ReportingRuleList;

                                        var returnedData = response.getReturnValue();
                                        console.log('Return ReportingRule', returnedData);

                                        var newReportingRule =  JSON.parse(returnedData);
                                        let groupLength = 0;

                                        newEachPeriodReportingRuleList = newEachPeriodReportingRuleList.map(function(rowData) {
                                            if (!rowData.isToDeleteRecord) {
                                                groupLength++;
                                            }
                                            return rowData;
                                        });

                                        // newReportingRule.GroupNumber = (groupLength>0)?groupLength +1:groupLength;
                                        newReportingRule.GroupNumber = groupLength;

                                        newEachPeriodReportingRuleList.push(newReportingRule);   
                                        
                                        newEachPeriod.GPWithMinSection.ReportingRuleList = newEachPeriodReportingRuleList;

                                        var numberActiveReportingRule = 0;
                                        newEachPeriod.GPWithMinSection.ReportingRuleList.forEach((rowData, index) =>{
                                            if (!rowData.isToDeleteRecord) {
                                                numberActiveReportingRule ++;
                                            }
                                        });
                                        
                                        if (numberActiveReportingRule > 1) {
                                            component.set("v.isDisabledAllSales",false);
                                        }
                                        component.set("v.eachPeriod.GPWithMinSection.ReportingRuleList", newEachPeriod.GPWithMinSection.ReportingRuleList);
                                        component.set("v.addedRangReportingRule", '');
                                        component.set("v.addedRangReportingRuleLabel", '');

                                        
                                    }
                                });

                                $A.enqueueAction(action);

                                // var newReportingRule = {
                                //                         ReportingRule : selectedRangeReportingRule,
                                //                         ReportingRuleLabel : selectedRangeReportingRuleLabel,
                                //                         ReportingRuleDescription : "",
                                //                         ReportingRuleDetailList : [
                                //                             {
                                //                                 rangFrom : 0,
                                //                                 rangTo : 0,
                                //                                 GPPercent : 0,
                                //                                 IsIncludeCam : false
                                //                             }
                                //                         ]
                                //                     };

                           }
                       }
                   })
               }
           });                     
    },

    addReportingRuleDetail :function(component, event, helper){
        component.set("v.isChangeGrading",true);
    	var indexPosition = event.getSource().get("v.name");
    	console.log(indexPosition);

        debugger;

        var action = component.get("c.getNewReportingRuleDetailJson");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var eachPeriod = component.get("v.eachPeriod");
                var newEachPeriod = Object.assign({}, eachPeriod);
                var newEachPeriodReportingRuleDetailList = newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition].ReportingRuleDetailList;
                var returnedData = response.getReturnValue();
                console.log('Return ReportingRuleDetail', returnedData);

                var newDetail =  JSON.parse(returnedData);

                let groupLength = 0;

                newEachPeriodReportingRuleDetailList = newEachPeriodReportingRuleDetailList.map(function(rowData) {
                    if (!rowData.isToDeleteRecord) {
                        groupLength++;
                    }
                    return rowData;
                });
                newDetail.GradingIndex = groupLength +1;

                newEachPeriodReportingRuleDetailList.push(newDetail);
                newEachPeriod.GPWithMinSection.ReportingRuleList[indexPosition].ReportingRuleDetailList = newEachPeriodReportingRuleDetailList;
                component.set("v.eachPeriod.GPWithMinSection.ReportingRuleList", newEachPeriod.GPWithMinSection.ReportingRuleList);
                
            }
        });

        $A.enqueueAction(action);
        // var newDetail = {
        //                     rangFrom : 0,
        //                     rangTo : 0,
        //                     GPPercent : 0,
        //                     IsIncludeCam : false
        //                 }
    },
    onMeasurmentPricingBlur : function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);


        var totalMeasurmentPrice =0;
        var totalSummaryPrice =0;
        var measurmentSummary;

        newEachPeriod.GPWithMinSection.PricingSection.MeasumentPricingList = newEachPeriod.GPWithMinSection.PricingSection.MeasumentPricingList.map(function(rowData) {
            measurmentSummary = 0; 

            if(!rowData.isToDeleteRecord){

                if (!rowData.Price.value) {
                    rowData.Price.value = 0;
                }

                measurmentSummary = parseFloat(rowData.Area) *parseFloat(rowData.Price.value);
                measurmentSummary = helper.roundDecimal(measurmentSummary);

                totalMeasurmentPrice += parseFloat(rowData.Price.value);
                totalMeasurmentPrice = helper.roundDecimal(totalMeasurmentPrice);

                totalSummaryPrice += measurmentSummary;
                totalSummaryPrice = helper.roundDecimal(totalSummaryPrice);
            }

            rowData.Summary = measurmentSummary;


            return rowData;
        });

        newEachPeriod.GPWithMinSection.PricingSection.TotalPrice = totalMeasurmentPrice;
        newEachPeriod.GPWithMinSection.PricingSection.TotalSummary = totalSummaryPrice;

        var salesmin = helper.calculateSalesMinHelper(component, event, newEachPeriod);
        newEachPeriod.GPWithMinSection.SalesMin = salesmin;

        component.set("v.eachPeriod.GPWithMinSection", newEachPeriod.GPWithMinSection);
    },
    onMeasurmentPricingChange : function(component, event, helper) {
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);


        var totalMeasurmentPrice =0;
        var totalSummaryPrice =0;
        var measurmentSummary;

        newEachPeriod.GPWithMinSection.PricingSection.MeasumentPricingList = newEachPeriod.GPWithMinSection.PricingSection.MeasumentPricingList.map(function(rowData) {
            measurmentSummary = 0; 

            if(!rowData.isToDeleteRecord){

                measurmentSummary = (rowData.Price.value)?parseFloat(rowData.Area) *parseFloat(rowData.Price.value): parseFloat(rowData.Area) *0;
                measurmentSummary = helper.roundDecimal(measurmentSummary);

                totalMeasurmentPrice += (rowData.Price.value)?parseFloat(rowData.Price.value):0;
                totalMeasurmentPrice = helper.roundDecimal(totalMeasurmentPrice);

                totalSummaryPrice += measurmentSummary;
                totalSummaryPrice = helper.roundDecimal(totalSummaryPrice);
            }

            rowData.Summary = measurmentSummary;


            return rowData;
        });

        newEachPeriod.GPWithMinSection.PricingSection.TotalPrice = totalMeasurmentPrice;
        newEachPeriod.GPWithMinSection.PricingSection.TotalSummary = totalSummaryPrice;

        var salesmin = helper.calculateSalesMinHelper(component, event, newEachPeriod);
        newEachPeriod.GPWithMinSection.SalesMin = salesmin;

        component.set("v.eachPeriod.GPWithMinSection", newEachPeriod.GPWithMinSection);
    },
    onFixedPricingChange : function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);
        var salesmin = helper.calculateSalesMinHelper(component, event, newEachPeriod);
        eachPeriod.GPWithMinSection.SalesMin = salesmin;
        eachPeriod.GPWithMinSection.PricingSection.FixedPricing.Price = parseFloat(eachPeriod.GPWithMinSection.PricingSection.FixedPricing.Price);

        component.set("v.eachPeriod.GPWithMinSection", eachPeriod.GPWithMinSection);
    },
    onFixedPricingBlur : function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);

        if (!eachPeriod.GPWithMinSection.PricingSection.FixedPricing.Price) {
            eachPeriod.GPWithMinSection.PricingSection.FixedPricing.Price = 0;
        }else{
            eachPeriod.GPWithMinSection.PricingSection.FixedPricing.Price = parseFloat(eachPeriod.GPWithMinSection.PricingSection.FixedPricing.Price);
        }

        component.set("v.eachPeriod.GPWithMinSection", eachPeriod.GPWithMinSection);
    },
    onchangeReportingRulePrice : function(component, event, helper){
        component.set("v.isChangeGrading",true);
        debugger;
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod); 
        var salesmin = helper.calculateSalesMinHelper(component, event, newEachPeriod);
        eachPeriod.GPWithMinSection.SalesMin = salesmin;

        // newEachPeriod.GPWithMinSection.ReportingRuleList.forEach((eachReportingRule) => {
        //     eachReportingRule.ReportingRuleDetailList.forEach((eachReportingRuleDetailData) => {
        //         if (!isNaN(eachReportingRuleDetailData.rangFrom)){
        //             eachReportingRuleDetailData.rangFrom = parseFloat(eachReportingRuleDetailData.rangFrom);
        //         }else{
        //             eachReportingRuleDetailData.rangFrom = null;
        //         }

        //         if (!isNaN(eachReportingRuleDetailData.rangTo)){
        //             eachReportingRuleDetailData.rangTo = parseFloat(eachReportingRuleDetailData.rangTo);
        //         }else{
        //             eachReportingRuleDetailData.rangTo = null;
        //         }

        //         if (!isNaN(eachReportingRuleDetailData.GPPercent)){
        //             eachReportingRuleDetailData.GPPercent = parseFloat(eachReportingRuleDetailData.GPPercent);
        //         }else{
        //             eachReportingRuleDetailData.GPPercent = null;
        //         }
        //     });            
        // });

        component.set("v.eachPeriod.GPWithMinSection", eachPeriod.GPWithMinSection);
    },
    onBlurProportion: function(component, event, helper){
        component.set("v.isChangePricing",true);
        var eachPeriod = component.get("v.eachPeriod");
        if (!eachPeriod.Proportion.Rent) {
            eachPeriod.Proportion.Rent =0;
        }else{
            eachPeriod.Proportion.Rent = parseFloat(eachPeriod.Proportion.Rent);
        }

        if (!eachPeriod.Proportion.Service) {
            eachPeriod.Proportion.Service =0;
        }else{
            eachPeriod.Proportion.Service = parseFloat(eachPeriod.Proportion.Service);
        }
        
        component.set("v.eachPeriod",eachPeriod);
    }, 
})