# Register product type

```sql
BEGIN TRANSACTION;

-- core
insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.')

select * from product

ROLLBACK TRANSACTION;
```