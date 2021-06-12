# Passive_discounts

Shows the IDs of all [individual clients](../Tables/client_person) who have spent enough to be eligible for a **passive discount**.

The parameters of the passive discount can be found in the table [const](../Tables/const).
## Definition

```sql
CREATE OR ALTER VIEW [dbo].[passive_discounts] AS
select client_id
from orders_per_client
where dbo.getClientType(client_id) = 'person'
  and effective_price >= (select k1 from const)
GROUP BY client_id
HAVING COUNT(client_id) >= (select z1 from const);
```