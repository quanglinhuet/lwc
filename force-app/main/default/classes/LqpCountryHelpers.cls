public with sharing class LqpCountryHelpers {
    
    @AuraEnabled (cacheable = true)
    public static List<String> getAllCountry() {
        List<String> rs = new List<String>();
        if (M_Country__c.SObjectType.getDescribe().isAccessible()) {
            for (AggregateResult item : [SELECT Name FROM M_Country__c GROUP BY Name]) {
                rs.add(string.valueOf(item.get('Name')));
            }
        }
        return rs;
    }

    @AuraEnabled(cacheable = true)
    public static List<String> getAllISOCountry(){
        List<String> rs =  new List<String>();
        if (M_ISOCountry__c.SObjectType.getDescribe().isAccessible()) {
            for (AggregateResult item : [SELECT Name FROM M_ISOCountry__c GROUP BY Name]) {
                rs.add(string.valueOf(item.get('Name')));
            }
        }
        return rs;
    }

    @AuraEnabled(cacheable = true)
    public static String getISOCountryByCountryCode(String countryCode){
        try {
            if (M_Country__c.SObjectType.getDescribe().isAccessible()) {
                return [SELECT ISOCounteyCode_Alphabet3__r.Name FROM M_Country__c WHERE Name = :countryCode LIMIT 1].ISOCounteyCode_Alphabet3__r.Name;
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static List<M_Country__c> searhForCountry(String pattern){
        try {
            List<M_Country__c> listCountry = new List<M_Country__c>();
            if (M_Country__c.sObjectType.getDescribe().isAccessible()){
                String likePattern = '%' + pattern + '%';
                listCountry = [SELECT Name, Country__c FROM M_Country__c WHERE Name LIKE :likePattern];
            }
            return listCountry;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}