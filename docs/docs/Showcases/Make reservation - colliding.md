# Make reservation - colliding

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
values ('Bardzo Drogie Ziemniaczki', 0.23, 'Bardzo drogie ziemniaczusie.');
insert into product_availability (product_id, price, date)
VALUES ('Bardzo Drogie Ziemniaczki', 300, CONVERT(date, getdate()));

insert into [order] (order_owner_id, preferred_serve_time)
values (@client1, dateadd(hour, 2, getdate()));
DECLARE @order1 INT = scope_identity();

insert into [order] (order_owner_id, preferred_serve_time)
values (@client2, dateadd(hour, 3, getdate()));
DECLARE @order2 INT = scope_identity();


exec addProduct @order_id = @order1, @product_id = 'Bardzo Drogie Ziemniaczki'
exec addProduct @order_id = @order2, @product_id = 'Bardzo Drogie Ziemniaczki'

insert into seat_limit (day, seats)
values (CONVERT(date, getdate()), 6)

-- core

-- Reservations overlap, and together they take more seats than available
INSERT INTO reservation (order_id, duration_minutes, seats)
values (@order1, 120, 3) -- change duration to 30, and it'll work
INSERT INTO reservation (order_id, duration_minutes, seats)
values (@order2, 90, 4)

select * from reservations;

ROLLBACK TRANSACTION;
```