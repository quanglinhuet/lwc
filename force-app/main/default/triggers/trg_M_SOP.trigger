trigger trg_M_SOP on M_SOP__c (before insert,before update,after update) {
    cntl_Dup_SOP DuplicateChecker = new cntl_Dup_SOP();
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