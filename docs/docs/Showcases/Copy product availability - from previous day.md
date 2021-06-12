# Copy product availability - from previous day

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 0.5, 'Najlepsze ziemniaczusie.')

insert into product_availability (product_id, price, date) VALUES ('Super Ekstra Ziemniaczki', 12.40, '2021-05-06')

-- core
exec copyProductsAvailableFromPreviousDay @date = '2021-05-07'
exec copyProductsAvailableFromPreviousDay @date = '2021-05-08'
exec copyProductsAvailableFromPreviousDay @date = '2021-05-09'

select * from product_availability;

ROLLBACK TRANSACTION;
```