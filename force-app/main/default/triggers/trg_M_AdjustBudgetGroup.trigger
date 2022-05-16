trigger trg_M_AdjustBudgetGroup on M_AdjustBudgetGroup__c (before insert,before update) {
    cntl_Dup_AdjustBudgetGroup DuplicateChecker = new cntl_Dup_AdjustBudgetGroup();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}