# Awaiting_completion

Returns all orders that are `accepted` and await further processing (completion or rejection).
## Definition

```sql
CREATE OR ALTER VIEW dbo.awaiting_completion
AS
SELECT *
FROM [order] o
         LEFT JOIN reservation r on o.id = r.order_id
WHERE o.state = 'accepted'
GO;

CREATE OR ALTER VIEW dbo.products_per_order AS
SELECT o.id AS "order_id", p.id as "product_id", effective_price, pa.price as product_price
FROM [order] o
         LEFT JOIN order_product op on o.id = op.order_id
         LEFT JOIN product p ON op.product_id = p.id
         LEFT JOIN product_availability pa on p.id = pa.product_id AND pa.date = CONVERT(date, o.date_placed)
```