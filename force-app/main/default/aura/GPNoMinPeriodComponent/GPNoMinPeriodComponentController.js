({
    init : function(component, event, helper) {
        var eachPeriod = component.get("v.eachPeriod");
        if (eachPeriod.GPNoMinSection.ReportingRuleList.length > 1) {
            component.set("v.isDisabledAllSales",false);
        }else{
            component.set("v.isDisabledAllSales",true);
        }
    },

    onChangePricing: function(component, event, helper){
        component.set("v.isChangePricing",true);
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

        if (!newEachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangFrom) {
            newEachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangFrom = 0;
        }
        if(!newEachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangTo){
            newEachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].rangTo = 0;
        }
        if(!newEachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].GPPercent){
            newEachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList[indexPosition[2]].GPPercent = 0;
        }

        component.set("v.eachPeriod.GPNoMinSection", newEachPeriod.GPNoMinSection);

    },
    onChangePeriodIncludeCAM: function(component, event, helper){
        var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriod = Object.assign({}, eachPeriod);

        if (newEachPeriod.IsIncludeCAM) {
            newEachPeriod.GPNoMinSection.ReportingRuleList.forEach((eachReportingRule, reportingRuleIndex) =>{
               
               eachReportingRule.ReportingRuleDetailList.forEach((eachReportingRuleDetail, reportingRuleDetailIndex) =>{
                    
                    eachReportingRuleDetail.IsIncludeCam = false;
                }); 
            });

            component.set("v.eachPeriod.GPNoMinSection", eachPeriod.GPNoMinSection);
        }

    },
    onChangeDatePeriod: function(component, event, helper){
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
                                component.set("v.isChangeGrading",true);
                                var eachPeriod = component.get("v.eachPeriod");
                                var newEachPeriodReportingRuleList = [...eachPeriod.GPNoMinSection.ReportingRuleList];
                                let numberActiveReportingRule = 0;

                                var indexPosition = event.target.name;
                                console.log("Delete Row ",indexPosition);

                                // newEachPeriodReportingRuleList.splice(indexPosition, 1);
                                newEachPeriodReportingRuleList[indexPosition].isToDeleteRecord = true;

                                eachPeriod.GPNoMinSection.ReportingRuleList = newEachPeriodReportingRuleList;

                                let groupLength = 0;
                                eachPeriod.GPNoMinSection.ReportingRuleList.sort((a, b) => a.GroupNumber - b.GroupNumber);
                                eachPeriod.GPNoMinSection.ReportingRuleList.forEach((rowData, index) =>{
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
            var newEachPeriodReportingRuleList = [...eachPeriod.GPNoMinSection.ReportingRuleList];
            let numberActiveReportingRule = 0;

        	var indexPosition = event.target.name;
            console.log("Delete Row ",indexPosition);

            // newEachPeriodReportingRuleList.splice(indexPosition, 1);
            newEachPeriodReportingRuleList[indexPosition].isToDeleteRecord = true;

            eachPeriod.GPNoMinSection.ReportingRuleList = newEachPeriodReportingRuleList;

            let groupLength = 0;
            eachPeriod.GPNoMinSection.ReportingRuleList.sort((a, b) => a.GroupNumber - b.GroupNumber);
            eachPeriod.GPNoMinSection.ReportingRuleList.forEach((rowData, index) =>{
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

                                var eachPeriod = component.get("v.eachPeriod");
                                var newEachPeriodReportingRuleDetailList = [...eachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList];

                                // newEachPeriodReportingRuleDetailList.splice(indexPosition[1], 1);
                                newEachPeriodReportingRuleDetailList[indexPosition[2]].isToDeleteRecord = true;

                                eachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList = newEachPeriodReportingRuleDetailList;
                                component.set("v.eachPeriod.GPNoMinSection.ReportingRuleList", eachPeriod.GPNoMinSection.ReportingRuleList);
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

            var eachPeriod = component.get("v.eachPeriod");
            var newEachPeriodReportingRuleDetailList = [...eachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList];

            // newEachPeriodReportingRuleDetailList.splice(indexPosition[1], 1);
            newEachPeriodReportingRuleDetailList[indexPosition[2]].isToDeleteRecord = true;

            eachPeriod.GPNoMinSection.ReportingRuleList[indexPosition[0]].ReportingRuleDetailList = newEachPeriodReportingRuleDetailList;
            component.set("v.eachPeriod.GPNoMinSection.ReportingRuleList", eachPeriod.GPNoMinSection.ReportingRuleList);
       }

    },

    addReportingRule :function(component, event, helper){
        component.set("v.isChangeGrading",true);
        var modalBody;
        var selectedRangeReportingRule;
        var selectedRangeReportingRuleLabel;
        console.log(component.get("v.reportingRuleOption"));
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
          						    	var eachPeriod = component.get("v.eachPeriod");
          						        var newEachPeriodReportingRuleList = [...eachPeriod.GPNoMinSection.ReportingRuleList];

                                        var action = component.get("c.getNewReportingRuleJson");
                                        action.setParams({reportingRule: selectedRangeReportingRule, reportingRuleLabel:selectedRangeReportingRuleLabel});
             
                                        action.setCallback(this, function(response) {
                                            var state = response.getState();
                                            if (state === "SUCCESS") {
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
                  							    
                  							    eachPeriod.GPNoMinSection.ReportingRuleList = newEachPeriodReportingRuleList;

                                                var numberActiveReportingRule = 0;
                                                eachPeriod.GPNoMinSection.ReportingRuleList.forEach((rowData, index) =>{
                                                    if (!rowData.isToDeleteRecord) {
                                                        numberActiveReportingRule ++;
                                                    }
                                                });
                                                
                                                if (numberActiveReportingRule > 1) {
                                                    component.set("v.isDisabledAllSales",false);
                                                }

                  						        component.set("v.eachPeriod.GPNoMinSection.ReportingRuleList", eachPeriod.GPNoMinSection.ReportingRuleList);
                                                component.set("v.addedRangReportingRule", '');
                                                component.set("v.addedRangReportingRuleLabel", '');

                                                
                                                
                                            }
                                        });

                                        $A.enqueueAction(action);

          						        // var newReportingRule = {
          						        //                         ReportingRule : selectedRangeReportingRule,
                        //                                         ReportingRuleLabel : selectedRangeReportingRuleLabel,
                        //                                         ReportingRuleDescription : "",
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

    	var eachPeriod = component.get("v.eachPeriod");
        var newEachPeriodReportingRuleDetailList = [...eachPeriod.GPNoMinSection.ReportingRuleList[indexPosition].ReportingRuleDetailList];

        var action = component.get("c.getNewReportingRuleDetailJson");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
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
                eachPeriod.GPNoMinSection.ReportingRuleList[indexPosition].ReportingRuleDetailList = newEachPeriodReportingRuleDetailList;
                component.set("v.eachPeriod.GPNoMinSection.ReportingRuleList", eachPeriod.GPNoMinSection.ReportingRuleList);
                
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