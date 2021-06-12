# List products available today

```sql
BEGIN TRANSACTION;

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 9.40, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Mix Sałat', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Mix Sałat', 9.00, CONVERT(date, getdate()));

insert into product (id, tax_percent)
values ('Barszcz z jajkiem', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Barszcz z jajkiem', 6.00, dateadd(day, 1, CONVERT(date, getdate())));

-- core
-- select * from product_availability where date = convert(date, getdate())
select * from todays_products;

ROLLBACK TRANSACTION;
```