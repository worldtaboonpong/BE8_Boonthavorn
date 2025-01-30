global class FloorPlanFloorListWrapper {
    global class FloorListWrapper{
    	@TestVisible String floor;
    	@TestVisible String floorPlanImageLink;
    	@TestVisible String phase;
    	@TestVisible List<ROListWrapper> unitList;

    	public FloorListWrapper(String floorNumber, String floorPlanImageLink, String phase, List<ROListWrapper> unitPhaseList){
    		this.floor = floorNumber; 
    		this.floorPlanImageLink = floorPlanImageLink; 
    		this.phase = phase; 
    		this.unitList = unitPhaseList;
    	}

    }

    global class ROListWrapper{
    	@TestVisible String floor;
    	@TestVisible String id;
    	@TestVisible Integer numberOfOpportunities;
    	@TestVisible String unitNumber;
    	@TestVisible String status;
    	@TestVisible ROStatusWrapper UNIT_STATUS_MAPPING;
    	@TestVisible String unitKey;
    	@TestVisible String unitType;
    	@TestVisible Decimal coordX;
    	@TestVisible Decimal coordY;
        @TestVisible Decimal pointerSize;

    	public ROListWrapper(String floor, String id, Integer numberOfOpportunities, String unitNumber, String status, ROStatusWrapper unitStatus, String unitKey, String unitType, Decimal coordX, Decimal coordY, Decimal pointerSize){
    		this.floor = floor;
			this.id = id;
			this.numberOfOpportunities = numberOfOpportunities;
			this.unitNumber = unitNumber;
			this.status = status;
			this.UNIT_STATUS_MAPPING = unitStatus;
			this.unitKey = unitKey;
			this.unitType = unitType;
			this.coordX = coordX;
			this.coordY = coordY;
            this.pointerSize = pointerSize;

    	}
		public ROListWrapper(String floor, Integer numberOfOpportunities, Units__c eachUnit, String status){
    		this.floor = floor;
			this.id = eachUnit.id;
			this.numberOfOpportunities = numberOfOpportunities;
			this.unitNumber = eachUnit.Name;
			this.status = status;
			this.UNIT_STATUS_MAPPING = new FloorPlanFloorListWrapper.ROStatusWrapper();
			this.unitKey = eachUnit.Name;
			this.unitType = eachUnit.Usage_Type__c;
			this.coordX = eachUnit.CoordX__c;
			this.coordY = eachUnit.CoordY__c;
            this.pointerSize = eachUnit.PointerSize__c;
    	}
    }

    global class ROStatusWrapper{
    	@TestVisible String Available;
    	@TestVisible String Booked;
    	@TestVisible String Signed;
    	@TestVisible String Down_Payment;
    	@TestVisible String Floating_Transfer;
    	@TestVisible String Defer_Payment;
    	@TestVisible String Transferred;
    	@TestVisible String Locked ;
		public ROStatusWrapper(){}
    	public ROStatusWrapper (String available, String booked, String signed, String down_Payment, String floating_Transfer, String defer_Payment,String transferred,String locked){
    		this.Available = available;
			this.Booked = booked;
			this.Signed = signed;
			this.Down_Payment =  down_Payment;
			this.Floating_Transfer = floating_Transfer;
			this.Defer_Payment =  defer_Payment;
			this.Transferred =  transferred;
			this.Locked =  locked;
    	}
    }

    global class ROSaveListWrapper{
        public final String floor {get; private set; }
        public final String id {get; private set; }
        public final Integer numberOfOpportunities {get; private set; }
        public final String unitNumber {get; private set; }
        public final String status {get; private set; }
        public final ROStatusWrapper UNIT_STATUS_MAPPING {get; private set; }
        public final Decimal pointerSize {get; private set; }
        public final String unitKey {get; private set; }
        public final String unitType {get; private set; }
        public final Decimal coordX {get; private set; }
        public final Decimal coordY {get; private set; }
    }

	global class unitModelDisplayField{
        @AuraEnabled public String labelLeft {get; set; }
        @AuraEnabled public String fieldNameLeft {get; set; }
        @AuraEnabled public String valueLeft {get; set; }
		@AuraEnabled public String labelRight {get; set; }
        @AuraEnabled public String fieldNameRight {get; set; }
        @AuraEnabled public String valueRight {get; set; }
    }

	global class unitModelDisplayRentalObject{
		@AuraEnabled
        public List<unitModelDisplayField> rentalHeaderList{get; set; }
		@AuraEnabled
		public List<unitModelDisplayField> rentalItemList{get; set; }
		public unitModelDisplayRentalObject(){}
		public unitModelDisplayRentalObject(List<unitModelDisplayField> rentalHeaderList, List<unitModelDisplayField> rentalItemList){
			this.rentalHeaderList = rentalHeaderList;
			this.rentalItemList = rentalItemList;
		}
    }
}