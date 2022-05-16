trigger trg_M_SCS_PLCategory on M_SCS_PLCategory__c (before insert,before update, after insert) {
    cntl_Dup_SCS_PLCategory DuplicateChecker = new cntl_Dup_SCS_PLCategory();
    cntl_trg_M_SCS_PLCategory handler = new cntl_trg_M_SCS_PLCategory();
        
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.onBeforeInsertProcess(Trigger.new);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    } else if( Trigger.isAfter ) {
        if( Trigger.isInsert ) {
            handler.onAfterInsertProcess(Trigger.new);
        }
    }
}