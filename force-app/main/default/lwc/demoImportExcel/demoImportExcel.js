import { LightningElement, track, wire } from "lwc";

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from 'lightning/platformResourceLoader';
import lpqresource from "@salesforce/resourceUrl/lpqresource";
import importObjectFromExcel from "@salesforce/apex/ImportExcelDemo.importObjectFromExcel";
import getSampleFieldsInfo from "@salesforce/apex/ImportExcelDemo.getSampleFieldsInfo";

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

    @wire(getSampleFieldsInfo)
    wiredFieldsInfo({error, data}) {
        if (data) {
            this.fieldsInfo = data;
        } else if (error) {
            console.log(error);
        }
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
        // Validate FrontEnd
        // this.invalidExcel = false;
        // let startTimeValidate = performance.now();
        // let validateResult = this.validateExcelInput();
        // // Handle when validate frontend error
        // if (!validateResult.valid) {
        //     // export excel
        //     // console.log(validateResult.errors);
        //     this.invalidExcel = true;
        //     this.showExcelValidateError(validateResult.errors);
        //     console.log(`Validate frontent took ${performance.now() - startTimeValidate}`);
        //     return;
        // } 
        console.log(
            "Size Object: " + this.roughSizeOfObject(this.xlsxImportData)
        );
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
                    // Refresh datatable
                    console.log('Mùi và Toàn thật tuyệt vời!');
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

    /**
     * Function caculate size of object
     * @param {*} object object to caculate size
     * @returns {Number} size of object in bytes 
     */
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

    /**
     * Function validate file excel loaded
     * @returns {Object} validate result Object
     */
    validateExcelInput() {
        const types = [];
        let valid = true;
        let errors = new Map();
        let fieldsInfo = [...this.fieldsInfo];
        this.excelHeader.forEach((header) => {
            types.push(fieldsInfo.find((item) => {
                return item.fieldLabel === header;
            }));
        });
        this.xlsxImportData.forEach((element, index) => {
            let rowValidateErrorObject = this.validateRow(element, types);
            if (rowValidateErrorObject) {
                valid = false;
                errors.set(index, rowValidateErrorObject);
            }
        });

        return {
            valid : valid,
            errors: errors
        }
    }

    /**
     * Validate special row of file excel
     * @param {*} row 
     * @param {*} types 
     * @returns {Object} validate result Object
     */
    validateRow(row, types) {
        let rowValid = true;
        let message = {};
        let invalidColumns = [];
        
        for (let i = 0; i < row.length; i++) {
            let cellValidateError = this.validateCell(row[i], types[i]);
            if (cellValidateError != null) {
                rowValid = false;
                message[this.excelHeader[i]] = cellValidateError;
                invalidColumns.push(i);
            }
        }

        if(rowValid) {
            return null;
        }

        return {
            invalidColumns: invalidColumns,
            message: JSON.stringify(message)
        };
    }

    /**
     * Function validate special cell of row
     * @param {*} value Value of cell
     * @param {*} type Type of cell 
     * @returns {String} error message, if valid return ''.
     */
    validateCell(value, type) {
        if (type) {
            if (!value && type.isRequired) {
                return 'Must not empty';
            }
    
            // type demo : String, number
            if (value && (type.type === 'NUMBER' && isNaN(+value) || (type.type === 'STRING' && typeof value !== 'string'))) {
                return 'Type invalid';
            }
    
            // length
            if ((value+'').length > type.length) {
                return 'Length error';
            }
        }
        return null;
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
                    value: rowDataTemp[i]+ ''
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
        let mapOfFieldInfo = this.getMapOfFieldByHeader([...this.fieldsInfo], [...this.excelHeader]);
        let mapErrors = new Map();
        for(const [key, value] of Object.entries(data.saveResults)) {
            let message = "";
            let invalidColumns = [];
            value.errors.forEach(error => {
                error.fields.forEach(field =>{
                    let fieldName = field.toLowerCase();
                    let col = mapOfFieldInfo.has(fieldName) && mapOfFieldInfo.get(fieldName) ? mapOfFieldInfo.get(fieldName) : undefined;
                    if (col) {
                        invalidColumns.push(col);
                    }
                });
                message += error.message + ',';
            });
            mapErrors.set(parseInt(key, 10), {
                invalidColumns: invalidColumns,
                message: message
            })
        }
        return mapErrors;
    }

    /**
     * Mapping excel header to Apex SObject field.
     * @param {*} fieldsInfo 
     * @param {*} headers 
     * @returns {Map} map of FieldName to index in header. Ex: "field_101" => 2
     */
    getMapOfFieldByHeader(fieldsInfo, headers) {
        let map = new Map();
        fieldsInfo.forEach((info) => {
            let key = info.fieldName;
            let value;
            headers.some((header, indexHeader) => {
                if (info.fieldLabel === header) {
                    value = indexHeader;
                    return true;
                }
                return false;
            });
            map.set(key, value);
        });
        return map;
    }

}
