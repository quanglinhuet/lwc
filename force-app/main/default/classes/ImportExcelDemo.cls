public with sharing class ImportExcelDemo {

    @AuraEnabled
    public static Object validateExcelData(List<List<String>> listData, Integer startIndex, List<String> headers){
        // Validate backend here
        LnhImportResult result = ValidateBackendDemo.validateBE(listData, headers);
        // Return validate result
        return JSON.deserializeUntyped(JSON.serialize(result));
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
