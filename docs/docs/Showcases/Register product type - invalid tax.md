# Register product type - invalid tax

```sql
BEGIN TRANSACTION;

-- core
insert into product (id, tax_percent, description) values ('Super Ekstra Ziemniaczki', 1.34, 'Najlepsze ziemniaczusie.')

select * from product

ROLLBACK TRANSACTION;
```