# Check saved by discounts

```sql
select o.id                                    as 'order_id',
       sum(pa.price)                           as 'raw_price_sum',
       sum(op.effective_price)                 as 'effective_price_sum',
       sum(pa.price) - sum(op.effective_price) as 'saved_by_discounts'
from [order] o
         left join order_product op on o.id = op.order_id
         left join product p on p.id = op.product_id
         left join product_availability pa on p.id = pa.product_id and convert(date, o.preferred_serve_time) = pa.date
group by o.id;
```