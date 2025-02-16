public with sharing class ErrorEventLogTriggerHelper {
    
    public static void getFix(Map<Id, Error_Event_Log__c> errorLogList) {
        Map<Id, Error_Event_Log__c> errorEventLogMap = new Map<Id, Error_Event_Log__c>();
        for(Error_Event_Log__c errorLog : errorLogList.values()){
            if(errorLog.Object__c != 'Error_Event_Log__c' && errorLog.Type__c == 'Error'){
                errorEventLogMap.put(errorLog.Id, errorLog);
            }
        }
        if(!errorEventLogMap.isEmpty()){
            ErrorEventLogBatch errorBatch = new ErrorEventLogBatch(errorEventLogMap);
            Database.executeBatch(errorBatch, 200);
        }
    }
    
}