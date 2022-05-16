trigger trg_M_SetOrderSplitTarget on M_SetOrderSplitTarget__c (before insert,before update) {
    cntl_Dup_SetOrderSplitTarget DuplicateChecker = new cntl_Dup_SetOrderSplitTarget();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}