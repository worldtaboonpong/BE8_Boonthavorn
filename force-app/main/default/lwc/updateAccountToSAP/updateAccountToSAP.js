import { LightningElement, api, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getcid from '@salesforce/apex/UpdateAccountToSAPController.getcid';
import calloutAndUpdateAccount from '@salesforce/apex/UpdateAccountToSAPController.calloutAndUpdateAccount';

const FIELDS = [
    'Account.Name'
];

export default class UpdateAccountToSAP extends LightningElement {
    @api recordId;
    @api objectApiName;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account;

    isLoading = false;
    
    handleSubmit(event) {
        console.log('on handleSubmit');
        this.isLoading = true;
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        const detail = event.detail;
        console.log('detail : ', JSON.stringify(detail));
        console.log('fields : ', JSON.stringify(fields));
        getcid({accId : this.recordId})
        .then((res) => {
            console.log(res);
            if(res.isSuccess) {
                calloutAndUpdateAccount({acc : fields, accId : this.recordId, cid : res.cid})
                .then((result) => {
                    console.log(result);
                    this.showToast(result.status,result.remark);
                    if(result.status.toLowerCase() === 'success'){
                        console.log('success');
                        getRecordNotifyChange([{recordId: this.recordId}]);
                        this.handleClose();
                    } 
                    this.isLoading = false;
                });
            } else {
                this.showToast('error',res.message);
                this.isLoading = false;
            }
        });
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());  
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