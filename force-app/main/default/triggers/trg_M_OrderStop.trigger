trigger trg_M_OrderStop on M_OrderStop__c (before insert,before update) {
    cntl_Dup_OrderStop DuplicateChecker = new cntl_Dup_OrderStop();
    cntl_trg_M_OrderStop handler = new cntl_trg_M_OrderStop();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.onBeforeInsertProcess(Trigger.new);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}