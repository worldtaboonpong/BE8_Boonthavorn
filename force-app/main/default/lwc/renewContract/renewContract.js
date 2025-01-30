import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from 'lightning/navigation';
import renew from '@salesforce/apex/renewContractController.renew';
import modal from "@salesforce/resourceUrl/smallmodalcss";
import { loadStyle } from "lightning/platformResourceLoader";

export default class RenewContract extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading = false;

    connectedCallback() {
        console.log('connected===============');
        console.log(this.recordId + ' is null');
        loadStyle(this, modal);
    }

    handleRenew() {
        this.isLoading = true;
        console.log('===============Renew===============');
        renew({contractId: this.recordId}).then(result => {
            console.log(result);
            this.showToast(result.status,result.message);
            if(result.status.toLowerCase() === 'success'){

                this.navigateToRecordPage(result.oppId, 'Opportunity');
            } 
            this.isLoading = false;
        }).catch(error => {
            console.log(error);
            this.showToast('Unknown Error', JSON.stringify(error));
            this.isLoading = false;
        });
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());  
    }

    navigateToRecordPage(recId, objName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objName,
                actionName: 'view'
            }
        });
    }

    showToast(status,message) {
        const event = new ShowToastEvent({
            title: status,
            message: message,
            variant: status
        });
        this.dispatchEvent(event);
    }

}