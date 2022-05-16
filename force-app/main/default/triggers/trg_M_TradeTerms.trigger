/*
//**************************************************************************
//  プログラムID ： trg_M_TradeTerms
//  プログラム名 ： Trade Terms トリガ
//  処理形態     ： Apex Trigger
//  処理概要     ： Trade Terms トリガ処理
//  作成日       ： 2021/10/18
//  作成者       ： SBS中川
//**************************************************************************
*/
trigger trg_M_TradeTerms on M_TradeTerms__c (before insert, before update , after update) {
    cntl_trg_M_TradeTerms handler = new cntl_trg_M_TradeTerms();
    //履歴
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if( Trigger.isBefore ){
        if( Trigger.isInsert ) {
            handler.onBeforeInsertProcess(Trigger.new);
        }
        if( Trigger.isUpdate ){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
        }
    // } else if( Trigger.isAfter ) {
    //     if( Trigger.isInsert) {
    //         handler.onAfterInsertProcess(Trigger.new);
    //     }
    //     if( Trigger.isUpdate ) {
    //         handler.onAfterUpdateProcess(Trigger.new);
    //     }

    }
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }
}