import { LightningElement, wire, track, api } from "lwc";
import { deleteRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";

import fetchDataList from "@salesforce/apex/LpqBuyerHelpers.fetchDataList";
import countRecordOfList from "@salesforce/apex/LpqBuyerHelpers.countRecordOfList";
import deleteRecordInList from "@salesforce/apex/LpqBuyerHelpers.deleteRecordInList";
import editRecordsInList from "@salesforce/apex/LpqBuyerHelpers.editRecordsInList";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";
import importObjectFromExcel from "@salesforce/apex/ImportExcelDemo.importObjectFromExcel";
import getSampleFieldsInfo from "@salesforce/apex/ImportExcelDemo.getSampleFieldsInfo";

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
            label: "Buyer Code",
            fieldName: "BuyerCode",
            type: "text",
            initialWidth: 150,
            editable: false
        },
        {
            label: "Buyer Address",
            fieldName: "BuyerAddress",
            type: "text",
            initialWidth: 300,
            editable: false
        },
        {
            label: "Country Code",
            fieldName: "CountryCode",
            initialWidth: 150,
            type: "text",
            editable: false
        },
        {
            label: "ISO Country Code",
            fieldName: "ISOCountryCode",
            initialWidth: 150,
            type: "text"
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
    @track importModalIsShow = false
    @track xlsxImportData;
    @track fileXlsxName;
    @track fileXlsxReady = false;
    @track fileXlsxLoading = false;
    @track fileContent = null;
    @track allCountry = [];
    @track isInImportProcess = false;
    @track isImportSuccess = false;
    @track excelHeader;

    get importEnable() {
        return this.fileXlsxReady && !this.isInImportProcess;
    }

    connectedCallback() {
        // Loading sheetjs library
        Promise.all([loadScript(this, lpqresource + "/lib/xlsx.core.min.js")], [loadScript(this, lpqresource + "/lib/write-excel-file.min.js")])
        .then(() => {
            XLS = XLSX;
            writeExcel = writeXlsxFile;
        })
        .catch(() => {
            console.log("loading SheetJS library failue!");
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

    get labelEdit() {
        return this.modeEdit ? "Cancel Edit" : "Edit";
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

    // Import xlsx
    openImportModal() {
        this.importModalIsShow = true;
    }

    handleCloseImportModal() {
        this.importModalIsShow = false;
    }

    @wire(getSampleFieldsInfo)
    wiredFieldsInfo({error, data}) {
        if (data) {
            this.fieldsInfo = data;
        } else if (error) {
            console.log(error);
        }
    }

    handleUploadExcel(event) {
        this.isImportSuccess = false;
        const uploadedFiles = event.target.files;
        if (uploadedFiles.length > 0) {
            this.fileXlsx = uploadedFiles[0];
            this.excelToJSON(this.fileXlsx);
        }
    }

    getFirstSheetData(workbook) {
        var result = {};
        if (workbook.SheetNames.length > 0) {
            let roa = XLS.utils.sheet_to_json(
                workbook.Sheets[workbook.SheetNames[0]],
                { header: 1 }
            );
            if (roa.length && Array.isArray(roa)) {
                this.excelHeader = [...roa[0]];
                roa.shift();
                result = roa;
            }
        }
        return result;
    }

    excelToJSON(file) {
        var reader = new FileReader();
        reader.onload = (event) => {
            let data = event.target.result;
            this.fileContent = data;
            let workbook = XLS.read(data, {
                type: "binary"
            });
            let jsonObj = this.getFirstSheetData(workbook);
            jsonObj = jsonObj.filter((row) => {
                return row.length > 0;
            });
            this.xlsxImportData = jsonObj;
            // console.log(jsonObj);
        };
        reader.onerror = function (ex) {
            this.error = ex;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while reding the file",
                    message: ex.message,
                    variant: "error"
                })
            );
        };
        reader.onloadend = () => {
            this.fileXlsxReady = true;
            this.fileXlsxLoading = false;
            this.fileXlsxName = file.name;
        };

        reader.onloadstart = () => {
            this.fileXlsxReady = false;
            this.fileXlsxLoading = true;
        };

        reader.readAsBinaryString(file);
    }



    async importExcelHandle() {
        // Validate FrontEnd
        this.invalidExcel = false;
        let validateResult = this.validateExcelInput();

        if (!validateResult.valid) {
            // export excel
            // console.log(validateResult.errors);
            this.invalidExcel = true;
            this.showExcelValidateError(validateResult.errors);
            return;
        } 
        console.log(
            "Size Object: " + this.roughSizeOfObject(this.xlsxImportData)
        );
        let startTime = performance.now();
        const BLOCK_SIZE = 10000;
        const REQUESTS_PER_TIME = 1;
        console.log(`Block size: ${BLOCK_SIZE}`);
        let totalBlock = Math.ceil(this.xlsxImportData.length / BLOCK_SIZE);
        this.fileXlsxLoading = true;
        let promises = [];
        let count = 0;
        for (let i = 0; i < this.xlsxImportData.length; i += BLOCK_SIZE) {
            count++;
            promises.push(
                importObjectFromExcel({
                    listData: this.xlsxImportData.slice(i, i + BLOCK_SIZE),
                    startIndex: i,
                    headers: [...this.excelHeader]
                })
            );
            if (count % REQUESTS_PER_TIME === 0 || count === totalBlock) {
                // eslint-disable-next-line no-await-in-loop
                await Promise.allSettled(promises);
            }
        }
        await Promise.all(promises)
            .then((values) => {
                console.log(values);
                this.isImportSuccess = true;
                this.fileXlsxLoading = false;
            })
            .catch((error) => {
                console.log(error);
            });
        console.log (`Total time: ${performance.now() - startTime}`);   
    }

    roughSizeOfObject(object) {
        var objectList = [];
        var stack = [object];
        var bytes = 0;

        while (stack.length) {
            let value = stack.pop();

            if (typeof value === "boolean") {
                bytes += 4;
            } else if (typeof value === "string") {
                bytes += value.length * 2;
            } else if (typeof value === "number") {
                bytes += 8;
            } else if (
                typeof value === "object" &&
                objectList.indexOf(value) === -1
            ) {
                objectList.push(value);

                // eslint-disable-next-line guard-for-in
                for (let i in value) {
                    stack.push(value[i]);
                }
            }
        }
        return bytes;
    
    }
}
