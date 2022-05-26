public with sharing class ImportExcelDemo {

    @AuraEnabled
    public static Object importObjectFromExcel(List<List<String>> listData, Integer startIndex){
        LpqImportResult result = new LpqImportResult();
        result.success = true;
        result.indexsErrorRecord = new List<Integer>();
        Integer heapNew = Limits.getHeapSize();
        // Validate backend here

        List<sample2__c> listBuyerImport = convertListDataImportToListSampleObject(listData);
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
    private static List<sample2__c> convertListDataImportToListSampleObject(List<List<String>> listData) {
        List<sample2__c> listSampleObject = new List<sample2__c>();
        List<String> listFieldExcel = getListColumnExcel();
        String jsonString = '';
        for (List<String> data : listData) {
            jsonString = '{';
            for (Integer i = 0; i < data.size(); i++) {
                jsonString += '"'+listFieldExcel.get(i)+'":"'+data.get(i)+'"';
                if (i != data.size() - 1) {
                    jsonString += ',';
                }
            }
            jsonString += '}';
            sample2__c newSampleObject = (sample2__c) JSON.deserialize(jsonString, sample2__c.class);
            listSampleObject.add(newSampleObject);
        }
        return listSampleObject;
    }

    private static List<String> getListColumnExcel() {
        List<String> listFieldExcel = new List<String>();
        listFieldExcel.add('Field895__c');
        listFieldExcel.add('Field757__c');
        listFieldExcel.add('Field856__c');
        listFieldExcel.add('Field974__c');
        listFieldExcel.add('Field326__c');
        listFieldExcel.add('Field324__c');
        listFieldExcel.add('Field942__c');
        listFieldExcel.add('Field936__c');
        listFieldExcel.add('Field101__c');
        listFieldExcel.add('GPC__c');
        listFieldExcel.add('Field794__c');
        listFieldExcel.add('Field504__c');
        listFieldExcel.add('LISS__c');
        listFieldExcel.add('Field421__c');
        listFieldExcel.add('Field126__c');
        listFieldExcel.add('Field750__c');
        listFieldExcel.add('Field373__c');
        listFieldExcel.add('Field601__c');
        listFieldExcel.add('Field313__c');
        listFieldExcel.add('X1__c');
        listFieldExcel.add('X2__c');
        listFieldExcel.add('X3__c');
        listFieldExcel.add('X4__c');
        listFieldExcel.add('Field266__c');
        listFieldExcel.add('IPCArticle__c');
        listFieldExcel.add('Field348__c');
        listFieldExcel.add('Field899__c');
        return listFieldExcel;
    }

    @AuraEnabled(cacheable = true)
    public static Object getSampleFieldsInfo() {
        SObjectType sample2Type = Schema.getGlobalDescribe().get('sample2__c');
        Map<String,Schema.SObjectField> mfields = sample2Type.getDescribe().fields.getMap();
        List<FieldValidateConditionEntity> listFieldInfo = new List<FieldValidateConditionEntity>();
        for(String key : mfields.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = mfields.get(key).getDescribe();
            if (fieldDescribe.isCustom()) {
                FieldValidateConditionEntity validateEntity = new FieldValidateConditionEntity();
                validateEntity.fieldName = key;
                validateEntity.fieldLabel = fieldDescribe.getLabel();
                validateEntity.length = fieldDescribe.getLength();
                validateEntity.type = fieldDescribe.getType().name();
                validateEntity.isRequired = !fieldDescribe.isNillable();
                listFieldInfo.add(validateEntity);
            }
        }
        return Json.deserializeUntyped(JSON.serialize(listFieldInfo));
    }

    @AuraEnabled(cacheable = true)
    public static List<FieldValidateConditionEntity> getSampleFieldsInfoApex() {
        SObjectType sample2Type = Schema.getGlobalDescribe().get('sample2__c');
        Map<String,Schema.SObjectField> mfields = sample2Type.getDescribe().fields.getMap();
        List<FieldValidateConditionEntity> listFieldInfo = new List<FieldValidateConditionEntity>();
        for(String key : mfields.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = mfields.get(key).getDescribe();
            if (fieldDescribe.isCustom()) {
                FieldValidateConditionEntity validateEntity = new FieldValidateConditionEntity();
                validateEntity.fieldName = key;
                validateEntity.fieldLabel = fieldDescribe.getLabel();
                validateEntity.length = fieldDescribe.getLength();
                validateEntity.type = fieldDescribe.getType().name();
                validateEntity.isRequired = !fieldDescribe.isNillable();
                listFieldInfo.add(validateEntity);
            }
        }
        return listFieldInfo;
    }
    
}
