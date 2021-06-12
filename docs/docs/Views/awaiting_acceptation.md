# Awaiting_acceptation

Returns all orders that are `placed` and await further processing (acceptation or rejection).
## Definition

```sql
CREATE OR ALTER VIEW dbo.awaiting_acceptation
AS
SELECT *
FROM [order] o
         LEFT JOIN reservation r on o.id = r.order_id
WHERE o.state = 'placed'
```