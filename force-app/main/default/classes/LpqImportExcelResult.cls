public with sharing class LpqImportExcelResult {
    public Boolean success;
    public List<Integer> indexsErrorRecord;
    public Map<Integer, Database.SaveResult> saveResults;
    public Boolean isInputValid;
    public Map<Integer, String> validateErrorMessages;
    public Map<Integer,List<Integer>> validateErrorCollumns;
    public LpqImportExcelResult() {
        this.success = true;
        this.indexsErrorRecord = new List<Integer>();
        this.saveResults = new Map<Integer, Database.SaveResult>();
        this.validateErrorCollumns = new Map<Integer, List<Integer>>();
        this.validateErrorMessages = new Map<Integer, String>();
    }
}
