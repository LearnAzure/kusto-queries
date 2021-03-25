# Application Insights
The queries below allow you to query various diagnostic and metric data for Application Insights

Optimal rendering options are also included below each query.

### List Failed Requests 
The following query shows all requests that experienced exceptions (error 500 or greater) along with the count of exceptions thrown. The table is rendered by "Count" in descending order

```sql
requests
| where timestamp >= ago(1d)
| where toint(resultCode) >= 500
| summarize Count=count() by name
| order by Count desc 
```

{{ chart.table }}
{{ chart.bar }}
{{ chart.pie }}