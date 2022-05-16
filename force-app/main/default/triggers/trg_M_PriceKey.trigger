trigger trg_M_PriceKey on M_PriceKey__c (after update) {
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }
}