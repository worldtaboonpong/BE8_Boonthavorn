import { LightningElement, track, api } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRentalObjectDetail from '@salesforce/apex/masterPlanController.getRentalObjectDetailByRentalObjId';
import getOpportunityByRentalObjId from '@salesforce/apex/masterPlanController.getOpportunityByRentalObjId';
import getContactByRentalObjId from '@salesforce/apex/masterPlanController.getContactByRentalObjId';
export default class UnitModal extends LightningElement {
    @track isModalOpen = false;
    @api unit = {};
    @track targetRentalObject = {};
    @track targetOppLineItemList = {};
    @track targetContractLineItemList = {};
    @track retalObjectHeaderFieldList = [];
    @track retalObjectDetailFieldList = [];
    // @track columnAPIName = [
    //     'tms_RentalObjectCode__c',
    //     'tms_IsAvailableForSales__c',
    //     'Name',
    //     'tms_RentalObjectType__c',
    //     'tms_TotalArea__c',
    //     'tms_UsageType__c',
    //     'tms_LeasableArea__c',
    //     'tms_LocationOnFloor__c',
    //     'tms_ValidFrom__c',
    //     'tms_CurrentContract__c',
    //     'tms_ValidTo__c',
    //     'tms_CurrentContractAccountName__c',
    //     'IsRetailZone__c',
    //     'CurrentContractStartDate__c',
    //     'IsSPWGSublease__c',
    //     'CurrentContractEndDate__c',
    // ];
    @track columnOpportunityList = [
        { label: 'Opportunity Name', fieldName: 'OPP_FIELD_NAME', type: 'text', sortable: true},
        { label: 'Record Type', fieldName: 'RECORDTYPE_FIELD_NAME', type: 'text', sortable: true},
        { label: 'Stage', fieldName: 'OPP_FIELD_STAGE', type: 'text', sortable: true},
        { label: 'Account Name', fieldName: 'ACCOUNT_FIELD_URL', type: 'url', sortable: true,
            typeAttributes: { label: { fieldName: 'ACCOUNT_FIELD_NAME' }, value: { fieldName: 'ACCOUNT_FIELD_URL'}, target: '_blank'}
        },
        { label: 'Shop Name', fieldName: 'BRAND_FIELD_SHOPURL', type: 'url', sortable: false,
            typeAttributes: { label: { fieldName: 'BRAND_FIELD_SHOPNAME' }, value: { fieldName: 'BRAND_FIELD_SHOPURL'}, target: '_blank'}
        },
        { label: 'Contract Start Date', fieldName: 'OPP_FIELD_STARTDATE', type: 'date', sortable: true},
        { label: 'Contract End Date', fieldName: 'OPP_FIELD_ENDDATE', type: 'date', sortable: true}
    ];
    @track columnContractList = [
        { label: 'Contract Name', fieldName: 'CONTRACT_FIELD_NAME', type: 'text', sortable: true},
        { label: 'Contract Stage', fieldName: 'CONTRACT_FIELD_STAGE', type: 'text', sortable: true},
        { label: 'Tetant Name', fieldName: 'ACCOUNT_FIELD_URL', type: 'url', sortable: true,
            typeAttributes: { label: { fieldName: 'ACCOUNT_FIELD_NAME' }, value: { fieldName: 'ACCOUNT_FIELD_URL'}, target: '_blank'}
        },
        { label: 'Shop Name', fieldName: 'BRAND_FIELD_SHOPURL', type: 'url', sortable: false,
            typeAttributes: { label: { fieldName: 'BRAND_FIELD_SHOPNAME' }, value: { fieldName: 'BRAND_FIELD_SHOPURL'}, target: '_blank'}
        },
        { label: 'Contract Start Date', fieldName: 'CONTRACT_FIELD_STARTDATE', type: 'date', sortable: true},
        { label: 'Contract End Date', fieldName: 'CONTRACT_FIELD_ENDDATE', type: 'date', sortable: true}
    ];

    @api
    openModal() {
        this.isModalOpen = true;
        console.log('openModal');
        console.log('this.unit.id: ', this.unit.id);
        this.fetchRentalDetail(this.unit.id);
    }

    closeModal() {
        this.isModalOpen = false;
    }

    fetchRentalDetail(rentalObjectId) {
        console.log('fetchRentalDetail', rentalObjectId);
        getRentalObjectDetail({rentalObjectId : rentalObjectId})
            .then((result) => {
                console.log('result', result);
                this.targetRentalObject = result;
                this.assignRentalObjectHeaderValues(result);
                this.assignAllRentalObjectValues(result);
                this.fetchOppLineItem(rentalObjectId);
                this.fetchContractLineItem(rentalObjectId);  
                console.log('columnOpportunityList', this.columnOpportunityList);
                console.log('targetOppLineItemList', this.targetOppLineItemList);
            }).catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({ title: 'Error', message: error.message, variant: 'error'})
                );
            });
    }

    fetchOppLineItem(rentalObjectId) {
        console.log('fetchOppLineItem', rentalObjectId);
        getOpportunityByRentalObjId({rentalObjectId : rentalObjectId})
            .then((result) => {
                console.log('result', result);
                var resultOppLineList = [];
                result.forEach(eachOppLineItem => {
                    resultOppLineList.push(
                        {   'OPP_FIELD_NAME' : eachOppLineItem.Opportunity__r.Name,
                            'RECORDTYPE_FIELD_NAME' : eachOppLineItem.Opportunity__r.RecordType.Name,
                            'OPP_FIELD_STAGE' : eachOppLineItem.Opportunity__r.StageName,
                            'ACCOUNT_FIELD_NAME' : ((eachOppLineItem.Opportunity__r.AccountId)? eachOppLineItem.Opportunity__r.Account.Name:""),
                            'ACCOUNT_FIELD_URL' : ((eachOppLineItem.Opportunity__r.AccountId)? "/"+eachOppLineItem.Opportunity__r.AccountId:""),
                            'OPP_FIELD_STARTDATE' : eachOppLineItem.Opportunity__r.Estimated_Contract_Start_Date__c,
                            'OPP_FIELD_ENDDATE' : eachOppLineItem.Opportunity__r.Estimated_Contract_End_Date__c,
                            'BRAND_FIELD_SHOPNAME' : ((eachOppLineItem.Opportunity__r.Shop_Name__c)? eachOppLineItem.Opportunity__r.Shop_Name__c:""),
                            'BRAND_FIELD_SHOPURL' : ((eachOppLineItem.Opportunity__r.Shop_Name__c)? "/"+eachOppLineItem.Opportunity__r.Shop_Name__c:"")
                        });
                });
                this.targetOppLineItemList = resultOppLineList;
            }).catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({ title: 'Error', message: error.message, variant: 'error'})
                );
            });
    }

    fetchContractLineItem(rentalObjectId) {
        console.log('fetchContractLineItem', rentalObjectId);
        getContactByRentalObjId({rentalObjectId : rentalObjectId})
            .then((result) => {
                console.log('result', result);
                var resultContractLineList = [];
                result.forEach(eachContractLineItem => {
                    resultContractLineList.push(
                        {   'CONTRACT_FIELD_NAME' : eachContractLineItem.Contract__r.Name,
                            'CONTRACT_FIELD_STAGE' : eachContractLineItem.Contract__r.Status__c,
                            'ACCOUNT_FIELD_NAME' : ((eachContractLineItem.Contract__r.Account_Name__c)? eachContractLineItem.Contract__r.Account_Name__r.Name:""),
                            'ACCOUNT_FIELD_URL' :  ((eachContractLineItem.Contract__r.Account_Name__c)? "/"+eachContractLineItem.Contract__r.Account_Name__c:""),
                            'BRAND_FIELD_SHOPNAME' : ((eachContractLineItem.Contract__r.ShopName__c)? eachContractLineItem.Contract__r.ShopName__c:""),
                            'BRAND_FIELD_SHOPURL' : ((eachContractLineItem.Contract__r.ShopName__c)? "/"+eachContractLineItem.Contract__r.ShopName__c:""),
                            'CONTRACT_FIELD_STARTDATE' : eachContractLineItem.Contract__r.ContractStartDate__c,
                            'CONTRACT_FIELD_ENDDATE' : eachContractLineItem.Contract__r.ContractEndDate__c
                        });
                });
                this.targetContractLineItemList = resultContractLineList;
            }).catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({ title: 'Error', message: error.message, variant: 'error'})
                );
            });
    }

    assignRentalObjectHeaderValues(RentalObj) {
        this.retalObjectHeaderFieldList = [];
        this.retalObjectHeaderFieldList.push(
            {   'labelLeft': 'Building',
                'isBooleanLeft': false,
                'apiLeft': 'Building__c',
                'valueLeft': ((RentalObj.Building__c)? RentalObj.Building__r.Name:""),
                'labelRight': 'Floor',
                'isBooleanRight': false,
                'apiRight': 'Floor__c',
                'valueRight': ((RentalObj.Floor__c)? RentalObj.Floor__r.Name:"")}
        );
    }

    assignAllRentalObjectValues(RentalObj) {
        this.retalObjectDetailFieldList = [];
        this.assignRentalObjectValuesRow_1(RentalObj);
        this.assignRentalObjectValuesRow_2(RentalObj);
        this.assignRentalObjectValuesRow_3(RentalObj);
        this.assignRentalObjectValuesRow_4(RentalObj);
        this.assignRentalObjectValuesRow_5(RentalObj);
        this.assignRentalObjectValuesRow_6(RentalObj);
        this.assignRentalObjectValuesRow_7(RentalObj);
        this.assignRentalObjectValuesRow_8(RentalObj);
        this.assignRentalObjectValuesRow_9(RentalObj);
    }

    assignRentalObjectValuesRow_1(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelLeft': 'Rental Object Code',
                'isBooleanLeft': false,
                'apiLeft': 'RentalObjectCode__c',
                'valueLeft': RentalObj.Units_Code__c,
                'labelRight': 'Type',
                'isBooleanRight': false,
                'apiRight': 'Type__c',
                'valueRight': RentalObj.Type__c}
        );
    }
    assignRentalObjectValuesRow_2(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelLeft': 'Room No.',
                'isBooleanLeft': false,
                'apiLeft': 'Name',
                'valueLeft': RentalObj.Name,
                'labelRight': 'Rental Object Type',
                'isBooleanRight': false,
                'apiRight': 'UnitType__c',
                'valueRight': RentalObj.UnitType__c}
        );
    }
    assignRentalObjectValuesRow_3(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelLeft': 'Total Area (sq.m.)',
                'isBooleanLeft': false,
                'apiLeft': 'TotalArea__c',
                'valueLeft': RentalObj.TotalArea__c,
                'labelRight': 'Usage Type',
                'isBooleanRight': false,
                'apiRight': 'Usage_Type__c',
                'valueRight': RentalObj.Usage_Type__c}
        );
    }
    assignRentalObjectValuesRow_4(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelLeft': 'Leasable Area (sq.m.)',
                'isBooleanLeft': false,
                'apiLeft': 'LeasableArea__c',
                'valueLeft': RentalObj.LeasableArea__c,
                'labelRight': 'Special Zone',
                'isBooleanRight': false,
                'apiRight': 'LocationOnFloor__c',
                'valueRight': ((RentalObj.LocationOnFloor__c)? RentalObj.LocationOnFloor__r.Name:"")}
        );
    }
    assignRentalObjectValuesRow_5(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelLeft': 'Valid From',
                'isBooleanLeft': false,
                'apiLeft': 'ValidFrom__c',
                'valueLeft': RentalObj.ValidFrom__c,
                'labelRight': 'Current Contract',
                'isBooleanRight': false,
                'apiRight': 'CurrentContract__c',
                'valueRight': ((RentalObj.CurrentContract__c)? RentalObj.CurrentContract__r.Name:"")}
        );
    }
    assignRentalObjectValuesRow_6(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelLeft': 'Valid To',
                'isBooleanLeft': false,
                'apiLeft': 'ValidTo__c',
                'valueLeft': RentalObj.ValidTo__c,
                'labelRight': 'Current Contract Account Name',
                'isBooleanRight': false,
                'apiRight': 'CurrentContractAccountName__c',
                'valueRight': RentalObj.CurrentContractAccountName__c}
        );
    }
    assignRentalObjectValuesRow_7(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelLeft': 'Retail Zone',
                'isBooleanLeft': true,
                'apiLeft': 'IsRetailZone__c',
                'valueLeft': RentalObj.IsRetailZone__c,
                'labelRight': 'Current Contract Brand Name',
                'isBooleanRight': false,
                'apiRight': 'CurrentContractShopName__c',
                'valueRight': RentalObj.CurrentContractShopName__c}
        );
    }
    assignRentalObjectValuesRow_8(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   /*'labelLeft': 'Is SPWG Sublease',
                'isBooleanLeft': true,
                'apiLeft': 'IsSPWGSublease__c',
                'valueLeft': RentalObj.IsSPWGSublease__c,*/
                'labelLeft': 'Available for Sales',
                'isBooleanLeft': true,
                'apiLeft': 'Available_for_Sales__c',
                'valueLeft': RentalObj.Available_for_Sales__c,
                'labelRight': 'Current Contract Start Date',
                'isBooleanRight': false,
                'apiRight': 'CurrentContractStartDate__c',
                'valueRight': ((RentalObj.CurrentContractStartDate__c)? RentalObj.CurrentContractStartDate__c:"")}
        );
    }
    assignRentalObjectValuesRow_9(RentalObj) {
        this.retalObjectDetailFieldList.push(
            {   'labelRight': 'Current Contract End Date',
                'isBooleanRight': false,
                'apiRight': 'CurrentContractEndDate__c',
                'valueRight': ((RentalObj.CurrentContractEndDate__c)? RentalObj.CurrentContractEndDate__c:"")}
        );
    }
}