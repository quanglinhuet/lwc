public with sharing class ImportExcelDemo {
    /**
     * function get Object Field info in apex, return to frontend
     */
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
}
