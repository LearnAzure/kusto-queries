# Azure Storage
The queries below allow you to query various diagnostic and metric data for Azure Data Lake Gen1.

Optimal rendering options are also included below each query.

### Get the number of httpMethod calls against the data lake gen1 storage account

```sql
AzureDiagnostics
| where TimeGenerated >= ago(3d)
//use the following to get the number of httpMethod calls by identity over the specified time period
| summarize count(TimeGenerated) by identity_s, HttpMethod_s
```

{{ chart.table }}

### Get all the request events within a given timespan

```sql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DATALAKESTORE" and TimeGenerated >= ago(3d)
//request logs capture every API request made on the Data Lake Storage Gen1 account
| where Category == "Requests"
| project Resource, ResourceGroup, ResourceType, OperationName, ResultType, CorrelationId, HttpMethod_s, Path_s, identity_s, UserId_g, StoreEgressSize_d, StoreIngressSize_d, CallerIPAddress
```

### Get all the requests within a given timespan and break out the Path into different columns for analysis
```sql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DATALAKESTORE" and TimeGenerated >= ago(3d)
//request logs capture every API request made on the Data Lake Storage Gen1 account
| where Category == "Requests"
| project Resource, ResourceGroup, ResourceType, OperationName, ResultType, CorrelationId, HttpMethod_s, Path_s, identity_s, UserId_g, StoreEgressSize_d, StoreIngressSize_d, CallerIPAddress, StartTime_t, EndTime_t, RequestDuration = datetime_diff("Millisecond", EndTime_t, StartTime_t)
| extend Path = split(Path_s, '/')
| mv-expand root = Path[0], level1 = Path[1], level2 = Path[2], level3 = Path[3], level4 = Path[4], level5 = Path[5], level6 = Path[6], level7 = Path[7], level8 = Path[8], level9 = Path[9]
| extend likelyfileName = coalesce(level9, level8, level7, level6, level5, level4)
```

### Get the number of http method calls and their type against all the containers/folders within the account

```sql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DATALAKESTORE" and TimeGenerated >= ago(3d)
//request logs capture every API request made on the Data Lake Storage Gen1 account
| where Category == "Requests"
| project Resource, ResourceGroup, ResourceType, OperationName, ResultType, CorrelationId, HttpMethod_s, Path_s, identity_s, UserId_g, StoreEgressSize_d, StoreIngressSize_d, CallerIPAddress, StartTime_t, EndTime_t, RequestDuration = datetime_diff("Millisecond", EndTime_t, StartTime_t)
| extend Path = split(Path_s, '/')
| mv-expand root = Path[0], level1 = Path[1], level2 = Path[2], level3 = Path[3], level4 = Path[4], level5 = Path[5], level6 = Path[6], level7 = Path[7], level8 = Path[8], level9 = Path[9]
| summarize count() by tostring(level3), HttpMethod_s 
```

### Get the number of httpMethod calls by identity and the counts against the account

```sql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DATALAKESTORE" and TimeGenerated >= ago(3d)
| where Category == "Requests"
| project identity_s, CorrelationId, HttpMethod_s
| summarize count() by identity_s, HttpMethod_s
```

### Have I been throttled over the given time period? Give me all the requests that have been throttled and who called them

```sql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.DATALAKESTORE" and TimeGenerated >= ago(3d)
| where Category == "Requests"
//am I being throttled? Have I submitted too many requests within a given timeframe?
| where ResultType == 429
| project Resource, ResourceGroup, ResourceType, OperationName, ResultType, CorrelationId, HttpMethod_s, Path_s, identity_s, UserId_g, StoreEgressSize_d, StoreIngressSize_d, CallerIPAddress, StartTime_t, EndTime_t
```