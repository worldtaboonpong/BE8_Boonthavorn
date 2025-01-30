import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import updateClosedWon from '@salesforce/apex/ClosedWonOppController.updateClosedWonOpp';
import syncAccount from '@salesforce/apex/ClosedWonOppController.syncAccount';
import syncContact from '@salesforce/apex/ClosedWonOppController.syncContact';

export default class ClosedWonOpportunity extends LightningElement {
    @api recordId;
    accId;
    message;
    isLoading = false;

    connectedCallback() {
        console.log('connected===============');
        console.log(this.recordId + ' is null');
    }

    renderedCallback() {
        this.isLoading = true;
        //TO DO
        console.log('this.recordId : ', this.recordId);
        if(this.recordId && !this.message) {
            syncAccount({oppId: this.recordId}).then(result => {
                console.log('================syncAccount==============');
                console.log(result);
                if(result.status == 'Success') {
                    this.accId = result.remark;
                    this.syncContact();
                    this.closeWON();
                } else {
                    this.showToast('Error', result.remark);
                    this.isLoading = false;
                }
            }).catch(error => {
                console.log(error);
                this.showToast('Unknown Error', JSON.stringify(error));
                this.handleClose();
            });
            this.message = 'Pass';
        }
        console.log('Execution Stop');
    } 

    syncContact() {
        syncContact({accId: this.accId}).then(result => {
            console.log('================syncContact==============');
            console.log(result);
        }).catch(error => {
            console.log(error);
        });
    }

    closeWON() {
        updateClosedWon({ oppId: this.recordId}).then(result => {
            console.log(result);
            if(result.status == 'Success') {
                this.showToast('Success', 'Update completed');
            } else {
                this.showToast('Error', result.remark);
            }
            this.handleClose();
            this.isLoading = false;
        }).catch(error => {
            console.log(error);
            this.showToast('Unknown Error', JSON.stringify(error));
            this.handleClose();
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