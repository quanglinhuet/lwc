trigger trg_M_OrderDeadline on M_OrderDeadline__c (before insert,before update,after update) {
    //重複
    cntl_Dup_OrderDeadline DuplicateChecker = new cntl_Dup_OrderDeadline();
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