# Azure SQL
The queries below allow you to query various diagnostic and metric data for Azure SQL Server and Azure SQL Databases.

Optimal rendering options are also included below each query.

### Average CPU Utilization by Database
List all application gateways currently being monitored.  This query can be executed against `AzureMetrics` _or_ `AzureDiagnostics`.  

```
AzureMetrics
| where ResourceProvider == "MICROSOFT.SQL" and Resource != "MASTER"
| where TimeGenerated > ago(24h)
| where MetricName == "cpu_percent"
| summarize avg(Average) by Resource, bin(TimeGenerated, 5m) 
```

{{ chart.time }}
{{ chart.area }}

### Size in MB by Database
Display the size in MB for each database.  The results display the average size in increments of 1-hour blocks for the past 24 hours.

```
AzureMetrics
| where ResourceProvider == "MICROSOFT.SQL" and Resource != "MASTER"
| where TimeGenerated > ago(24h)
| where MetricName == "storage"
| summarize avg(Average) by Resource, bin(TimeGenerated, 1h) 
| extend AverageMB = avg_Average / 1000000
| project TimeGenerated, Resource, AverageMB 
```

{{ chart.time }}
{{ chart.area }}

### Successful Connections by Database
Show the number of successful connecions by database.  The results display the average number of connections in increments of 5-minute blocks for the past 24 hours.

```
AzureMetrics
| where ResourceProvider == "MICROSOFT.SQL" and Resource != "MASTER"
| where TimeGenerated > ago(24h)
| where MetricName == "connection_successful"
| summarize avg(Total) by Resource, bin(TimeGenerated, 5m) 
```

{{ chart.time }}
{{ chart.area }}

### Unsuccessful Connections by Database
Show the number of successful connecions by database.  The results display the average number of connections in increments of 5-minute blocks for the past 24 hours.

```
AzureMetrics
| where ResourceProvider == "MICROSOFT.SQL" and Resource != "MASTER"
| where TimeGenerated > ago(24h)
| where MetricName == "connection_unsuccessful"
| summarize avg(Total) by Resource, bin(TimeGenerated, 5m) 
```

{{ chart.time }}
{{ chart.area }}

### Blocked Firewall Attempts by Database
Show the number of connection attempts, by database, block by the firewall.  The results display the average number of blocks in increments of 5-minute blocks for the past 24 hours.

```
AzureMetrics
| where ResourceProvider == "MICROSOFT.SQL" and Resource != "MASTER"
| where TimeGenerated > ago(24h)
| where MetricName == "blocked_by_firewall"
| summarize avg(Total) by Resource, bin(TimeGenerated, 5m) 
```

{{ chart.time }}
{{ chart.area }}

### CPU Utilization Percentage by Database
Display the CPU utilization percentage by database.  The results display the average utilization in increments of 1-minute blocks for the past 1 hour.

```
AzureMetrics
| where ResourceProvider == "MICROSOFT.SQL" and Resource != "MASTER"
| where TimeGenerated > ago(1h)
| where MetricName == "cpu_used"
| summarize avg(Average) by Resource, bin(TimeGenerated, 1m) 
| extend AvgCPU = avg_Average * 100
| project TimeGenerated, Resource, AvgCPU 
```

{{ chart.time }}
{{ chart.area }}


### List All SQL Vulnerabilities
List all SQL vulnerabilities, sorted from 'High' risk to 'Low' riskk, from the last 3 days.

```
let results = SqlVulnerabilityAssessmentResult
| where TimeGenerated > ago(72h)
| distinct Computer, DatabaseName, Title, Risk, Category, Description, Impact, Query, Remediation, BenchmarkReferences;
results | extend RiskLevel = 1 | where Risk == "High"
| union
  ( results | extend RiskLevel = 2 | where Risk == "Medium" )
| union
  ( results | extend RiskLevel = 3 | where Risk == "Low" )
| order by RiskLevel asc 
```

<span style="font-size:.85em;font-weight:bold;color:white;background:slateblue;padding:5px">#table</span>

### SQL Vulnerability List with Count by Database

```
let results = SqlVulnerabilityAssessmentResult
| where TimeGenerated > ago(72h)
| summarize count() by Computer, DatabaseName, Risk;
results | extend RiskLevel = 1 | where Risk == "High"
| union
  ( results | extend RiskLevel = 2 | where Risk == "Medium" )
| union
  ( results | extend RiskLevel = 3 | where Risk == "Low" )
| order by RiskLevel asc 
```

<span style="font-size:.85em;font-weight:bold;color:white;background:slateblue;padding:5px">#table</span>

### SQL Vulnerability List with Count by Database

```
SqlVulnerabilityAssessmentResult
| where TimeGenerated > ago(72h)
| summarize count() by DatabaseName
```

{{ chart.bar }}

### SQL Vulnerability List with Count by Risk Level

```
SqlVulnerabilityAssessmentResult
| where TimeGenerated > ago(72h)
| summarize count() by DatabaseName
```

{{ chart.bar }}