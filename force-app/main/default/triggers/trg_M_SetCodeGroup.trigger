/*
//**************************************************************************
//  プログラムID ： trg_M_SetCodeGroup
//  プログラム名 ： M_SetCodeGrouping__c トリガー
//  処理形態     ： Apex Trigger
//  処理概要     ： M_SetCodeGrouping__c　トリガー処理
//  作成日       ： 2021/10/12
//  作成者       ： SBS草野
//***************************************************************************
*/
trigger trg_M_SetCodeGroup on M_SetCodeGrouping__c (before insert, before update, after insert, after update) {
    cntl_trg_M_SetCodeGroup handler = new cntl_trg_M_SetCodeGroup();
    //重複チェッククラス
    cntl_Dup_SetCodeGrouping DuplicateChecker = new cntl_Dup_SetCodeGrouping();
    //履歴トリガ
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.OnBeforeInsertProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.OnBeforeUpdateProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        } 
    }
    if(Trigger.isAfter){   
        if(Trigger.isInsert){
            handler.OnAfterInsertProcess(Trigger.new);
        }
        if(Trigger.isUpdate){
            //履歴
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }
}