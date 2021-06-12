# Company_spendings_per_month

Shows monthly spendings per [companies](../Tables/client_company).
## Definition

```sql
CREATE OR ALTER VIEW dbo.company_spendings_per_month AS
SELECT cs.name,
       cs.nip,
       DATEPART(Year, cs.date_placed)  as 'year',
       DATEPART(Month, cs.date_placed) as 'month',
       SUM(effective_price)            as 'total_spendings'
from company_spendings cs
GROUP BY cs.nip, cs.name, DATEPART(Year, cs.date_placed), DATEPART(Month, cs.date_placed);
```