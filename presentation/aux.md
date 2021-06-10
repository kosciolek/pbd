## Insert
### Create a product
```sql
insert into product (id, tax_percent, isSeafood, description) values ('Ziemniaki', 0.23, 0, 'Super ekstra najlepsze ziemniaki.');
```

### Make a product available on a given day
```sql
insert into product_availability (product_id, price, date) values ('Ziemniaki', 12.32, '2018-05-24');
```

### Copy product availability from the previous day
```sql
exec copyProductsAvailableFromPreviousDay @date = '2018-05-25'
```

### Copy product availability from any day to any day
```sql
exec copyProductsAvailableFromPreviousDay @date = '2018-05-25'
```

## Read
### List prices of today's products and their prices
```sql
select * from price_table_daily;
```
### List prices of products for a given day, including dicounts for a given client

This should be always used with `WHERE` for select clients due to performance.

``` sql
select * from price_table_daily_for_client
where availability_date = '2018-10-25'
  and client_id = 1684;
```

### trCheckOnlyOneClientLinked_client and trCheckOnlyOneClientLinked_company
 Ensure a client is linked either to a company or a person, but not both

```sql
BEGIN TRANSACTION

insert client default values;
DECLARE @id INT = scope_identity();

insert client_company (id, name, phone_number, nip) values (@id, 'Some Company', '789456867', '1010101010');

insert client_person (id, first_name, second_name, phone_number) values (@id, 'Jan', 'Kowalzgi', '123321123')

ROLLBACK TRANSACTION


BEGIN TRANSACTION

insert client default values;
DECLARE @id INT = scope_identity();

insert client_person (id, first_name, second_name, phone_number) values (@id, 'Jan', 'Kowalzgi', '123321123')

insert client_company (id, name, phone_number, nip) values (@id, 'Some Company', '789456867', '1010101010');

ROLLBACK TRANSACTION
```


