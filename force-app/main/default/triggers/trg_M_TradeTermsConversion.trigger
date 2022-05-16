trigger trg_M_TradeTermsConversion on M_TradeTermsConversion__c (before insert,before update,after update) {
    //重複
    cntl_Dup_TradeTermsConversion DuplicateChecker = new cntl_Dup_TradeTermsConversion();
    //履歴
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