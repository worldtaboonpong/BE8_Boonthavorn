import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import checkAvaliable from '@salesforce/apex/ContractController.checkAvaliable';
import changePeriodDetail from '@salesforce/apex/ContractController.changePeriodDetail';

export default class ChangeContractPeriod extends LightningElement {

    @api recordId;
    @api objectApiName;
    startDate;
    endDate;
    year;
    month;
    day;
    graceMonth;
    graceDay;
    isLoading = true;
    oldStartDate;

    // @api invoke() {
    //     console.log('Hello from invoke:', this.recordId);
    // }

    // connectedCallback() {
    //     console.log('connectedCallback recordId:', this.recordId); 
    // }

    renderedCallback() {
        //console.log('renderedCallback recordId:', this.recordId);
        if(this.recordId != null) {

        }
    }

    handleOnLoad(event) {
        var record = event.detail.records;
        var fields = record[this.recordId].fields;
        //console.log(JSON.stringify(fields)); 
        this.endDate = fields.Contract_End_Date__c.value;
        this.year = fields.Rental_Year__c.value;
        this.month = fields.Rental_Period_Month__c.value;
        this.day = fields.Rental_day__c.value;
        this.graceMonth = fields.Grace_Month__c.value;
        this.graceDay = fields.Grace_Day__c.value;
        this.oldStartDate = fields.Contract_Start_Date__c.value;

        this.isLoading = false;
    }

    handleChange(event) {
        //console.log(event.detail.value); 
        this.isLoading = true;
        var temp = new Date(event.detail.value);
        this.startDate = new Date(event.detail.value);
        temp.setFullYear(temp.getFullYear() + this.year);
        temp.setMonth(temp.getMonth() + this.month);
        temp.setDate(temp.getDate() + this.day - 1);

        let ye = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(temp);
        let mo = new Intl.DateTimeFormat('en', { month: 'short' }).format(temp);
        let da = new Intl.DateTimeFormat('en', { day: '2-digit' }).format(temp);
        //this.endDate = temp.toDateString().replace(/^\S+\s/,'');
        this.endDate = da+' '+mo+' '+ye;
        console.log(this.endDate); 
        this.isLoading = false;
    }

    handleSubmit(event){
        this.isLoading = true;
        event.preventDefault();       // stop the form from submitting
        var fields = event.detail.fields;
        var endDate = new Date(this.endDate);
        fields.Contract_End_Date__c = endDate.getFullYear()+'-'+(endDate.getMonth()+1)+'-'+endDate.getDate();
        var startText = this.startDate.getFullYear()+'-'+(this.startDate.getMonth()+1)+'-'+this.startDate.getDate()
        var temp = this.startDate;
        temp.setMonth(temp.getMonth() + this.graceMonth);
        temp.setDate(temp.getDate() + this.graceDay);
        fields.Shop_Opening_Date__c = temp.getFullYear()+'-'+(temp.getMonth()+1)+'-'+temp.getDate();
        //Check Avaliable
        checkAvaliable({contractId : this.recordId, startDate : startText, endDate: fields.Contract_End_Date__c})
        .then((result) => {
            console.log(result);
            var res = JSON.parse(result);
            if(res.avaliable) {
                console.log(JSON.stringify(fields));
                this.changeDetail(fields);
            } else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: res.message,
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.isLoading = false;
            }
        });
    }

    changeDetail(fields) {
        var olddate = new Date(this.oldStartDate);
        console.log('Old: '+olddate);
        console.log('New: '+this.startDate);
        var Difference_In_Time = this.startDate.getTime() - olddate.getTime();
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
        console.log('Diff: '+Difference_In_Days);

        changePeriodDetail({contractId : this.recordId, days : Difference_In_Days}) 
        .then((result) => {
            console.log(result);
            if(result) {
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Cannot change period contract detail!',
                        variant: 'error'
                    })
                );
            }
        });
    }

    handleSuccess(event) {
        //const payload = event.detail;
        //console.log(JSON.stringify(payload));

        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Contract Period Updated!',
                variant: 'success'
            })
        );
    }

    handleError(event) {
        console.log(JSON.stringify(event.detail));
        this.isLoading = false;
    }

    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}