trigger trg_M_Exception_Source on M_Source_Exception__c (before insert,before update) {
    cntl_Dup_Exception_Source DuplicateChecker = new cntl_Dup_Exception_Source();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}