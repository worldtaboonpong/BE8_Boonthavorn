import { LightningElement, api, track } from 'lwc';
import getFloorList from '@salesforce/apex/masterPlanController.getFloorList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MasterPlanComponent extends LightningElement {
    projectList = [
        { id: '1', name: 'Project 1' },
        { id: '2', name: 'Project 2' }
    ];
    @track floorList = [];
    _currentProjectId = null;
    @api refreshInterval = 3000;

    get projectListValues() {
        return this.projectList.map(each => ({ value: each.id, label: each.name }));
    }

    connectedCallback() {
        // setInterval(function () {
        //     console.log('interval');
            if (this._currentProjectId) this.fetchFloorList(this._currentProjectId);
        // }.bind(this), this.refreshInterval);
    }

    handleSelectionChange(event) {
        const selection = this.template.querySelector('c-project-selector').getSelection();
        if (selection && selection.length > 0) {
            this._currentProjectId = selection[0].id;
            this.fetchFloorList(this._currentProjectId);
        } else {
            this._currentProjectId = null;
            this.floorList = [];
            //this.template.querySelector('c-table-view').setFloorList([]);
        }
    }

    fetchFloorList(projectId) {
        const tableViewComponent = this.template.querySelector('c-table-view');
        getFloorList({ buildingId: projectId }).then(floorList => {
            // tableViewComponent.setFloorList(floorList);
            this.floorList = floorList;
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error'
                })
            );
        });
    }
}