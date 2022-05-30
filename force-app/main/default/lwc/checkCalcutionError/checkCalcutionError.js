import { api, LightningElement, track } from 'lwc';
import importObjectFromExcel from "@salesforce/apex/ImportExcelDemo.importObjectFromExcel";
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";

let XLS = {};
let writeExcel = {};
export default class CheckCalcutionError extends LightningElement {
    @api closemodal;
    @track xlsxImportData;
    @track fileXlsxName;
    @track fileXlsxReady = false;
    @track fileXlsxLoading = false;
    @track fileContent = null;
    @track allCountry = [];
    @track isInImportProcess = false;
    @track isImportSuccess = false;
    @track excelHeader;
    @track newData = [];

    get importEnable() {
        return this.fileXlsxReady && !this.isInImportProcess;
    }

    connectedCallback() {
        // Loading sheetjs library
        Promise.all([loadScript(this, lpqresource + "/lib/xlsx.full.min.js")], [loadScript(this, lpqresource + "/lib/write-excel-file.min.js")])
        .then(() => {
            XLS = XLSX;
            writeExcel = writeXlsxFile;
        })
        .catch(() => {
            console.log("loading SheetJS library failue!");
        });
    }

    handleCloseImportModal() {
        this.closemodal = false;
        this.handleReloadData();
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
                this.isImportSuccess = true;
                this.fileXlsxLoading = false;
                this.closemodal = false;
                let resultData = values[0];
                let newDataTable = [];
                resultData.map((record) => {
                    let viewRecord = {};
                    Object.keys(record).map(key => {
                        viewRecord.Id = record.Field895__c.value;
                        if (record.Field895__c.value) {
                            viewRecord.Field895__c = record.Field895__c.value;
                        }
                        if (record.Field757__c.value) {
                            viewRecord.Field757__c = record.Field757__c.value;
                        }
                        if (record.Field856__c.value) {
                            viewRecord.Field856__c = record.Field856__c.value;
                        }
                        if (record.Field348__c.value) {
                            viewRecord.Field348__c = record.Field348__c.value;
                            viewRecord.errorCalcultion = record.Field348__c.error? 'background-color-red' : '';
                        }
                    })
                    newDataTable.push(viewRecord);
                })
                
                this.newData = newDataTable;
                this.handleReloadData();

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

    handleReloadData() {
        const data = new CustomEvent('reloadtable', {
            detail: {
                importModalIsShow: this.closemodal,
                listData: this.newData
            }
        });
        this.dispatchEvent(data);

    }
}