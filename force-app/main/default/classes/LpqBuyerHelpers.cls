public with sharing class LpqBuyerHelpers {
    // Map country code to : [Id_Country, Id_CountryCode ]
    static private Map<String, List<String>> mapOfCountrys;
    
    static{
        LpqBuyerHelpers.mapOfCountrys = new Map<String, List<String>>();
        if (M_Country__c.getSObjectType().getDescribe().isAccessible()) {
            List<M_Country__c> listTemp = new List<M_Country__c>();
            listTemp = [SELECT Name ,Id,ISOCounteyCode_Alphabet3__r.Id FROM M_Country__c];
            for (M_Country__c country : listTemp) {
                List<String> lstId = new List<String>();
                lstId.add(country.Id);
                if (country.ISOCounteyCode_Alphabet3__r.Id != null) {
                    lstId.add(country.ISOCounteyCode_Alphabet3__r.Id);
                }
                mapOfCountrys.put(country.Name, lstId);
            }
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<M_Buyer__c> fetchDataList(Integer offsetNum, Integer limitNum){
        return [
                SELECT 
                    Id , 
                    Name,
                    BuyerAddress__c,
                    CountryCode__r.Name,
                    ISOCountryCode_Alphabet3__r.Name
                FROM M_Buyer__c
                WITH SECURITY_ENFORCED
                LIMIT :limitNum
                OFFSET :((offsetNum - 1) * limitNum)
            ];
    }

    @AuraEnabled(cacheable = true)
    public static Integer countRecordOfList(){
        Integer numberDatas = 0;
        if (M_Buyer__c.SObjectType.getDescribe().isAccessible()){
        numberDatas = [SELECT COUNT() FROM M_Buyer__c];
        }
        return numberDatas;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> deleteRecordInList(List<String> lstRecordId) {
        List <String> errorMsg = new List < String > ();
        if (M_Buyer__c.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.personal_info__c.fields.Id.isAccessible()){
            M_Buyer__c[] lstDeleteRec = [SELECT Id FROM M_Buyer__c WHERE Id IN: lstRecordId];
            system.debug(lstDeleteRec);
            Database.DeleteResult[] deleteResult = Database.delete(lstDeleteRec, false);
            for (Database.DeleteResult dr: deleteResult) {
                if (dr.isSuccess()) {
                    system.debug('Delete successful');
                } else {
                    errorMsg.add('');
                    for (Database.Error err: dr.getErrors()) {
                        errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        return errorMsg;
    }
    
    @AuraEnabled
    public static string editRecordsInList(Object data) {
        string mess;
        List<M_Buyer__c> dataForUpdate = new List<M_Buyer__c>();
        List<Object> datas = (List<Object>) data;
        for (Object dataObj : datas) {
            M_Buyer__c buyerObj = gennerateUpdateBuyerObject(dataObj);
            if (buyerObj != null) {
                dataForUpdate.add(buyerObj);
            }
        }
        system.debug(dataForUpdate);
        try {
            if (M_Buyer__c.SObjectType.getDescribe().isUpdateable()) {
                update dataForUpdate;
                mess = 'Success: contacts updated successfully';
            }
        }
        catch (Exception e) {
            mess = 'The following exception has occurred: ' + e.getMessage();
        }
    return mess;
    }

    private static M_Buyer__c gennerateUpdateBuyerObject(Object data) {
        try {
            M_Buyer__c buyer = new M_Buyer__c();
            LpqBuyerDataEdit dataObj = (LpqBuyerDataEdit) JSON.deserialize(
                JSON.serialize(data)
                    .replace('"Id":', '"id":')
                    .replace('"BuyerCode":', '"buyerCode":')
                    .replace('"BuyerAddress":', '"buyerAddress":') 
                    .replace('"CountryCode":', '"countryCode":'),
                LpqBuyerDataEdit.class
            );
            buyer.Id = Id.valueOf(dataObj.Id);
            if (dataObj.buyerCode != null) {
                buyer.Name = dataObj.BuyerCode;
            }
            if (dataObj.buyerAddress != null) {
                buyer.BuyerAddress__c = dataObj.BuyerAddress;
            }
            if (dataObj.countryCode != null) {
                if (M_Country__c.SObjectType.getDescribe().isAccessible()) {
                    List<M_Country__c> countryTargetLst = [
                        SELECT 
                            Id, 
                            ISOCounteyCode_Alphabet3__c
                        FROM M_Country__c
                        WHERE Name = :(dataObj.countryCode) LIMIT 1
                    ];
                    if (countryTargetLst.size() > 0) {
                        buyer.CountryCode__c = countryTargetLst.get(0).Id;
                        buyer.ISOCountryCode_Alphabet3__c = countryTargetLst.get(0).ISOCounteyCode_Alphabet3__c;
                    } else {
                        return null;
                    }
                } else {
                    return null;
                }
            }
            return buyer;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static LpqImportResult importFromExcel(Object data, Integer startIndex){
        LpqImportResult result = new LpqImportResult();
        result.success = true;
        result.indexsErrorRecord = new List<Integer>();
        List<List<String>> listData = new List<List<String>>();
        listData = (List<List<String>>) JSON.deserialize(JSON.serialize(data), List<List<String>>.class);
        List<M_Buyer__c> listBuyerImport = convertListDataImportToListBuyer(listData);
        if (M_Buyer__c.SObjectType.getDescribe().isCreateable()) {
            Database.SaveResult[] sr = Database.insert(listBuyerImport, false);
            for (Integer i = 0; i < sr.size(); i++) {
                if (!sr.get(i).isSuccess()) {
                    result.success = false;
                    result.indexsErrorRecord.add(i + startIndex);
                }
            }
        }
        Integer i1 = 1;
        return result;
    }

    /**
     * convert list data import to list SObject
     */
    private static List<M_Buyer__c> convertListDataImportToListBuyer(List<List<String>> listData) {
        List<M_Buyer__c> listBuyer = new List<M_Buyer__c>();
        Map<String,Id> mapOfCompany = LpqBuyerHelpers.getMapOfCompanys();
        // data: ["buyer", "address", "buyer code", "country code", "order company code"]
        for (List<String> data : listData) {
            M_Buyer__c newBuyer = convertDataRecordToBuyer(data, mapOfCompany);
            if (newBuyer != null) {
                listBuyer.add(newBuyer);
            }
        }
        return listBuyer;
    }

    private static Map<String,Id> getMapOfCompanys () {
        Map<String, Id> mapOfCompany = new Map<String,Id>();
        List<M_OrderCompany__c> listCompany = new List<M_OrderCompany__c>();
        if (M_OrderCompany__c.SObjectType.getDescribe().isAccessible()) {
            listCompany = [SELECT Name,Id FROM M_OrderCompany__c];
            for (M_OrderCompany__c company : listCompany) {
                mapOfCompany.put(company.Name, company.Id);
            }
        }
        return mapOfCompany;
    }

    private static M_Buyer__c convertDataRecordToBuyer (List<String> data, Map<String,Id> mapOfCompany) {
        if (data.size() < 5) {
            return null;
        } 
        M_Buyer__c buyer = new M_Buyer__c();
        if (data.get(0) != null) {
            buyer.Buyer__c = data.get(0);
        }
        if (data.get(1) != null) {
            buyer.BuyerAddress__c = data.get(1);
        }
        buyer.Name = data.get(2);
        if (data.get(3) != null) {
            buyer = LpqBuyerHelpers.assignContryAttribute(buyer, data.get(3));
        } else if (data.get(3) != null && !LpqBuyerHelpers.mapOfCountrys.containsKey(data.get(3))){
            return null;
        }
        if (data.get(4) != null && mapOfCompany.containsKey(data.get(4))) {
            buyer.OrderCompanyCode__c = mapOfCompany.get(data.get(4));
        } else if (data.get(4) != null && !mapOfCompany.containsKey(data.get(4))) {
            return null;
        }
        return buyer;
    }

    private static M_Buyer__c assignContryAttribute(M_Buyer__c buyer, String countryCode) {
        List<String> listId = LpqBuyerHelpers.mapOfCountrys.get(countryCode);
        buyer.CountryCode__c = Id.valueOf(listId.get(0));
        if (listId.size() > 1) {
            buyer.ISOCountryCode_Alphabet3__c = Id.valueOf(listId.get(1));
        }
        return buyer;
    }
}