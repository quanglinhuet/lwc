trigger trg_M_MemoSettingConditionProdWeek on M_MemoSettingConditionProdWeek__c (before insert,before update) {
    cntl_Dup_MemoSettingConditionProdWeek DuplicateChecker = new cntl_Dup_MemoSettingConditionProdWeek();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}