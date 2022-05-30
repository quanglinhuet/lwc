public with sharing class ValidateBackendDemo {
    public ValidateBackendDemo() {
        //constructor
    }
    public static LpqImportResult validateBE(List<List<String>> listData, List<String> headers) {
        Integer row = 0;
        Integer abcd;
        Boolean isColumnError = false;
        Boolean isRowError = false;
        Map<String,String> messageError = new Map<String,String>();
        FieldValidateConditionEntity field = new FieldValidateConditionEntity();
        String dataColumn = '';
        LpqImportResult result = new LpqImportResult();
        result.isInputValid = true;

        // Khởi tạo List Integer chứa list các cột lỗi
        List<Integer> listColumnError = new List<Integer>();

        // Khởi tạo list đối tượng chứa thông tin field Infor
        List<FieldValidateConditionEntity> listFieldInfor = new List<FieldValidateConditionEntity>();
        // Call hàm get FieldsInfor lấy về list thông tin các trường 
        listFieldInfor = ImportExcelDemo.getSampleFieldsInfoApex();
        // Sort fieldInfor theo header truyền lên
        listFieldInfor = sortFieldInfor(listFieldInfor, headers);
        System.debug('==== So row: ');
        System.debug(listData.size());
        for(List<String> rowData: listData ){
            listColumnError = new List<Integer>();
            row = listData.indexOf(rowData);
            for(Integer i = 0; i< rowData.size(); i++){
                Integer column = i;
                field = listFieldInfor.get(i);
                dataColumn = rowData.get(i);
                if (field != null && dataColumn != null) {
                    // if (field.type)
                    if (field.isRequired && String.isEmpty(dataColumn)) {
                        isColumnError = true;
                        messageError.put(field.fieldLabel, 'Required error!');
                    } else if (dataColumn.length() > field.length) {
                        isColumnError = true;
                        messageError.put(field.fieldLabel, 'Max length error!');
                    } 
                    // TODO: validate data type
                    // Add to list column error if data in this column is error
                    if(isColumnError) {
                        listColumnError.add(i);
                        isRowError = true;
                    }
                    isColumnError = false;
                }
            }
            // If data in this row has error, add to list and map for result
            if (isRowError) {
                result.validateErrorMessages.put(row,JSON.serialize(messageError));
                result.validateErrorCollumns.put(row,listColumnError);
                result.indexsErrorRecord.add(row);
                result.isInputValid = false;
            }
            isRowError = false;
            messageError.clear();
        }
        return result;
    }
        
    public static List<FieldValidateConditionEntity> sortFieldInfor(List<FieldValidateConditionEntity> listFieldInfor, List<String> headers) {
        List<FieldValidateConditionEntity> result = new List<FieldValidateConditionEntity>();
        // For: all header in list headers
        for(String header: headers) {
            // For: all field in list fieldInfor
            for(FieldValidateConditionEntity fieldInfor: listFieldInfor) {
                // If this header === label of this field infor
                if(header.equals(fieldInfor.fieldLabel)) {
                    // Add fieldInfor to result list
                    result.add(fieldInfor);
                    break;
                }
            }
        }
        return result;
    }
}





