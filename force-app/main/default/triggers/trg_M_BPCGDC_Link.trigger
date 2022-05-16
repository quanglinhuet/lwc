trigger trg_M_BPCGDC_Link on M_BPCGDC_Link__c (before insert,before update) {
    cntl_Dup_BPCGDC_Link DuplicateChecker = new cntl_Dup_BPCGDC_Link();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}