trigger trg_M_CodeLinkRequestStatus on M_CodeLinkRequestStatus__c (before insert,before update,after update) {
    cntl_Dup_CodeLinkRequestStatus DuplicateChecker = new cntl_Dup_CodeLinkRequestStatus();
    cntl_createHistories Historycreater = new cntl_createHistories();
    
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
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }

}