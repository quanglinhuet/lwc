import { LightningElement, track, wire } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";
import importObjectFromExcel from "@salesforce/apex/ImportExcelDemo.importObjectFromExcel";
import getSampleFieldsInfo from "@salesforce/apex/ImportExcelDemo.getSampleFieldsInfo";

let XLS = {};

export default class DemoImportExcel extends LightningElement {

    // XLSX properties
    @track importModalIsShow = false;
    @track xlsxImportData;
    @track fileXlsxName;
    @track fileXlsxReady = false;
    @track fileXlsxLoading = false;
    @track allCountry = [];
    @track isInImportProcess = false;
    @track isImportSuccess = false;

    get importEnable() {
        return this.fileXlsxReady && !this.isInImportProcess;
    }

    @wire(getSampleFieldsInfo)
    fieldsInfo;

    connectedCallback() {
        // Loading sheetjs library
        Promise.all([loadScript(this, lpqresource + "/lib/xlsx.full.min.js")])
            .then(() => {
                // eslint-disable-next-line no-undef
                XLS = XLSX;
            })
            .catch(() => {
                console.log("loading SheetJS library failue!");
            });
    }

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

    closeImportModal() {
        this.importModalIsShow = false;
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
            let workbook = XLS.read(data, {
                type: "binary"
            });
            var jsonObj = this.getFirstSheetData(workbook);
            jsonObj = jsonObj.filter((row) => {
                return row.length > 0;
            });
            this.xlsxImportData = jsonObj;
            console.log(jsonObj);
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
                    startIndex: i
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
