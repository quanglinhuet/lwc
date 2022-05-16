/*
//**************************************************************************
//  プログラムID ： trg_M_CodeLink
//  プログラム名 ： Code Linkトリガ
//  処理形態     ： Apex Trigger
//  処理概要     ： Code Linkトリガ処理
//  作成日       ： 2021/11/05
//  作成者       ： SBS斎藤
//**************************************************************************
*/
trigger trg_M_CodeLink on M_CodeLink__c (before insert, before update, after insert, after update, before delete) {
    cntl_trg_M_CodeLink handler = new cntl_trg_M_CodeLink();
    //重複チェッククラス
    cntl_Dup_CodeLink DuplicateChecker = new cntl_Dup_CodeLink();
    
    if( Trigger.isBefore ){
        if( Trigger.isInsert ) {
            handler.onBeforeInsertProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if( Trigger.isUpdate ){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.oldMap);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if( Trigger.isDelete ) {
            handler.onBeforeDeleteProcess(Trigger.old);
        }
    } else if( Trigger.isAfter ) {
        if( Trigger.isInsert) {
            handler.onAfterInsertProcess(Trigger.new);
        }
        if( Trigger.isUpdate ) {
            handler.onAfterUpdateProcess(Trigger.new);
        }
    }
}