import { LightningElement, wire, track, api } from "lwc";
import { deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";

import fetchDataList from "@salesforce/apex/LpqBuyerHelpers.fetchDataList";
import countRecordOfList from "@salesforce/apex/LpqBuyerHelpers.countRecordOfList";
import deleteRecordInList from "@salesforce/apex/LpqBuyerHelpers.deleteRecordInList";
import editRecordsInList from "@salesforce/apex/LpqBuyerHelpers.editRecordsInList";
import getISOCountryByCountryCode from "@salesforce/apex/LqpCountryHelpers.getISOCountryByCountryCode";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";
import getAllCountry from "@salesforce/apex/LqpCountryHelpers.getAllCountry";
import importFromExcel from "@salesforce/apex/LpqBuyerHelpers.importFromExcel";

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
    console.log("aa: ", type, mess);
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

const defaultHeader = (isEdit) => {
    return [
        {
            label: "Buyer Code",
            fieldName: "BuyerCode",
            type: "text",
            initialWidth: 150,
            editable: isEdit
        },
        {
            label: "Buyer Address",
            fieldName: "BuyerAddress",
            type: "text",
            initialWidth: 300,
            editable: isEdit
        },
        {
            label: "Country Code",
            fieldName: "CountryCode",
            initialWidth: 150,
            type: "text",
            editable: isEdit
        },
        {
            label: "ISO Country Code",
            fieldName: "ISOCountryCode",
            initialWidth: 150,
            type: "text"
        }
    ];
};

const initHeader = (isEdit, data, addViewAndDel = true) => {
    let headerColumn = [];

    let defValue;
    if (
        data === undefined ||
        data === null ||
        (Array.isArray(data) && data.length === 0)
    ) {
        defValue = defaultHeader();
    } else {
        defValue = data;
    }
    const addOn = [
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
    if (addViewAndDel) {
        headerColumn = defValue.concat(addOn);
    } else {
        headerColumn = defValue;
    }
    return headerColumn;
};

const limitPageValue = [
    {
        label: "3 Records",
        value: 3
    },
    {
        label: "5 Records",
        value: 5
    },
    {
        label: "10 Records",
        value: 10
    }
];

let XLS = {};

export default class DataTableComponent extends LightningElement {
    lstIdSeleced = [];
    dataList;
    modeEdit = false;
    draftValues = [];
    @track optionsLimit = limitPageValue;
    @track numberSelected = 0;
    @track disableDelete = true;
    @track disableBack = true;
    @track disableNext = true;
    @track totalPageInList = 1;
    @track columns = initHeader(this.modeEdit);
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
    @track isoCountryCodeDisplayed = '';


    // XLSX properties
    @track importModalIsShow = false;
    @track xlsxImportData;
    @track fileXlsxName;
    @track fileXlsxReady = false;
    @track fileXlsxLoading = false;
    @track allCountry = [];
    @track isInImportProcess = false;
    @track isImportSuccess = null;

    get importEnable () {
        return this.fileXlsxReady && !this.isInImportProcess;
    }

    connectedCallback() {
        // Loading sheetjs library
        Promise.all([
        loadScript(this, lpqresource + '/lib/xlsx.full.min.js')
        ]).then(() => {
            // eslint-disable-next-line no-undef
            XLS = XLSX;
        }).catch(()=>{
            console.log('loading SheetJS library failue!')
        });
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
                if (record.Name) {
                    viewRecord.BuyerCode = record.Name;
                }
                if (record.BuyerAddress__c) {
                    viewRecord.BuyerAddress = record.BuyerAddress__c;
                }
                if (record.CountryCode__r && record.CountryCode__r.Name) {
                    viewRecord.CountryCode = record.CountryCode__r.Name;
                }
                if (
                    record.ISOCountryCode_Alphabet3__r &&
                    record.ISOCountryCode_Alphabet3__r.Name
                ) {
                    viewRecord.ISOCountryCode =
                        record.ISOCountryCode_Alphabet3__r.Name;
                }
                return viewRecord;
            });
            this.dataTable = newDataTable;
        } else if (result.error) {
            this.dataTable = [];
            this.error = result.error;
        }
    }

    @wire(getAllCountry) 
    wiredAllCountry({error, data}) {
        if (data) {
            this.allCountry = data;
        } else if (error) {
            console.log(error);
        }
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

    get getLabelEdit() {
        return this.modeEdit ? "Cancel Edit" : "Edit";
    }

    get getLabelLimitPage() {
        return limitPageValue.find(
            (e) => e.value.toString() === this.limitPage.toString()
        ).label;
    }

    editTable() {
        this.modeEdit = !this.modeEdit;
        const tmpColumns = jsonParse(JSON.stringify(this.columns));
        tmpColumns.forEach((element) => {
            if (element.fieldName !== "ISOCountryCode") {
                element.editable = this.modeEdit;
            }
        });
        this.columns = tmpColumns;
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
                    if (record.Name) {
                        viewRecord.BuyerCode = record.Name;
                    }
                    if (record.BuyerAddress__c) {
                        viewRecord.BuyerAddress = record.BuyerAddress__c;
                    }
                    if (record.CountryCode__r && record.CountryCode__r.Name) {
                        viewRecord.CountryCode = record.CountryCode__r.Name;
                    }
                    if (
                        record.ISOCountryCode_Alphabet3__r &&
                        record.ISOCountryCode_Alphabet3__r.Name
                    ) {
                        viewRecord.ISOCountryCode =
                            record.ISOCountryCode_Alphabet3__r.Name;
                    }
                    return viewRecord;
                });
                
                this.dataTable = newDataTable;
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
     * Handle table action
     * @param {*} event
     */
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        this.record = row;
        switch (action.name) {
            case "preview_detail":
                this.bShowModal = true;
                break;
            case "delete_record":
                this.deleteRecord(row.Id);
                break;
            default:
                console.log("a", row);
                break;
        }
    }

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

    handleRowSelect(event) {
        const listSelected = event.detail.selectedRows;
        this.numberSelected = listSelected.length;
        if (listSelected.length > 0) {
            this.disableDelete = false;
            const lstRecordSeleced = [];
            for (let i = 0; i < listSelected.length; i++) {
                lstRecordSeleced.push(listSelected[i].Id);
            }
            this.lstIdSeleced = lstRecordSeleced;
        } else {
            this.disableDelete = true;
            this.lstIdSeleced = [];
        }
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        const result = await editRecordsInList({ data: updatedFields });
        console.log(JSON.stringify("Apex update result: " + result));
        this.dispatchEvent(
            getToastMessage(TYPE_MESS.Success, `Records updared`)
        );
        this.editTable();
        refreshApex(this.dataList);
    }

    handleChangeLimitPage(event) {
        this.limitPage = event.detail.value;
        this.currentPage = 1;
        this.rowOffset = 0;
        this.getDataList(event.detail.value);
        this.getPageInfo();
    }

    openSetting() {
        this.modeList = false;
    }

    closeSetting = () => {
        this.modeList = true;
    };

    refreshTableList = (event) => {
        if (event.detail.isRefresh) refreshApex(this.dataList);
    };

    /**
     * Render call back
     */
    renderedCallback() {
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

    // handleCellChange(e) {
    //     let drafValues = e.detail.draftValues;
    //     drafValues.forEach( async value => {
    //         if (value.CountryCode) {
    //             let indexRecord = -1;
    //             await getISOCountryByCountryCode({countryCode: value.CountryCode})
    //                 .then((result) => {
    //                     this.dataTable.find((record, index) => {
    //                         if(record.Id === value.Id) {
    //                             indexRecord = index;
    //                             record.ISOCountryCode = result;
    //                             return true;
    //                         }
    //                         return false;
    //                     });
    //                     let newDataTable = [...this.dataTable];
    //                     newDataTable[indexRecord].ISOCountryCode = result;
    //                     this.dataTable = newDataTable;
    //                 })
    //                 .catch((error) => {
    //                     console.log(error);
    //                 });
    //         }
    //     });
    // }

    // select box
    handleSelectCountry (e) {
        let value = e.target.value;
        if (value) {
            getISOCountryByCountryCode({countryCode: value}).then((result) => {
                this.isoCountryCodeDisplayed = result;
            })
            .catch(() => {
                this.isoCountryCodeDisplayed = '';
            });
        }
    }

    // Import xlsx  
    openImportModal() {
        this.importModalIsShow = true;
    }

    closeImportModal() {
        this.importModalIsShow = false;
    }

    handleUploadExcel(event){
        this.isImportSuccess = false;
        const uploadedFiles = event.target.files;
        if(uploadedFiles.length > 0) {
            this.fileXlsx = uploadedFiles[0];
            this.excelToJSON(this.fileXlsx);
        }
    }

    getFirstSheetData(workbook) {
        var result = {};
        if (workbook.SheetNames.length > 0) {
            let roa = XLS.utils.sheet_to_json(workbook.Sheets[workbook.SheetNames[0]], {header:1});
            if(roa.length && Array.isArray(roa)) {
                roa.shift();
                result = roa;
            }
        }
		return result;
    }

    excelToJSON(file){
        var reader = new FileReader();
        reader.onload = event => {
            let data=event.target.result;
            let workbook=XLS.read(data, {
                type: 'binary'
            });
            var jsonObj = this.getFirstSheetData(workbook);
            jsonObj = jsonObj.filter((row) => {
                return row.length > 0;
            })
            this.xlsxImportData = jsonObj;
            console.log(jsonObj);
        };
        reader.onerror = function(ex) {
            this.error=ex;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while reding the file',
                    message: ex.message,
                    variant: 'error',
                }),
            );
        };
        reader.onloadend = () => {
            this.fileXlsxReady = true;
            this.fileXlsxLoading = false;
            this.fileXlsxName = file.name;
        }

        reader.onloadstart = () => {
            this.fileXlsxReady = false;
            this.fileXlsxLoading = true;
        }

        reader.readAsBinaryString(file);
    }

    async importExcelHandle() {
        console.log('Size Object: ' + this.roughSizeOfObject(this.xlsxImportData));
        let importSuccess = true;
        let rowsError = [];
        let totalBlock = Math.ceil(this.xlsxImportData.length / 500);
        this.fileXlsxLoading = true;
        // TODO
        let handleResult = (result) => {
            // console.log(result);
            let rsObject = JSON.parse(result);
            if (!rsObject.success) {
                importSuccess = false;
                rowsError.push(rsObject.indexsErrorRecord);
            }
            if (--totalBlock === 0) {
                console.log(`success: ${importSuccess}\n`);
                if (!importSuccess) {
                    console.log(rowsError.toString());
                }
                this.isInImportProcess = false;
                this.isImportSuccess = true;
                this.fileXlsxLoading = false;
            }
        }
        for (let i = 0; i < this.xlsxImportData.length; i+= 500) {
            // eslint-disable-next-line no-await-in-loop
            await importFromExcel({data: this.xlsxImportData.slice(i, i + 500), startIndex: i})
            .then(handleResult)
            .catch (error => {
                console.log(error);
                this.isInImportProcess = false;
                this.isImportSuccess = false;
                this.fileXlsxLoading = false;
            });
        }
    }

    roughSizeOfObject( object ) {

        var objectList = [];
        var stack = [ object ];
        var bytes = 0;
    
        while ( stack.length ) {
            var value = stack.pop();
    
            if ( typeof value === 'boolean' ) {
                bytes += 4;
            }
            else if ( typeof value === 'string' ) {
                bytes += value.length * 2;
            }
            else if ( typeof value === 'number' ) {
                bytes += 8;
            }
            else if
            (
                typeof value === 'object'
                && objectList.indexOf( value ) === -1
            )
            {
                objectList.push( value );
    
                for( var i in value ) {
                    stack.push( value[ i ] );
                }
            }
        }
        return bytes;
    }
}
