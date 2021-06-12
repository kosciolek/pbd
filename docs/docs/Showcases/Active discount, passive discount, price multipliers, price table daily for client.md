# Active discount, passive discount, price multipliers, price table daily for client

```sql
BEGIN TRANSACTION;

exec insert_client_person @first_name = 'Jan', @second_name = 'Kowalski', @phone_number = '789271345'
DECLARE @client1 int = (select top 1 id
                        from client_person);
exec insert_client_person @first_name = 'Irek', @second_name = 'Irkowaty', @phone_number = '123123123'
DECLARE @client2 int = (select id
                        from client_person
                        where id != @client1);



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

insert into product (id, tax_percent)
values ('Trufle', 0.07);
insert into product_availability (product_id, price, date)
VALUES ('Trufle', 150, CONVERT(date, getdate()));


DECLARE @cnt INT = 0;

WHILE @cnt < 10
    BEGIN

        insert into [order] (order_owner_id, preferred_serve_time)
        values (@client1, dateadd(hour, 2, getdate()));
        DECLARE @order1 INT = scope_identity();

        exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
        exec addProduct @order_id = @order1, @product_id = 'Mix Sałat'
        exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
        exec addProduct @order_id = @order1, @product_id = 'Trufle'
        exec addProduct @order_id = @order1, @product_id = 'Super Ekstra Ziemniaczki'
        exec addProduct @order_id = @order1, @product_id = 'Mix Sałat'
        exec addProduct @order_id = @order1, @product_id = 'Barszcz z jajkiem'
        exec addProduct @order_id = @order1, @product_id = 'Trufle'

        insert into [order] (order_owner_id, preferred_serve_time)
        values (@client2, dateadd(hour, 3, getdate()));
        DECLARE @order2 INT = scope_identity();

        exec addProduct @order_id = @order2, @product_id = 'Mix sałat'

        SET @cnt = @cnt + 1;
    END;

select * from passive_discounts;

/*select * from price_multipliers;*/

/*insert into discount (date_start, client_person_id) values (convert(date, getdate()), @client1);
select * from price_multipliers;*/

/*select * from price_table_daily_for_client;*/
ROLLBACK TRANSACTION;
```