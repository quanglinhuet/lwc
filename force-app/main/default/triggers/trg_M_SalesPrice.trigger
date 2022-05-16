/*
//**************************************************************************
// プログラムID : trg_M_SalesPrice
// プログラム名 : 販売価格トリガ処理
// 処理形態　　 : Apex Trigger
// 処理概要　　 : 販売価格オブジェクトのトリガ処理
// 作成日　　　 : 2021/10/11
// 作成者　　　 : SBS 中澤
//**************************************************************************
*/
trigger trg_M_SalesPrice on M_SalesPrice__c ( before insert , before update ,after insert , after update ) {

    cntl_trg_M_SalesPrice handler = new cntl_trg_M_SalesPrice();
    //重複チェッククラス
    cntl_Dup_SalesPrice DuplicateChecker = new cntl_Dup_SalesPrice();
    //履歴
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
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