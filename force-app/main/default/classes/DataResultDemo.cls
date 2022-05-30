public with sharing class DataResultDemo {
    public static List<Map<String, Object>> buildJsonObject(List<List<String>> listData, List<String> listFieldExcel) {
        List<Map<String, Object>> listResult = new List<Map<String, Object>>();
        
        for (List<String> data : listData) {
            Map<String, Object> dataObj = new Map<String, Object>();
            List<Object> listObj = new List<Object>();
            Map<String, Object> listDataObj = new Map<String, Object>();
            for (Integer i = 0; i < data.size(); i++) {
                Map<String,Object> value = new Map<String,Object>();
                if (data.get(i) != null) {
                    value.put('value', data.get(i));
                } else {
                    value.put('value', '');
                }
                if (listFieldExcel[i] == 'Field348__c') {
                    if (Integer.valueOf(data.get(i)) < 60) {
                        value.put('error', true);
                    } else {
                        value.put('error', false);
                    }
                } else {
                    value.put('error', false);
                }
                dataObj.put(listFieldExcel[i], value);
            }
            listResult.add(dataObj);
        }
        return listResult;
    }

    @AuraEnabled(cacheable = true)
    public static List<sample2__c> fetchDataList(Integer offsetNum, Integer limitNum){
        return [
                SELECT 
                    Id , 
                    Field895__c,
                    Field757__c,
                    Field856__c,
                    Field348__c
                FROM sample2__c
                WITH SECURITY_ENFORCED
                LIMIT :limitNum
                OFFSET :((offsetNum - 1) * limitNum)
            ];
    }

    @AuraEnabled(cacheable = true)
    public static Integer countRecordOfList(){
        Integer numberDatas = 0;
        if (sample2__c.SObjectType.getDescribe().isAccessible()){
            numberDatas = [SELECT COUNT() FROM sample2__c];
        }
        return numberDatas;
    }
}
