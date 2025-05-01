The Salesforce Error Event Log is a scalable and asynchronous error logging framework designed for Salesforce environments. Leveraging Platform Events, it captures and records error and event logs, enabling efficient monitoring and debugging of Apex code. This solution facilitates real-time error tracking and supports integration with external monitoring systems, enhancing the observability of your Salesforce applications. 

## 📌 Key Features

- Centralized error handling via Platform Events  
- Compatible with **Salesforce Flows** through `@InvocableMethod`  
- Supports logging for:
  - Apex exceptions
  - JavaScript errors
  - Database errors
  - Custom debug messages
- Option to throw exceptions dynamically
- Works **without sharing** to ensure unrestricted logging

---

## 🔍 Class Overview

### `ErrorEventLogService` (Apex Class)

- **Scope**: `without sharing` (bypasses record-level sharing)
- **Usage**: Can be called from Flows, Apex Triggers, or Classes

### Variables
| Field | Description |
|-------|-------------|
| `source` | Origin of the error (e.g. Flow, Apex Class) |
| `objectName` | Salesforce object involved |
| `operation` | Type of operation (e.g. Create, Update) |
| `className`, `methodName` | Where the error occurred |
| `type` | Type of exception or message |
| `errorMessage`, `stackTrace` | Error details |
| `ownerId`, `recordId` | Contextual record data |
| `throwError` | Boolean flag to raise exception |
| `displayError` | Custom message for exception display |

### Internal Class

- `MyException`: Custom exception for controlled error throwing

---

## ⚙️ Methods

### `@InvocableMethod flowException(List<ErrorEventLogService>)`
Logs error details from Salesforce Flow context. If `throwError = true`, throws a custom exception using `displayError`.

---

### `apexException(Exception ex, ...)`
Captures Apex exception details and publishes them as a platform event.

### `javascriptException(...)`
Used to log client-side JavaScript errors in Salesforce via server-side callouts.

### `apexExceptionAPI(Exception ex, ..., Map<String, Object> params)`
Advanced version of `apexException` that accepts custom parameter maps for deeper context.

### `apexDatabaseError(Database.Error err, ...)`
Logs errors thrown from DML operations or database save results.

### `apexDebug(title, message, ...)`
Simple debug logger to record arbitrary internal messages.

### `publishEvent(...)`
Core method that publishes `Event_Log__e` platform events with full error context.

---

## 🧪 Example Use Case

```apex
try {
    // risky operation
} catch (Exception e) {
    ErrorEventLogService.apexException(
        e,
        'Opportunity',
        'MyTriggerHandler',
        'handleInsert',
        myOpportunity.Id
    );
}


