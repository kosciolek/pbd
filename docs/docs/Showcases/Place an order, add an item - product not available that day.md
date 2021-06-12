# Place an order, add an item - product not available that day

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
DECLARE @client1 int = (select top 1 id
                        from client_person);


insert into product (id, tax_percent, description, isSeafood)
values ('Owoce morza - miks', 0.23, 'Super ekstra najlepsze.', 1);
insert into product_availability (product_id, price, date)
VALUES ('Owoce morza - miks', 300, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(day, 2, getdate()));
DECLARE @order1 INT = scope_identity();

-- core
exec addProduct @order_id = @order1, @product_id = 'Owoce morza - miks'

ROLLBACK TRANSACTION;
```