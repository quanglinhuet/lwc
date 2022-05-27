public with sharing class ImportExcelDemo {

    @AuraEnabled
    public static Object importObjectFromExcel(List<List<String>> listData, Integer startIndex, List<String> headers){
        LpqImportResult result = new LpqImportResult();
        result.success = true;
        result.indexsErrorRecord = new List<Integer>();
        Integer heapNew = Limits.getHeapSize();
        // Validate backend here
        LpqImportResult resultValidate = validateBE(listData, headers);
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
    
    public static LpqImportResult validateBE(List<List<String>> listData, List<String> headers) {
        Integer row = 0;
        Boolean isError = false;
        String messageError = '';
        FieldValidateConditionEntity field = new FieldValidateConditionEntity();
        String dataColumn = '';
        LpqImportResult result = new LpqImportResult();
        // Khởi tạo List Integer chứa list các dòng lỗi
        List<Integer> indexsErrorRecord = new List<Integer>();
        // Khởi tạo List Integer chứa list các cột lỗi
        List<Integer> listColumnError = new List<Integer>();
        // Khởi tạo map chứa message lỗi theo từng row
        Map<Integer, String> validateErrorMessages = new Map<Integer, String>();
        // Khởi tạo map chứa list các cột bị lỗi theo từng dòng
        Map<Integer, List<Integer>> validateErrorCollumns = new Map<Integer, List<Integer>>();
        // Khởi tạo list đối tượng chứa thông tin field Infor
        List<FieldValidateConditionEntity> listFieldInfor = new List<FieldValidateConditionEntity>();
        // Call hàm get FieldsInfor lấy về list thông tin các trường 
        listFieldInfor = getSampleFieldsInfoApex();
        // Sort fieldInfor theo header truyền lên
        listFieldInfor = sortFieldInfor(listFieldInfor, headers);
        for(List<String> rowData: listData ){
            for(Integer i = 0; i< rowData.size(); i++){
                field = listFieldInfor.get(i);
                dataColumn = rowData.get(i);
                if (field.type)
                if (field.invalid && String.isEmpty(dataColumn)) {
                    isError = true;
                    messageError += field.fieldLabel + ':Required error!';
                } else if (dataColumn.length > field.length) {
                    isError = true;
                    messageError += field.fieldLabel + ':Max length error!';
                } 
                    // TODO: validate data type
                // Add to list column error if data in this column is error
                if(isError) {
                    listColumnError.add(i);
                }
            }
            // If data in this row has error, add to list and map for result
            if (isError) {
                row = listData.indexOf(rowData);
                validateErrorMessages.put(row,messageError);
                validateErrorCollumns.put(row,listColumnError);
                indexsErrorRecord.add(row);
            }
        }
        return result;
    }
        
    public List<FieldValidateConditionEntity> sortFieldInfor(List<FieldValidateConditionEntity> listFieldInfor, List<String> headers) {
        List<FieldValidateConditionEntity> result;
        // For: all header in list headers
        for(String header: headers) {
            // For: all field in list fieldInfor
            for(FieldValidateConditionEntity fieldInfor: listFieldInfor) {
                // If this header === label of this field infor
                if(header.equals(fieldInfor.fieldLabel)) {
                    // Add fieldInfor to result list
                    result.add(fieldInfor);
                    // remove this fieldInfor for next step in loop
                    listFieldInfor.remove(indexOf(fieldInfor));
                    break;
                }
            }
        }
        return result;
    }
}
