import { LightningElement, track, wire } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";
import validateExcelData from "@salesforce/apex/ImportExcelDemo.validateExcelData";

let XLS = {};
let writeExcel = {};

export default class DemoImportExcel extends LightningElement {

    // XLSX properties
    @track importModalIsShow = false;
    @track xlsxImportData;
    @track fileXlsxName;
    @track fileXlsxReady = false;
    @track fileXlsxLoading = false;
    @track fileContent = null;
    @track allCountry = [];
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
        Promise.all([loadScript(this, lpqresource + "/lib/xlsx.full.min.js")], [loadScript(this, lpqresource + "/lib/write-excel-file.min.js")])
            .then(() => {
                // eslint-disable-next-line no-undef
                XLS = XLSX;
                // eslint-disable-next-line no-undef
                writeExcel = writeXlsxFile;
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

    handleCloseImportModal() {
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
        this.fileXlsxLoading = true;
        // Validate backend
        validateExcelData({
                    listData: this.xlsxImportData,
                    startIndex: 0,
                    headers: [...this.excelHeader]
                })
            .then((value) => {
                if (!value.isInputValid) {
                    const errors = this.getListErrorsValidate(value);
                    this.showExcelValidateError(errors);
                    return;
                }
                console.log('File excel is valid!');
                this.isImportSuccess = true;
                this.fileXlsxLoading = false;
            })
            .catch((error) => {
                console.log(error);
            });
    }

    /**
     * Function create excel file with infomation of errors.
     * @param {*} errors error object
     */
     async showExcelValidateError (errors) {
        const wb = XLS.read(this.fileContent, {
            type: "binary"
        });
        let ws = wb.Sheets[wb.SheetNames[0]];
        let sheetJson = XLS.utils.sheet_to_json(ws, {
            header: 1,
            raw: true
        });
        
        let data = [];
        let header = sheetJson[0].map((elem) => {
            return {
                value: elem
            }
        });
        header.push({value: 'エラー内容'});
        data.push(header);
        sheetJson.splice(0, 1);
        sheetJson = sheetJson.filter((row) => {
            return row.length > 0;
        });
        // Create excel content with current excel data append response errors
        let rows = sheetJson.map((row, index) => {
            let rowDataTemp = [...row];
            let rowData = []
            for (let i = 0; i < header.length; i++) {
                let temp = {
                    type: String,
                    value: rowDataTemp[i] ? rowDataTemp[i] + '' : ''
                };
                rowData.push(temp);
            }
            if (errors.has(index)) {
                let error = errors.get(index);
                rowData[rowData.length - 1].value = error.message;
                error.invalidColumns.forEach(colIndex => {
                    rowData[colIndex].backgroundColor = '#FF6161';
                })
            }
            return rowData;
        });
        data = [...data, ...rows];
        await writeExcel(data, {
            fileName: 'file.xlsx'
        })
    }

    /**
     * Create errors object from apex response. For creating file excel with error infomation.
     * @param {*} data 
     * @returns 
     */
    getListErrorsValidate(data) {
        let mapErrors = new Map();
        data.indexsErrorRecord.forEach(rowNumber => {
            let message = data.validateErrorMessages[rowNumber+''];
            let invalidColumns = data.validateErrorCollumns[rowNumber+''];
            mapErrors.set(parseInt(rowNumber, 10), {
                invalidColumns: invalidColumns,
                message: message
            })
        })
        return mapErrors;
    }
}
