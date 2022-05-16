trigger trg_M_GSOSASOCertification on M_GSOSASOCertification__c (before insert,before update, after insert,after update) {
    cntl_Dup_GSOSASOCertification DuplicateChecker = new cntl_Dup_GSOSASOCertification();
    cntl_createHistories Historycreater = new cntl_createHistories();
    cntl_trg_M_GSOSASOCertification handler = new cntl_trg_M_GSOSASOCertification();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.onBeforeInsertProcess(Trigger.New);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.New, Trigger.oldMap);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    
    if(Trigger.isAfter){
        if( Trigger.isInsert ) {
            handler.onAfterInsertProcess(Trigger.New);
        }
        if(Trigger.isUpdate){
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }

}