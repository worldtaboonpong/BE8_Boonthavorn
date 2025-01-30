global class SumTotalAreaBatch implements Database.Batchable<sobject>, Database.Stateful {
    private String query;
   	//tms_SumTotalAreaScheduler
   	public SumTotalAreaBatch(){
        query = 'SELECT Id FROM Units__c ';
        //query = 'SELECT Id FROM tms_RentalObject__c WHERE ID=\'a0D0T000001bQBkUAM\'';
        
   	}

    global Database.Querylocator start(Database.BatchableContext bc){
        return Database.getquerylocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Units__c> rentalObjList){
    	Map<Id,Units__c> rentalObjectMapById = new Map<Id,Units__c>(rentalObjList);
        Map<Id,List<Measurement__c>> rentalMeasurementListMapByRentalObjId = new Map<Id,List<Measurement__c>>(); //Map Id of Unit with List<Measurement__c>
        List<Measurement__c> rentalMeasurementList =  [SELECT Id,Unit_No__c, Measurement_Area_Sqm__c, IsFOC__c , Valid_From_Date__c, Valid_To_Date__c  FROM Measurement__c  WHERE Valid_From_Date__c <= Today AND Valid_To_Date__c >= Today  AND Unit_No__c=:rentalObjectMapById.keyset()  ORDER BY Unit_No__c ];

        for(Measurement__c eachMeasurement : rentalMeasurementList){
            if(rentalMeasurementListMapByRentalObjId.containsKey(eachMeasurement.Unit_No__c)){
                rentalMeasurementListMapByRentalObjId.get(eachMeasurement.Unit_No__c).add(eachMeasurement);
            }else{
                List<Measurement__c> tmpRentalMeasurementList = new List<Measurement__c>();
                tmpRentalMeasurementList.add(eachMeasurement);
                rentalMeasurementListMapByRentalObjId.put(eachMeasurement.Unit_No__c,tmpRentalMeasurementList);
            }
        }

        for(Id eachrentalObjId : rentalObjectMapById.keyset()){
            Decimal sumTotalArea = 0;
            Decimal sumLeasableArea = 0;

            if(rentalMeasurementListMapByRentalObjId.containsKey(eachrentalObjId)){
                List<Measurement__c> tmpRentalMeasurementList = rentalMeasurementListMapByRentalObjId.get(eachrentalObjId);
                for(Measurement__c eachMeasurement : tmpRentalMeasurementList){
                    if(eachMeasurement.Measurement_Area_Sqm__c != null) {
                        sumTotalArea = sumTotalArea + eachMeasurement.Measurement_Area_Sqm__c ;
                        if(eachMeasurement.IsFOC__c == false){
                            sumLeasableArea = sumLeasableArea + eachMeasurement.Measurement_Area_Sqm__c ;
                        }
                    }
                }
            }
            rentalObjectMapById.get(eachrentalObjId).TotalArea__c = sumTotalArea;
            rentalObjectMapById.get(eachrentalObjId).LeasableArea__c = sumLeasableArea;
        }


        Database.SaveResult [] updateResult = Database.update(rentalObjectMapById.values(), false);
        // for (Database.SaveResult result : updateResult) {
        //     if (result.isSuccess()) {
                
        //     }
        // }
    }
    
    global void finish(Database.BatchableContext bc){ 
    }
}