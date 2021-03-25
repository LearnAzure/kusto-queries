# Traffic Manager
The queries below allow you to query various diagnostic and metric data for a Traffic Manager Profile.

Optimal rendering options are also included below each query.

### Status Report (by profile)
Reports the status of a Traffic Manager Profile endpoint.  For each profile, the query reports either a `1` for the endpoint being _Up_ or `0` for the endpoint being _Down_. Being that a downstate is a high-priority incident, the results display the _minimum_ (e.g. `0`) of 1-minute blocks by each traffic manager profile.

```sql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ProbeHealthStatusEvents"
| extend Endpoint = strcat(Resource, "/", EndpointName_s)
| extend Up = case(Status_s == "Up", 1, 0)
| summarize min(Up) by Endpoint, bin(TimeGenerated, 1m)
```
{{ chart.time }}
{{ chart.bar }}
{{ chart.area }}

### List Down Endpoints (by profile)
Reports all Traffic Manager Profile endpoints that have been reported as "Down" within the past 5 minutes.

```sql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ProbeHealthStatusEvents"
| where Status_s == "Down"
| where TimeGenerated > ago(5m)
| extend Endpoint = strcat(Resource, "/", EndpointName_s)
| project Endpoint 
| distinct Endpoint
```

### Total Queries by Endpoint (by profile)
Displays the total number of queries by endpoint.  The results display the query count in increments of 5-minute blocks for the past 24 hours.
```sql
AzureMetrics
| where ResourceId contains "TRAFFICMANAGERPROFILE"
| where MetricName == "QpsByEndpoint"
| summarize sum(Total) by Resource, bin(TimeGenerated, 5m)
```
{{ chart.time }}
{{ chart.bar }}
{{ chart.area }}
