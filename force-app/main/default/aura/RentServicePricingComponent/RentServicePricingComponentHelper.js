({
    roundDecimal: function(number){
          return Math.round((number + Number.EPSILON) * 100) / 100;
    },
    isSetReadOnly : function(component, event){
        var rentServicePricing = component.get("v.rentServicePricing");
  
        if (rentServicePricing) {
  
          if (component.get("v.isReadOnly")) {
              var newRentServicePricing = Object.assign({}, rentServicePricing);
  
              rentServicePricing.RentServiceEscalationRate.IsDisabled = true;
              
              rentServicePricing.RentServiceMeasurment = rentServicePricing.RentServiceMeasurment.map(function(rentServiceRowData) {
                
                rentServiceRowData.Price.IsDisabled = true;
                return rentServiceRowData;
              });
  
              component.set("v.rentServicePricing",newRentServicePricing);
          }   
        }
      },
      initEscalationType : function(component, event){
        var rentServiceDetail = component.get("v.rentServicePricing");
        
        console.log("rentServiceDetail ", JSON.parse( JSON.stringify(rentServiceDetail)));
        debugger;
  
        if (rentServiceDetail) {
          if (rentServiceDetail.RentCondition) {
            if (rentServiceDetail.RentCondition === "% Escalation") {
              component.set("v.isSelectRentServiceEscalation", true);
              // component.set("v.isSelectRenServiceAdvance", false);
            }
            else if (rentServiceDetail.RentCondition === "Advance"){
              component.set("v.isSelectRenServiceAdvance", true);
              // component.set("v.isSelectRentServiceEscalation", false);
            }
          }else{
            component.set("v.isSelectRentServiceEscalation", true);
            // component.set("v.isSelectRenServiceAdvance", false);
          }
        }
  
        // component.set("v.rentServicePricing", rentServiceDetail)
  
      }
  })