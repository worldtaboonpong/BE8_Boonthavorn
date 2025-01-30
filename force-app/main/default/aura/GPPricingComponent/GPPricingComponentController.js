({
    init : function(component, event, helper) {
  		helper.setCAMOrAirserviceHelper(component, event);

  		console.log("FROM GP Pricing" , component.get("v.oppDetail_calculationAndReporting"));
  		console.log("FROM GP Pricing Picklist" , JSON.stringify(component.get("v.calculationReporting")));
    },
    onChangeCalculationReporting : function(component, event, helper){
    	var oppDetail_calculationAndReporting = component.get("v.oppDetail_calculationAndReporting");
    	var oppObject = component.get("v.oppObject");
    	var newoppObject = Object.assign({}, oppObject);
    	component.set("v.isChangePricing", true);

    	newoppObject.calculationAndReporting = oppDetail_calculationAndReporting;
    	var compEvent = component.getEvent("oppDetailEvent");
        compEvent.setParams({
            "oppObject" : newoppObject
        });
        compEvent.fire();

    },
    onPricingTypeChange: function(component, event, helper) {
		 var selected = event.getSource().getLocalId();
		 component.set("v.oppDetail_CAMOrAirService", selected);
		 console.log(component.get("v.oppDetail_CAMOrAirService"));
		 component.set("v.isChangePricing", true);

		 helper.setCAMOrAirserviceHelper(component, event);
	 },
	 onRenservicePriceChange : function(component, event, helper){
	 	 debugger;
	 	 component.set("v.isChangePricing", true);
         var rentServicePricing = event.getParam("rentServicePricingMessage");
         console.log("rentServicePricing from Event", JSON.stringify(rentServicePricing));
         
         if (rentServicePricing.RentCondition === "% Escalation") {
	         let measurmentSummary = 0;
	         let periodTotalPrice = 0;
	         let periodTotalSumary = 0;

	         let periodPricing = component.get("v.periodPricing");
	         let newPeriodList = [...periodPricing];
	         let escalationRate = rentServicePricing.RentServiceEscalationRate.value;
	         let previousAvailableInex;

	         debugger;

	         newPeriodList.sort((a, b) => a.PeriodNumber - b.PeriodNumber);
	         let availableIndexList = [];

	         newPeriodList.forEach((eachPeriod, index) => {
				if (!eachPeriod.isCustomPeriod && !eachPeriod.isToDeleteRecord){
					availableIndexList.push(index);
				}            				
		     });

	         availableIndexList.forEach((currentPeriodRowData, periodRowIndex) => {
	           	
					periodTotalPrice = 0;
					periodTotalSumary = 0;

					if (newPeriodList[currentPeriodRowData].CalculationMethod ==="GP on Top") {

			            newPeriodList[currentPeriodRowData].GPOnTopSection.PricingSection.MeasumentPricingList.forEach((currentPeriodMeasurmentRowData, measurementIndex) => {
			           	
			           		measurmentSummary = 0;
		                      
		            		if (periodRowIndex>0) {

		            			newPeriodList[availableIndexList[periodRowIndex-1]].GPOnTopSection.PricingSection.MeasumentPricingList.forEach((previousPeriodMeasurementRowData, previousPeriodMeasurmentRowIndex) => {
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

		                newPeriodList[currentPeriodRowData].GPOnTopSection.PricingSection.TotalPrice = periodTotalPrice;
		                newPeriodList[currentPeriodRowData].GPOnTopSection.PricingSection.TotalSummary = periodTotalSumary;
					}
					else if (newPeriodList[currentPeriodRowData].CalculationMethod ==="GP with Min") {
						newPeriodList[currentPeriodRowData].GPWithMinSection.PricingSection.MeasumentPricingList.forEach((currentPeriodMeasurmentRowData, measurementIndex) => {
			           	
			           		measurmentSummary = 0;
		                      
			            		
		            		if (periodRowIndex>0) {

		            			newPeriodList[availableIndexList[periodRowIndex-1]].GPWithMinSection.PricingSection.MeasumentPricingList.forEach((previousPeriodMeasurementRowData, previousPeriodMeasurmentRowIndex) => {
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

		                newPeriodList[currentPeriodRowData].GPWithMinSection.PricingSection.TotalPrice = periodTotalPrice;
		                newPeriodList[currentPeriodRowData].GPWithMinSection.PricingSection.TotalSummary = periodTotalSumary;

		                var salesmin = helper.calculateSalesMinHelper(component, event, newPeriodList[currentPeriodRowData]);
        				newPeriodList[currentPeriodRowData].GPWithMinSection.SalesMin = salesmin;

					}
	           	

	        });
	         
         	console.log("newPeriodList", newPeriodList);
	       	component.set("v.periodPricing", newPeriodList)
         }

    },

})