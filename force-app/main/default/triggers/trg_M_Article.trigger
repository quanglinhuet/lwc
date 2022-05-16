trigger trg_M_Article on M_Article__c (before insert,before update) {
    cntl_Dup_Article DuplicateChecker = new cntl_Dup_Article();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}