trigger trg_M_Generic on M_Generic__c (before insert,before update) {
    cntl_Dup_Generic DuplicateChecker = new cntl_Dup_Generic();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}