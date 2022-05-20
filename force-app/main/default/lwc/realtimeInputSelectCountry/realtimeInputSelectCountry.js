import searhForCountry from '@salesforce/apex/LqpCountryHelpers.searhForCountry';
import { LightningElement, track } from 'lwc';

export default class RealtimeInputSelectCountry extends LightningElement {
    @track searchResult = [];
    @track isSearching = true;
    @track countrysResult = [];
    @track initialized = false;

    connectedCallback() {
        if (!this.initialized) {
            searhForCountry({pattern: ''}).then(rs =>{
                this.countrysResult = rs;
                this.searchResult = rs.map(item => {
                    return {
                        value: item.Id,
                        label: item.Name
                    }
                });
                this.isSearching = false;
            }).catch(err => {
                this.isSearching = false;
                console.log(err);
            })
            this.initialized = true;
        } 
    }

    handleInputChange(e) {
        this.isSearching = true;
        searhForCountry({pattern:  e.target.value}).then(rs =>{
            this.countrysResult = rs;
            let newRs = rs.map(item => {
                return {
                    value: item.Id,
                    label: item.Name
                }
            });
            this.isSearching = false;
            this.searchResult = newRs;
        }).catch(err => {
            this.isSearching = false;
            console.log(err);
        })
    }

    handleSelectCountry(e) {
        let selectedCountry = ''
        this.countrysResult.find(item => {
            if (item.Id === e.target.value) {
                selectedCountry = item.Country__c;
                return true;
            }
            return false;
        })
        if (selectedCountry) {
            console.log(`Selected ${selectedCountry}`);
        }
    }
}