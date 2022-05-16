/*
//**************************************************************************
//  プログラムID ： trg_M_Dimension
//  プログラム名 ： Dimensionトリガ
//  処理形態     ： Apex Trigger
//  処理概要     ： Dimensionトリガ処理
//  作成日       ： 2022/03/07
//  作成者       ： SBS斎藤
//**************************************************************************
*/
trigger trg_M_Dimension on M_Dimension__c (before insert, before update, after insert, after update) {

    cntl_trg_M_Dimension handler = new cntl_trg_M_Dimension();

    if( Trigger.isBefore ) {
        if( Trigger.isInsert ) {
            handler.onBeforeInsertProcess(Trigger.new);
        } else if( Trigger.isUpdate ) {
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
        }

    } else if( Trigger.isAfter ) {
        if( Trigger.isInsert ) {
            handler.onAfterInsertProcess(Trigger.new);
        } else if( Trigger.isUpdate ) {
            handler.onAfterUpdateProcess(Trigger.new, Trigger.oldMap);
        }
    }
}