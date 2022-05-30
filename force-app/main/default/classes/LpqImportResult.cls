public with sharing class LpqImportExcelResult {
    public Boolean success;
    public List<Integer> indexsErrorRecord;
    public Map<Integer, Database.SaveResult> saveResults;
    public LpqImportExcelResult() {
        this.success = true;
        this.indexsErrorRecord = new List<Integer>();
        this.saveResults = new Map<Integer, Database.SaveResult>();
    }
}