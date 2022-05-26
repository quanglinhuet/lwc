public with sharing class LpqImportResult {
    public Boolean success;
    public List<Integer> indexsErrorRecord;
    public Boolean isInputValid;
    public Map<Integer, String> validateErrorMessages;
    public Map<Integer, List<Integer>> validateErrorCollumns;
}
