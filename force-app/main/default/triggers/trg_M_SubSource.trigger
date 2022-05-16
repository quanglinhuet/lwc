/**
//**************************************************************************
//  プログラムID ： trg_M_SubSource
//  プログラム名 ： Sub Source トリガ
//  処理形態     ： Apex Trigger
//  処理概要     ： Sub Source トリガ処理
//  作成日       ： 2021/11/05
//  作成者       ： SBS中川
//**************************************************************************
*/
trigger trg_M_SubSource on M_SubSource__c (before insert, before update) {
    cntl_trg_M_SubSource handler = new cntl_trg_M_SubSource();
    if( Trigger.isBefore ){
        if (Trigger.isInsert) {
            handler.onBeforeInsertProcess(Trigger.new);
        }
        if (Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
        }
    } else if( Trigger.isAfter ) {
        if (Trigger.isInsert) {
            //handler.onAfterInsertProcess(Trigger.new);
        }
        if (Trigger.isUpdate) {
            //handler.onAfterUpdateProcess(Trigger.new);
        }
    }
}