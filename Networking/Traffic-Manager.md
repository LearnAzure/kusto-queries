# Traffic Manager
The queries below allow you to query various diagnostic and metric data for a Traffic Manager Profile.

Optimal rendering options are also included below each query.

## Table of Contents
1. [Status Report (by profile)](#report-status-(by-profile))
1. [Total Queries by Endpoint (by profile)](#total-queries-by-endpoint-(by-profile))
___
### Status Report (by profile)
Reports the status of a Traffic Manager Profile endpoint.  For each profile, the query reports either a `1` for the endpoint being _Up_ or `0` for the endpoint being _Down_. Being that a downstate is a high-priority incident, the results display the _minimum_ (e.g. `0`) of 1-minute blocks by each traffic manager profile.

```
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ProbeHealthStatusEvents"
| extend Endpoint = strcat(Resource, "/", EndpointName_s)
| extend Up = case(Status_s == "Up", 1, 0)
| summarize min(Up) by Endpoint, bin(TimeGenerated, 1m)
```
<span style="font-size:.85em;font-weight:bold;color:white;background:teal;padding:5px">#timechart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:deeppink;padding:5px">#barchart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:darkorange;padding:5px">#areachart</span>

### Total Queries by Endpoint (by profile)
Displays the total number of queries by endpoint.  The results display the query count in increments of 5-minute blocks for the past 24 hours.
```
AzureMetrics
| where ResourceId contains "TRAFFICMANAGERPROFILE"
| where MetricName == "QpsByEndpoint"
| summarize sum(Total) by Resource, bin(TimeGenerated, 5m)
```
<span style="font-size:.85em;font-weight:bold;color:white;background:teal;padding:5px">#timechart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:deeppink;padding:5px">#barchart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:darkorange;padding:5px">#areachart</span>