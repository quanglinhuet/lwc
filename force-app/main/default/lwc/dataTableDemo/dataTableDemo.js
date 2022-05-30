import { LightningElement, wire, track } from "lwc";

import fetchDataList from "@salesforce/apex/ImportExcelDemo.fetchDataList";
import countRecordOfList from "@salesforce/apex/ImportExcelDemo.countRecordOfList";

import {loadStyle } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";

const getNumberPage = (numberRecord, limitPage) => {
    return numberRecord % limitPage === 0
        ? numberRecord / limitPage
        : ~~(numberRecord / limitPage) + 1;
};

export default class DataTableDemo extends LightningElement {
    lstIdSeleced = [];
    dataList;
    modeEdit = false;
    @track lstdata;
    @track numberSelected = 0;
    @track disableDelete = true;
    @track disableBack = true;
    @track disableNext = true;
    @track totalPageInList = 1;
    @track columns = [
        {
            label: "*供給ソース",
            fieldName: "Field895__c",
            type: "text",
            initialWidth: 150,
            editable: false
        },
        {
            label: "品種",
            fieldName: "Field757__c",
            type: "text",
            initialWidth: 300,
            editable: false
        },
        {
            label: "ブロック",
            fieldName: "Field856__c",
            initialWidth: 150,
            type: "text",
            editable: false
        },
        {
            label: "*価格",
            fieldName: "Field348__c",
            initialWidth: 150,
            type: "text",
            cellAttributes: {
                class: {fieldName: 'errorCalcultion'}
            } 
        }
    ];
    @track record = {};
    @track rowOffset = 0;
    @track data = {};
    @track error;
    @track currentPage = 1;
    @track limitPage = 10;
    /**
     * Get data for list
     * @param {*} result
     */
    @wire(fetchDataList, { offsetNum: 1, limitNum: 10 })
    wiredDataList(result) {
        // this.dataList = result;
        // if (result.data) {
        //     this.error = undefined;
        //     let newDataTable = result.data.map((record) => {
        //         let viewRecord = { Id: record.Id };
        //         if (record.Field895__c) {
        //             viewRecord.Field895__c = record.Field895__c;
        //         }
        //         if (record.Field757__c) {
        //             viewRecord.Field757__c = record.Field757__c;
        //         }
        //         if (record.Field856__c) {
        //             viewRecord.Field856__c = record.Field856__c;
        //         }
        //         if (record.Field348__c) {
        //             viewRecord.Field348__c =
        //                 record.Field348__c;
        //             viewRecord.errorCalcultion = '';
        //         }
        //         return viewRecord;
        //     });
        //     this.lstdata = newDataTable;
            console.log(result);
        // } else if (result.error) {
        //     this.lstdata = [];
        //     this.error = result.error;
        // }
    }

    /**
     * Get Navigation Info
     * @param {*} result
     */
    @wire(countRecordOfList)
    wiredRecordOfList(result) {
        if (result.data) {
            this.error = undefined;
            const totalPage = getNumberPage(result.data, this.limitPage);
            this.totalPageInList = totalPage;
            if (this.currentPage === 1) {
                this.disableBack = true;
            } else {
                this.disableBack = false;
            }
            if (this.currentPage === this.totalPageInList) {
                this.disableNext = true;
            } else {
                this.disableNext = false;
            }
        } else if (result.error) {
            this.counts = 0;
            this.error = result.error;
        }
    }
    /**
     * Get data of list
     */
    getDataList = (limit) => {
        fetchDataList({ offsetNum: this.currentPage, limitNum: limit })
            .then((result) => {
                this.error = undefined;
                let newDataTable = result.map((record) => {
                    let viewRecord = { Id: record.Id };
                    if (record.Field895__c) {
                        viewRecord.Field895__c = record.Field895__c;
                    }
                    if (record.Field757__c) {
                        viewRecord.Field757__c = record.Field757__c;
                    }
                    if (record.Field856__c) {
                        viewRecord.Field856__c = record.Field856__c;
                    }
                    if (record.Field348__c) {
                        viewRecord.Field348__c =
                            record.Field348__c;
                        viewRecord.errorCalcultion = '';
                    }
                    return viewRecord;
                });

                this.lstdata = newDataTable;
            })
            .catch((e) => {
                this.error = e;
            });
    };

    getPageInfo = () => {
        countRecordOfList()
            .then((result) => {
                this.error = undefined;
                const totalPage = getNumberPage(result, this.limitPage);
                this.totalPageInList = totalPage;
                if (this.currentPage === 1) {
                    this.disableBack = true;
                } else {
                    this.disableBack = false;
                }
                if (this.currentPage === this.totalPageInList) {
                    this.disableNext = true;
                } else {
                    this.disableNext = false;
                }
            })
            .catch((e) => {
                this.error = e;
            });
    };



    disableNavigation() {
        const totalPage = this.totalPageInList;
        let test = this.template.querySelectorAll("lightning-button");
        for (let i = 0; i < test.length; i++) {
            if (test[i].name === "previous") {
                if (this.currentPage === 1) test[i].disabled = true;
            } else if (test[i].name === "next") {
                if (this.currentPage === totalPage) test[i].disabled = true;
            }
        }
    }

    /**
     * Handle back or next
     * @param {*} event
     */
    handleNavigation(event) {
        const action = event.target;
        switch (action.name) {
            case "previous":
                if (this.currentPage > 1) {
                    this.currentPage -= 1;
                    this.getDataList(this.limitPage);
                }
                break;
            case "next":
                if (this.currentPage < this.totalPageInList) {
                    this.currentPage += 1;
                    this.getDataList(this.limitPage);
                }
                break;
            default:
                console.log("a", action);
                break;
        }
        this.rowOffset = (this.currentPage - 1) * this.limitPage;
    }

    /**
     * Render call back
     */
    renderedCallback() {
        loadStyle(this, lpqresource + "/style/customDatatableStyle.css").then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors");
            console.log(error);
        })
        if (this.currentPage === 1) {
            this.disableBack = true;
        } else {
            this.disableBack = false;
        }
        if (this.currentPage === this.totalPageInList) {
            this.disableNext = true;
        } else {
            this.disableNext = false;
        }
    }
}
