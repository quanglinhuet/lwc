import { LightningElement, track} from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";
import importObjectFromExcel from "@salesforce/apex/ImportExcelDemo.importObjectFromExcel";

let XLS = {};

export default class DemoImportExcel extends LightningElement {

    // XLSX properties
    @track importModalIsShow = false;
    @track xlsxImportData;
    @track fileXlsxName;
    @track fileXlsxReady = false;
    @track fileXlsxLoading = false;
    @track fileContent = null;
    @track isInImportProcess = false;
    @track isImportSuccess = false;
    @track excelHeader;

    // File error
    @track invalidExcel = false;
    @track urlErrorExcel;

    get importEnable() {
        return this.fileXlsxReady && !this.isInImportProcess;
    }

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

    // Import xlsx
    openImportModal() {
        this.importModalIsShow = true;
    }

    handleCloseImportModal() {
        this.importModalIsShow = false;
    }

    /**
     * Handle when click attack file excel
     * @param {*} event 
     */
    handleUploadExcel(event) {
        this.isImportSuccess = false;
        const uploadedFiles = event.target.files;
        if (uploadedFiles.length > 0) {
            this.fileXlsx = uploadedFiles[0];
            this.excelToJSON(this.fileXlsx);
        }
    }

    /**
     * function get content of first sheet in excel workbook, exclude header
     * @param {*} workbook 
     * @returns {Object} JSON Object
     */
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

    /**
     * Function read file excel and write content to local variable
     * @param {File} file file excel to read
     */
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


    /**
     * Handle when click button import excel
     */
    async importExcelHandle() {
        let startTime = performance.now();
        const BLOCK_SIZE = 10000;
        console.log(`Block size: ${BLOCK_SIZE}`);
        this.fileXlsxLoading = true;

        importObjectFromExcel({
            listData: this.xlsxImportData,
            startIndex: 0,
            headers: [...this.excelHeader]
        })
            .then((data) => {
                if (data.success) {
                    console.log(data);
                    this.isImportSuccess = true;
                    this.fileXlsxLoading = false;
                    this.importModalIsShow = false;
                    this.template.querySelector('c-data-table-demo').refreshData();
                } else {
                    // Gen file excel
                    this.isImportSuccess = false;
                    this.invalidExcel = true;
                    this.fileXlsxLoading = false;
                    this.showExcelValidateError(this.getListErrorsValidate(data));
                }
                console.log (`Total time: ${performance.now() - startTime}`); 
            })
            .catch((error) => {
                console.log(error);
            });
          
    }
}
