# Application Gateway
blah, blah
## Table of Contents
1. [List Monitored Application Gateways (Individual List)](#list-monitored-application-gateways-(individual-list))
1. [List Monitored Application Gateways (Comparitive List - Join)](#list-monitored-application-gateways-(comparitive-list---join))
1. [List Unmonitored Application Gateways (XOR List)](#list-unmonitored-application-gateways-(xor-list))
1. [Average Throughput Per Second (Bytes)](#average-throughput-per-second-(bytes))
1. [Average Throughput Per Second (Mb)](#average-throughput-per-second-(mb))
1. [Unhealthy Hosts (Compared to Healthy)](#unhealthy-hosts-(compared-to-healthy))
1. [Unhealthy Hosts (For All Gateways)](#unhealthy-hosts-(for-all-gateways))
1. [Healthy Hosts (For All Gateways)](#healthy-hosts-(for-all-gateways))
___
### List Monitored Application Gateways (Individual List)
List all application gateways currently being monitored.  This query can be executed against `AzureMetrics` _or_ `AzureDiagnostics`.  

**AzureMetrics**
```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY"
| distinct Resource, ResourceGroup
```

**AzureDiagnostics**
```
AzureDiagnostics
| where ResourceId contains "APPLICATIONGATEWAY"
| distinct Resource, ResourceGroup
```

<span style="font-size:.85em;font-weight:bold;color:white;background:slateblue;padding:5px">#table</span>

### List Monitored Application Gateways (Comparitive List - Join)
List all application gateways currently being monitored.  This query joins both, `AzureMetrics` and `AzureDiagnostics`, to create an all-inclusive list of gateways being monitored.

```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY"
| distinct Resource, ResourceGroup
| as Metrics
| union withsource=Source
  (
  AzureDiagnostics
  | where ResourceId contains "APPLICATIONGATEWAY"
  | distinct Resource, ResourceGroup
  | as Diagnostics
  )
```

<span style="font-size:.85em;font-weight:bold;color:white;background:slateblue;padding:5px">#table</span>

### List Unmonitored Application Gateways (XOR List)
List all application gateways currently being monitored, but only have one setting turned on - _either_ `AzureMetrics` or `AzureDiagnostics` - but, not both.  This creates a union of outer joins against both tables and returns results that are exclusive to either table and not found in both.  Additionally, the query reports which setting is missing for the application gateway.

```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY"
| distinct Type, Resource, ResourceGroup
| join kind=leftanti
  (
  AzureDiagnostics
  | where ResourceId contains "APPLICATIONGATEWAY"
  | distinct Type, Resource, ResourceGroup
  )
  on Resource, ResourceGroup
  | as Diagnostics
  | union withsource=MissingSetting
    (
    AzureMetrics
    | where ResourceId contains "APPLICATIONGATEWAY"
    | distinct Type, Resource, ResourceGroup
    | join kind=rightanti
      (
      AzureDiagnostics
      | where ResourceId contains "APPLICATIONGATEWAY"
      | distinct Type, Resource, ResourceGroup
      )
      on Resource, ResourceGroup
      | as Metrics
    )
| project Resource, ResourceGroup, MissingSetting
```

<span style="font-size:.85em;font-weight:bold;color:white;background:slateblue;padding:5px">#table</span>

### Average Throughput Per Second (Bytes)
Display the average throughput per second of the application gateways.  The results display the average of 5-minute blocks by each application gateway resource.  
```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY"
| where MetricName == "Throughput"
| summarize avg(Average) by Resource, bin(TimeGenerated, 5m)
| project TimeGenerated, avg_Average, Resource
```
<span style="font-size:.85em;font-weight:bold;color:white;background:teal;padding:5px">#timechart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:deeppink;padding:5px">#barchart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:darkorange;padding:5px">#areachart</span>

### Average Throughput Per Second (Mb)
The same as the query above, but converted to megabytes (Base 10).
```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY"
| where MetricName == "Throughput"
| summarize avg(Average) by Resource, bin(TimeGenerated, 5m)
| extend ThroughputMb = todecimal((avg_Average/1000)/1000)
| project TimeGenerated, ThroughputMb, Resource
```
<span style="font-size:.85em;font-weight:bold;color:white;background:teal;padding:5px">#timechart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:deeppink;padding:5px">#barchart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:darkorange;padding:5px">#areachart</span>

### Unhealthy Hosts (Compared to Healthy)
Show when hosts connected to the application gateway become unreachable.  This query will produce a comparison graph between the number of nodes that are healthy and those that are unhealthy for a _single_ application gateway.  The results display the average health in increments of 5-minute blocks for the past 24 hours.
```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY" and Resource == "<your gateway's name>"
| where MetricName == "UnhealthyHostCount" or MetricName == "HealthyHostCount"
| summarize avg(Total) by Resource, MetricName, bin(TimeGenerated, 5m)
| project TimeGenerated, MetricName, avg_Total
```
<span style="font-size:.85em;font-weight:bold;color:white;background:teal;padding:5px">#timechart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:darkorange;padding:5px">#areachart</span>

### Unhealthy Hosts (For All Gateways)
Show when hosts connected to the application gateway become unreachable.  This query will produce the number of nodes that are unhealthy for _all_ application gateways.  The results display the average disconnected state in increments of 5-minute blocks for the past 24 hours.
```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY"
| where MetricName == "UnhealthyHostCount"
| summarize avg(Total) by Resource, bin(TimeGenerated, 5m)
| project TimeGenerated, Resource, avg_Total
```
<span style="font-size:.85em;font-weight:bold;color:white;background:teal;padding:5px">#timechart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:darkorange;padding:5px">#areachart</span>

### Healthy Hosts (For All Gateways)
Show healthy, reachable hosts connected to the application gateway.  This query will produce the number of nodes that are healthy for _all_ application gateways.  The results display the average connected state in increments of 5-minute blocks for the past 24 hours.
```
AzureMetrics
| where ResourceId contains "APPLICATIONGATEWAY"
| where MetricName == "HealthyHostCount"
| summarize avg(Total) by Resource, bin(TimeGenerated, 5m)
| project TimeGenerated, Resource, avg_Total
```
<span style="font-size:.85em;font-weight:bold;color:white;background:teal;padding:5px">#timechart</span>
<span style="font-size:.85em;font-weight:bold;color:white;background:darkorange;padding:5px">#areachart</span>

### All Errors
Display requests that resulted in some type of error (error code 400 or above).  
Results are grouped by hour.
```
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ApplicationGatewayAccessLog"
| where httpStatus_d >= 400
| summarize event_count=count() by serverStatus_s, bin(TimeGenerated, 1h)
```

### Bad Gateway
Find requests that resulted in a server error of _502 - Bad Gateway_.
```
AzureDiagnostics 
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ApplicationGatewayAccessLog" 
| where serverStatus_s == 502
```

Find errored requests by backend VM per 5-minute intervals
```
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ApplicationGatewayAccessLog"
| where httpStatus_d == 502
| parse requestQuery_s with * "SERVER-ROUTED=" serverRouted "&" *
| extend httpStatus = tostring(httpStatus_d)
| summarize count() by serverRouted, bin(TimeGenerated, 5m)
| render timechart
```

### Blocked Firewall Rules
Find all requests that resulted in a firewall block due to an OWASP rule.
```
AzureDiagnostics 
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ApplicationGatewayFirewallLog" 
| where requestUri_s == "/" and action_s == "Blocked" 
```

Group and count all blocked requests by rule violation.
```
AzureDiagnostics 
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ApplicationGatewayFirewallLog" 
| where requestUri_s == "/" and action_s == "Blocked" 
| summarize count() by ruleId_S
```