public without sharing class ErrorEventLogService {

    @InvocableVariable public String source;
    @InvocableVariable public String objectName;
    @InvocableVariable public String operation;
    @InvocableVariable public String className;
    @InvocableVariable public String methodName;
    @InvocableVariable public String type;
    @InvocableVariable public String errorMessage;
    @InvocableVariable public String stackTrace;
    @InvocableVariable public String ownerId;
    @InvocableVariable public String recordID;
    @InvocableVariable public boolean throwError;
    @InvocableVariable public string displayError;
    
    public class MyException extends Exception {}

    @InvocableMethod(label='Flow Exception')
    public static void flowException(list<ErrorEventLogService> logs) {

        for (ErrorEventLogService log : logs) {
            System.debug(log);
            publishEvent(log.source, log.operation, log.errorMessage, log.stackTrace, log.objectName, log.className, log.methodName, log.recordId, log.type, '');
        }
        if(logs[0].throwError){
            throw new MyException(logs[0].displayError);
        }
    }

    public static void apexException(Exception ex, string objectName, string className, string methodName, string recordId) {   
        publishEvent('Apex', ex.getTypeName(), ex.getmessage(), ex.getStackTraceString(), objectName, className, methodName, recordId, 'Error');
    }

    public static void javascriptException(String errorMessage, String objectName, String className, String methodName, String recordId) {   
        publishEvent('JavaScript', '', errorMessage, '', objectName, className, methodName, recordId, 'Error', '');
    }

    public static void apexDatabaseError(Database.Error ex, string objectName, string className, string methodName, string recordId) {   
        publishEvent('Apex', String.ValueOf(ex.getStatusCode()), ex.getMessage(), '', objectName, className, methodName, recordId, 'Error', '');
    }

    public static void apexExceptionAPI(Exception ex, string objectName, string className, string methodName, string recordId, Map<String,String> params, String StringParams) {   
        String paramString = '';
        if (Stringparams != null && Stringparams != '') {
            paramString = Stringparams;
        }else{
            for (String key : params.keySet()){
                paramString = paramString == '' ? paramString + '?' : paramString + '&';
                paramString += key + '=' + params.get(key);
            }
        }    
        publishEvent('Apex', ex.getTypeName(), ex.getMessage(), ex.getStackTraceString(), objectName, className, methodName, recordId, 'Error', paramString);
    }

    public static void apexDebug(string title, string message, string objectName, string className, string methodName, string recordId) {   
        publishEvent('Apex', null, title, message, objectName, className, methodName, recordId, 'Debug');
    }

    public static void publishEvent(string source, string operation, string errorMessage, string stackTrace, string objectName, string className, string methodName, string recordId, string type) {
        
        //Governer Limit of executingQuery 
        String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
        String DMLimit = '2. Records queried so far / Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
        String DMLStat = '3. DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();
        String CPUT = '4. CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        
        
        Event_Log__e log = new Event_Log__e();
        log.Source__c = source;
        log.Object__c = objectName;
        log.Operation__c = operation;
        log.Class__c = className;
        log.Method__c = methodName;
        log.Type__c = type;
        log.Error_Message__c = errorMessage;
        log.Stack_Trace__c = stackTrace;
        //log.OwnerId = UserInfo.getUserId();
        log.Record_ID__c = recordId;
        log.Governor_Limits__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit,DMLStat,CPUT});
        log.API_Parameters__c = params;
        
        Database.SaveResult result = EventBus.publish(log);

        if (result.isSuccess()) {
            System.debug(type + ' event published successfully');
        } else {
            // Handle event publishing errors
            for (Database.Error error : result.getErrors()) {
                System.debug(type + ' publishing event: ' + error.getMessage());
            }
        }
    }
    
    
    public static void writeLog(list<Event_Log__e> events) {

        list<Error_Event_Log__c> logs = new list<Error_Event_Log__c>();

        for(Event_Log__e event : events){
            Error_Event_Log__c log = new Error_Event_Log__c();
            log.Source__c = event.Source__c;
            log.Object__c = event.Object__c;
            log.Operation__c = event.Operation__c;
            log.Class__c = event.Class__c;
            log.Method__c = event.Method__c;
            log.Type__c = event.Type__c;
            log.Error_Message__c = event.Error_Message__c;
            log.Stack_Trace__c = event.Stack_Trace__c;
            log.OwnerId = event.createdbyId;
            log.Record_ID__c = event.Record_ID__c;
            log.Governor_Limits__c = event.Governor_Limits__c;
            log.API_Parameters__c = event.API_Parameters__c;
            logs.add(log);
        }
        try{
            insert logs;
        }catch(Exception ex){
            system.debug('Error in writing log: ' + ex.getMessage());
        }
    }
}
