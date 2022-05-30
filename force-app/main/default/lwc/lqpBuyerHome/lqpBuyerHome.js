import { LightningElement, wire, track, api } from "lwc";
import { deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";

import fetchDataList from "@salesforce/apex/ImportExcelDemo.fetchDataList";
import countRecordOfList from "@salesforce/apex/ImportExcelDemo.countRecordOfList";
import deleteRecordInList from "@salesforce/apex/LpqBuyerHelpers.deleteRecordInList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadStyle } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";

const TYPE_MESS = {
    Error: "error",
    Success: "success"
};

const getNumberPage = (numberRecord, limitPage) => {
    return numberRecord % limitPage == 0
        ? numberRecord / limitPage
        : ~~(numberRecord / limitPage) + 1;
};

const getToastMessage = (type, mess) => {
    const eventMessSuccess = new ShowToastEvent({
        title: type === TYPE_MESS.Success ? "Success" : "Error",
        message: mess,
        variant: type.toString()
    });
    return eventMessSuccess;
};

const jsonParse = (str, defaultVal = null) => {
    try {
        return JSON.parse(str);
    } catch {
        return defaultVal;
    }
};

let XLS = {};
let writeExcel = {};

export default class DataTableComponent extends LightningElement {
    lstIdSeleced = [];
    dataList;
    modeEdit = false;
    draftValues = [];
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
        },
        {
            label: "View",
            type: "button-icon",
            typeAttributes: {
                name: "preview_detail",
                iconName: "action:preview",
                title: "Preview",
                variant: "border-filled",
                alternativeText: "View"
            }
        },
        {
            label: "Delete",
            type: "button-icon",
            fieldName: "id",
            typeAttributes: {
                iconName: "utility:delete",
                title: "Delete",
                variant: "border-filled",
                alternativeText: "Delete",
                name: "delete_record"
            }
        }
    ];
    @track record = {};
    @track rowOffset = 0;
    @track data = {};
    @track bShowModal = false;
    @track error;
    @track currentPage = 1;
    @track limitPage = 10;
    @track dataTable;
    @track modeList = true;
    @track allFiled;
    @track getDataForTableSetting;
    @track infoData = { first_name__c: "a" };
    // Select box
    @track isoCountryCodeDisplayed = "";
    @track countrySearchString = "";

    // XLSX properties
    @track importModalIsShow = false;

    get importEnable() {
        return this.fileXlsxReady && !this.isInImportProcess;
    }

    /**
     * Get data for list
     * @param {*} result
     */
    @wire(fetchDataList, { offsetNum: 1, limitNum: 10 })
    wiredDataList(result) {
        this.dataList = result;
        if (result.data) {
            this.error = undefined;
            let newDataTable = result.data.map((record) => {
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
            this.dataTable = newDataTable;
        } else if (result.error) {
            this.dataTable = [];
            this.error = result.error;
        }
    }

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

    /**
     * Delete a record.
     * @param {*} idRecord id of record
     */
    deleteRecord = (idRecord) => {
        deleteRecord(idRecord)
            .then(() => {
                this.dispatchEvent(
                    getToastMessage(TYPE_MESS.Success, "Record deleted")
                );
                refreshApex(this.dataList);
            })
            .catch((error) => {
                this.dispatchEvent(
                    getToastMessage(TYPE_MESS.Error, error.body.message)
                );
            });
    };

    /**
     * Close modal preview
     */
    closeModal() {
        this.bShowModal = false;
    }

    deleteSelected() {
        if (this.numberSelected > 0) {
            deleteRecordInList({ lstRecordId: this.lstIdSeleced })
                .then(() => {
                    this.dispatchEvent(
                        getToastMessage(
                            TYPE_MESS.Success,
                            `${this.numberSelected} records deleted`
                        )
                    );
                    refreshApex(this.dataList);
                })
                .catch((error) => {
                    this.dispatchEvent(getToastMessage(TYPE_MESS.Error, error));
                });
        }
    }

    refreshTableList = (event) => {
        if (event.detail.isRefresh) refreshApex(this.dataList);
    };

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

    // Import xlsx
    openImportModal() {
        this.importModalIsShow = true;
    }

    handleReloadTable(event) {
        this.importModalIsShow = event.detail.importModalIsShow;
        let newData = event.detail.listData;
        this.dataTable = [...this.dataTable, ...newData];
    }
}
