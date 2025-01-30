import { LightningElement, api } from 'lwc';
import searchProject from '@salesforce/apex/masterPlanController.searchProject';

export default class ProjectSelector extends LightningElement {
    @api handler;

    handleSearch(event) {
        const target = event.target;
        if (event.detail) {
            searchProject(event.detail)
                .then(results => {
                    target.setSearchResults(results);
                })
                .catch(error => {
                    // TODO: handle error
                });
        }
    }

    @api
    getSelection() {
        return this.template.querySelector('c-lookup').getSelection();
    }
}