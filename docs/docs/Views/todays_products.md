# Todays_products

Shows [products](../Tables/product) available today, with their raw prices.

Use [price_table_daily_for_client](price_table_daily_for_client) to view effective prices for a given client.
## Definition

```sql
CREATE OR ALTER VIEW dbo.todays_products AS
select *
from [dbo].[price_table_daily]
where date = convert(date, getdate());
```