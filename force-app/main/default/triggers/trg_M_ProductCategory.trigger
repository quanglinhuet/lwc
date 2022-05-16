trigger trg_M_ProductCategory on M_ProductCategory__c (before insert,before update) {
    cntl_Dup_ProductCategory DuplicateChecker = new cntl_Dup_ProductCategory();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
}