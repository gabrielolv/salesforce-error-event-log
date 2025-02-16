public with sharing class ErrorEventLogBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    private Map<Id, Error_Event_Log__c> errorEventLogMap = new Map<Id, Error_Event_Log__c>();

    public ErrorEventLogBatch(Map<Id, Error_Event_Log__c> contactsMap){
        this.errorEventLogMap = contactsMap;
    }

    public System.Iterable<sObject> start(Database.BatchableContext BC){
        return errorEventLogMap.values();
    }

    public void execute(Database.BatchableContext BC, List<Error_Event_Log__c> contacts){
        System.enqueueJob(new ErrorEventLogQueueable(errorEventLogMap));
    }

    public void finish(Database.BatchableContext BC){}
}