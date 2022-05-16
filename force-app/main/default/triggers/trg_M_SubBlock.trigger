trigger trg_M_SubBlock on M_SubBlock__c (before insert,before update) {
    cntl_Dup_SubBlock DuplicateChecker = new cntl_Dup_SubBlock();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}