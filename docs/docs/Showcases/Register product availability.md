# Register product availability

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 0.5, 'Najlepsze ziemniaczusie.')

-- core
insert into product_availability (product_id, price, date) VALUES ('Super Ekstra Ziemniaczki', 12.40, '2021-05-06')

select * from product_availability;

ROLLBACK TRANSACTION;
```