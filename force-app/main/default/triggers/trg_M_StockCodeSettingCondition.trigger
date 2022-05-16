trigger trg_M_StockCodeSettingCondition on M_StockCodeSettingCondition__c (before insert,before update) {
    cntl_Dup_StockCodeSettingCondition DuplicateChecker = new cntl_Dup_StockCodeSettingCondition();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}