trigger trg_M_SCS_Exception on M_SCS_Exception__c (before insert, before update) {
	cntl_Dup_Exception_SCS DuplicateChecker = new cntl_Dup_Exception_SCS();
    if(Trigger.isbefore){
        if(trigger.isInsert){
           DuplicateChecker.DuplicateCheck(Trigger.New);
        }
        if(trigger.isUpdate){
           DuplicateChecker.DuplicateCheck(Trigger.New);
        }
    }
}