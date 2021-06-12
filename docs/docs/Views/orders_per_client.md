# Orders_per_client

Shows all orders made by all clients and their price.
## Definition

```sql
CREATE OR ALTER VIEW dbo.orders_per_client AS
SELECT o.id                    AS "order_id",
       o.order_owner_id        as "client_id",
       o.date_placed           as "date_placed",
       SUM(op.effective_price) as "effective_price",
       o.state                 as "state"
FROM [order] o
         INNER JOIN order_product op on o.id = op.order_id
GROUP BY o.id, o.date_placed, o.order_owner_id, o.state;
```