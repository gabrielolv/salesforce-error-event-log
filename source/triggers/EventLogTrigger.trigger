trigger EventLogTrigger on Event_Log__e (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        List<Event_Log__e> eventList = new List<Event_Log__e>();
        for(Event_Log__e event :Trigger.new){
            eventList.add(event);
        }
        if(!eventList.isEmpty()){
            ErrorEventLogService.writeLog(eventList);
        }       
    }
}