# Azure Storage
The queries below allow you to query various diagnostic and metric data for Azure Storage.

Optimal rendering options are also included below each query.

## Table of Contents
1. [List Last Regeneration of Account Keys](#list-last-regeneration-of-account-keys)
___
### List Last Regeneration of Account Keys
List the last attempt and status of changing account keys (within the past 3 days) for the storage accounts.

```
AzureActivity
| where OperationName == "Regenerate Storage Account Keys" and ActivityStatus != "Started"
| where TimeGenerated > ago(3d)
| summarize any(TimeGenerated) by Resource, ActivityStatus
| project-rename DateTimeStamp = any_TimeGenerated, Resource, ActivityStatus
```

<span style="font-size:.85em;font-weight:bold;color:white;background:slateblue;padding:5px">#table</span>

