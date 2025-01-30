@isTest
public class FloorPlanFloorListWrapperTest {

    @isTest
    static void test_FloorListWrapper() {
        String floorNumber = '01';
        String floorPlanImageLink = 'image';
        String phase = '01';
        List<FloorPlanFloorListWrapper.ROListWrapper> unitPhaseList = null;
        Test.startTest();
            FloorPlanFloorListWrapper.FloorListWrapper targetResult = new FloorPlanFloorListWrapper.FloorListWrapper(floorNumber, floorPlanImageLink, phase, unitPhaseList);
        Test.stopTest();
        System.assertEquals(targetResult.floor, floorNumber);
        System.assertEquals(targetResult.floorPlanImageLink, floorPlanImageLink);
        System.assertEquals(targetResult.phase, phase);
        System.assertEquals(targetResult.unitList, unitPhaseList);
    }

    @isTest
    static void test_ROListWrapper() {
        String floor = '01';
    	String id = null;
    	Integer numberOfOpportunities = 1;
    	String unitNumber = '01';
    	String status = 'status';
    	FloorPlanFloorListWrapper.ROStatusWrapper UNIT_STATUS_MAPPING = null;
    	String unitKey = 'key';
    	String unitType = 'type';
    	Decimal coordX = 10.0;
    	Decimal coordY = 12.21;
        Decimal pointerSize = 11.11;
        Test.startTest();
            FloorPlanFloorListWrapper.ROListWrapper targetResult = new FloorPlanFloorListWrapper.ROListWrapper(floor,
                                                                                                                    id,
                                                                                                                    numberOfOpportunities,
                                                                                                                    unitNumber,
                                                                                                                    status,
                                                                                                                    UNIT_STATUS_MAPPING,
                                                                                                                    unitKey,
                                                                                                                    unitType,
                                                                                                                    coordX,
                                                                                                                    coordY,
                                                                                                                    pointerSize);
        Test.stopTest();
        System.assertEquals(targetResult.floor, floor);
        System.assertEquals(targetResult.id, id);
        System.assertEquals(targetResult.numberOfOpportunities, numberOfOpportunities);
        System.assertEquals(targetResult.unitNumber, unitNumber);
        System.assertEquals(targetResult.status, status);
        System.assertEquals(targetResult.UNIT_STATUS_MAPPING, UNIT_STATUS_MAPPING);
        System.assertEquals(targetResult.unitKey, unitKey);
        System.assertEquals(targetResult.unitType, unitType);
        System.assertEquals(targetResult.coordX, coordX);
        System.assertEquals(targetResult.coordY, coordY);
        System.assertEquals(targetResult.pointerSize, pointerSize);
    }

    @isTest
    static void test_ROListWrapper_WithRecord() {
        String floor = '01';
        Integer numberOfOpportunities = 1;
        Units__c eachRentalObject = new Units__c();
        String status = 'status';
        Test.startTest();
            FloorPlanFloorListWrapper.ROListWrapper targetResult = new FloorPlanFloorListWrapper.ROListWrapper(floor,
                                                                                                                    numberOfOpportunities,
                                                                                                                    eachRentalObject,
                                                                                                                    status);
        Test.stopTest();
        System.assertEquals(targetResult.floor, floor);
        System.assertEquals(targetResult.numberOfOpportunities, numberOfOpportunities);
        System.assertEquals(targetResult.status, status);
    }

    @isTest
    static void test_ROStatusWrapper() {
        String Available = 'Available';
    	String Booked = 'Booked';
    	String Signed = 'Signed';
    	String Down_Payment = 'Down_Payment';
    	String Floating_Transfer = 'Floating_Transfer';
    	String Defer_Payment = 'Defer_Payment';
    	String Transferred = 'Transferred';
    	String Locked  = 'Locked ';
        List<FloorPlanFloorListWrapper.ROListWrapper> unitPhaseList = null;
        Test.startTest();
            FloorPlanFloorListWrapper.ROStatusWrapper targetResult = new FloorPlanFloorListWrapper.ROStatusWrapper( Available,
                                                                                                                        Booked,
                                                                                                                        Signed,
                                                                                                                        Down_Payment,
                                                                                                                        Floating_Transfer,
                                                                                                                        Defer_Payment,
                                                                                                                        Transferred,
                                                                                                                        Locked 
        );
        Test.stopTest();
        System.assertEquals(targetResult.Available, Available);
        System.assertEquals(targetResult.Booked, Booked);
        System.assertEquals(targetResult.Signed, Signed);
        System.assertEquals(targetResult.Down_Payment, Down_Payment);
        System.assertEquals(targetResult.Floating_Transfer, Floating_Transfer);
        System.assertEquals(targetResult.Defer_Payment, Defer_Payment);
        System.assertEquals(targetResult.Transferred, Transferred);
        System.assertEquals(targetResult.Locked, Locked);
    }

    @isTest
    static void test_ROSaveListWrapper() {
        Test.startTest();
            FloorPlanFloorListWrapper.ROSaveListWrapper targetResult = new FloorPlanFloorListWrapper.ROSaveListWrapper();
        Test.stopTest();
        system.assertEquals(null, targetResult.floor);
        system.assertEquals(null, targetResult.id);
        system.assertEquals(null, targetResult.numberOfOpportunities);
        system.assertEquals(null, targetResult.unitNumber);
        system.assertEquals(null, targetResult.status);
        system.assertEquals(null, targetResult.UNIT_STATUS_MAPPING);
        system.assertEquals(null, targetResult.pointerSize);
        system.assertEquals(null, targetResult.unitKey);
        system.assertEquals(null, targetResult.unitType);
        system.assertEquals(null, targetResult.coordX);
        system.assertEquals(null, targetResult.coordY);
    }

    @isTest
    static void test_unitModelDisplayField() {
        Test.startTest();
            FloorPlanFloorListWrapper.unitModelDisplayField targetResult = new FloorPlanFloorListWrapper.unitModelDisplayField();
        Test.stopTest();
        system.assertEquals(null, targetResult.labelLeft);
        system.assertEquals(null, targetResult.fieldNameLeft);
        system.assertEquals(null, targetResult.valueLeft);
        system.assertEquals(null, targetResult.labelRight);
        system.assertEquals(null, targetResult.fieldNameRight);
        system.assertEquals(null, targetResult.valueRight);
    }

    @isTest
    static void test_unitModelDisplayRentalObject() {
        List<FloorPlanFloorListWrapper.unitModelDisplayField> rentalHeaderList = null;
		List<FloorPlanFloorListWrapper.unitModelDisplayField> rentalItemList = null;
        Test.startTest();
            FloorPlanFloorListWrapper.unitModelDisplayRentalObject targetResult = new FloorPlanFloorListWrapper.unitModelDisplayRentalObject();
        Test.stopTest();
        system.assertEquals(null, targetResult.rentalHeaderList);
        system.assertEquals(null, targetResult.rentalItemList);
    }
    @isTest
    static void test_unitModelDisplayRentalObjectWithParam() {
        FloorPlanFloorListWrapper.unitModelDisplayField targetElement = new FloorPlanFloorListWrapper.unitModelDisplayField();
        targetElement.labelLeft = 'labelLeft';
        targetElement.fieldNameLeft = 'fieldNameLeft';
        targetElement.valueLeft = 'valueLeft';
        targetElement.labelRight = 'labelRight';
        targetElement.fieldNameRight = 'fieldNameRight';
        targetElement.valueRight = 'valueRight';

        List<FloorPlanFloorListWrapper.unitModelDisplayField> rentalHeaderList = new List<FloorPlanFloorListWrapper.unitModelDisplayField>();
		List<FloorPlanFloorListWrapper.unitModelDisplayField> rentalItemList = new List<FloorPlanFloorListWrapper.unitModelDisplayField>();
        
        rentalHeaderList.add(targetElement);
        rentalItemList.add(targetElement);
        Test.startTest();
            FloorPlanFloorListWrapper.unitModelDisplayRentalObject targetResult = new FloorPlanFloorListWrapper.unitModelDisplayRentalObject(rentalHeaderList, rentalItemList);
        Test.stopTest();
        system.assertEquals(1, targetResult.rentalHeaderList.size());
        system.assertEquals(1, targetResult.rentalItemList.size());
    }
    

}