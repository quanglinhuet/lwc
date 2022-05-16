import { api, LightningElement, track, wire } from 'lwc';
import getAllCountry from '@salesforce/apex/LqpCountryHelpers.getAllCountry';
import getAllISOCountry from '@salesforce/apex/LqpCountryHelpers.getAllISOCountry';

export default class LpqFillter extends LightningElement {
    // @api options;
    @api id;
    @wire(getAllCountry) 
    wiredAllCountry({error, data}) {
        if (data) {
            this.listFillter.find(item => item.name === 'CountryCode').options = data;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getAllISOCountry)
    wiredAllISOCountry({error, data}) {
        if (data) {
            this.listFillter.find(item => item.name === 'ISOCountryCode').options = data;
        } else if (error) {
            console.log(error);
        }
    }

    @track listFillter = [
        {
            name: 'BuyerCode',
            label: 'Buyer Code',
            sqlParam: 'Name',
            value: null,
            inUse: false,
            isCombobox: false
        },
        {
            name: 'BuyerAddress',
            label: 'Buyer Address',
            sqlParam: 'BuyerAddress__c',
            value: null,
            inUse: false,
            isCombobox: false
        },
        {
            name: 'CountryCode',
            label: 'Country Code',
            sqlParam: 'CountryCode__r.Name',
            value: null,
            inUse: false,
            isCombobox: true,
            options: []
        },
        {
            name: 'ISOCountryCode',
            label: 'ISO Country Code',
            sqlParam: 'ISOCountryCode_Alphabet3__r.Name',
            value: null,
            inUse: false,
            isCombobox: true,
            options: []
        },
    ];
    @track showFillterInput = false;
    @track currentFillterInput = null;

    handleSelectFillter (e) {
        let targetName = e.currentTarget.value;
        this.currentFillterInput = this.listFillter.find(fillter => {
            return fillter.name === targetName;
        })
        this.showFillterInput = this.currentFillterInput ? true: false;
    }
}