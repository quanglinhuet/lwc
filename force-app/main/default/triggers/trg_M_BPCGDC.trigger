/*
//**************************************************************************
//  プログラムID ： trg_M_BPCGDC
//  プログラム名 ： BPC+GDCトリガ
//  処理形態     ： Apex Trigger
//  処理概要     ： BPC+GDCトリガ処理
//  作成日       ： 2021/09/10
//  作成者       ： SBS杉本
//**************************************************************************
*/
trigger trg_M_BPCGDC on M_BPCGDC__c (before insert ,before update ,after insert,after update) {
    cntl_trg_M_BPCGDC handler = new cntl_trg_M_BPCGDC();
    //重複チェックトリガ
    cntl_Dup_BPCGDC DuplicateChecker = new cntl_Dup_BPCGDC();
    //履歴トリガ
    cntl_createHistories Historycreater = new cntl_createHistories();
    
    if(Trigger.isBefore){
/** Debug for ST */
for(M_BPCGDC__c bpc : Trigger.new) {
    System.debug('----- Name : ' + bpc.Name);
    System.debug('----- RepresentativeProductFactory__c : ' + bpc.RepresentativeProductFactory__c);
  System.debug('----- MaxInflationPressure_kPa_forDualUse__c : ' + bpc.MaxInflationPressure_kPa_forDualUse__c);
  System.debug('----- MaxInflationPressure_PSI_forDualUse__c : ' + bpc.MaxInflationPressure_PSI_forDualUse__c);
  System.debug('----- MaxLoadLBS_for_DualUse__c : ' + bpc.MaxLoadLBS_for_DualUse__c);
  System.debug('----- MaxLoadLBS_for_DualUse__c : ' + bpc.MaxLoadLBS_for_DualUse__c);
  System.debug('----- MaxInflationPressure_kPa__c : ' + bpc.MaxInflationPressure_kPa__c);
  System.debug('----- MaxInflationPressure_PSI__c : ' + bpc.MaxInflationPressure_PSI__c);
  System.debug('----- MaxLoad_kg__c : ' + bpc.MaxLoad_kg__c);
  System.debug('----- MaxLoad_LBS__c : ' + bpc.MaxLoad_LBS__c);
  System.debug('----- Indicator1__c : ' + bpc.Indicator1__c);
  System.debug('----- Indicator2__c : ' + bpc.Indicator2__c);
  System.debug('----- Indicator3__c : ' + bpc.Indicator3__c);
  System.debug('----- Indicator4__c : ' + bpc.Indicator4__c);

}
/** Debug for ST */
        if(Trigger.isInsert){
            handler.onBeforeInsertProcess(Trigger.new);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            handler.onBeforeUpdateProcess(Trigger.new, Trigger.old);
            //重複チェック
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            handler.onAfterInsertProcess(Trigger.new);
        }
        if(Trigger.isUpdate){
            //履歴
            Historycreater.Create_ChangeHisroty(Trigger.New, Trigger.Old);
        }
        
    }
    // エラー通知
    if( handler.lst_error.size() > 0 ){
        List<String> lst_to = new List<String>();
        for( String str_to : System.label.Ml_to_TriggerError.split(',') ) {
            lst_to.add(str_to.trim());
        }
        List<String> lst_cc = new List<String>();
        for( String str_cc : System.label.Ml_cc_TriggerError.split(',') ) {
            lst_cc.add(str_cc.trim());
        }
        
        Common.sendErrorMail(handler.lst_error, lst_to, lst_cc, 'trg_M_BPCGDC');
    }
}