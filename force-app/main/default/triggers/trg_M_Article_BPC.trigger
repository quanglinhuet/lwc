/*
//**************************************************************************
//  プログラムID ： Trigger_M_Article_BPC
//  プログラム名 ： Article-BPC トリガー
//  処理形態     ： Apex Trigger
//  処理概要     ： Article-BPC トリガー処理
//  作成日       ： 2021/09/15
//  作成者       ： SBS杉本
//***************************************************************************
*/
trigger trg_M_Article_BPC on M_Article_BPC__c (before insert ,before update ,after insert) {
    cntl_trg_M_Article_BPC handler = new cntl_trg_M_Article_BPC();
    //重複チェッククラス
    cntl_Dup_Article_BPC DuplicateChecker = new cntl_Dup_Article_BPC();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.onAfterInsertProcess(Trigger.new);
        }
    }
}