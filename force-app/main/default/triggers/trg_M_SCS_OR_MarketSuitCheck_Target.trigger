trigger trg_M_SCS_OR_MarketSuitCheck_Target on M_SCS_OR_MarketSuitCheck_Target__c (before insert,before update) {
    cntl_Dup_SCS_OR_MarketSuitCheck_Target DuplicateChecker = new cntl_Dup_SCS_OR_MarketSuitCheck_Target();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}