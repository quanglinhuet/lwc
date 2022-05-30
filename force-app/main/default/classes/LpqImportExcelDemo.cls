public with sharing class LpqImportExcelDemo {
    @AuraEnabled
    public static Object importObjectFromExcel(List<List<String>> listData, Integer startIndex, List<String> headers){
        LpqImportExcelResult result = new LpqImportExcelResult();
        Integer heapNew = Limits.getHeapSize();
        // Validate backend here

        List<sample2__c> listBuyerImport = convertListDataImportToListSampleObject(listData);
        // Tinh Toan luu record bi loi vao customobject, neu tinh toan loi => 
        Savepoint sp = Database.setSavePoint();
        Integer heapNew1 = Limits.getHeapSize();
        if (sample2__c.SObjectType.getDescribe().isCreateable()) {
            Database.SaveResult[] sr = Database.insert(listBuyerImport, false);
            for (Integer i = 0; i < sr.size(); i++) {
                if (!sr.get(i).success) {
                    result.success = false;
                    result.indexsErrorRecord.add(i + startIndex);
                    result.saveResults.put(i + startIndex, sr.get(i));
                }
            }
        }
        if (!result.success) {
            Database.rollback(sp);
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
            Boolean first = true;
            for (Integer i = 0; i < data.size(); i++) {
                if (data.get(i) != null) {
                    if(first) {
                        jsonString += '"'+listFieldExcel.get(i)+'":"'+data.get(i)+'"';
                        first = false;
                    } else {
                        jsonString += ',"'+listFieldExcel.get(i)+'":"'+data.get(i)+'"';
                    }
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



    /**
     * Function validate list rows of object
     */
    @AuraEnabled
    public static LpqImportExcelResult validateListUser(List<List<String>> rows, List<String> listHeader) {
        LpqImportExcelResult validateResult = new LpqImportExcelResult();
        List<FieldValidateConditionEntity> listFieldInfo = getListFieldInfoByListHeader(listHeader);
        for (Integer i = 0; i < rows.size(); i++) {
            List<String> row = rows.get(i);
            // validate row
            Boolean rowValid = true;
            List<Integer> listColumnInvalid = new List<Integer>();
            Map<String,String> mapErrorMessage = new Map<String,String>();
            for (Integer j = 0; j< row.size(); j++) {
                String value = row.get(j);
                
                String errorMessage = validateCol(value, listFieldInfo.get(j));
                if (errorMessage != '') {
                    listColumnInvalid.add(j);
                    mapErrorMessage.put(listHeader.get(j), errorMessage);
                    rowValid = false;
                }
            }

            if (!rowValid) {
                validateResult.isInputValid = false;
                validateResult.validateErrorMessages.put(i, JSON.serialize(mapErrorMessage));
                validateResult.validateErrorCollumns.put(i, listColumnInvalid);
            }
        }

        return validateResult;
    }
    
    /**
     * Validate row data
     */
    private static String validateCol(String value, FieldValidateConditionEntity fieldInfo) {
        // 0:isValid,  1: message
        String errorMessage = '';

        // Check if field not exist
        if (fieldInfo == null) {
            return errorMessage;
        }

        // check require
        if (fieldInfo.isRequired && (value == null || value == '')) {
            errorMessage = 'Must not empty';
        } else if(fieldInfo.type == 'NUMBER') {
            try {
                Double.valueOf(value);
            } catch (Exception e) {
                errorMessage = 'Type invalid';
            }
        } else if(value != null && value.length() > fieldInfo.length) {
            errorMessage = 'Length error';
        }
        return errorMessage;
    }

    /**
     * get list field info mapping with list header
     */
    private static List<FieldValidateConditionEntity> getListFieldInfoByListHeader (List<String> listHeader) {
        List<FieldValidateConditionEntity> listFieldInfo = getSampleFieldsInfoApex();
        // Get field info from apex and sort to match list header
        List<FieldValidateConditionEntity> listFieldInfoOrdered = new List<FieldValidateConditionEntity>(listHeader.size());
        for (Integer i = 0; i < listHeader.size(); i++) {
            Boolean typeExist = false;
            for (FieldValidateConditionEntity fieldInfo : listFieldInfo) {
                if (fieldInfo.fieldLabel == listHeader.get(i)) {
                    listFieldInfoOrdered.set(i, fieldInfo);
                    typeExist = true;
                    break;
                }
            }
            if (!typeExist) {
                listFieldInfoOrdered.set(i, null);
            }
        }
        return listFieldInfoOrdered;
    }

    /**
     * function get Object Field info in apex
     */
    private static List<FieldValidateConditionEntity> getSampleFieldsInfoApex() {
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
