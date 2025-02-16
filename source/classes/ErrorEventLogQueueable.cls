public with sharing class ErrorEventLogQueueable implements Queueable, Database.AllowsCallouts {
    
    private Map<Id, Error_Event_Log__c> errorEventLogMap = new Map<Id, Error_Event_Log__c>();

    public ErrorEventLogQueueable(Map<Id, Error_Event_Log__c> errorEventLogMap){
        this.errorEventLogMap = errorEventLogMap;
    }

    public void execute(QueueableContext context) {
        if(!errorEventLogMap.isEmpty()){
            handleErrorEventLogs(errorEventLogMap);
        }
    }

    private static void handleErrorEventLogs(Map<Id, Error_Event_Log__c> errorEventLogMap) {
        try {        
            // Get the first Error_Event_Log__c record from the map
            String errorEventLogId = errorEventLogMap.keySet().iterator().next();
            Error_Event_Log__c errorEventLogRecord = errorEventLogMap.get(errorEventLogId);
            
            // Perform the HTTP callout
            HttpResponse response = executeDeepseekCallout(errorEventLogRecord);
            
            if (response.getStatusCode() == 200) {
                // Handle the success response
                System.debug('Success Response: ' + response);
                Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                // Extract the "choices" array
                List<Object> choices = (List<Object>) res.get('choices');
                if (choices.isEmpty()) {
                    throw new CalloutException('No response from DeepSeek');
                }

                // Extract the first choice's "message" content
                Map<String, Object> firstChoice = (Map<String, Object>) choices[0];
                Map<String, Object> message = (Map<String, Object>) firstChoice.get('message');
                String generatedText = (String) message.get('content');
                errorEventLogRecord.Error_Fix__c = generatedText;
                update errorEventLogRecord;
            } else {
                // Handle the error response
                System.debug('Error Response: ' + response);
            }
            
            // Remove the processed Error_Event_Log__c record from the map
            errorEventLogMap.remove(errorEventLogId);
            
            // If there are remaining Error_Event_Log__c records in the map, enqueue the queueable class again
            if (!errorEventLogMap.isEmpty()) {
                System.enqueueJob(new ErrorEventLogQueueable(errorEventLogMap));
            }
        } catch (Exception e) {
            ErrorEventLogService.apexException(e, 'Error_Event_Log__c', 'ErrorEventLogQueueable', 'handleErrorEventLogs', null);       
        }
    }

    private static HttpResponse executeDeepseekCallout(Error_Event_Log__c errorEventLogRecord) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Deepseek/chat/completions');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        // Construct the request body compatible with DeepSeek's OpenAI-style API
        Map<String, Object> requestBody = new Map<String, Object>{
            'model' => 'deepseek-chat',
            'messages' => new List<Map<String, String>>{
                new Map<String, String>{ 'role' => 'user', 'content' => errorEventLogRecord.Error_Message__c + '\n' + System.Label.Deepseek_Apex_Error_Instruction }
            },
            'stream' => false
        };
        request.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }
}