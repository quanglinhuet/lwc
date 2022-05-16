trigger trg_M_CP on M_CP__c (before insert,before update,after update) {
    cntl_Dup_CP DuplicateChecker = new cntl_Dup_CP();
    cntl_createHistories Historycreater = new cntl_createHistories();
    cntl_trg_M_CP handler = new cntl_trg_M_CP();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
            handler.onBeforeInsertProcess(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
            handler.onBeforeUpdateProcess(Trigger.New, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }

}