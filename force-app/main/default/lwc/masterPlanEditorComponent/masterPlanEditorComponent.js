import { LightningElement, track } from 'lwc';
// import getFloorList from '@salesforce/apex/tms_masterPlanController.getFloorList';
// import saveUnitList from '@salesforce/apex/tms_masterPlanController.saveUnitList';
import getFloorList from '@salesforce/apex/masterPlanController.getFloorList';
import saveUnitList from '@salesforce/apex/masterPlanController.saveUnitList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const defaultPointerSize = 30;

export default class MasterPlanEditorComponent extends LightningElement {
    isLoading = false;
    @track floorList = [];
    @track disableSaveUnitButton = true;
    @track unitWithCoordList = [];
    @track allUnitList = [];
    @track undoStack = [];
    _currentFloorName = null;
    _currentDraftUnit = null;
    _selectedUnitKey = null;
    _originalFloorList = [];
    _fromFloor = null;
    _toFloor = null;
    _currentProjectId = null;
    showCloneSection = false;
    pointerSize = defaultPointerSize;

    handleSelectionChange(event) {
        const selection = this.template.querySelector('c-project-selector').getSelection();
        if (selection && selection.length > 0) {
            this._currentProjectId = selection[0].id;
            this.fetchFloorList(this._currentProjectId);
        }else {
            this._currentProjectId = null;
            this.floorList = [];
            this.unitWithCoordList = [];
            this.allUnitList = [];
            this.undoStack = [];
            this.disableSaveUnitButton = true;
            this._currentFloorName = null;
            //this.template.querySelector('c-table-view').setFloorList([]);
        }
    }

    handleSizeChange(event) {
        this.pointerSize = Number(event.target.value);
        const planView = this.template.querySelector('c-plan-view');
        planView.pointerSize = this.pointerSize;
        planView.drawPlanView();
    }

    fetchFloorList(projectId) {
        this.isLoading = true;
        getFloorList({buildingId: projectId}).then(floorList => {
            this.floorList = floorList;
            this._originalFloorList = floorList;
            this.isLoading = false;
            this.getUnitWithCoordList();
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        });
    }

    getUnitWithCoordList() {
        debugger;
        const planView = this.template.querySelector('c-plan-view');
        if (planView) {
            const thisFloor = planView.getCurrentFloor();
            if (thisFloor && thisFloor.unitList && thisFloor.unitList.length > 0) {
                this._currentFloorName = thisFloor.floor;
                const floor = this.floorList.filter(each => each.floor === this._currentFloorName)[0];
                if (floor) {
                    if (floor.unitList) {
                        let unitWithCoordList = floor.unitList.filter(each => each.coordX && each.coordY);
                        if(unitWithCoordList && unitWithCoordList.length > 0) {
                            this.pointerSize = unitWithCoordList[0].pointerSize || defaultPointerSize;
                        }
                        this.unitWithCoordList = unitWithCoordList.map(each => ({...each, pointerSize: this.pointerSize}));
                        this.template.querySelector('c-plan-view').drawPlanView();
                    }
                }
            } else {
                this.unitWithCoordList = [];
            }
        } else {
            this.unitWithCoordList = [];
        }
    }

    getAllUnitList() {
        const planView = this.template.querySelector('c-plan-view');
        if (planView) {
            const thisFloor = planView.getCurrentFloor();
            if (thisFloor && thisFloor.unitList && thisFloor.unitList.length > 0) {
                this._currentFloorName = thisFloor.floor;
                const floor = this.floorList.filter(each => each.floor === this._currentFloorName)[0];
                if (floor.unitList) {
                    let allUnitList = floor.unitList;
                    if(allUnitList && allUnitList.length > 0) {
                        this.pointerSize = allUnitList[0].pointerSize || defaultPointerSize;
                    }
                    this.allUnitList = allUnitList.map(each => ({...each, pointerSize: this.pointerSize}));
                }
            } else {
                this.allUnitList = [];
            }
        } else {
            this.allUnitList = [];
        }
    }

    handleNewDraftUnit(event) {
        const currentDraftUnit = event.detail;
        if (currentDraftUnit) {
            this.disableSaveUnitButton = !this._currentDraftUnit || !this._selectedUnitKey;
            this._currentDraftUnit = currentDraftUnit;
        }
    }

    handleSaveUnit() {
        if (this._currentDraftUnit && this._selectedUnitKey) {
            this.updateUnitUtil(this._currentDraftUnit.coordX, this._currentDraftUnit.coordY, this._selectedUnitKey);
            this._currentDraftUnit = null;
            this._selectedUnitKey = null;
            this.template.querySelector('c-lookup').selection = [];
            this.disableSaveUnitButton = true;
        }
    }

    updateUnitUtil(coordX, coordY, unitKey) {
        let thisFloor = JSON.parse(JSON.stringify(this.floorList.filter(each => each.floor === this._currentFloorName)[0]));
        if (thisFloor && thisFloor.unitList) {
            thisFloor.unitList.forEach(each => {
                if (each.unitKey === unitKey) {
                    each.coordX = coordX;
                    each.coordY = coordY;
                }
            });
            let newFloorList = JSON.parse(JSON.stringify(this.floorList));
            for (let i = 0; i < newFloorList.length; i++) {
                if (newFloorList[i].floor === thisFloor.floor) {
                    newFloorList[i] = thisFloor;
                    break;
                }
            }
            this.undoStack = [...this.undoStack, this.floorList];
            this.floorList = newFloorList;
        }
        this.getUnitWithCoordList();
        this.getAllUnitList();
    }

    handleUnitSearch(event) {
        const target = event.target;
        const searchTerm = event.detail.searchTerm;
        if (searchTerm) {
            const thisFloor = this.template.querySelector('c-plan-view').getCurrentFloor();
            if (thisFloor && thisFloor.unitList && thisFloor.unitList.length > 0) {
                this._currentFloorName = thisFloor.floor;
                const results = thisFloor.unitList.filter((each) => {
                    return each.unitKey && each.unitKey.toLowerCase().indexOf(searchTerm) >= 0;
                }).filter(each => !each.coordX || !each.coordY).map(each => ({
                    id: each.unitKey,
                    sObjectType: 'Floor__c',
                    icon: 'standard:apps',
                    title: each.unitKey,
                    subtitle: ''
                }));
                event.target.setSearchResults(results);
            }
        }
    }

    handleFloorSearch(event) {
        const target = event.target;
        const searchTerm = event.detail.searchTerm;
        if (searchTerm) {
            const results = this.floorList
                .filter(each => each.floor.toLowerCase().indexOf(searchTerm) >= 0)
                .map(each => ({
                    id: each.floor,
                    sObjectType: 'Floor__c',
                    icon: 'standard:orders',
                    title: each.floor,
                    subtitle: ''
                }))
            event.target.setSearchResults(results);
        }
    }

    handleStartFloorSelectionChange(event) {
        const selection = event.target.getSelection();
        console.log(JSON.stringify(selection));
        if (selection) {
            this._fromFloor = selection[0].id;
        }
    }

    handleEndFloorSelectionChange(event) {
        const selection = event.target.getSelection();
        if (selection) {
            this._toFloor = selection[0].id;
        }
    }

    handleUnitSelectionChange(event) {
        const selection = event.target.getSelection();
        if (selection) {

            this._selectedUnitKey = (selection[0]) ? selection[0].id : "";
            this.disableSaveUnitButton = !this._currentDraftUnit || !this._selectedUnitKey;
        }
    }

    handleFloorChange(event) {
        this.getUnitWithCoordList();
    }

    handleDeleteUnit(event) {
        const unitKey = event.target.dataset.key;
        this.updateUnitUtil(null, null, unitKey);
    }

    handleSaveAll() {
        if (this.allUnitList.length > 0) {
            this.callSaveUnitList(JSON.stringify(this.allUnitList));
        }
    }

    callSaveUnitList(unitList) {
        this.isLoading = true;
        saveUnitList({ unitObjList: unitList }).then(() => {
            this._originalFloorList = this.floorList;
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Save Master Plan Success',
                    variant: 'success'
                })
            );
            this.getUnitWithCoordList();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        })
    }

    handleReset() {
        this.floorList = this._originalFloorList;
        this.getUnitWithCoordList();
    }

    handleUndo() {
        this.floorList = this.undoStack.pop();
        this.getUnitWithCoordList();
    }

    handleClone() {
        const fromFloor = this._fromFloor === '12A' ? 13 : Number(this._fromFloor);
        const toFloor = this._toFloor === '12A' ? 13 : Number(this._toFloor);
        let unitsToBeUpdated = [];
        //console.log('fromFloor : '+ fromFloor + ', toFloor : ' + toFloor);
        //console.log('unitWithCoordList : '+ JSON.stringify(this.unitWithCoordList));
        //console.log('floorList : '+ JSON.stringify(this.floorList));
        if (fromFloor < toFloor) {
            let coordMapByUnitNumber = {};
            this.unitWithCoordList.forEach(each => {
                coordMapByUnitNumber[each.unitNumber] = each;
            });
            this.floorList.forEach(eachFloor => {
                if (eachFloor.unitList && eachFloor.unitList.length > 0) {
                    const floor = eachFloor.floor === '12A' ? 13 : Number(eachFloor.floor);
                    if (fromFloor <= floor && floor <= toFloor) {
                        eachFloor.unitList.forEach(eachUnit => {
                            const coords = coordMapByUnitNumber[eachUnit.unitNumber];
                            if(coords) unitsToBeUpdated.push({ ...eachUnit, coordX: coords.coordX, coordY: coords.coordY });
                        });
                        
                    }
                }
            })
        }
        //console.log('unitsToBeUpdated : '+ unitsToBeUpdated.length);
        if (unitsToBeUpdated.length > 0) {
            this.callSaveUnitList(JSON.stringify(unitsToBeUpdated));
        }
    }

    handleShowHideClone(event) {
        this.showCloneSection = !this.showCloneSection;
    }

    get disabledUndo() {
        return this.undoStack.length === 0;
    }

    get cloneShowHideLabel() {
        return this.showCloneSection ? 'Hide' : 'Show';
    }
}