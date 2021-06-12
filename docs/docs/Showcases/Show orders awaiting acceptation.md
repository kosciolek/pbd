# Show orders awaiting acceptation

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'

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
VALUES ('Barszcz z jajkiem', 6.00, CONVERT(date, getdate()));

insert into [order] (preferred_serve_time, date_placed, order_owner_id)
values (getdate(), getdate(), (select top 1 id from client_person));

DECLARE @order_id INT = (select top 1 id
                         from [order]);

exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Mix Sałat'
exec addProduct @order_id = @order_id, @product_id = 'Barszcz z jajkiem'

-- core
select * from awaiting_acceptation;

ROLLBACK TRANSACTION;
```