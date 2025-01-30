({
    init : function(component, event, helper) {
  		helper.setCAMOrAirserviceHelper(component, event);
    },
    onPricingTypeChange: function(component, event, helper) {
		 var selected = event.getSource().getLocalId();
		 component.set("v.oppDetail_CAMOrAirService", selected);
		 console.log(component.get("v.oppDetail_CAMOrAirService"));
		 helper.setCAMOrAirserviceHelper(component, event);
		 component.set("v.isChangePricing", true);
	 },

	 onRenservicePriceChange : function(component, event, helper){
	 	 component.set("v.isChangePricing", true);
         var rentServicePricing = event.getParam("rentServicePricingMessage");
         console.log("rentServicePricing from Event", JSON.stringify(rentServicePricing));
         debugger;
         if (rentServicePricing.RentCondition === "% Escalation") {
	         let measurmentSummary = 0;
	         let periodTotalPrice = 0;
	         let periodTotalSumary = 0;

	         let periodPricing = component.get("v.periodPricing");
	         let newPeriodList = [...periodPricing];
	         let escalationRate = rentServicePricing.RentServiceEscalationRate.value;

	         newPeriodList.sort((a, b) => a.PeriodNumber - b.PeriodNumber);
	         let availableIndexList = [];

	         newPeriodList.forEach((eachPeriod, index) => {
				if (!eachPeriod.isCustomPeriod && !eachPeriod.isToDeleteRecord){
					availableIndexList.push(index);
				}            				
		     });

	         availableIndexList.forEach((currentPeriodRowData, periodRowIndex) => {
	         	debugger;

					periodTotalPrice = 0;
					periodTotalSumary = 0;

					if (newPeriodList[currentPeriodRowData].CalculationMethod ==="Fixed Measurement"){

			            newPeriodList[currentPeriodRowData].FixedMeasurementSection.pricingList.forEach((currentPeriodMeasurmentRowData, measurementIndex) => {
			           	
			           		measurmentSummary = 0;
		                      
			            		
		            		if (periodRowIndex>0) {

		            			newPeriodList[availableIndexList[periodRowIndex-1]].FixedMeasurementSection.pricingList.forEach((previousPeriodMeasurementRowData, previousPeriodMeasurmentRowIndex) => {
		            				debugger;
		            				if (previousPeriodMeasurementRowData.MeasurementType == currentPeriodMeasurmentRowData.MeasurementType && !previousPeriodMeasurementRowData.isFOC) {
		            					

		            					currentPeriodMeasurmentRowData.Price.value = previousPeriodMeasurementRowData.Price.value + (previousPeriodMeasurementRowData.Price.value*(escalationRate/100));
		            					currentPeriodMeasurmentRowData.Price.value = helper.roundDecimal(currentPeriodMeasurmentRowData.Price.value);
		            					
		            					measurmentSummary = currentPeriodMeasurmentRowData.Price.value * currentPeriodMeasurmentRowData.Area;
		            					measurmentSummary = helper.roundDecimal(measurmentSummary);

		            					currentPeriodMeasurmentRowData.Summary = measurmentSummary;
		            				}
		            			});

		            		}else{
		            			
		            			rentServicePricing.RentServiceMeasurment.forEach((rentServiceMeasurementRowData, rentServiceMeasurementIndex) => {
		            				if (rentServiceMeasurementRowData.MeasurementType == currentPeriodMeasurmentRowData.MeasurementType && !rentServiceMeasurementRowData.isFOC) {

				            			currentPeriodMeasurmentRowData.Price.value = (rentServiceMeasurementRowData.Price.value)?parseFloat(rentServiceMeasurementRowData.Price.value):0 ;				

				            			measurmentSummary = currentPeriodMeasurmentRowData.Price.value * currentPeriodMeasurmentRowData.Area;
				            			measurmentSummary = helper.roundDecimal(measurmentSummary);

				            			currentPeriodMeasurmentRowData.Summary = measurmentSummary;
		            				}

		            			});

			            	}

			            	currentPeriodMeasurmentRowData.Summary = (typeof currentPeriodMeasurmentRowData.Summary == 'number')?helper.roundDecimal(currentPeriodMeasurmentRowData.Summary):0;

			            	periodTotalPrice += currentPeriodMeasurmentRowData.Price.value
			            	periodTotalSumary += currentPeriodMeasurmentRowData.Summary;
		                });

			            periodTotalPrice = helper.roundDecimal(periodTotalPrice);
			            periodTotalSumary = helper.roundDecimal(periodTotalSumary);

		                newPeriodList[currentPeriodRowData].FixedMeasurementSection.TotalPrice = periodTotalPrice;
		                newPeriodList[currentPeriodRowData].FixedMeasurementSection.TotalSummary = periodTotalSumary;
					}
	           	
	        });
	         
         	console.log("newPeriodList", newPeriodList);
	       	component.set("v.periodPricing", newPeriodList)
         }

    },

})