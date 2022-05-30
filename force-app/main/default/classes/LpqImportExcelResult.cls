public with sharing class LpqImportExcelResult {
    public Boolean success;
    public List<Integer> indexsErrorRecord;
    public Map<Integer, Database.SaveResult> saveResults;
    public Boolean isInputValid;
    public List<Integer, String> validateErrorMessages;
    public List<Integer,List<Integer>> validateErrorCollumns;
    public LpqImportExcelResult() {
        this.success = true;
        this.indexsErrorRecord = new List<Integer>();
        this.saveResults = new Map<Integer, Database.SaveResult>();
        this.validateErrorCollumns = new List<Integer, List<Integer>>();
        this.validateErrorMessages = new List<Integer, String>();
    }
}
