trigger trg_M_SCS_GenTire_MarketSuitCheck_Result on M_SCS_GenTire_MarketSuitCheck_Result__c (before insert,before update) {
    cntl_Dup_SCS_GenTire_MarketSuitCheck DuplicateChecker = new cntl_Dup_SCS_GenTire_MarketSuitCheck();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}