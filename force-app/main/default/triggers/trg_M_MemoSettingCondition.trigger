trigger trg_M_MemoSettingCondition on M_MemoSettingCondition__c (before insert,before update,after update) {
    cntl_Dup_MemoSettingCondition DuplicateChecker = new cntl_Dup_MemoSettingCondition();
    cntl_createHistories createHistories = new cntl_createHistories();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            createHistories.Create_ChangeHisroty(Trigger.new, Trigger.Old);
        }
    }

}