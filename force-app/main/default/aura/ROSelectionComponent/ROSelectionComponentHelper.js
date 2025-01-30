({
    addROAction : function(component, event, row) {
    	var curentSelectedRoom = component.get("v.selectedRoom");
    	var currentDataTable = component.get("v.data");
        var totalLeasableArea = 0;
        var totalMeasurmentArea = 0;

        //debugger;

    	var newDataTable = [...currentDataTable];
    	var newVersionSelectedRoom = [...curentSelectedRoom];

    	newDataTable = newDataTable.map(function(rowData) {
            if (rowData.id === row.id) {
    			rowData.actionDisabled = true;
                rowData.actionLabel = 'Selected';
            }
            return rowData;
        });

        var newRowData = Object.assign({}, row);

    	newVersionSelectedRoom.push(newRowData);

        newVersionSelectedRoom.forEach(element =>{
            if (element.isToDeleteRecord != true) {
                totalLeasableArea += element.leasableArea;
                totalMeasurmentArea += element.measurement;
            }
        });

        console.log('Test Selected Room', JSON.stringify(newVersionSelectedRoom));

    	component.set("v.selectedRoom" ,newVersionSelectedRoom);
    	component.set("v.data", newDataTable);
        component.set("v.isChangeSelectedRO",true);
        component.set("v.isDisabledSaveButton", false);
        
        component.set("v.TotalMeasurmentArea",totalMeasurmentArea);
        component.set("v.TotalLeasableArea",totalLeasableArea);
    },

    removeSelectedRoom : function(component, event){
    	var curentSelectedRoom = component.get("v.selectedRoom");
    	var currentDataTable = component.get("v.data");
        var totalLeasableArea = component.get("v.TotalLeasableArea");
        var totalMeasurmentArea = component.get("v.TotalMeasurmentArea");

    	var newDataTable = [...currentDataTable];
    	var newVersionSelectedRoom = [...curentSelectedRoom];

    	var indexPosition = event.target.name;
        console.log("Delete Row ",indexPosition);

        newDataTable = newDataTable.map(function(rowData) {
            if (rowData.id === newVersionSelectedRoom[indexPosition].id && newVersionSelectedRoom[indexPosition] != true) {
    			rowData.actionDisabled = false;
                rowData.actionLabel = '';
            }
            return rowData;
        });

        totalLeasableArea -= newVersionSelectedRoom[indexPosition].leasableArea;
        totalMeasurmentArea -= newVersionSelectedRoom[indexPosition].measurement;

        newVersionSelectedRoom[indexPosition].isToDeleteRecord = true;
        console.log(newVersionSelectedRoom);

        let numberOfActiveRO = 0;
        newVersionSelectedRoom = newVersionSelectedRoom.map(function(rowData) {
            if (!rowData.isToDeleteRecord) {
                numberOfActiveRO++;
            }
            return rowData;
        });

        component.set("v.isChangeSelectedRO",true);
        component.set("v.selectedRoom" ,newVersionSelectedRoom);
        component.set("v.data", newDataTable);
        component.set("v.TotalMeasurmentArea",totalMeasurmentArea);
        component.set("v.TotalLeasableArea",totalLeasableArea);

        if (numberOfActiveRO==0) {
            var compEvent = component.getEvent("selectedROEvent");
            compEvent.setParams({
                "isDisabledSaveButton" : true
            });
            compEvent.fire();
        }
    }
})