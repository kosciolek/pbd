# Make reservation - error, not paid enough

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client1 int = (select top 1 id
                        from client_person);
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);


insert into product (id, tax_percent, description)
values ('Super Ekstra Ziemniaczki', 0.23, 'Najlepsze ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Super Ekstra Ziemniaczki', 10, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'

insert into seat_limit (day, seats)
values (CONVERT(date, getdate()), 6)

-- core
INSERT INTO reservation (order_id, duration_minutes, seats)
values (@order1, 90, 3)

select * from reservations;

ROLLBACK TRANSACTION;
```