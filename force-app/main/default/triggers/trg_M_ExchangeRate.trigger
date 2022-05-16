trigger trg_M_ExchangeRate on M_ExchangeRate__c (before insert,before update) {
    cntl_Dup_ExchangeRate DuplicateChecker = new cntl_Dup_ExchangeRate();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}