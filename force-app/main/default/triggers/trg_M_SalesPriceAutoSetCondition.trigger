trigger trg_M_SalesPriceAutoSetCondition on M_SalesPriceAutoSetCondition__c (before insert, before update) {
    cntl_trg_M_SalesPriceAutoSetCondition handler = new cntl_trg_M_SalesPriceAutoSetCondition();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.onBeforeInsertProcess(Trigger.new);
        }
        if(Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
        }
    }
}