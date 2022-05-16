trigger trg_M_Buyer on M_Buyer__c (before insert,before update) {
    cntl_Dup_Buyer DuplicateChecker = new cntl_Dup_Buyer();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}