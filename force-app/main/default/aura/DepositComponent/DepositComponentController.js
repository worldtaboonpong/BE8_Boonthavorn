({
    init : function(component, event, helper){
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);
        var oppDetail = component.get("v.oppObject");

        if(newDepositObject.DepositCalculationType == 'Advance'){

            var camOrAirService_TotalDeposit = (!oppDetail.isNoCAM)?newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit:0;
            var rent_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit;
            var service_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit;
            
            var totalDepositAdvance = camOrAirService_TotalDeposit+rent_TotalDeposit+service_TotalDeposit;
            component.set("v.sumTotalDeposit",totalDepositAdvance); 
        }

    },
    onChangeDeposit : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
    },
    onChangeDepositMonth : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;
        debugger;

        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);

        let camOrAirService_LastMonthlyRate =  (!oppDetail.isNoCAM)?depositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate:0;
        let rent_LastMonthlyRate = depositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate;
        let service_LastMonthlyRate = depositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate;

        if(depositObject.DepositCalculationType === "System Calculation"){

            let depositMonth = depositObject.DepositMonth;
            if(!depositMonth || depositMonth  == 0){
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = 0;
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = 0;
                newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = 0;
            }else{

                if (camOrAirService_LastMonthlyRate == 0 && rent_LastMonthlyRate == 0 && service_LastMonthlyRate == 0) {
                    var camPricing = component.get("v.camPricing");
                    var pricing = component.get("v.periodPricing");
                    let camOrAirService = oppDetail.camOrAirService;
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

                    rentPrice = (typeof rentPrice == 'number')?helper.roundDecimal(rentPrice):0;
                    servicePrice = (typeof servicePrice == 'number')?helper.roundDecimal(servicePrice):0;

                    if (!oppDetail.isNoCAM) {

                        if (oppDetail.camOrAirService === "Air Service") {
                            var service = (depositMonth>0)?helper.roundDecimal(servicePrice):0;
                            var airService = (depositMonth>0)?helper.roundDecimal(camOrAirServicePrice):0;

                            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = 0;
                            newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = (depositMonth>0)?helper.roundDecimal(rentPrice):0;
                            newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = airService+service;

                        }else{
                            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = (depositMonth>0)?helper.roundDecimal(camOrAirServicePrice):0;
                            newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = (depositMonth>0)?helper.roundDecimal(rentPrice):0;
                            newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = (depositMonth>0)?helper.roundDecimal(servicePrice):0;
                        }
                    }else{
                        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate = 0;
                        newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate = (depositMonth>0)?helper.roundDecimal(rentPrice):0;
                        newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate = (depositMonth>0)?helper.roundDecimal(servicePrice):0;
                    }
                }
            }

            
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_LastMonthlyRate * newDepositObject.DepositMonth;
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit);

            newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.rent_LastMonthlyRate * newDepositObject.DepositMonth;
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit);

            newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.service_LastMonthlyRate * newDepositObject.DepositMonth;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit);
            

            if (oppDetail.isAllowChangeOptionToRenew) {
                let rentTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)):0;
                let serviceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)):0;
                let camOrAirServiceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)):0;

                let rentCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
                rentCarriedDeposit = helper.roundDecimal(rentCarriedDeposit);

                let serviceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
                serviceCarriedDeposit = helper.roundDecimal(serviceCarriedDeposit);

                let camOrAirServiceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;
                camOrAirServiceCarriedDeposit = helper.roundDecimal(camOrAirServiceCarriedDeposit);

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
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
            }else{

                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit;  
                newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary)
                
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit; 
                newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary);

                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit - newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit;
                newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary);

                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary;
                newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);
            }


            var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
            camOrAirService_Summary_vat = helper.roundDecimal(camOrAirService_Summary_vat);

            var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
            service_Summary_vat = helper.roundDecimal(service_Summary_vat);

            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat);

            newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat);

            newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat)

            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat);
            
            component.set("v.depositObject", newDepositObject);
            component.set("v.oppObject.depositMonth",newDepositObject.DepositMonth);
        }else{
            component.set("v.oppObject.depositMonth",depositObject.DepositMonth);
        }


        helper.calculateInstallmentHelper(component, event);
    },
    onChangeDatePeriod: function(component, event, helper){
        var depositObject = component.get("v.depositObject");
        var installmentIndex = event.getSource().get("v.name");

        depositObject.DepositSummary.InstallmentList[installmentIndex].isEditRecord = true;

        component.set("v.depositObject",depositObject);
        component.set("v.isChangeDeposit",true);

    },
    
    depositCalMethoChangeHandler : function(component, event, helper) {
    	var depositObject = component.get("v.depositObject");
        component.set("v.isChangeDeposit",true);

        if(depositObject.DepositCalculationType === "System Calculation"){
            helper.getNewSystemCalculationDeposit(component,event);
        }else if(depositObject.DepositCalculationType === "Advance"){
            helper.getNewAdvanceCalculationDeposit(component,event);
        }
    	

    	component.set("v.depositObject",depositObject);
    },

    depositOptionChangeHandler : function(component, event, helper){
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);
        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;

        component.set("v.isChangeDeposit",true);

        let rentTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)):0;
        let serviceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)):0;
        let camOrAirServiceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)):0;

        let rentCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
        rentCarriedDeposit = helper.roundDecimal(rentCarriedDeposit);

        let serviceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
        serviceCarriedDeposit = helper.roundDecimal(serviceCarriedDeposit);

        let camOrAirServiceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;
        camOrAirServiceCarriedDeposit = helper.roundDecimal(camOrAirServiceCarriedDeposit);

        if(newDepositObject.DepositOption === "คิดเงินประกันตามสัญญาใหม่"){
            
            newDepositObject.DepositRemark = "";

            newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentTotalDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceTotalDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceTotalDeposit;

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
            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);

            var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
            camOrAirService_Summary_vat = helper.roundDecimal(camOrAirService_Summary_vat);

            var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
            service_Summary_vat = helper.roundDecimal(service_Summary_vat);

            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat>0)?helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat):0;

            component.set("v.depositObject", newDepositObject);

            var newInstallmentList = [...newDepositObject.DepositSummary.InstallmentList];
            var numberOfActiveInstallment = 0;
            newInstallmentList.forEach((installmentRowData, index) => {
            
                if (!installmentRowData.isToDeleteRecord) {
                    numberOfActiveInstallment ++;
                }
            });

            if (numberOfActiveInstallment > 1) {
                if (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit <= 0) {
                    helper.resetInstallmentHelper(component, event);
                }
            }else if(numberOfActiveInstallment < 1){
                helper.addInstallmentHelper(component, event);
            }else{
                helper.calculateInstallmentHelper(component, event);
            }


        }else if(newDepositObject.DepositOption === "คงเงินประกันเดิม"){

            newDepositObject.DepositRemark = (oppDetail.quotationLanguage == "TH")?oppDetail.depositRemarkTH : oppDetail.depositRemarkEN;  

            newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentCarriedDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceCarriedDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceCarriedDeposit;

            let rentActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit;
            let serviceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit;
            let camOrAirServiceActualDDeposit = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit;

            var rentSummaryDeposit =  rentActualDDeposit - rentCarriedDeposit ;
            var serviceSummaryDeposit =  serviceActualDDeposit - serviceCarriedDeposit ;
            var camOrAirServiceSummaryDeposit =  camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit ;

            newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;
            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);

            var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
            camOrAirService_Summary_vat = helper.roundDecimal(camOrAirService_Summary_vat);

            var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
            service_Summary_vat = helper.roundDecimal(service_Summary_vat);

            newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
            newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
            newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
            newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat>0)?helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat):0;

            component.set("v.depositObject", newDepositObject);
            
            var newInstallmentList = [...newDepositObject.DepositSummary.InstallmentList];
            var numberOfActiveInstallment = 0;
            newInstallmentList.forEach((installmentRowData, index) => {
            
                if (!installmentRowData.isToDeleteRecord) {
                    numberOfActiveInstallment ++;
                }
            });

            if (numberOfActiveInstallment > 1) {

                helper.resetInstallmentHelper(component, event);
                
            }else if(numberOfActiveInstallment < 1){
                helper.addInstallmentHelper(component, event);
            }else{
                helper.calculateInstallmentHelper(component, event);
            }
        }
    },

    addInstallment : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
    	helper.addInstallmentHelper(component, event);
    },
    addOtherDeposit : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
    	helper.addOtherDepositHelper(component, event);
    },

    onblurCarrierDeposit: function(component, event, helper){
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);

        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;

        debugger;

        newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit = (!newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?0:newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit = (!newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?0:newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit = (!newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?0:newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit;

        newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit = (!newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)?0:newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit = (!newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)?0:newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit = (!newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)?0:newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit;
        

        let rentTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)):0;
        let serviceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)):0;
        let camOrAirServiceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)):0;

        component.set("v.sumTotalDeposit", rentTotalDeposit + serviceTotalDeposit + camOrAirServiceTotalDeposit);
        if (newDepositObject.DepositCalculationType == 'Advance') {
            newDepositObject.DepositSummary.AdvanceDepositAmount = helper.roundDecimal(rentTotalDeposit + serviceTotalDeposit + camOrAirServiceTotalDeposit);
        }

        let rentCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
        rentCarriedDeposit = helper.roundDecimal(rentCarriedDeposit);

        let serviceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
        serviceCarriedDeposit = helper.roundDecimal(serviceCarriedDeposit);

        let camOrAirServiceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;
        camOrAirServiceCarriedDeposit = helper.roundDecimal(camOrAirServiceCarriedDeposit);

        let rentActualDDeposit  = 0;
        let serviceActualDDeposit  = 0;
        let camOrAirServiceActualDDeposit  = 0;

        if (oppDetail.isAllowChangeOptionToRenew && newDepositObject.DepositOption == "คงเงินประกันเดิม") {
            rentActualDDeposit = rentCarriedDeposit;
            serviceActualDDeposit = serviceCarriedDeposit;
            camOrAirServiceActualDDeposit = camOrAirServiceCarriedDeposit;

        }else{
            rentActualDDeposit = rentTotalDeposit;
            serviceActualDDeposit = serviceTotalDeposit;
            camOrAirServiceActualDDeposit = camOrAirServiceTotalDeposit;
        }
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentActualDDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceActualDDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceActualDDeposit;

        var rentSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( rentActualDDeposit - rentCarriedDeposit) : (rentTotalDeposit - rentCarriedDeposit);
        var serviceSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( serviceActualDDeposit - serviceCarriedDeposit) : (serviceTotalDeposit - serviceCarriedDeposit);
        var camOrAirServiceSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit) : (camOrAirServiceTotalDeposit - camOrAirServiceCarriedDeposit);


        newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);

        var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
        camOrAirService_Summary_vat = helper.roundDecimal(camOrAirService_Summary_vat);

        var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
        service_Summary_vat = helper.roundDecimal(service_Summary_vat);

        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat>0)?helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat):0;

        component.set("v.depositObject", newDepositObject);
        helper.calculateInstallmentHelper(component, event);
    },

    onchangeCarrierDeposit : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
        debugger;
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);

        var oppDetail = component.get("v.oppObject");
        var vatPercent = oppDetail.vatPercentValue;

        let rentTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_TotalDeposit)):0;
        let serviceTotalDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_TotalDeposit)):0;
        let camOrAirServiceTotalDeposit = (!oppDetail.isNoCAM)?((newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)?helper.roundDecimal(parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_TotalDeposit)):0):0;

        component.set("v.sumTotalDeposit", rentTotalDeposit + serviceTotalDeposit + camOrAirServiceTotalDeposit);
        if (newDepositObject.DepositCalculationType == 'Advance') {
            newDepositObject.DepositSummary.AdvanceDepositAmount = helper.roundDecimal(rentTotalDeposit + serviceTotalDeposit + camOrAirServiceTotalDeposit);
        }

        let rentCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.rent_CarriedDeposit):0;
        rentCarriedDeposit = helper.roundDecimal(rentCarriedDeposit);

        let serviceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.service_CarriedDeposit):0;
        serviceCarriedDeposit = helper.roundDecimal(serviceCarriedDeposit);

        let camOrAirServiceCarriedDeposit = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit)?parseFloat(newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_CarriedDeposit):0;
        camOrAirServiceCarriedDeposit = helper.roundDecimal(camOrAirServiceCarriedDeposit);

        let rentActualDDeposit  = 0;
        let serviceActualDDeposit  = 0;
        let camOrAirServiceActualDDeposit  = 0;

        if (oppDetail.isAllowChangeOptionToRenew && newDepositObject.DepositOption == "คงเงินประกันเดิม") {
            rentActualDDeposit = rentCarriedDeposit;
            serviceActualDDeposit = serviceCarriedDeposit;
            camOrAirServiceActualDDeposit = camOrAirServiceCarriedDeposit;

        }else{
            rentActualDDeposit = rentTotalDeposit;
            serviceActualDDeposit = serviceTotalDeposit;
            camOrAirServiceActualDDeposit = camOrAirServiceTotalDeposit;
        }
        
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_ActualDeposit = rentActualDDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_ActualDeposit = serviceActualDDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_ActualDeposit = camOrAirServiceActualDDeposit;

        var rentSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( rentActualDDeposit - rentCarriedDeposit) : (rentTotalDeposit - rentCarriedDeposit);
        var serviceSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( serviceActualDDeposit - serviceCarriedDeposit) : (serviceTotalDeposit - serviceCarriedDeposit);
        var camOrAirServiceSummaryDeposit = (oppDetail.isAllowChangeOptionToRenew) ? ( camOrAirServiceActualDDeposit - camOrAirServiceCarriedDeposit) : (camOrAirServiceTotalDeposit - camOrAirServiceCarriedDeposit);

        newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary = rentSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary = serviceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary = camOrAirServiceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = rentSummaryDeposit + serviceSummaryDeposit + camOrAirServiceSummaryDeposit;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit = helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit);

        var camOrAirService_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary*(vatPercent/100));
        camOrAirService_Summary_vat = helper.roundDecimal(camOrAirService_Summary_vat);

        var service_Summary_vat = (newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary*(vatPercent/100));
        service_Summary_vat = helper.roundDecimal(service_Summary_vat);

        newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary + camOrAirService_Summary_vat;
        newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary;
        newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary + service_Summary_vat;

        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = newDepositObject.DepositSummary.DepositSummaryPricing.camOrAirService_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.rent_Summary_WithVat + newDepositObject.DepositSummary.DepositSummaryPricing.service_Summary_WithVat;
        newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat = (newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat>0)?helper.roundDecimal(newDepositObject.DepositSummary.DepositSummaryPricing.totalDeposit_WithVat):0;

        debugger;

        component.set("v.depositObject", newDepositObject);


        if (oppDetail.isAllowChangeOptionToRenew) {
            var newInstallmentList = [...newDepositObject.DepositSummary.InstallmentList];
            var numberOfActiveInstallment = 0;
            newInstallmentList.forEach((installmentRowData, index) => {
            
                if (!installmentRowData.isToDeleteRecord) {
                    numberOfActiveInstallment ++;
                }
            });

            if (numberOfActiveInstallment > 1) {

                if (rentSummaryDeposit < 0 || serviceSummaryDeposit < 0 || camOrAirServiceSummaryDeposit < 0) {
                    helper.resetInstallmentHelper(component, event);
                }else{
                    helper.calculateInstallmentHelper(component, event);
                }
            }else{
                helper.calculateInstallmentHelper(component, event);
            }
        }else{
            helper.calculateInstallmentHelper(component, event);
        }
    },

    removeInstallment : function(component, event, helper){
        var oppDetail = component.get("v.oppObject");

        if(oppDetail.popupSetting["การลบ Installment"].tms_Enable__c){

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
                                component.set("v.isChangeDeposit",true);
                                helper.removeInstallmentHelper(component, event);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
            component.set("v.isChangeDeposit",true);
            helper.removeInstallmentHelper(component, event);
       }

    },
    removeOtherDeposit : function(component, event, helper){
        var oppDetail = component.get("v.oppObject");

        if(oppDetail.popupSetting["การลบ Other Deposit"].tms_Enable__c){

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
                                component.set("v.isChangeDeposit",true);
                                helper.removeOtherDepositHelper(component, event);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
            component.set("v.isChangeDeposit",true);
            helper.removeOtherDepositHelper(component, event);
       }

    },
    changeInstallmentHandler : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
        helper.changeInstallmentHelper(component, event);
    },
    onblurchangeInstallmentHandler : function(component, event, helper){
        helper.onblurchangeInstallmentHelper(component, event);
    },

    onChangeDepositAmount : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
        helper.calculateAdvanceDeposit(component,event);
    },
    onBlurChangeDepositAmount : function(component, event, helper){
        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);
        
        if (!newDepositObject.DepositSummary.AdvanceDepositAmount) {
            newDepositObject.DepositSummary.AdvanceDepositAmount = 0;
            component.set("v.depositObject.DepositSummary.AdvanceDepositAmount",newDepositObject.DepositSummary.AdvanceDepositAmount);
        }

        helper.calculateAdvanceDeposit(component,event);
    },

    handleComponentEvent : function(component, event, helper){
        component.set("v.isChangeDeposit",true);
        var eachOtherDeposit = event.getParam("eachOtherDeposit");
        var OtherDepositIndex = event.getParam("OtherDepositIndex");

        var depositObject = component.get("v.depositObject");
        var newDepositObject = Object.assign({}, depositObject);

        newDepositObject.OtherDepositList[parseInt(OtherDepositIndex)] = eachOtherDeposit;

        component.set("v.depositObject", newDepositObject);
    }

})