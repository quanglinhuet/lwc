/*
//**************************************************************************
// プログラムID : trg_M_PurchasePrice
// プログラム名 : 購入価格トリガ処理
// 処理形態　　 : Apex Trigger
// 処理概要　　 : 購入価格オブジェクトのトリガ処理
// 作成日　　　 : 2021/10/12
// 作成者　　　 : SBS 杉本
//**************************************************************************
*/
trigger trg_M_PurchasePrice on M_PurchasePrice__c (before insert, before update, after insert, after update) {
  
    cntl_trg_M_PurchasePrice handler = new cntl_trg_M_PurchasePrice();
    //重複チェッククラス
    cntl_Dup_PurchasePrice DuplicateChecker = new cntl_Dup_PurchasePrice();
    //履歴
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if( Trigger.isBefore ){
        if( Trigger.isInsert ){
            handler.onBeforeInsertProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if( Trigger.isUpdate ){
            handler.onBeforeUpdateProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    if( Trigger.isAfter ){
        if( Trigger.isInsert ){
            handler.onAfterInsertProcess(Trigger.newMap);
        }
        if( Trigger.isUpdate ){
            handler.onAfterUpdateProcess(Trigger.newMap);
            //履歴
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }
}