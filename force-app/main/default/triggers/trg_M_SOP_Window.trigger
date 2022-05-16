/*
//**************************************************************************
// プログラムID : trg_M_SOP_Window
// プログラム名 : SOP Windowトリガ処理
// 処理形態　　 : Apex Trigger
// 処理概要　　 : SOP Windowオブジェクトのトリガ処理
// 作成日　　　 : 2021/09/27
// 作成者　　　 : SBS 斎藤
//**************************************************************************
*/
trigger trg_M_SOP_Window on M_SOP_Window__c ( before insert, before update,after insert, after update ) {
    //before処理
    cntl_Dup_SOP_Window DuplicateChecker = new cntl_Dup_SOP_Window();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    
    //after処理
    cntl_trg_M_SOP_Window handler = new cntl_trg_M_SOP_Window();
    if( Trigger.isAfter ) {
        if( Trigger.isInsert ) {
            handler.onAfterInsertProccess(Trigger.new);
        }
        if( Trigger.isUpdate ) {
            handler.onAfterUpdateProccess(Trigger.new);
        }
    }
}