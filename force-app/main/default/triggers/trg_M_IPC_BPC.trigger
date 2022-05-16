/*
//**************************************************************************
//  プログラムID ： Trigger_M_IPC_BPC
//  プログラム名 ： IPC-BPC トリガー
//  処理形態     ： Apex Trigger
//  処理概要     ： IPC-BPC トリガー処理
//  作成日       ： 2021/09/14
//  作成者       ： SBS杉本
//***************************************************************************
*/
trigger trg_M_IPC_BPC on M_IPC_BPC__c ( before insert, before update, after insert,after update) {
    cntl_trg_M_IPC_BPC handler = new cntl_trg_M_IPC_BPC();
    //重複チェッククラス
    cntl_Dup_IPC_BPC DuplicateChecker = new cntl_Dup_IPC_BPC();

    if( Trigger.isBefore ) {
        if( Trigger.isInsert ) {
            handler.onBeforeInsertProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
            
        }
        if( Trigger.isUpdate ) {
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
            
        }
    } 
    if( Trigger.isAfter ) {
        if(Trigger.isInsert){
            handler.onAfterInsertProcess(Trigger.new);
        }
    }
}