trigger ErrorEventLogTrigger on Error_Event_Log__c (after insert) {
    if(Run_Trigger__mdt.getInstance('ErrorEventLogTrigger')?.Active__c){
        new ErrorEventLogTriggerHandler().run();
    }
}