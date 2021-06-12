# Register product availability - invalid price

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniczaki', 0.5, 'Najlepsze ziemniaczusie.')

-- core
insert into product_availability (product_id, price, date) VALUES ('Super Ekstra Ziemniczaki', -12.40, '2021-05-06')

select * from product_availability;

ROLLBACK TRANSACTION;
```