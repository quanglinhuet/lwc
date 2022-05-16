trigger trg_M_Exception_SCS on M_SCS_Exception__c (before insert,before update) {
    cntl_Dup_Exception_SCS DuplicateChecker = new cntl_Dup_Exception_SCS();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}