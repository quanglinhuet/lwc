/*
//**************************************************************************
//  プログラムID ： trg_M_CostandVolume
//  プログラム名 ： M_CostandVolume__c トリガー
//  処理形態     ： Apex Trigger
//  処理概要     ： M_CostandVolume__c　トリガー処理
//  作成日       ： 2021/10/12
//  作成者       ： SBS草野
//***************************************************************************
*/
trigger trg_M_CostandVolume on M_CostandVolume__c (before insert, before update, after insert, after update) {
    cntl_trg_M_CostandVolume handler = new cntl_trg_M_CostandVolume();
    //重複チェッククラス
    cntl_Dup_CostandVolume DuplicateChecker = new cntl_Dup_CostandVolume();
    //履歴
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if(Trigger.isBefore){        
        if(Trigger.isInsert){
            handler.OnBeforeInsertProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.OnBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    if(Trigger.isAfter){
        if( Trigger.isInsert ) {
            handler.onAfterInsertProcess(Trigger.new);
        }
        //履歴
        if(Trigger.isupdate){
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }
}