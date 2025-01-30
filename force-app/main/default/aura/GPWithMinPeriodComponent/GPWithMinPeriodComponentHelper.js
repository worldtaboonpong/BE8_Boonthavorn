({
    roundDecimal: function(number){
        return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    calculateSalesMinHelper : function(component, event, eachPeriod) {
        console.log("To calcuate Salesmin: ");
        debugger;

        var summaryPrice = 0;
        var salesMin = 0;
        var calculationObject = [];
        var diffRange = 0;
        var gpPercent = 0;
        var gpPriceValue = 0;
        var sumGPPrice = 0;
        var isExceedSummaryPrice = false;
        var isOverMinValue = false;
        var skipLoop = false;

        var newEachPeriod = Object.assign({}, eachPeriod);
        var newReportingRuleList = [];
        eachPeriod.GPWithMinSection.ReportingRuleList.forEach((eachGPRowData, eachGPRowIndex) => {

            if (!eachGPRowData.isToDeleteRecord){
                newReportingRuleList.push(eachGPRowData);
            }

        });

        newEachPeriod.GPWithMinSection.ReportingRuleList = newReportingRuleList;
        
        if (newEachPeriod.GPWithMinSection.ReportingRuleList.length > 0 ) {
            if (newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList) {

                if (newEachPeriod.GPWithMinSection.PricingSection.MinType === "Measurement" && newEachPeriod.GPWithMinSection.PricingSection.MeasumentPricingList) {
                    summaryPrice = parseFloat(newEachPeriod.GPWithMinSection.PricingSection.TotalSummary);
                }
                else if (newEachPeriod.GPWithMinSection.PricingSection.MinType === "Fixed" && newEachPeriod.GPWithMinSection.PricingSection.FixedPricing) {
                    summaryPrice = parseFloat(newEachPeriod.GPWithMinSection.PricingSection.FixedPricing.Price);
                }

                if (summaryPrice) {

                    var numberOfZeroRangeForm = 0;
                    newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.forEach((eachGPRowData, eachGPRowIndex, eachReportingRuleList) => {
                        if ((isNaN(parseFloat(eachGPRowData.rangFrom)) || parseFloat(eachGPRowData.rangFrom) == 0) && !eachGPRowData.isToDeleteRecord) {
                            numberOfZeroRangeForm = numberOfZeroRangeForm +1;
                        }
                    });

                    newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.forEach((eachGPRowData, eachGPRowIndex, eachReportingRuleList) => {
                        debugger;
                        if (!skipLoop && !eachGPRowData.isToDeleteRecord) {
                            diffRange = 0;
                            gpPercent = 0;
                            sumGPPrice = 0;

                            if (
                                (
                                    (!isNaN(parseFloat(eachGPRowData.rangFrom)) && parseFloat(eachGPRowData.rangFrom)==0 && isNaN(parseFloat(eachGPRowData.rangTo))) ||
                                    (!isNaN(parseFloat(eachGPRowData.rangFrom)) && parseFloat(eachGPRowData.rangFrom)==0 && parseFloat(eachGPRowData.rangTo) == 0) ||
                                    (!isNaN(parseFloat(eachGPRowData.rangFrom)) && parseFloat(eachGPRowData.rangFrom)==0 && parseFloat(eachGPRowData.rangTo) > summaryPrice)
                                )  && newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.length == 1
                                   && parseFloat(eachGPRowData.GPPercent) > 0
                               ) {
                                salesMin = summaryPrice/(parseFloat(eachGPRowData.GPPercent)/100);
                                salesMin = this.roundDecimal(salesMin);
                            }else if(
                                        (
                                            (!isNaN(parseFloat(eachGPRowData.rangFrom)) && parseFloat(eachGPRowData.rangFrom)>0 && isNaN(parseFloat(eachGPRowData.rangTo))) || 
                                            ((!isNaN(parseFloat(eachGPRowData.rangFrom)) && parseFloat(eachGPRowData.rangFrom)>0 && parseFloat(eachGPRowData.rangTo) == 0)) ||
                                            ((!isNaN(parseFloat(eachGPRowData.rangFrom)) && parseFloat(eachGPRowData.rangFrom)>0 && parseFloat(eachGPRowData.rangTo) - parseFloat(eachGPRowData.rangFrom) >  summaryPrice))
                                        )&& newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.length == 1
                                         && parseFloat(eachGPRowData.GPPercent) > 0
                            ){
                                salesMin = (summaryPrice/(parseFloat(eachGPRowData.GPPercent)/100))+parseFloat(eachGPRowData.rangFrom);
                                salesMin = this.roundDecimal(salesMin);
                            }

                            var isOverMinAtFirstRange = false;
                            var zeroIndexDiff = newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList[0].rangTo - newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList[0].rangFrom;
                            var rangeDiff = eachGPRowData.rangTo - eachGPRowData.rangFrom;
                            var zeroIndexGPPercent = (!isNaN(newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList[0].GPPercent))?parseFloat(newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList[0].GPPercent):0;
                            var gpPercenToCheck = (!isNaN(eachGPRowData.GPPercent))?parseFloat(eachGPRowData.GPPercent):0;
                            var gpPriceValueToCheck = 0;
                            var isZeroRangeFromThanOneRange = numberOfZeroRangeForm>1;

                            if (isZeroRangeFromThanOneRange) {
                                gpPriceValueToCheck = (rangeDiff*(gpPercenToCheck/100));

                                if ((isNaN(parseFloat(eachGPRowData.rangFrom)) || parseFloat(eachGPRowData.rangFrom) == 0) && (parseFloat(eachGPRowData.rangTo)>0) && gpPriceValueToCheck > summaryPrice) {
                                    salesMin = summaryPrice/(parseFloat(eachGPRowData.GPPercent)/100);
                                    salesMin = this.roundDecimal(salesMin);
                                    skipLoop = true;
                                }
                                else if((isNaN(parseFloat(eachGPRowData.rangTo)) || parseFloat(eachGPRowData.rangTo) == 0) && (isNaN(parseFloat(eachGPRowData.rangFrom)) || parseFloat(eachGPRowData.rangFrom) == 0) && gpPriceValueToCheck < summaryPrice ){
                                    salesMin = summaryPrice/(parseFloat(eachGPRowData.GPPercent)/100);
                                    salesMin = this.roundDecimal(salesMin);
                                }

                            }else{
                                isOverMinAtFirstRange = (zeroIndexDiff*(zeroIndexGPPercent/100)) > summaryPrice;
                                
                                if(!isNaN(parseFloat(eachGPRowData.rangTo)) && parseFloat(eachGPRowData.rangTo) > 0 && !isNaN(parseFloat(eachGPRowData.rangFrom)) && newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.length>1 && isOverMinAtFirstRange && !isOverMinValue){
                                    salesMin = summaryPrice/(parseFloat(eachGPRowData.GPPercent)/100);
                                    salesMin = this.roundDecimal(salesMin);
                                    isOverMinValue = isOverMinAtFirstRange;
                                }
                                else if (!isNaN(parseFloat(eachGPRowData.rangTo)) && parseFloat(eachGPRowData.rangTo) > 0 && !isNaN(parseFloat(eachGPRowData.rangFrom)) && newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.length>1 && gpPriceValueToCheck < summaryPrice && !isOverMinValue) {
                                    diffRange = parseFloat(eachGPRowData.rangTo) - parseFloat(eachGPRowData.rangFrom);
                                    diffRange = this.roundDecimal(diffRange);

                                    gpPercent = (!isNaN(eachGPRowData.GPPercent))?parseFloat(eachGPRowData.GPPercent):0;
                                    
                                    gpPriceValue = (diffRange*(gpPercent/100));
                                    gpPriceValue = this.roundDecimal(gpPriceValue);

                                    if(gpPriceValue < summaryPrice && eachGPRowIndex > 0 &&  parseFloat(eachReportingRuleList[eachGPRowIndex-1].rangFrom) == 0 && parseFloat(eachGPRowData.rangFrom) == 0){
                                        if (calculationObject) {
                                            calculationObject[eachGPRowIndex-1].gpPrice = 0;
                                            calculationObject[eachGPRowIndex-1].salePeriod = 0;
                                        }
                                    }

                                    if(calculationObject){
                                        calculationObject.forEach((eachCalculated, index) =>{
                                            sumGPPrice += eachCalculated.gpPrice ;
                                            sumGPPrice = this.roundDecimal(sumGPPrice);
                                        });
                                    }

                                    console.log('sumGPPrice' + sumGPPrice);

                                    if (gpPriceValue > summaryPrice || (sumGPPrice+gpPriceValue) > summaryPrice) {
                                        isExceedSummaryPrice = true;
                                    }

                                    console.log('isExceedSummaryPrice' + isExceedSummaryPrice);
                                    
                                    if (calculationObject) {
                                        calculationObject.push({
                                                        from: eachGPRowData.rangFrom, 
                                                        to: eachGPRowData.rangTo, 
                                                        gp: gpPercent, 
                                                        gpPrice: (isExceedSummaryPrice && eachGPRowIndex>0)? ((summaryPrice -sumGPPrice)) : gpPriceValue,
                                                        salePeriod: (isExceedSummaryPrice && eachGPRowIndex>0)? (summaryPrice -sumGPPrice)/(gpPercent/100) :diffRange
                                                        });
                                    }
                                }
                                else if(
                                        (
                                            (parseFloat(eachGPRowData.rangFrom)>0 && isNaN(parseFloat(eachGPRowData.rangTo))) || 
                                            (parseFloat(eachGPRowData.rangFrom)>0 && parseFloat(eachGPRowData.rangTo)==0)
                                        )
                                        && newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.length> 1 && gpPriceValueToCheck < summaryPrice && !isOverMinValue){
                                    gpPercent = (eachGPRowData.GPPercent)?eachGPRowData.GPPercent:0;
                                    sumGPPrice = 0;

                                    if(calculationObject){
                                        
                                        calculationObject.forEach((eachCalculated, index) =>{
                                            sumGPPrice += eachCalculated.gpPrice;
                                            sumGPPrice = this.roundDecimal(sumGPPrice);
                                        });
                                        
                                        calculationObject.push({
                                                        from: eachGPRowData.rangFrom, 
                                                        to: eachGPRowData.rangTo, 
                                                        gp: gpPercent, 
                                                        gpPrice: (isExceedSummaryPrice && eachGPRowIndex>0)? 0 : (summaryPrice -sumGPPrice),
                                                        salePeriod: (isExceedSummaryPrice && eachGPRowIndex>0)? 0 : ((summaryPrice -sumGPPrice)/(gpPercent/100))
                                                        });
                                    }
                                }else if((isNaN(parseFloat(eachGPRowData.rangTo)) || parseFloat(eachGPRowData.rangTo) == 0) && (isNaN(parseFloat(eachGPRowData.rangFrom)) || parseFloat(eachGPRowData.rangFrom) == 0) && newEachPeriod.GPWithMinSection.ReportingRuleList[0].ReportingRuleDetailList.length>1 && gpPriceValueToCheck < summaryPrice && !isOverMinValue){
                                    salesMin = summaryPrice/(parseFloat(eachGPRowData.GPPercent)/100);
                                    salesMin = this.roundDecimal(salesMin);
                                    calculationObject = null;
                                    skipLoop = true;
                                }
                            }
                        }
                    });

                    if(calculationObject){
                        calculationObject.forEach((eachCalculated, index) =>{
                            eachCalculated.salePeriod = (typeof eachCalculated.salePeriod == 'number')?this.roundDecimal(eachCalculated.salePeriod):0;
                            salesMin += eachCalculated.salePeriod;
                        });
                    }
                }
            }
            console.log("salesMin", salesMin);
            console.log("calculationObject", calculationObject);

            return salesMin;
        }
    }
})