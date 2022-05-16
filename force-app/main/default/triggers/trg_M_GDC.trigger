/*
//**************************************************************************
//  プログラムID ： trg_M_GDC
//  プログラム名 ： GDCトリガ
//  処理形態     ： Apex Trigger
//  処理概要     ： 無し
//  説明       　： 項目変更履歴デモ用
//  作成日       ： 2021/09/30
//  作成者       ： SBS光瀬
//**************************************************************************
*/
trigger trg_M_GDC on M_GDC__c (after update) {
    cntl_createHistories Historycreater = new cntl_createHistories();
    if(Trigger.isafter){
        if(Trigger.isupdate){
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
    }

}