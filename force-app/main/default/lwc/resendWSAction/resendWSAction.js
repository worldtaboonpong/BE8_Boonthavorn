import { LightningElement, api } from 'lwc';
import resend from '@salesforce/apex/ResendWSActionController.resend';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ResendWSAction extends LightningElement {
    @api recordId;

    isExecuting = false;    
    @api async invoke() {
        if (this.isExecuting) {
            return;
        }  
        console.log('Execution Start');
        this.isExecuting = true;
        
        //TO DO
        resend({ logID: this.recordId}).then(status => {
            console.log(status);
            if(status == 'Success') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message : 'Resend Services Completed',
                        variant: 'success',
                    }),
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'API Error',
                        message : status,
                        variant: 'error',
                    }),
                );
            }
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Unknown Error',
                    message : JSON.stringify(error),
                    variant: 'error',
                }),
            );
        });

        this.isExecuting = false;
        console.log('Execution Stop');
    }  sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
}