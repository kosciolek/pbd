# Discounts

Shows all [discounts](../Tables/discount) for [individual clients](../Tables/client_person), whether they're active or not, and their start and end dates.
## Definition

```sql
CREATE OR ALTER VIEW [dbo].discounts AS
SELECT *,
       DATEADD(DAY, (select d1 from const), d.date_start) as 'date_end',
       iif(DATEADD(DAY, (select d1 from const), d.date_start) >= getdate() AND d.date_start <= getdate(), 1,
           0)                                             as 'active'
from discount d;
```