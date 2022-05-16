/*
//**************************************************************************
//  プログラムID ： Trigger_M_BPC_FromTo
//  プログラム名 ： M_BPC_FromTo__c トリガー
//  処理形態     ： Apex Trigger
//  処理概要     ： M_BPC_FromTo__c トリガー処理
//  作成日       ： 2021/09/15
//  作成者       ： SBS 草野
//***************************************************************************
*/
trigger trg_M_BPCFromTo on M_BPC_FromTo__c (before insert, after insert, before update) {
    cntl_trg_M_BPCFromTo handler = new cntl_trg_M_BPCFromTo();
     //重複チェッククラス
    cntl_Dup_BPC_FromTo DuplicateChecker = new cntl_Dup_BPC_FromTo();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            // handler.OnBeforeInsertProcess(Trigger.new);
         //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.OnAfterInsertProcess(Trigger.new);
        }
    }
}