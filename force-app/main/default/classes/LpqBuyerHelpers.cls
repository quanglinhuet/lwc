public with sharing class LpqBuyerHelpers {

    @AuraEnabled(cacheable = true)
    public static List<M_Buyer__c> fetchDataList(Integer offsetNum, Integer limitNum){
        return [
                SELECT 
                    Id , 
                    Name,
                    BuyerAddress__c,
                    CountryCode__r.Name,
                    ISOCountryCode_Alphabet3__r.Name,
                    PointTest__c
                FROM M_Buyer__c
                WITH SECURITY_ENFORCED
                LIMIT :limitNum
                OFFSET :((offsetNum - 1) * limitNum)
            ];
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
                    .replace('"CountryCode":', '"countryCode":')
                    .replace('"PointTest":', '"pointTest":'),
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
            if (dataObj.pointTest != null) {
                buyer.PointTest__c = dataObj.pointTest;
            }
            return buyer;
        } catch (Exception e) {
            return null;
        }
    }
}