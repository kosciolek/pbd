# Discount_eligibility

Shows all [individual clients](../Tables/client_person), how much they have spent, how many [active discounts](../Tables/discount) have they applied, and if they have spent enough to be  eligible for another discount.
## Definition

```sql
CREATE OR ALTER VIEW [dbo].discount_eligibility AS
SELECT client_id,
       total_spent                                     as 'total_spent',
       iif(has_discounts = 0, 0, COUNT(client_id))     as 'discounts_count',
       IIF((iif(has_discounts = 0, 1, COUNT(client_id) + 1)) *
           (select k2 from const) < total_spent, 1, 0) as 'eligible'
FROM (select *, iif(d.id is not null, 1, 0) as 'has_discounts'
      from (select client_id, sum(effective_price) as 'total_spent'
            from orders_per_client opc
            group by client_id) as _spendings
               LEFT JOIN discount d ON d.client_person_id = _spendings.client_id) as spendings
GROUP BY client_id, total_spent, has_discounts;
GO;

CREATE OR ALTER VIEW [dbo].discounts AS
SELECT *,
       DATEADD(DAY, (select d1 from const), d.date_start) as 'date_end',
       iif(DATEADD(DAY, (select d1 from const), d.date_start) >= getdate() AND d.date_start <= getdate(), 1,
           0)                                             as 'active'
from discount d;
```