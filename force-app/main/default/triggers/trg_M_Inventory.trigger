trigger trg_M_Inventory on M_Inventory__c (after insert, after update) {
    cntl_trg_M_Inventory handler = new cntl_trg_M_Inventory();
    if( Trigger.isAfter ){
        if( Trigger.isInsert ){
            handler.onAfterInsertProcess(Trigger.new);
        }
        if( Trigger.isUpdate ){
            handler.onAfterUpdateProcess(Trigger.new);
        }
    }
}