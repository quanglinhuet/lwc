trigger trg_M_MC_Label on M_MC_Label__c (before insert,before update,after update) {
    cntl_trg_M_MC_Label handler = new cntl_trg_M_MC_Label();
    //重複チェック
    cntl_Dup_MC_Label DuplicateChecker = new cntl_Dup_MC_Label();
    //履歴
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.onBeforeInsertProcess(Trigger.new);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.new);
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }
}