import { LightningElement, api, wire } from 'lwc';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import calloutAndUpdateContact from '@salesforce/apex/UpdateContactToSAPController.calloutAndUpdateContact';

const FIELDS = [
    'Contact.Name'
];

export default class UpdateContactToSAP extends LightningElement {
    @api recordId;
    @api objectApiName;
    contactId;
    firstName;
    lastName;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    contact;

    isLoading = false;
    handleOnLoad(event) {
        var record = event.detail.records;
        var fields = record[this.recordId].fields;
        //console.log('fields : ', JSON.stringify(fields));
        this.contactId = fields.Contact_ID__c.value;
        this.firstName = fields.FirstName.value;
        this.lastName = fields.LastName.value;
    }

    contactChangeVal(event) {
        console.log(event.target.label);
        console.log(event.target.value);
        if(event.target.label == 'Firstname') {
            this.firstName = event.target.value;
        } else if(event.target.label == 'Lastname') {
            this.lastName = event.target.value;
        }
    }

    handleSubmit(event) {
        console.log('on handleSubmit');
        this.isLoading = true;
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        const detail = event.detail;
        console.log('detail : ', JSON.stringify(detail));
        console.log('fields : ', JSON.stringify(fields));
        fields.Contact_ID__c = this.contactId;
        fields.FirstName = this.firstName;
        fields.LastName = this.lastName;
        calloutAndUpdateContact({contact : fields, contactId : this.recordId})
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