trigger trg_M_SetCode on M_SetCode__c (before insert,before update, after insert) {
    cntl_Dup_SetCode DuplicateChecker = new cntl_Dup_SetCode();
    cntl_trg_M_SetCode handler = new cntl_trg_M_SetCode();
    
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
    if( Trigger.isAfter ) {
        if( Trigger.isInsert ) {
            handler.onAfterInsertProcess(Trigger.New);
        }
    }
}