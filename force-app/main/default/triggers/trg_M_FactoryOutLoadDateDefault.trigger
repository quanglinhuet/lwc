trigger trg_M_FactoryOutLoadDateDefault on M_FactoryOutLoadDateDefault__c (before insert,before update) {
    cntl_Dup_FactoryOutLoadDateDefault DuplicateChecker = new cntl_Dup_FactoryOutLoadDateDefault();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(Trigger.isUpdate){
            DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }

}