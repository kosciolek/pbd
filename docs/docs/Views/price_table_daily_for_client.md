# Price_table_daily_for_client

Shows a list of today's products available today, with `effective_price` including all present passive and [active discounts](../Table/discount) for the client.

:::caution
Due to performance reasons, queries should be made with a `WHERE` clause only for select clients.
:::

## Definition

```sql
CREATE OR ALTER VIEW [dbo].[price_table_daily_for_client] AS
SELECT cp.id                         as 'client_id',
       p.id                          as 'product_id',
       pa.date                       as 'availability_date',
       sum(pa.price)                 as 'price',
       sum(pa.price) * pm.multiplier as 'effective_price'
FROM product_availability pa
         LEFT JOIN product p ON p.id = pa.product_id
         FULL JOIN client_person cp ON 1 = 1
         LEFT JOIN price_multipliers pm ON pm.client_id = cp.id
GROUP BY cp.id, p.id, pa.date, pm.multiplier;
```