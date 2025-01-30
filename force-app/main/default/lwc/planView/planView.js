import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import easeljs from '@salesforce/resourceUrl/easeljs';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getStatusColorMapping from '@salesforce/apex/masterPlanController.getStatusColorMapping';


export default class PlanView extends LightningElement {
    @api mode = 'view';
    @api pointerSize = 30;
    @track _floorList = [];
    @track _floorMap = {};
    @track _unitMap = {};
    @track _stage = null;
    @track showPlanViewEmptyState = false;
    @track easeljsLoaded = false;
    @track floorListLoaded = false;
    @track selectedFloorNumber = null;
    @track currentUnitModal = null;
    _currentDraftUnit = null;
    emptyStateLabel = 'Floor plan image has not been set up for this floor.';

    // @wire(getStatusColorMapping)
    // getstatusColorMapping({data, error}) {
    //     console.log(data, error);
    // }
    @wire(getStatusColorMapping)
    statusColorMapping;

    @api
    get floorList() {
        return this._floorList;
    }

    set floorList(input) {
        this.setAttribute('floorList', input);
        this._floorList = input;
        this._floorList.forEach(each => {
            this._floorMap[each.floor] = each;
        })
        this.floorListLoaded = input && input.length > 0;
        this.initLoad();
    }

    initLoad() {
        if (!this.easeljsLoaded) {
            const v = this;
            Promise.all([
                loadScript(this, easeljs)
            ])
                .then(() => {
                    v.easeljsLoaded = true;
                    v.drawPlanView();
                })
                .catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error loading easeljs',
                            message: error.message,
                            variant: 'error'
                        })
                    );
                });
        } else {
            this.drawPlanView();
        }
    }

    @api
    drawPlanView() {
        debugger;
        if (this._floorList.length > 0 && this.selectedFloorNumber && this._floorMap[this.selectedFloorNumber]) {
            const thisFloor = this._floorMap[this.selectedFloorNumber];
            const v = this;
            let canvas = this.template.querySelector('canvas');
            var stage = this._stage ? this._stage : new createjs.Stage(canvas);
            this._stage = stage;
            if (this.mode === 'edit') {
                stage.on('stagemousedown', function (event) {
                    if(v._currentDraftUnit && v._currentDraftUnit.unitShape){
                        stage.removeChild(v._currentDraftUnit.unitShape);
                    } 
                    var circle = new createjs.Shape();
                    circle.graphics.beginFill('black').drawCircle(0, 0, v.pointerSize);
                    circle.x = event.stageX;
                    circle.y = event.stageY;
                    stage.addChild(circle);
                    stage.update();
                    v._currentDraftUnit = { coordX: event.stageX, coordY: event.stageY, unitShape: circle };
                    v.dispatchEvent(new CustomEvent('newdraftunit', { detail: v._currentDraftUnit }));
                })
            }


            createjs.Touch.enable(stage, true, false);
            if (!thisFloor.floorPlanImageLink) {
                this.showPlanViewEmptyState = true;
                return;
            }
            this.showPlanViewEmptyState = false;
            debugger;
            var bmp = new createjs.Bitmap(thisFloor.floorPlanImageLink);
            
            stage =  new createjs.Stage(canvas);
            this._stage = stage;

            stage.addChild(bmp);
            bmp.image.onload = function () {


                canvas.width = this.width;
                canvas.height = this.height;

                thisFloor.unitList.forEach(eachUnit => {
                    v._unitMap[eachUnit.unitKey] = eachUnit;
                    if (eachUnit.coordX && eachUnit.coordY) {
                        var circle = new createjs.Shape();
                        const color = v.statusColorMapping.data[eachUnit.status] || '#4bca81';
                        circle.graphics.beginFill(color).drawCircle(0, 0, eachUnit.pointerSize || v.pointerSize);
                        circle.x = eachUnit.coordX;
                        circle.y = eachUnit.coordY;
                        circle.name = eachUnit.unitKey;
                        circle.addEventListener("click", function (event) {
                            v.currentUnitModal = v._unitMap[event.target.name];
                            v.template.querySelector('c-unit-modal').unit = v._unitMap[event.target.name];
                            v.template.querySelector('c-unit-modal').openModal();
                        }.bind(this));
                        stage.addChild(circle);
                    }
                });

                stage.update();
            }
        } else {
            if (this._stage) {
                this._stage.removeAllChildren();
                this._stage.update();
            }
            this.showPlanViewEmptyState = false;
        }
    }

    handleSearch(event) {
        const results = this.floorList
            .filter((eachFloor) => {
                return eachFloor.floor && eachFloor.floor.toLowerCase().indexOf(event.detail.searchTerm) >= 0
            })
            .map(eachFloor => ({
                id: eachFloor.floor,
                sObjectType: 'Floor__c',
                icon: 'standard:orders',
                title: eachFloor.floor,
                subtitle: ''
            }));
        event.target.setSearchResults(results);
    }

    handleSelectionChange(event) {
        debugger;
        this.selectedFloorNumber = event.detail ? event.detail[0] : null;
        this.drawPlanView();
        this.dispatchEvent(new CustomEvent('floorchange'));
    }

    @api getCurrentFloor() {
        return this._floorMap[this.selectedFloorNumber];
    }

    @api getCurrentDrafUnit() {
        return this._currentDraftUnit;
    }

    @api clearCurrentDrafUnit() {
        this._currentDraftUnit = null;
    }
}