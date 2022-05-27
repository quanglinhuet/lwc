public with sharing class LpqImportResult {
    public Boolean success;
    public List<Integer> indexsErrorRecord;
    public Boolean isInputValid;
    public Map<Integer, String> validateErrorMessages;
    public Map<Integer, List<Integer>> validateErrorCollumns;

    public LpqImportResult () {
        this.indexsErrorRecord = new List<Integer>();
        this.isInputValid = true;
        this.validateErrorMessages = new Map<Integer,String>();
        this.validateErrorCollumns = new Map<Integer,List<Integer>>();
    }
}
