import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from "@salesforce/apex";
import fetchDataList from '@salesforce/apex/LpqBuyerHelpers.fetchDataList';
import editRecordsInList from '@salesforce/apex/LpqBuyerHelpers.editRecordsInList';
import {loadStyle} from 'lightning/platformResourceLoader'
import lpqresource from "@salesforce/resourceUrl/lpqresource";

export default class DatatableTest extends LightningElement {
    @track draftValues = [];
    @track dataTable;
    @track rowOffset = 0;
    @track isEdit = false;
    @track isCssLoaded = false;

    // 属性にはテーブルヘッダー情報が含まれています
    @track columns = [
        { label: "Buyer Code", fieldName: "BuyerCode", type: "text", initialWidth: 150, editable: false },
        { label: "Buyer Address", fieldName: "BuyerAddress", type: "text", initialWidth: 300, editable: false },
        { label: "Country Code", fieldName: "CountryCode", initialWidth: 150,  type: "text", editable: false },
        { 
            label: "PointTest", 
            fieldName: "PointTest", 
            initialWidth: 150, 
            type: "number", 
            editable: false, 
            cellAttributes: {
                class: {fieldName: 'PointValid'}
            } 
        },
        { label: "ISO Country Code", fieldName: "ISOCountryCode", initialWidth: 150, type: "text" },
    ];

    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, lpqresource + "/style/customDatatableStyle.css").then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors");
            console.log(error);
        })
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
                if (record.PointTest__c != null && record.PointTest__c !== undefined) {
                    viewRecord.PointTest = record.PointTest__c;
                    viewRecord.PointValid = record.PointTest__c <= 99 ? 'background-color-red' : '';
                }
                return viewRecord;
            });
            this.dataTable = newDataTable;
        } else if (result.error) {
            this.dataTable = [];
            this.error = result.error;
        }
    }

    editTable() {
        this.modeEdit = !this.modeEdit;
        const tmpColumns = JSON.parse(JSON.stringify(this.columns));
        tmpColumns.forEach((element) => {
            if (element.fieldName !== "ISOCountryCode") {
                element.editable = this.modeEdit;
            }
        });
        this.columns = tmpColumns;
    }

    async handleSave(event) {
        const updatedFields = event.detail.draftValues;
        const result = await editRecordsInList({ data: updatedFields });
        console.log(JSON.stringify("Apex update result: " + result));
        this.editTable();
        refreshApex(this.dataList);
    }
}