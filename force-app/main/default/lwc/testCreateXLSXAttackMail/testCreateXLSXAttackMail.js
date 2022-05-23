import { LightningElement, track, wire } from "lwc";

import lpqresource from "@salesforce/resourceUrl/lpqresource";
import { loadScript } from "lightning/platformResourceLoader";
import getData from "@salesforce/apex/LpqSendMail.getData";

var XLS = {};
export default class TestCreateXLSXAttackMail extends LightningElement {
    @track url = '';
    @track XLSXReady = false;
    @track file;
    @track numberOfRecord = 1000;

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

    handleInputChange(e){
        this.numberOfRecord = e.target.value;
    }

    createXlsx() {
        let limitRecord = parseInt(this.numberOfRecord, 10);
        getData({limitRecord: limitRecord}).then(data=>{
            // let arr = [...data].slice(0, 20);
            // const LIMIT = 20;
            // let limitedArr = arr.slice(0, LIMIT);
            // let xlsxRawData = limitedArr.map((country) => {
            //     return [country];
            // });
            console.log(data);
            const wb = XLS.utils.book_new();
            const ws = XLS.utils.json_to_sheet(data);
            wb.SheetNames.push("Sheet1");
            wb.Sheets.Sheet1 = ws;
            // // console.log(arr);
    
            let wbout = XLS.write(wb, { booktype: "xlsx", type: "binary" });
            function s2ab(s) {
                var buf = new ArrayBuffer(s.length); //convert s to arrayBuffer
                var view = new Uint8Array(buf); //create uint8array as viewer
                for (let i = 0; i < s.length; i++) view[i] = s.charCodeAt(i) & 0xff; //convert to octet
                return buf;
            }
            let xlsxFile = new Blob([s2ab(wbout)],{type:"application/octet-stream"});
            this.file = xlsxFile;
            this.url = URL.createObjectURL(xlsxFile);
            this.XLSXReady = true;
        }).catch(error =>{
            console.log(error);
        });
    }

    sendMail() {

    }
}
