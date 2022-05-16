trigger trg_M_MC_MarketSuitCheck_Result on M_MC_MarketSuitCheck_Result__c (before insert,before update) {
    cntl_Dup_MC_MarketSuitCheck_Result DuplicateChecker = new cntl_Dup_MC_MarketSuitCheck_Result();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}