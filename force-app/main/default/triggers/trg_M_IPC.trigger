/*
//**************************************************************************
// プログラムID : trg_M_IPC
// プログラム名 : IPCトリガ処理
// 処理形態　　 : Apex Trigger
// 処理概要　　 : IPCオブジェクトのトリガ処理
// 作成日　　　 : 2021/09/14
// 作成者　　　 : SBS 斎藤
//**************************************************************************
*/
trigger trg_M_IPC on M_IPC__c (before insert, before update,after update) {
    cntl_trg_M_IPC handler = new cntl_trg_M_IPC();
    //重複チェッククラス
    cntl_Dup_IPC DuplicateChecker = new cntl_Dup_IPC();
    
    if( Trigger.isBefore ){
        if( Trigger.isInsert ){
            handler.onBeforeInsertProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
            
        }
        if( Trigger.isUpdate ){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}