({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    isSetReadOnly : function(component, event){
      debugger;
      var camPricing = component.get("v.camPricing");
      var isEditPaymentDueDate = component.get("v.isEditPaymentDueDate");


      if (camPricing) {
        if (isEditPaymentDueDate) {
          
          var newCAMPeriodList = Object.assign({}, camPricing);
          
          if(newCAMPeriodList.CAMCondition == "Advance"){

            component.set("v.isSelectCAMEscalation", false);
            component.set("v.isDisableAddCAMPeriod", false);

             newCAMPeriodList.CAMYearPeriod = newCAMPeriodList.CAMYearPeriod.map(function(camRowData) {

                if (!camRowData.isLockPeriod) {
                    camRowData.IsDisableInput = false;
                    
                    camRowData.CAMMeasurmentList = camRowData.CAMMeasurmentList.map(function(camMeasurementRow) {
                        camMeasurementRow.Price.IsDisabled = false;
                        return camMeasurementRow;
                    });
                }

                return camRowData;
            });

             camPricing = newCAMPeriodList;
             component.set("v.camPricing", camPricing);
          }

        }else{

          if (component.get("v.isReadOnly")) {
              var newCamPricing = Object.assign({}, camPricing);

              component.set("v.isDisableAddCAMPeriod",true);
              newCamPricing.CAMEscationRate.IsDisabled = true;
              
              newCamPricing.CAMYearPeriod = newCamPricing.CAMYearPeriod.map(function(camRowData) {
                
                camRowData.IsDisableInput = true;
                  
                camRowData.CAMMeasurmentList = camRowData.CAMMeasurmentList.map(function(camMeasurementRowData) {
                    
                    camMeasurementRowData.Price.IsDisabled = true;

                    return camMeasurementRowData;
                });  

                  return camRowData;
              });

              component.set("v.camPricing",newCamPricing);
          }   
        }
      }
    },

    initEscalationType : function(component, event){
      var camDetail = component.get("v.camPricing");
      var isEditPaymentDueDate = component.get("v.isEditPaymentDueDate");

      console.log("camDetail ",  JSON.stringify(camDetail));
      //debugger;
      if(camDetail){
        if (camDetail.CAMCondition) {
          if (camDetail.CAMCondition === "% Escalation") {
            component.set("v.isSelectCAMEscalation", true);
            component.set("v.isDisableAddCAMPeriod", true);

            camDetail.CAMYearPeriod = camDetail.CAMYearPeriod.map(function(camRowData) {
                camRowData.IsDisableInput = true;
                return camRowData;
            });
          }
          else if (camDetail.CAMCondition === "Advance"){
            component.set("v.isSelectCAMAdvance", true);
            component.set("v.isDisableAddCAMPeriod", false);
            
            if (isEditPaymentDueDate){
                camDetail.CAMYearPeriod = camDetail.CAMYearPeriod.map(function(camRowData) {
                  if (!camRowData.isLockPeriod){
                      camRowData.IsDisableInput = false;
                  }
                    return camRowData;
                });
            }else{

              camDetail.CAMYearPeriod = camDetail.CAMYearPeriod.map(function(camRowData) {
                  camRowData.IsDisableInput = false;
                  return camRowData;
              });
            }
          }
        }else{
          component.set("v.isSelectCAMEscalation", true);
          component.set("v.isDisableAddCAMPeriod", true);
          camDetail.CAMCondition = "% Escalation";

          camDetail.CAMYearPeriod = camDetail.CAMYearPeriod.map(function(camRowData) {
              camRowData.IsDisableInput = true;
              return camRowData;
          });
        }

        component.set("v.camPricing", camDetail)
      }

    },
    addCAMPeriodHelper : function(component, event){
      var camPricing = component.get("v.camPricing");
      var newPeriodList = [...camPricing.CAMYearPeriod];
      var selectedroom = component.get("v.seletedRoom");

      var action = component.get("c.getNewCAMPeriod");
      action.setParams({selectedRoomJson : JSON.stringify(selectedroom), periodLength: parseInt(newPeriodList.length)});

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              console.log("Success");

              var returnedData = response.getReturnValue();
              var newPeriod = JSON.parse(returnedData);
              newPeriod.isAddBGColor = true;
              newPeriodList.push(newPeriod);
              camPricing.CAMYearPeriod = newPeriodList;
              component.set("v.camPricing", camPricing);
              
          }
      });

      $A.enqueueAction(action);
    },

    getDefaultCAMDetaiHelper :function(component, event){
      var oppDetail = component.get("v.oppObject");
      var selectedroom = component.get("v.seletedRoom");
      var action = component.get("c.getCAMPricingDetail");
      component.set("v.toggleSpinner",true);
      action.setParams({
                    oppId : oppDetail.oppId,
                    selectedRoomJson : JSON.stringify(selectedroom),
                    contractStartDate : oppDetail.contractStartDateForm,
                    contractEndDate : oppDetail.contractEndDateFrom,
                    escalationType : '% Escalation',
                    leaseType : oppDetail.leaseType,
                    escalationRate : oppDetail.camOrAirEscalationRate,
                    isUpdateOpp : false,
                    optionToRenewYear : oppDetail.optionToRenewYear,
                    optionToRenewMonth: oppDetail.optionToRenewMonth,
                    oppUiWrapper: JSON.stringify(oppDetail)});

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              console.log("Success");

              var returnedData = response.getReturnValue();
              var newCamPricing = JSON.parse(returnedData);
               
              component.set("v.camPricing",newCamPricing); 
              component.set("v.toggleSpinner",false);
          }
      });

      $A.enqueueAction(action);
    },

    setEscalatePeriodFromAdvance :function(component, event, camPricing){
      var oppDetail = component.get("v.oppObject");
      var selectedroom = component.get("v.seletedRoom");
      var action = component.get("c.getCAMPricingDetail");
      component.set("v.toggleSpinner",true);
      action.setParams({
                    oppId : oppDetail.oppId,
                    selectedRoomJson : JSON.stringify(selectedroom),
                    contractStartDate : oppDetail.contractStartDateForm,
                    contractEndDate : oppDetail.contractEndDateFrom,
                    escalationType : '% Escalation',
                    leaseType : oppDetail.leaseType,
                    escalationRate : oppDetail.camOrAirEscalationRate,
                    isUpdateOpp : false,
                    optionToRenewYear : oppDetail.optionToRenewYear,
                    optionToRenewMonth: oppDetail.optionToRenewMonth,
                    oppUiWrapper: JSON.stringify(oppDetail)});

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              console.log("Success");

              var returnedData = response.getReturnValue();
              var newCamPricing = JSON.parse(returnedData);

              camPricing.CAMEscationRate.IsDisabled = false;
             var newCAMPeriodList = [...camPricing.CAMYearPeriod];

              newCAMPeriodList = newCAMPeriodList.map(function(camRowData) {
                  camRowData.isToDeleteRecord = true;
                  return camRowData;
              });

              newCamPricing.CAMYearPeriod = newCamPricing.CAMYearPeriod.map(function(camRowData) {
                  
                  newCAMPeriodList.push(camRowData);

                  return camRowData;
              });

              camPricing.CAMYearPeriod = newCAMPeriodList;

              component.set("v.camPricing",camPricing); 
              component.set("v.toggleSpinner",false);
              
          }
      });

      $A.enqueueAction(action);
    },

    getSavedCAMDetaiHelper :function(component, event){
      var oppDetail = component.get("v.oppObject");
      var selectedroom = component.get("v.seletedRoom");
      var action = component.get("c.getSavedCAMPricingDetail");
      component.set("v.toggleSpinner",true);
      action.setParams({
                    "recordId" : oppDetail.oppId,
                    "escalationType": oppDetail.camOrAirEscalationType,
                    "escalationRate" : oppDetail.camOrAirEscalationRate,
                    "selectedRoomJson" : JSON.stringify(selectedroom),
                    "oppUiWrapper" : JSON.stringify(oppDetail)});

      action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
              console.log("Success");

              var returnedData = response.getReturnValue();
              var newCamPricing = JSON.parse(returnedData);
               
              component.set("v.camPricing",newCamPricing); 
              component.set("v.toggleSpinner",false);
          }
      });

      $A.enqueueAction(action);
    },
    onChangeMeasurmentPriceEscalationHelper: function(component, event, isOnblur){
        console.log("Change Price");
        component.set("v.isChangePricing",true);
        
        var oppDetail = component.get("v.oppObject");
        var isRenew = oppDetail.isRenew;

        if (isRenew){
          component.set("v.isRenewChangeDate",true);
        }

        var isSelectEscalation = component.get("v.isSelectCAMEscalation");
        var isSelectAdvance = component.get("v.isSelectCAMAdvance");
        var isSelectCAMType = component.get("v.isSelectedCAMType");
        var isSelectAirService = component.get("v.isSelectedAirServiceType");
        var camDetail = component.get("v.camPricing");

        console.log("isSelectAdvance", isSelectAdvance );
        console.log("isSelectEscalation", isSelectEscalation );

        var new_camDetail = Object.assign({}, camDetail);
        var escaltionRate = parseFloat(new_camDetail.CAMEscationRate.value)/100;
        debugger;

        console.log("new_camDetail.CAMYearPeriod" + JSON.stringify(new_camDetail.CAMYearPeriod));
        new_camDetail.CAMYearPeriod.sort((a, b) => a.Year - b.Year);
         let availableIndexList = [];

         new_camDetail.CAMYearPeriod.forEach((eachPeriod, index) => {
            if (!eachPeriod.isToDeleteRecord){
                availableIndexList.push(index);
            }                           
         });

         debugger;

        availableIndexList.forEach((camPeriodRow, periodIndex) => { 
            
            var totalPrice = 0;
            debugger;
            if (periodIndex>0) {                
            
                new_camDetail.CAMYearPeriod[camPeriodRow].CAMMeasurmentList.forEach((camMeasurementRow, measurementIndex) => {                    
                    var increasedMeasurementPriceRate = 0;
                    var previousPeriodMeasurementPrice = 0;

                    debugger;

                    increasedMeasurementPriceRate = parseFloat(new_camDetail.CAMYearPeriod[availableIndexList[periodIndex-1]].CAMMeasurmentList[measurementIndex].Price.value) * escaltionRate; 
                    increasedMeasurementPriceRate = (typeof increasedMeasurementPriceRate == 'number')?this.roundDecimal(increasedMeasurementPriceRate):0;

                    previousPeriodMeasurementPrice = parseFloat(new_camDetail.CAMYearPeriod[availableIndexList[periodIndex-1]].CAMMeasurmentList[measurementIndex].Price.value);
                    previousPeriodMeasurementPrice = (typeof previousPeriodMeasurementPrice == 'number')?this.roundDecimal(previousPeriodMeasurementPrice):0;
                    
                    var currentCAMYear = (new Date(new_camDetail.CAMYearPeriod[camPeriodRow].DateTo)).getFullYear();
                    var previousCAMYear = (new Date(new_camDetail.CAMYearPeriod[availableIndexList[periodIndex-1]].DateTo)).getFullYear();

                    if (new_camDetail.CAMYearPeriod[camPeriodRow].isOptionToRenew && currentCAMYear==previousCAMYear) {
                        camMeasurementRow.Price.value = new_camDetail.CAMYearPeriod[availableIndexList[periodIndex-1]].CAMMeasurmentList[measurementIndex].Price.value;
                    }else{
                        camMeasurementRow.Price.value = previousPeriodMeasurementPrice + increasedMeasurementPriceRate; 
                        camMeasurementRow.Price.value = (typeof camMeasurementRow.Price.value == 'number')?this.roundDecimal(camMeasurementRow.Price.value):0;
                    }


                    camMeasurementRow.MeasurementArea = (typeof camMeasurementRow.MeasurementArea == 'number')?this.roundDecimal(camMeasurementRow.MeasurementArea):0;
                    
                        totalPrice += parseFloat(camMeasurementRow.Price.value) * parseFloat(camMeasurementRow.MeasurementArea);
                        totalPrice = this.roundDecimal(totalPrice);
                    
                });
            }else{                
                new_camDetail.CAMYearPeriod[camPeriodRow].CAMMeasurmentList.forEach((camMeasurementRow) => {    
                    if(isOnblur){
                      if (!camMeasurementRow.Price.value) {
                          camMeasurementRow.Price.value = 0;
                      }
                    }
                    totalPrice += parseFloat(camMeasurementRow.Price.value) * parseFloat(camMeasurementRow.MeasurementArea);
                    totalPrice = this.roundDecimal(totalPrice);
                });
            }


                new_camDetail.CAMYearPeriod[camPeriodRow].TotalPrice = totalPrice;

         });

        component.set("v.camPricing", new_camDetail);
              
            
    },
    onChangeMeasurmentPriceEscalationAdvance: function(component, event, isOnblur){
        console.log("Change Price");
        component.set("v.isChangePricing",true);
        var isSelectEscalation = component.get("v.isSelectCAMEscalation");
        var isSelectAdvance = component.get("v.isSelectCAMAdvance");
        var isSelectCAMType = component.get("v.isSelectedCAMType");
        var isSelectAirService = component.get("v.isSelectedAirServiceType");
        var camDetail = component.get("v.camPricing");

        console.log("isSelectAdvance", isSelectAdvance );
        console.log("isSelectEscalation", isSelectEscalation );

        var new_camDetail = Object.assign({}, camDetail);
        var escaltionRate = parseFloat(new_camDetail.CAMEscationRate.value)/100;
        debugger;

        console.log("new_camDetail.CAMYearPeriod" + JSON.stringify(new_camDetail.CAMYearPeriod));
        var indexPosition = event.getSource().get("v.name");
        console.log("Edit At Row",indexPosition);

        var totalPrice = 0;

        new_camDetail.CAMYearPeriod[indexPosition].CAMMeasurmentList.forEach((camMeasurementRow) => {
            if(isOnblur){
                if (!camMeasurementRow.Price.value) {
                    camMeasurementRow.Price.value = 0;
                }
            }

            totalPrice += parseFloat(camMeasurementRow.Price.value) * parseFloat(camMeasurementRow.MeasurementArea);
            totalPrice = this.roundDecimal(totalPrice);
        });

        new_camDetail.CAMYearPeriod[indexPosition].TotalPrice = totalPrice;
        component.set("v.camPricing", new_camDetail);
            
        
              
            
    },
})