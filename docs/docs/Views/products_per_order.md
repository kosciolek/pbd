# Products_per_order

Shows all products linked to an [order](../Tables/order).
## Definition

```sql
CREATE OR ALTER VIEW dbo.products_per_order AS
SELECT o.id AS "order_id", p.id as "product_id", effective_price, pa.price as product_price
FROM [order] o
         LEFT JOIN order_product op on o.id = op.order_id
         LEFT JOIN product p ON op.product_id = p.id
         LEFT JOIN product_availability pa on p.id = pa.product_id AND pa.date = CONVERT(date, o.date_placed)
```