public with sharing class LpqSendMail {
    @AuraEnabled(cacheable = true)
    public static List<SObject> getData(Integer limitRecord){
        List<SObject> listData;
        listData = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,Field1__c, Field2__c, Field3__c, Field4__c, Field5__c, Field6__c, Field7__c, Field8__c, Field9__c, Field10__c, Field11__c, Field12__c, Field13__c, Field14__c, Field15__c, Field16__c, Field17__c, Field18__c, Field19__c, Field20__c FROM M_ObjectTest__c LIMIT :limitRecord];
        return listData;
    }

    public void sendXLSX(String excelFile) {
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        Messaging.EmailFileAttachment[] attachments = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        String attName = 'att' + DateTime.now()+ '.xlsx';
        attachment.setFileName(attName);
        attachment.setBody(EncodingUtil.base64Decode(excelFile));
        attachments.add(attachment);
    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String subject = 'Subject' + DateTime.now();
        mail.setSubject(subject);
        // Use userId to pass limit
        // mail.setTargetObjectId('0051s000002OUnrAAG');
        // mail.setSaveAsActivity(false);
        String[] toAddresses = new string[]{'linhpq.dev@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setPlainTextBody('This is Body');
        mail.setFileAttachments(attachments);
        mails.add(mail);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
}
