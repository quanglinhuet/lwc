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
        // a.Field895__c = (String)m.get('*供給ソース');
        // a.Field757__c = (String)m.get('*品種');
        // a.Field856__c = (String)m.get('ブロック');
        // a.Field974__c = (String)m.get('ブロック略称');
        // a.Field326__c = (String)m.get('仕向国');
        // a.Field324__c = (String)m.get('仕向国名');
        // a.Field942__c = (String)m.get('*適用開始年月');
        // a.Field936__c = (String)m.get('*適用終了年月');
        // a.Field101__c = (String)m.get('*製品コード');
        // a.GPC__c = (String)m.get('GPC');
        // a.Field794__c = (String)m.get('*内訳');
        // a.Field504__c = (String)m.get('ｻｲｽﾞ');
        // a.LISS__c = (String)m.get('LI/SS');
        // a.Field421__c = (String)m.get('ｾｸｼｮﾝ');
        // a.Field126__c = (String)m.get('ﾀｲﾌﾟ');
        // a.Field750__c = (String)m.get('ﾘﾑ');
        // a.Field373__c = (String)m.get('ﾌﾟﾗｲ');
        // a.Field601__c = (String)m.get('ﾊﾟﾀｰﾝ');
        // a.Field313__c = (String)m.get('基本構造');
        // a.X1__c = (String)m.get('表示1');
        // a.X2__c = (String)m.get('表示2');
        // a.X3__c = (String)m.get('表示3');
        // a.X4__c = (String)m.get('表示4');
        // a.Field266__c = (String)m.get('特殊構造');
        // a.IPCArticle__c = (String)m.get('IPC/Article');
        // a.Field348__c = (String)m.get('*価格');
        // a.Field899__c = (String)m.get('*通貨');
        List<sample2__c> listBuyer = new List<sample2__c>();
        return listBuyer;
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
