# Make reservation - error, no seat limit set

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 10, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values ((select top 1 id from client_person), dateadd(hour, 2, getdate()));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'

-- core
INSERT INTO reservation (order_id, duration_minutes, seats) values (@order_id, 90, 3)

ROLLBACK TRANSACTION;
```