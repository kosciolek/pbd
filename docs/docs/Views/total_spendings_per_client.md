# Total_spendings_per_client

Shows total amount spent (after applied passive and active discounts) for every client.
## Definition

```sql
CREATE OR ALTER VIEW [dbo].[total_spendings_per_client] AS
select client_id, sum(effective_price) as 'total_spent'
from orders_per_client
group by client_id;
```