public with sharing class ErrorEventLogTriggerHandler extends TriggerHandler{
    
    private List<Error_Event_Log__c> listNewAcc;
    private List<Error_Event_Log__c> listOldAcc;
    private Map<Id, Error_Event_Log__c> mapNewAcc;
    private Map<Id, Error_Event_Log__c> mapOldAcc;

    public ErrorEventLogTriggerHandler() {
        this.listNewAcc	= (List<Error_Event_Log__c>) Trigger.new;
        this.listOldAcc	= Trigger.old != null ? (List<Error_Event_Log__c>) Trigger.old : new List<Error_Event_Log__c>();
        this.mapNewAcc	= (Map<Id, Error_Event_Log__c>) Trigger.newMap;
        this.mapOldAcc	= Trigger.oldMap != null ? (Map<Id, Error_Event_Log__c>) Trigger.oldMap : new Map<Id, Error_Event_Log__c>();
    }
    
    public override void beforeInsert(){}
    public override void beforeUpdate(){}
    public override void beforeDelete(){}
    public override void afterInsert(){
        ErrorEventLogTriggerHelper.getFix(this.mapNewAcc);
    }
    public override void afterUpdate(){}
    public override void afterDelete(){}
    public override void afterUndelete(){}
}