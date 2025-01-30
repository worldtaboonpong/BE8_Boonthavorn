({
    init : function(component, event, helper) {
    	component.set('v.columns', [
    		{label: 'Action', type: 'button', initialWidth: 80, typeAttributes:
                { label: { fieldName: 'actionLabel'}, variant: 'base', title: 'Add', name: 'addRO', iconName: 'utility:add', disabled: {fieldName: 'actionDisabled'}}},
            {label: 'Room Number', fieldName: 'roomNumber', type: 'text'},
            {label: 'Floor', fieldName: 'floor', type: 'text' , initialWidth: 80},
            {label: 'Total Area', fieldName: 'totalArea', type: 'text', initialWidth: 110},
            {label: 'Type', fieldName: 'roTypeLabel', type: 'text'},
            {label: 'Request Header', fieldName: 'requestHeader', type: 'text'},
            {label: 'Request', fieldName: 'requestName', type: 'text'}
        ]);
        console.log('Initial Select Type', component.get("v.selectedUsageType"));
    },

    refetchRoom : function(component, event, helper){
        var selectedRoom = component.get("v.selectedRoom");
        var searchRentedROCondition = component.get("v.isSearchRentedRO");

        if (selectedRoom) {
            var newSelectedRoomList = [];
            selectedRoom = selectedRoom.map(function(rowData) {

                if (searchRentedROCondition) {
                    if (rowData.isContracted) {
                        newSelectedRoomList.push(rowData);
                    }
                }else{
                    if (!rowData.isContracted) {
                        newSelectedRoomList.push(rowData);
                    }
                }
                return rowData;
            });

            component.set("v.selectedRoom", newSelectedRoomList);
        }
    }, 

    searchRoom : function(component, event, helper) {

        var idToDisable = [];

    	var curentSelectedRoom = component.get("v.selectedRoom");
        var searchROValueCondtion = component.get("v.searchROValue");
        var searchRentedROCondition = component.get("v.isSearchRentedRO");
        var selectedUsageType = component.get("v.selectedUsageType");
        var contractStartDate = component.get("v.oppDetail_ContractStartDate");
        var contractEndDate = component.get("v.oppDetail_ContractEndDate");
        var validateInputLength = component.get("v.searchKeyLength");
        var buildingId = component.get("v.oppDetail_OppBuildingId");

        var isEnterKey = event.keyCode === 13;
        var queryTerm = component.find('enter-search').get('v.value');
        var returnedData;
        var oppRecordType = component.get("v.recordTypeName");
        var isRetailZone = (oppRecordType == 'Retail Zone Process')?"TRUE":"FALSE";

        //debugger;


            if (searchROValueCondtion) {
                var queryConditionString = "WHERE ";

                if (searchROValueCondtion === "roomnumber") {
                    queryConditionString += "Name LIKE  '%" + queryTerm + "%' AND Available_for_Sales__c = true AND Usage_Type__c = '" + selectedUsageType +"' AND IsRetailZone__c = "+isRetailZone+"  AND Type__c != 'Cancelled' AND Building__c = '"+buildingId+"'";

                }else if(searchROValueCondtion === "floor"){
                    queryConditionString += "Floor__r.Name LIKE '%" + queryTerm + "%' AND Available_for_Sales__c = true AND Usage_Type__c = '"+ selectedUsageType+"'  AND IsRetailZone__c = "+isRetailZone+"  AND Type__c != 'Cancelled' AND Building__c = '"+buildingId+"'";
                }
            }

            console.log('Condition',searchROValueCondtion);

            if (curentSelectedRoom) {
                curentSelectedRoom.forEach(element => {
                  if (element.isToDeleteRecord != true) {

                    idToDisable.push(element.id);
                  }
                });
            }

            if (isEnterKey) {
                if (queryTerm.length >= validateInputLength) {
                    component.set('v.isSearching', true);
                    console.log("Come to Enter");

                    var action = component.get("c.SearchRentalObject");
                    action.setParams({ queryCondition : queryConditionString, isRentedRoom : searchRentedROCondition, contractStartDate: contractStartDate, contractEndDate: contractEndDate });
             
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            returnedData = response.getReturnValue();
                            console.log(returnedData);

                            var jsonData =  JSON.parse(returnedData);

                            if (jsonData.length>0) {

                                jsonData = jsonData.map(function(rowData) {
                                    if (idToDisable) {
                                        if (idToDisable.includes(rowData.id)) {
                                            rowData.actionDisabled = true;
                                            rowData.actionLabel = 'Selected';
                                        }
                                    }

                                    // rowData.TotalArea = rowData.tms_RentalObjMeasurements__r[0].tms_MeasurementAmount__c;
                                    // rowData.FloorName = rowData.tms_FloorToFloor__r.Name;

                                    return rowData;
                                });
                            }else{
                                component.set("v.isNoROData",true);
                            }

                            component.set('v.data', jsonData);
                            component.set('v.isSearching', false);
             
                        } else {
                            console.log("Error: "+JSON.stringify(response.getError()));
                        }
                    });
             
                    $A.enqueueAction(action);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "warning",
                            "title": "Warning!",
                            "message": component.get("v.errorMessageWhenTooShort")
                        });
                        toastEvent.fire();
                }
                // var data = [
                //     {id:"1", RoomNumber: "1", Floor:"1", TotalArea:"10", UsageType :"Test1", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"2", RoomNumber: "2", Floor:"2", TotalArea:"20", UsageType :"Test2", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"3", RoomNumber: "3", Floor:"2", TotalArea:"30", UsageType :"Test3", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"4", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"5", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"6", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"7", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"8", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"9", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"10", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"11", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"12", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"13", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"14", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20},
                //     {id:"15", RoomNumber: "4", Floor:"3", TotalArea:"40", UsageType :"Test4", AvailableForSale:true, ValidForm:"01/01/2020", Meter:"Test Meter Data", LeasableArea:120, Measurement:130, Area:"50 sqm.", ValidTo:"12/12/2021", Occupied:true, FootPrint:100, FOC:10, Mezzanine:20}
                // ];
            }

    },

    removeSelectedRoom : function(component, event, helper) {
       var oppDetail = component.get("v.oppObject");
        console.log('-----removeSelectedRoom-----');
       if(oppDetail.popupSetting["การลบ Rental Object"].Enable){

           var modalBody;
           var modalFooter;
            $A.createComponents([
                ["c:ConfirmPopup",{}],
                ["c:ConfirmPopupFooter",{isConfirmRemove : component.getReference("v.isConfirmRemove")}]
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
                                helper.removeSelectedRoom(component, event);
                                component.set("v.isConfirmRemove",false);
                            }
                        }
                    })
                }
            }
           );
       }else{
            helper.removeSelectedRoom(component, event);
       }

    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'addRO':
                helper.addROAction(component, event, row);
                break;
            default:
                break;
        }
    },

    onchangeValue: function (component, event, helper){
        component.set("v.isChangeSelectedRO", true);
    }

})