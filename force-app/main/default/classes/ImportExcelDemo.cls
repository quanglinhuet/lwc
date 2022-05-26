public with sharing class ImportExcelDemo {

    @AuraEnabled
    public static Object importObjectFromExcel(List<List<String>> listData, Integer startIndex){
        LpqImportResult result = new LpqImportResult();
        result.success = true;
        result.indexsErrorRecord = new List<Integer>();
        Integer heapNew = Limits.getHeapSize();
        // Validate backend here

        List<sample2__c> listBuyerImport = convertListDataImportToListBuyer(listData);
        // Tinh Toan luu record bi loi vao customobject, neu tinh toan loi => 

        Integer heapNew1 = Limits.getHeapSize();
        if (sample2__c.SObjectType.getDescribe().isCreateable()) {
            Database.SaveResult[] sr = Database.insert(listBuyerImport, false);
            for (Integer i = 0; i < sr.size(); i++) {
                if (!sr.get(i).success) {
                    result.success = false;
                    result.indexsErrorRecord.add(i + startIndex);
                }
            }
        }
        Integer heapNew2 = Limits.getHeapSize();
        return JSON.deserializeUntyped(JSON.serialize(result));
    }
    /**
     * convert list data import to list SObject
     */
    private static List<sample2__c> convertListDataImportToListBuyer(List<List<String>> listData) {
        List<sample2__c> listBuyer = new List<sample2__c>();
        return listBuyer;
    }
}
